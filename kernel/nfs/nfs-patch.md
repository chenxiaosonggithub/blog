[toc]

# nfs: handle writeback errors correctly

https://patchwork.kernel.org/project/linux-nfs/list/?series=628066&state=%2A&archive=both

## 问题描述

1. 误报空间不足
2. 执行`dd`命令非常非常慢

复现程序：
```c
        nfs server            |       nfs client
 -----------------------------|---------------------------------------------
 # No space left on server    |
 fallocate -l 100G /svr/nospc |
                              | mount -t nfs $nfs_server_ip:/ /mnt
                              |
                              | # 预期错误：空间不足
                              | dd if=/dev/zero of=/mnt/file count=1 ibs=1M
                              |
                              | # 释放挂载点的空间
                              | rm /mnt/nospc
                              |
                              | # 问题1：误报空间不足，问题2：非常非常慢
                              | dd if=/dev/zero of=/mnt/file count=1 ibs=1M
```

## 原因分析

空间不足时执行 `dd`，返回错误 `-ENOSPC`，没有清除 `wb_err` 中的错误：
```c
filp_close
  nfs4_file_flush
    nfs_wb_all // 缓存落盘
      filemap_write_and_wait
        filemap_write_and_wait_range
          __filemap_fdatawrite_range
            filemap_fdatawrite_wbc
              do_writepages
                nfs_writepages // 向 nfs server 发送 write 请求
          filemap_fdatawait_range
            __filemap_fdatawait_range
              wait_on_page_writeback // 等待 write 请求回复
    filemap_check_wb_err // 返回错误 -ENOSPC，没有清除 wb_err 中的错误

rpc_async_release
  rpc_free_task
    rpc_release_calldata
      nfs_pgio_release
        nfs_write_completion
          nfs_mapping_set_error
            mapping_set_error
              __filemap_set_wb_err
                errset_set(&mapping->wb_err, err) // 在 wb_err 中记录错误
              set_bit(..., &mapping->flags); // 在 flags 中记录错误，现已经被 nfs maintainer 删除
```

空间释放后执行 `dd`, 上一次执行 `dd` 时的错误还没清除，导致变成了同步写，速度非常非常慢，即使空间足够还是报错空间不足：
```c
write
  ksys_write
    vfs_write
      new_sync_write
        call_write_iter
          nfs_file_write
            since = filemap_sample_wb_err = 0
              errseq_sample
                if (!(old & ERRSEQ_SEEM)) // 上一次执行 dd 时的错误还没清除
                return 0
            error = filemap_check_wb_err(..., since = 0) = -ENOSPC
            if (nfs_need_check_write) // 条件满足
              nfs_error_is_fatal_on_server
                nfs_error_is_fatal
                  return true // -ENOSPC
            nfs_wb_all // 变成了 sync write，每 4K 耗时约 10ms，导致 dd 命令非常非常慢


filp_close
  nfs4_file_flush
    nfs_wb_all // 缓存落盘
      filemap_write_and_wait
        filemap_write_and_wait_range
          if (mapping_needs_writeback) // 所有的数据已经落盘
    since = filemap_sample_wb_err = 0
      errseq_sample
        if (!(old & ERRSEQ_SEEM)) // 上一次执行 dd 时的错误还没清除
        return 0
    filemap_check_wb_err // 返回错误 -ENOSPC，还是没有清除 wb_err 中的错误
```

## 我的修改方案

### 第一个补丁：write返回更详细的错误

https://patchwork.kernel.org/project/linux-nfs/patch/20220401034409.256770-2-chenxiaosong2@huawei.com/

