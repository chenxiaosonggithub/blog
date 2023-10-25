# fdbd1a2e4a71 nfs: Fix a missed page unlock after pg_doio()

内核构造补丁:
```c
From 230808ff2f493491fa096093fda0f1157063ace8 Mon Sep 17 00:00:00 2001
From: ChenXiaoSong <chenxiaosongemail@foxmail.com>
Date: Mon, 2 May 2022 12:06:51 +0800
Subject: [PATCH] reproduce miss page unlock

Signed-off-by: ChenXiaoSong <chenxiaosongemail@foxmail.com>
---
 fs/nfs/pagelist.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 9157dd19b8b4..b6d491fa7b69 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -948,6 +948,7 @@ static int nfs_generic_pg_pgios(struct nfs_pageio_descriptor *desc)
 	unsigned short task_flags = 0;
 
 	hdr = nfs_pgio_header_alloc(desc->pg_rw_ops);
+	hdr = NULL;
 	if (!hdr) {
 		desc->pg_error = -ENOMEM;
 		return desc->pg_error;
@@ -1386,8 +1387,8 @@ void nfs_pageio_complete(struct nfs_pageio_descriptor *desc)
 	for (midx = 0; midx < desc->pg_mirror_count; midx++)
 		nfs_pageio_complete_mirror(desc, midx);
 
-	if (desc->pg_error < 0)
-		nfs_pageio_error_cleanup(desc);
+	// if (desc->pg_error < 0)
+	// 	nfs_pageio_error_cleanup(desc);
 	if (desc->pg_ops->pg_cleanup)
 		desc->pg_ops->pg_cleanup(desc);
 	nfs_pageio_cleanup_mirroring(desc);
-- 
2.25.1
```

步骤:
```shell
mount -t nfs -o vers=4.1 192.168.122.247:/s_test /mnt
cat /mnt/file & 文件已存在
ps aux | grep cat
cat /proc/591/stack
[<0>] folio_wait_bit_common+0x4ba/0x56a
[<0>] folio_put_wait_locked+0x16/0x17
[<0>] filemap_update_page+0x10c/0x1bd
[<0>] filemap_get_pages+0x320/0x430
[<0>] filemap_read+0x173/0x4db
[<0>] generic_file_read_iter+0x215/0x23a
[<0>] nfs_file_read+0xe7/0x127
[<0>] new_sync_read+0x1ec/0x26a
[<0>] vfs_read+0x16a/0x282
[<0>] ksys_read+0xb8/0x133
[<0>] __se_sys_read+0xa/0xb
[<0>] __x64_sys_read+0x3e/0x43
[<0>] do_syscall_64+0x43/0x92
[<0>] entry_SYSCALL_64_after_hwframe+0x44/0xae
```

```c
filp_close
  nfs4_file_flush
    nfs_wb_all
      filemap_write_and_wait
        filemap_write_and_wait_range
          __filemap_fdatawrite_range
            filemap_fdatawrite_wbc
              do_writepages
                nfs_writepages
                  nfs_pageio_complete
                    nfs_pageio_complete_mirror
                      nfs_pageio_doio
                        nfs_generic_pg_pgios

// 缺页异常
asm_exc_page_fault
  exc_page_fault
    handle_page_fault
      do_user_addr_fault
        handle_mm_fault
          __handle_mm_fault
            handle_pte_fault
              do_fault
                do_read_fault
                  __do_fault
                    lock_page

read
  ksys_read
    vfs_read
      new_sync_read
        call_read_iter
          nfs_file_read
            generic_file_read_iter
              filemap_read
                filemap_get_pages
                  page_cache_sync_readahead
                    page_cache_sync_ra
                      ondemand_readahead
                        page_cache_ra_order
                          do_page_cache_ra
                            page_cache_ra_unbounded
                              read_pages
                                nfs_readahead
                                  nfs_pageio_complete_read
                                    nfs_pageio_complete
                                      nfs_pageio_complete_mirror
                                        nfs_pageio_doio
                                          nfs_generic_pg_pgios
                                      nfs_pageio_error_cleanup
                                        nfs_async_read_error
                                          nfs_readpage_release
                                            unlock_page
                                              folio_unlock
                                                folio_wake_bit(folio, PG_locked)
                  filemap_update_page
                    folio_put_wait_locked(folio, PG_locked, state, DROP)
                      folio_wait_bit_common

// umount 时触发
kthread
  worker_thread
    process_one_work
      wb_workfn
        wb_do_writeback
          wb_writeback
            writeback_sb_inodes
              __writeback_single_inode
                do_writepages
                  nfs_writepages
                    nfs_pageio_complete
```

