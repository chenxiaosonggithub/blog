
# 问题描述

nfsv3挂载参数带`soft`或`actimeo=1`能挂载成功，不带这两个参数时挂载hung住:
```sh
mount -t nfs -o vers=3 ${server_ip}:/svr/export /mnt # hung
mount -t nfs -o vers=3,soft ${server_ip}:/svr/export /mnt # 成功
mount -t nfs -o vers=3,actimeo=1 ${server_ip}:/svr/export /mnt # 成功
```

类似问题请参考[Bug 204395 - NFS v3 mount hung](https://bugzilla.kernel.org/show_bug.cgi?id=204395#c1)。

# 调试

## kprobe

以下脚本验证都会走到`nfs_fs_mount_common()`:
```sh
kprobe_func_name=nfs_fs_mount_common
cd /sys/kernel/debug/tracing/
# 可以用 kprobe 跟踪的函数
cat available_filter_functions | grep ${kprobe_func_name}
echo 1 > tracing_on

echo "p:p_${kprobe_func_name} ${kprobe_func_name}" >> kprobe_events
echo 1 > events/kprobes/p_${kprobe_func_name}/enable
# echo stacktrace > events/kprobes/p_${kprobe_func_name}/trigger # 打印栈
# echo '!stacktrace' > events/kprobes/p_${kprobe_func_name}/trigger # 关闭栈
# echo 0 > events/kprobes/p_${kprobe_func_name}/enable
# echo "-:p_${kprobe_func_name}" >> kprobe_events

echo 0 > trace # 清除trace信息
cat trace_pipe
```

## 获取所有进程的栈

脚本查看[《nfs调试方法》](https://chenxiaosong.com/course/nfs/debug.html#get-all_stack)。

vim删除某个重复的栈:
```sh
:%s/\[<0>\] grab_super+0x2b\/0x90\_.\{-}=======================================================//g
:%s/\[<0>\] iterate_supers+0x7f\/0x100\_.\{-}=======================================================//g
```

找到以下可疑的nfs相关的栈:
```sh
=============== 进程 1232699 线程 1232699 kworker/u256:0+flush-0:48 栈信息 ===============
[<0>] inode_wait_for_writeback+0x21/0x30
[<0>] evict+0xbc/0x1a0
[<0>] __dentry_kill+0xdd/0x180
[<0>] dentry_kill+0x4d/0x260
[<0>] dput+0x183/0x200
[<0>] __put_nfs_open_context+0xd0/0x130 [nfs]
[<0>] nfs_free_request+0xb7/0x180 [nfs]
[<0>] nfs_release_request+0x59/0x80 [nfs]
[<0>] nfs_do_writepage+0x1bf/0x2d0 [nfs]
[<0>] nfs_writepages_callback+0xf/0x20 [nfs]
[<0>] write_cache_pages+0x187/0x410
[<0>] nfs_writepages+0xb0/0x170 [nfs]
[<0>] do_writepages+0x4b/0xe0
[<0>] __writeback_single_inode+0x3d/0x330
[<0>] writeback_sb_inodes+0x1ad/0x4b0
[<0>] __writeback_inodes_wb+0x5d/0xb0
[<0>] wb_writeback+0x26c/0x300
[<0>] wb_workfn+0x1dc/0x4c0
[<0>] process_one_work+0x195/0x3d0
[<0>] worker_thread+0x30/0x390 
[<0>] kthread+0x113/0x130
[<0>] ret_from_fork+0x35/0x40
=======================================================
```

```sh
rpm2cpio kernel-debuginfo-4.19.90-23.16.v2101.ky10.x86_64.rpm | cpio -div

./klinux-4.19/scripts/faddr2line usr/lib/debug/lib/modules/4.19.90-23.16.v2101.ky10.x86_64/kernel/fs/nfs/nfs.ko.debug nfs_release_request+0x59/0x80
nfs_release_request+0x59/0x80:
nfs_page_group_destroy at /usr/src/debug/kernel-4.19.90/linux-4.19.90-23.16.v2101.ky10.x86_64/fs/nfs/pagelist.c:314
(inlined by) kref_put at /usr/src/debug/kernel-4.19.90/linux-4.19.90-23.16.v2101.ky10.x86_64/./include/linux/kref.h:70
(inlined by) nfs_release_request at /usr/src/debug/kernel-4.19.90/linux-4.19.90-23.16.v2101.ky10.x86_64/fs/nfs/pagelist.c:458

./klinux-4.19/scripts/faddr2line usr/lib/debug/lib/modules/4.19.90-23.16.v2101.ky10.x86_64/kernel/fs/nfs/nfs.ko.debug nfs_do_writepage+0x1bf/0x2d0
nfs_do_writepage+0x1bf/0x2d0:
nfs_do_writepage at /usr/src/debug/kernel-4.19.90/linux-4.19.90-23.16.v2101.ky10.x86_64/fs/nfs/write.c:679
```

`nfs_do_writepage`内联了太多函数，所以要[查看反汇编](https://gitee.com/chenxiaosonggitee/tmp/blob/master/nfs/nfsv3-mount-hung-with-same-option-vmcore.md):
```sh
# fs/nfs/write.c: 674 if (ret == -EAGAIN) {
0xffffffffc08b2600 <nfs_do_writepage+0x1a0>:	cmp    $0xfffffff5,%r14d
0xffffffffc08b2604 <nfs_do_writepage+0x1a4>:	je     0xffffffffc08b2671 <nfs_do_writepage+0x211>
# fs/nfs/write.c: 679 return ret;
0xffffffffc08b2606 <nfs_do_writepage+0x1a6>:	pop    %rbx
0xffffffffc08b2607 <nfs_do_writepage+0x1a7>:	mov    %r14d,%eax
0xffffffffc08b260a <nfs_do_writepage+0x1aa>:	pop    %rbp
0xffffffffc08b260b <nfs_do_writepage+0x1ab>:	pop    %r12
0xffffffffc08b260d <nfs_do_writepage+0x1ad>:	pop    %r13
0xffffffffc08b260f <nfs_do_writepage+0x1af>:	pop    %r14
0xffffffffc08b2611 <nfs_do_writepage+0x1b1>:	pop    %r15
0xffffffffc08b2613 <nfs_do_writepage+0x1b3>:	retq   
# fs/nfs/write.c: 663 nfs_page_async_flush() nfs_write_error_remove_page(req);
0xffffffffc08b2614 <nfs_do_writepage+0x1b4>:	mov    %rbp,%rdi # x86_64下整数参数使用的寄存器依次为: RDI，RSI，RDX，RCX，R8，R9
# fs/nfs/write.c: 664 nfs_page_async_flush() return 0;
0xffffffffc08b2617 <nfs_do_writepage+0x1b7>:	xor    %r14d,%r14d # 最终效果是将 %r14d 寄存器的值设置为零
# fs/nfs/write.c: 663 nfs_page_async_flush() nfs_write_error_remove_page(req);
0xffffffffc08b261a <nfs_do_writepage+0x1ba>:	callq  0xffffffffc08b1580 <nfs_write_error_remove_page>
# fs/nfs/write.c: 679 return ret;
0xffffffffc08b261f <nfs_do_writepage+0x1bf>:	mov    %r14d,%eax # 返回值放在eax
0xffffffffc08b2622 <nfs_do_writepage+0x1c2>:	pop    %rbx
0xffffffffc08b2623 <nfs_do_writepage+0x1c3>:	pop    %rbp
0xffffffffc08b2624 <nfs_do_writepage+0x1c4>:	pop    %r12
0xffffffffc08b2626 <nfs_do_writepage+0x1c6>:	pop    %r13
0xffffffffc08b2628 <nfs_do_writepage+0x1c8>:	pop    %r14
0xffffffffc08b262a <nfs_do_writepage+0x1ca>:	pop    %r15
0xffffffffc08b262c <nfs_do_writepage+0x1cc>:	retq   
...
# fs/nfs/write.c: 675 redirty_page_for_writepage(wbc, page);
0xffffffffc08b2671 <nfs_do_writepage+0x211>:	mov    %rbx,%rsi
0xffffffffc08b2674 <nfs_do_writepage+0x214>:	mov    %r13,%rdi
```

# 代码分析

在`sget_userns()`中，如果指定不一样的挂载选项时（比如加了`soft`），会生成新的超级块；而如果挂载选项和其他挂载点一样，就会尝试获取已有的超级块，但其他挂载点对应的同一超级块的锁已经被其他进程持有，所以就出现hung住的情况:
```c
mount
  ksys_mount
    do_mount
      do_new_mount
        vfs_kern_mount
          mount_fs
            nfs_fs_mount
              nfs_try_mount
                nfs_try_mount_request
                  nfs3_create_server
                    nfs_create_server
                      nfs_init_server
                        nfs_get_client
                          nfs_alloc_client
                          nfs_init_client
                nfs_fs_mount_common
                  sget_userns
                    grab_super // 当挂载选项一样时，尝试获取已有的超级块
                      down_write // 其他挂载点对应的同一超级块的锁已经被其他进程持有
                    alloc_super // 只有挂载选项不同时，才会分配新的超级块

wb_workfn
  wb_writeback
    __writeback_inodes_wb
      trylock_super(sb)
        down_read_trylock(&sb->s_umount) // 持有超级块读锁
      writeback_sb_inodes
        __writeback_single_inode
          do_writepages
            nfs_writepages
              write_cache_pages
                nfs_writepages_callback
                  nfs_do_writepage
                    nfs_page_async_flush
                      nfs_write_error_remove_page
                        nfs_release_request
                          nfs_free_request
                            __put_nfs_open_context
                              dput
                                dentry_kill
                                  __dentry_kill
                                    evict
                                      inode_wait_for_writeback

nfs_parse_mount_options
  mnt->flags |= NFS_MOUNT_SOFT; // soft
  mnt->acregmin = mnt->acregmax = mnt->acdirmin = mnt->acdirmax = option; // actimeo
```

# 构造

```c
#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>
#include <string.h>

int main() {
    const char *filename = "/mnt/file"; // NFS文件路径
    const char *data = "hello\n";       // 要写入的数据

    // 打开文件（如果不存在则创建，只写模式）
    int fd = open(filename, O_CREAT | O_WRONLY, 0644);
    if (fd == -1) {
        // 错误处理：无法打开文件
        return 1;
    }

    // 计算数据长度并写入文件
    ssize_t bytes_written = write(fd, data, strlen(data));
    if (bytes_written == -1) {
        // 错误处理：写入失败
        close(fd);
        return 1;
    }

    // 无限循环，保持程序运行且不关闭文件
    while (1) {
        sleep(1); // 每秒休眠一次，减少CPU占用
    }

    // 关闭文件
    close(fd);
    return 0;
}
```

# 规避方案

默认选项值`acregmin=3,acregmax=60,acdirmin=30,acdirmax=60`，只需要更改其中一个选项，如`acdirmax=59`就能在挂载时生成新的超级块，从而挂载成功。