回退 6c984083ec24 ("NFS: Use of mapping_set_error() results in spurious errors")，并且在 `write` 中返回更详细的错误：
```c
rpc_async_release
  rpc_free_task
    rpc_release_calldata
      nfs_pgio_release
        nfs_write_completion
          nfs_mapping_set_error
            mapping_set_error
              __filemap_set_wb_err
                errset_set(&mapping->wb_err, err) // 在 wb_err 中记录错误
              set_bit(..., &mapping->flags); // 回退 maintainer 的补丁，在 flags 中记录错误

nfs_file_write
  generic_perform_write // 同步写
    nfs_write_end
      nfs_wb_all
        filemap_write_and_wait
          filemap_write_and_wait_range
            filemap_check_errors
              test_and_clear_bit(..., &mapping->flags) // 返回 flags 中的错误，并清除
  filemap_fdatawrite_range // 异步写
  filemap_fdatawait_range // 同步写
    __filemap_check_errors
      test_and_clear_bit(..., &mapping->flags) // 返回 flags 中的错误，并清除
  generic_write_sync // 同步写
    vfs_fsync_range
      nfs_file_fsync
  filemap_check_wb_err // 返回更详细的错误
    return -(file->f_mapping->wb_err & MAX_ERRNO) // 返回wb_err 中的错误
```

### 第二个补丁：flush返回正确的错误

https://patchwork.kernel.org/project/linux-nfs/patch/20220401034409.256770-3-chenxiaosong2@huawei.com/

只有在 `nfs_wb_all` 有新错误产生的情况下，才尝试返回更详细的错误：
```c
nfs_file_flush
  // nfs_wb_all 执行期间如果有新的错误产生，才尝试返回更详细的错误，否则返回0
  if (nfs_wb_all)
  filemap_check_wb_err
    return -(file->f_mapping->wb_err & MAX_ERRNO) // 返回 wb_err 中的错误
```

### 第三个补丁：解决 async write 变成 sync write 的问题

https://patchwork.kernel.org/project/linux-nfs/patch/20220401034409.256770-4-chenxiaosong2@huawei.com/

回退问题补丁 "nfs: nfs_file_write() should check for writeback errors"
问题补丁存在的问题：
```c
write
  ksys_write
    vfs_write
      new_sync_write
        call_write_iter
          nfs_file_write
            since = filemap_sample_wb_err = 0
              errseq_sample
                if (!(old & ERRSEQ_SEEM)) // 上一次执行 dd 时的错误还没清除
                return 0
            error = filemap_check_wb_err(..., since = 0) = -ENOSPC
            if (nfs_need_check_write) // 条件满足
              nfs_error_is_fatal_on_server
                nfs_error_is_fatal
                  return true // -ENOSPC
            nfs_wb_all // 变成了 sync write，每 4K 耗时约 10ms，导致 dd 命令非常非常慢
```

## maintainer 的修改方案（未解决此问题）

https://patchwork.kernel.org/project/linux-nfs/list/?series=631225&state=%2A&archive=both

### 想解决问题的补丁（实际没解决）

https://patchwork.kernel.org/project/linux-nfs/patch/20220411213346.762302-4-trondmy@kernel.org/

存在的问题：
1. 没解决空间释放后执行 dd 报错的问题
2. async write 清除 wb_err

```c
// dd 命令会多次调用 write, 由于第一次调用 write 就报错 -ENOSPC, 所以后续不再调用 write，dd 命令失败
nfs_file_write
  since = filemap_sample_wb_err = 0
    errseq_sample
      if (!(old & ERRSEQ_SEEM)) // 上一次执行 dd 时的错误还没清除
      return 0
  error = filemap_check_wb_err(..., since = 0) = -ENOSPC // 没有新的错误产生，却报错
  nfs_wb_all // 执行了一次落盘
  error = file_check_and_advance_wb_err // 返回 -ENOSPC，并清除 wb_err 错误
    errseq_check_and_advance
      // *eseq 和 old 比较，相等则 *eseq = new, return old，不相等则 return *eseq
      cmpxchg(eseq, old, new)
        *eseq = new
        return old
      return -(new & MAX_ERRNO)
  return error // -ENOSPC
```

### maintainer 的其他补丁