# nfs 死锁

```shell
dfe1fe75e00e NFSv4: Fix deadlock between nfs4_evict_inode() and nfs4_opendata_get_inode()
c3aba897c6e6 NFSv4: Fix second deadlock in nfs4_evict_inode()
fcb170a9d825 SUNRPC: Fix the batch tasks count wraparound.
5483b904bf33 SUNRPC: Should wake up the privileged task firstly.
```

```shell
# qemu 启动参数 -m 600
echo 0 > /proc/sys/kernel/soft_watchdog
mount -t nfs -o vers=4.0 192.168.122.247:/s_test /mnt
dd if=/dev/zero of=/root/chenxiaosong/dd_file bs=1M count=200
dd if=/dev/zero of=/var/swap bs=1M count=1024
mkswap -f /var/swap # 创建swap文件
swapon /var/swap # 加载, swapon -s 或 cat /proc/swaps 查看
vim /etc/fstab # 在最后添加 /var/swap swap swap defaults 0 0
swapoff /var/swap # 卸载
vim /root/chenxiaosong/dd_file # 打开大文件, 触发 swap
```

```c
// nfs4.0 权限没有冲突时,执行两次 cat /mnt/file, 设置 delegation
open
  do_sys_open
    do_sys_openat2
      do_filp_open
        path_openat
          do_open
            vfs_open
              do_dentry_open
                nfs4_file_open
                  nfs4_atomic_open
                    nfs4_do_open
                      _nfs4_do_open
                        _nfs4_open_and_get_state
                          _nfs4_opendata_to_nfs4_state
                            nfs4_opendata_check_deleg
                              nfs_inode_set_delegation

// 通过删除文件无法复现此问题: rm /mnt/file -rf, 因为回收 delegation 在设置 i_state 标记之前
unlinkat
  do_unlinkat
    vfs_unlink
      nfs_unlink
        nfs_safe_remove
          nfs4_proc_remove
            nfs4_inode_return_delegation
              nfs_end_delegation_return
                nfs_do_return_delegation
                  nfs4_proc_delegreturn
                    _nfs4_proc_delegreturn
    iput
      iput_final
        WRITE_ONCE(inode->i_state, state | I_FREEING)
        evict
          nfs4_evict_inode
            clear_inode
              inode->i_state = I_FREEING | I_CLEAR
            nfs_inode_evict_delegation
              nfs_inode_detach_delegation
                nfs_detach_delegation
                  nfs_detach_delegation_locked
          wake_up_bit(&inode->i_state, __I_NEW);

// swap
asm_exc_page_fault
  exc_page_fault
    handle_page_fault
      do_user_addr_fault
        handle_mm_fault
          __handle_mm_fault
            handle_pte_fault
              do_anonymous_page
                alloc_zeroed_user_highpage_movable
                  alloc_pages_vma
                    __alloc_pages
                      __alloc_pages_slowpath
                        __alloc_pages_direct_reclaim
                          __perform_reclaim
                            try_to_free_pages
                              do_try_to_free_pages
                                shrink_zones
                                  shrink_node
                                    shrink_node_memcgs
                                      shrink_slab
                                        shrink_slab_memcg
                                          do_shrink_slab
                                            super_cache_scan
                                              prune_icache_sb
                                                dispose_list
                                                  evict

// swap, 小概率执行到这里
kthread
  kswapd
    balance_pgdat
      kswapd_shrink_node
        shrink_node
          shrink_node_memcgs
            shrink_slab
              shrink_slab_memcg
                do_shrink_slab
                  super_cache_scan
                    prune_icache_sb
                      dispose_list
                        evict

// swap
evict
  nfs4_evict_inode
    clear_inode
      inode->i_state = I_FREEING | I_CLEAR
    nfs_inode_evict_delegation
      nfs_do_return_delegation
        nfs4_proc_delegreturn
          _nfs4_proc_delegreturn
            rpc_wait_for_completion_task // 等待 rpc 线程上的请求完成
              __rpc_wait_for_completion_task
                out_of_line_wait_on_bit
                  __wait_on_bit
                    rpc_wait_bit_killable

// deleg return 请求等待 drain 完成
kthread
  worker_thread
    process_one_work
      rpc_async_schedule
        __rpc_execute
          rpc_prepare_task
            nfs4_delegreturn_prepare
              nfs4_setup_sequence
                nfs4_slot_tbl_draining
                  test_bit(NFS4_SLOT_TBL_DRAINING, &tbl->slot_tbl_state
                rpc_sleep_on // 非特权队列上等待

kthread
  nfs4_run_state_manager
    nfs4_state_manager
      nfs4_reclaim_lease
        nfs4_establish_lease
          nfs4_begin_drain_session
            nfs4_drain_slot_tbl
              set_bit(NFS4_SLOT_TBL_DRAINING, &tbl->slot_tbl_state
              reinit_completion(&tbl->complete
              wait_for_completion_interruptible(&tbl->complete // 等待完成

open
  do_sys_open
    do_sys_openat2
      do_filp_open
        path_openat
          open_last_lookups
            lookup_open
              atomic_open
                nfs_atomic_open
                  nfs4_atomic_open
                    nfs4_do_open
                      _nfs4_do_open
                        _nfs4_open_and_get_state
                          _nfs4_proc_open
                            nfs4_run_open_task
                              rpc_run_task
                                rpc_execute
                          _nfs4_opendata_to_nfs4_state
                            nfs4_opendata_find_nfs4_state
                              nfs4_opendata_get_inode
                                nfs_fhget
                                  iget5_locked
                                    ilookup5
                                      ilookup5_nowait
                                        find_inode
                                          if (inode->i_state & (I_FREEING|I_WILL_FREE)) {
                                            __wait_on_freeing_inode
                                              DEFINE_WAIT_BIT(wait, &inode->i_state, __I_NEW)
                                              wq = bit_waitqueue(&inode->i_state, __I_NEW)

// 修复后
kthread
  worker_thread
    process_one_work
      rpc_async_schedule
        __rpc_execute
          rpc_prepare_task
            nfs4_delegreturn_prepare
              nfs4_setup_sequence
                nfs4_alloc_slot
                rpc_sleep_on_priority_timeout // 在特权队列上等待
```

# ce292d8faf41 NFS: Don't skip directory entries when doing uncached readdir

```c
getdents64
  .ctx.actor = filldir64
  iterate_dir
    nfs_readdir
      desc = kzalloc(sizeof(*desc), GFP_KERNEL)
      readdir_search_pagecache
        find_and_lock_cache_page
          nfs_readdir_xdr_to_array
            nfs_readdir_page_filler // echo 3 > /proc/sys/vm/drop_caches 后才会走到
              nfs_readdir_entry_decode
              desc->page_index_max++;
          nfs_readdir_search_array
            nfs_readdir_search_for_pos
            nfs_readdir_search_for_cookie // desc->dir_cookie != 0 条件怎么满足？
      uncached_readdir // if (res == -EBADCOOKIE)
        nfs_readdir_xdr_to_array
          nfs_readdir_xdr_filler
            error = NFS_PROTO(inode)->readdir // 重新读取目录项
      nfs_do_filldir
        // 执行 uncached_readdir 时如果没有把 cache_entry_index 置0，前面的目录项将不会被遍历到
        for (i = desc->cache_entry_index
        dir_emit
          filldir64 // ctx->actor
```

```shell
for((i=0; i<3000; i++))
do
        touch file${i}
        echo ${i}
done
```

# 6a0440e5b756 nfs_remount(): don't leak, don't ignore LSM options quietly