```c
[v2,1/5] NFS: Do not report EINTR/ERESTARTSYS as mapping errors
如果执行 flush 时被信号打断，page 请求重新排队传输

[v2,2/5] NFS: fsync() should report filesystem errors over EINTR/ERESTARTSYS
`nfs_file_fsync -> nfs_file_fsync_commit -> nfs_commit_inode` 被信号打断，优先报 wb err

[v2,4/5] NFS: Do not report flush errors in nfs_write_end()
在 `nfs_write_end` 中推迟报错

[v2,5/5] NFS: Don't report errors from nfs_pageio_complete() more than once
不尝试报 nfs_pageio_complete 的错误
```

## 其他文件系统对 wb err 的处理

### 调用 fsync 时清除 wb_err

`btrfs, ceph, ext4, fuse` 调用 `file_check_and_advance_wb_err` 清除 `address_space wb_err`

### 实现 flush 的文件系统

`cifs` 通过 `address_space` 中的 `flags` 返回错误（只有 -EIO 或 -ENOSPC）:
```c
cifs_flush
  filemap_write_and_wait
    filemap_write_and_wait_range
      filemap_check_errors
        test_and_clear_bit(..., &mapping->flags)
```

`fuse` 通过 `address_space` 中的 `flags` 返回错误（只有 -EIO 或 -ENOSPC）:
```c
fuse_flush
  filemap_check_errors
    test_and_clear_bit(..., &mapping->flags)
```

`orangefs` 通过 `address_space` 中的 `flags` 返回错误（只有 -EIO 或 -ENOSPC）:
```c
orangefs_flush
  filemap_write_and_wait
    filemap_write_and_wait_range
      filemap_check_errors
        test_and_clear_bit(..., &mapping->flags)
```

`f2fs` 的 `f2fs_file_flush` 总是返回0

`ecryptfs, overlayfs` 调用真实文件系统的 `flush` 函数

### async write

其他文件系统异步写都不会清除 `address_space` 中的 `wb_err`, 因为只会被 `file_check_and_advance_wb_err` 清除

## 与 maintainer 的交流

https://patchwork.kernel.org/project/linux-nfs/patch/20220411213346.762302-4-trondmy@kernel.org/
https://patchwork.kernel.org/project/linux-nfs/patch/20220305124636.2002383-2-chenxiaosong2@huawei.com/

### maintainer 两个版本的补丁都无法解决问题

和 maintainer 说了2次，他的回复没有正面回答这个问题。

第一次没有回答，马上发了第2版。

第二次没有正面回答：
```
I understand all that. The point you appear to be missing is that this
is in fact in agreement with the documented behaviour in the write(2)
and fsync(2) manpages. These errors are supposed to be reported once,
even if they were caused by a write to a different file descriptor.

In fact, even with your change, if you make the second 'dd' call fsync
(by adding a conv=fsync), I would expect it to report the exact same
ENOSPC error, and that would be correct behaviour!

So my patches are more concerned with the fact that we appear to be
reporting the same error more than once, rather than the fact that
we're reporting them in the second attempt at I/O. As far as I'm
concerned, that is the main change that is needed to meet the behaviour
that is documented in the manpages.
```

回复中提到我的补丁空间释放后加 `(conv=fsync)` 执行 `dd` 时应该要报错，我回复说我的补丁符合他的预期，maintainer 不再回复。

### maintainer 不断强调是文档规定

```
> And more importantly, we can not detect new error by using 
> filemap_sample_wb_err()/filemap_sample_wb_err() while
> nfs_wb_all(),just 
> as I described:
> 
> ```c
>    since = filemap_sample_wb_err() = 0
>      errseq_sample
>        if (!(old & ERRSEQ_SEEN)) // nobody see the error
>          return 0;
>    nfs_wb_all // no new error
>    error = filemap_check_wb_err(..., since) != 0 // unexpected error
> ```


As I keep repeating, that is _documented behaviour_!
```

我和他说的明明是 `filemap_sample_wb_err/filemap_check_wb_err` 的用法错误，他却强调是文档规定

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

```c

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