在 4.19 的代码上分析
```c
mount
  ksys_mount
    do_mount
      do_remount
        do_remount_sb
          nfs_remount
            data = kzalloc(sizeof(*data), GFP_KERNEL)
            nfs_parse_mount_options
              nfs_get_option_str(args, &mnt->client_address) // 以及其他几个字段
                match_strdup
                  kmalloc // 分配内存
            nfs_compare_remount_data
            security_sb_remount // 修复补丁增加的
              call_int_hook(sb_remount,
              selinux_sb_remount // LSM_HOOK_INIT(sb_remount, selinux_sb_remount)
                if (sb->s_type->fs_flags & FS_BINARY_MOUNTDATA) // nfs4_remote_fs_type.fs_flags = FS_RENAME_DOES_D_MOVE|FS_BINARY_MOUNTDATA,
                return 0;
                // 以下流程不会执行，那增加 security_sb_remount 有什么用？
                selinux_sb_copy_data
                  selinux_option
            kfree(data) // 没有释放 client_address 等字段的内存
```

# 862f35c94730 NFS: Fix memory leaks in nfs_pageio_stop_mirroring()

```c
nfs_writepages
  write_cache_pages
    nfs_writepages_callback
      nfs_do_writepage
        nfs_page_async_flush
          nfs_pageio_add_request
            nfs_pageio_setup_mirroring

nfs_readpages
  read_cache_pages
    readpage_async_filler
      nfs_pageio_add_request
        nfs_pageio_setup_mirroring

// 只有 pnfs 会调用到
nfs_pageio_reset_write_mds
  nfs_pageio_stop_mirroring
```

# add42de31721 NFS: Fix a page leak in nfs_destroy_unlinked_subrequests()

```c
nfs_writepages
  write_cache_pages
    nfs_writepages_callback
      nfs_do_writepage
        nfs_page_async_flush
          nfs_lock_and_join_requests
            nfs_destroy_unlinked_subrequests
              while (destroy_list) // 条件怎么满足？
```

# 4b310319c6a8 NFS: Fix memory leaks and corruption in readdir

```c
nfs_readdir
  readdir_search_pagecache
    find_and_lock_cache_page
      get_cache_page
        read_cache_page
          do_read_cache_page
            nfs_readdir_filler
              nfs_readdir_xdr_to_array
                nfs_readdir_page_filler
                  nfs_readdir_add_to_array
                    nfs_readdir_make_qstr 
                      string->name = kmemdup // 申请内存
              nfs_readdir_clear_array
                kfree(array->array[i].string.name) // 释放内存
```

# 79cc55422ce9 NFS: Fix an RCU lock leak in nfs4_refresh_delegation_stateid()

```c
// .rpc_call_done
nfs4_delegreturn_done
  case -NFS4ERR_OLD_STATEID
  nfs4_refresh_delegation_stateid
    rcu_read_lock
    return ret; // false
    rcu_read_unlock // 没解锁
```

# f4340e9314db NFSv4/pnfs: Fix a page lock leak in nfs_pageio_resend()

```c
nfs_pageio_resend
  // 修复前使用 list_move， 没有释放内存
  nfs_async_write_error // hdr->completion_ops->error_cleanup
    nfs_redirty_request
      nfs_release_request // 释放内存
```

# 4d91969ed4db NFS: Fix an I/O request leakage in nfs_do_recoalesce

```c
nfs_do_recoalesce
  req = list_first_entry
  nfs_list_remove_request(req) // 不能在这里从链表中移除
  __nfs_pageio_add_request
    nfs_pageio_do_add_request
      nfs_list_move_request(req, &mirror->pg_list); // 从 req->wb_list 中移到 pg_list
  // 如果前面 nfs_list_remove_request 已经从链表中移除了，则不会加到 pg_list 中
  list_splice_tail(&head, &mirror->pg_list);
```

# 03d5eb65b538 NFS: Fix a memory leak in nfs_do_recoalesce

`4d91969ed4db NFS: Fix an I/O request leakage in nfs_do_recoalesce` 的引入问题补丁

```c
nfs_pageio_complete_mirror
  nfs_do_recoalesce
    list_splice_init(&mirror->pg_list, &head) // 把 pg_list 移到 head 中， 重新初始化 pg_list
    __nfs_pageio_add_request
    if (desc->pg_error < 0) {
    list_splice_tail(&head, &mirror->pg_list) // 把 head 移到 pg_list 中，重新初始化 head
    mirror->pg_recoalesce = 1;
nfs_pageio_complete_mirror
  if (desc->pg_error < 0 || !mirror->pg_recoalesce) // 再次进入 nfs_pageio_complete_mirror， 条件不满足
  nfs_do_recoalesce
```

# f57dcf4c7211 NFS: Fix I/O request leakages

```c
nfs_pageio_add_request
  nfs_create_request // 申请 nfs_page 内存
    nfs_page_alloc
  nfs_pageio_add_request_mirror
    __nfs_pageio_add_request
      nfs_create_request // 申请 nfs_page 内存
      nfs_pageio_cleanup_request // // 释放 nfs_page 内存
  nfs_pageio_cleanup_request
    nfs_async_write_error // desc->pg_completion_ops->error_cleanup
      nfs_write_error_remove_page(req)
        nfs_release_request // 释放 nfs_page 内存
          kref_put
            nfs_page_group_destroy
              tmp = req
              nfs_free_request(tmp)
```

# 3b2d4dcf71c4 nfsd: Fix overflow causing non-working mounts on 1 TB machines

4.19 `8129a10ce78f nfsd: Fix overflow causing non-working mounts on 1 TB machines`
```c
// # free
//                total        used        free      shared  buff/cache   available
// Mem:        10212340      241768     9854012         372      116560     9766976
nfsd4_get_drc_mem // 4.19 的代码
  total_avail/3 = 10110976 // total_avail = 6442450944 时溢出， 总内存 805306368 KB = 786432 MB = 768 GB

// 启动nfsd时，current->comm: rpc.nfsd
write
  ksys_write
    vfs_write
      nfsctl_transaction_write
        write_ports
          __write_ports
            __write_ports_addfd
              nfsd_create_serv
                set_max_drc
                  nfsd_drc_max_mem
                  = (nr_free_buffer_pages() >> NFSD_DRC_SIZE_SHIFT) * PAGE_SIZE
                  = (nr_free_buffer_pages() / 128) * 4096
                  = 总内存(Unit:Byte) / 128
                  = 总内存(Unit:KB) * 8
```

调试补丁：
```shell
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 78191320f8e2..795c5b468f51 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1529,8 +1529,8 @@ static inline u32 slot_bytes(struct nfsd4_channel_attrs *ca)
 static u32 nfsd4_get_drc_mem(struct nfsd4_channel_attrs *ca)
 {
        u32 slotsize = slot_bytes(ca);
-       u32 num = ca->maxreqs;
-       unsigned long avail, total_avail;
+       u32 num = ca->maxreqs, num2 = num;
+       unsigned long avail, total_avail, avail2, total_avail2;
 
        spin_lock(&nfsd_drc_lock);
        total_avail = nfsd_drc_max_mem - nfsd_drc_mem_used;
@@ -1539,8 +1539,32 @@ static u32 nfsd4_get_drc_mem(struct nfsd4_channel_attrs *ca)
         * Never use more than a third of the remaining memory,
         * unless it's the only way to give this client a slot:
         */
+       printk("%s:%d, total_avail:%ld, avail:%ld, num:%d\n", __func__, __LINE__, total_avail, avail, num);
        avail = clamp_t(unsigned long, avail, slotsize, total_avail/3);
        num = min_t(int, num, avail / slotsize);
+       printk("%s:%d, total_avail:%ld, avail:%ld, num:%d\n", __func__, __LINE__, total_avail, avail, num);
+
+       total_avail2 = 6442450941;
+       avail2 = min((unsigned long)NFSD_MAX_MEM_PER_SESSION, total_avail2);
+       printk("%s:%d, total_avail2:%ld, avail2:%ld, num2:%d\n", __func__, __LINE__, total_avail2, avail2, num2);
+       avail2 = clamp_t(int, avail2, slotsize, total_avail2/3);
+       num2 = min_t(int, num2, avail2 / slotsize);
+       printk("%s:%d, total_avail2:%ld, avail2:%ld, num2:%d\n", __func__, __LINE__, total_avail2, avail2, num2);
+
+       total_avail2 = 6442450944;
+       avail2 = min((unsigned long)NFSD_MAX_MEM_PER_SESSION, total_avail2);
+       printk("%s:%d, total_avail2:%ld, avail2:%ld, num2:%d\n", __func__, __LINE__, total_avail2, avail2, num2);
+       avail2 = clamp_t(int, avail2, slotsize, total_avail2/3);
+       num2 = min_t(int, num2, avail2 / slotsize);
+       printk("%s:%d, total_avail2:%ld, avail2:%ld, num2:%d\n", __func__, __LINE__, total_avail2, avail2, num2);
+
+       total_avail2 = 8434659328;
+       avail2 = min((unsigned long)NFSD_MAX_MEM_PER_SESSION, total_avail2);
+       printk("%s:%d, total_avail2:%ld, avail2:%ld, num2:%d\n", __func__, __LINE__, total_avail2, avail2, num2);
+       avail2 = clamp_t(int, avail2, slotsize, total_avail2/3);
+       num2 = min_t(int, num2, avail2 / slotsize);
+       printk("%s:%d, total_avail2:%ld, avail2:%ld, num2:%d\n", __func__, __LINE__, total_avail2, avail2, num2);
+
        nfsd_drc_mem_used += num * slotsize;
        spin_unlock(&nfsd_drc_lock);
```

# 51b2ee7d006a nfsd4: readdirplus shouldn't return parent of export

```c
kthread
  nfsd
    svc_process
      svc_process_common
        nfsd_dispatch
          nfsd3_proc_readdirplus
            nfsd_readdir
              nfsd_buffered_readdir
                nfs3svc_encode_entryplus3
                  svcxdr_encode_entry3_plus
                    compose_entry_fh
```

# b0c6108ecf64 nfs_instantiate(): prevent multiple aliases for directory inode

测试程序 `open_by_handle_at.c`:
```c
#define _GNU_SOURCE
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>

#define errExit(msg)	do { perror(msg); exit(EXIT_FAILURE); \
						} while (0)

#define MNT_POINT	"/mnt"
#define TARGET_DIR	"/mnt/dir"

int
main(int argc, char *argv[])
{
	struct file_handle *fhp;
	int mount_id, fhsize, flags, dirfd;
	char *pathname = TARGET_DIR;
	int fd, mount_fd;

	/* Allocate file_handle structure */

	fhsize = sizeof(*fhp);
	fhp = malloc(fhsize);
	if (fhp == NULL)
		errExit("malloc");

	/* Make an initial call to name_to_handle_at() to discover
	   the size required for file handle */

	dirfd = AT_FDCWD;		   /* For name_to_handle_at() calls */
	flags = 0;				  /* For name_to_handle_at() calls */
	fhp->handle_bytes = 0;
	if (name_to_handle_at(dirfd, pathname, fhp,
				&mount_id, flags) != -1 || errno != EOVERFLOW) {
		fprintf(stderr, "Unexpected result from name_to_handle_at()\n");
		exit(EXIT_FAILURE);
	}

	/* Reallocate file_handle structure with correct size */

	fhsize = sizeof(*fhp) + fhp->handle_bytes;
	fhp = realloc(fhp, fhsize);		 /* Copies fhp->handle_bytes */
	if (fhp == NULL)
		errExit("realloc");

	/* Get file handle from pathname supplied on command line */

	if (name_to_handle_at(dirfd, pathname, fhp, &mount_id, flags) == -1)
		errExit("name_to_handle_at");

	/* Write mount ID, file handle size, and file handle to stdout,
	   for later reuse by t_open_by_handle_at.c */

	printf("mount_id: %d\n", mount_id);
	printf("handle_bytes: %u, handle_type: %d, f_handle:", fhp->handle_bytes, fhp->handle_type);
	for (int j = 0; j < fhp->handle_bytes; j++)
		printf(" %02x", fhp->f_handle[j]);
	printf("\n");

	/* Obtain file descriptor for mount point, either by opening
	   the pathname specified on the command line, or by scanning
	   /proc/self/mounts to find a mount that matches the 'mount_id'
	   that we received from stdin. */

	mount_fd = open(MNT_POINT, O_RDONLY);
	if (mount_fd == -1)
		errExit("opening mount fd");

	/* Open file using handle and mount point */

	fd = open_by_handle_at(mount_fd, fhp, O_RDONLY);
	if (fd == -1)
		errExit("open_by_handle_at");

	printf("fd: %d\n", fd);

	exit(EXIT_SUCCESS);
}
```

测试程序 `mkdir.c`:
```c
#include <sys/stat.h>
#include <sys/types.h>
#include <stdio.h>

int
main(int argc, char *argv[])
{
	int res = mkdir("/mnt/dir", 0755);
	printf("res: %d\n", res);
	return 0;
}
```

```c
name_to_handle_at
  user_path_at_empty
    filename_lookup
      path_lookupat
        walk_component
          lookup_slow
            __lookup_slow
              nfs_lookup
                d_splice_alias
                  __d_add // dentry与inode建立关联

open_by_handle_at
  do_handle_open
    handle_to_path
      do_handle_to_path
        exportfs_decode_fh
          exportfs_decode_fh_raw
            nfs_fh_to_dentry
              d_obtain_alias
                // d_find_any_alias必须要找不到dentryt才会往下走
                // name_to_handle_at执行完后，执行命令 echo 3 > /proc/sys/vm/drop_caches
                d_find_any_alias
                __d_instantiate_anon
                hlist_add_head // dentry与inode建立关联

mkdir
  do_mkdirat
    vfs_mkdir
      nfs_mkdir
        nfs4_proc_mkdir
          _nfs4_proc_mkdir
            nfs4_do_create
              nfs_instantiate
                nfs_add_or_obtain
                  d_add // dentry与inode建立关联
```

# b2b1ff3da6b2 NFS: Allow optimisation of lseek(fd, SEEK_CUR, 0) on directories

reading the file offset, only return it, do not need grab the inode lock, because do not operate the inode data.


# 7be7b3ca16a5 NFS: Ensure we immediately start writeback on rescheduled writes

`git log -L :nfs_async_write_reschedule_io:fs/nfs/write.c`

# nfsd macro seq_file.h

```shell
cat /proc/net/rpc/nfsd
```

```c
nfsd_proc_open
  single_open
     (file->private_data)->private = data
```

# ddf83afb9f60 cifs: add a warning if we try to to dequeue a deleted mid

after `list_del_init`, ` struct mid_q_entry` have not been freed yet.

# Fix up soft mounts for NFSv4.x

https://lore.kernel.org/all/20190407175912.23528-1-trond.myklebust@hammerspace.com/

## 22876f540bdf NFS: Don't call generic_error_remove_page() while holding locks

```c
nfs_page_async_flush
  nfs_lock_and_join_requests
    nfs_lock_request
  fs_write_error_remove_page

nfs_write_error_remove_page
  generic_error_remove_page # 未修复时
    truncate_inode_page
      delete_from_page_cache
```

## 6fbda89b257f NFS: Replace custom error reporting mechanism with generic one

```c

```
