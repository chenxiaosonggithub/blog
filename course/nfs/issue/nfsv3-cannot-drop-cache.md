# 问题描述

nfsv3的文件占用缓存太多。

# 20251105 vmcore分析

[详细的crash输出请点击这里查看](https://gitee.com/chenxiaosonggitee/tmp/blob/master/gnu-linux/nfs/nfsv3-cannot-drop-cache/nfsv3-cannot-drop-cache-vmcore-20251105.md)。

占用缓存最多的inode地址为`0xffff8dc8f6cb4380`，找出超级块地址:
```sh
crash> struct inode.i_sb 0xffff8dc8f6cb4380
  i_sb = 0xffff8df33b6a5800,
```

在挂载信息中找不到这个超级块地址:
```sh
crash> mount | grep ffff8df33b6a5800
```

根据以下在虚拟机中验证可知，在导出vmcore之前，环境已经执行过`umount -l`。

查看第一个page，可以看到private标记没有清除:
```sh
crash> kmem ffffc7b0a71abc40
      PAGE         PHYSICAL      MAPPING       INDEX CNT FLAGS
ffffc7b0a71abc40 19c6af1000 ffff8db67005d210     3773  2 17ffffc000102a error,uptodate,lru,private
```

# 20251202 vmcore分析

[详细的crash输出请点击这里查看](https://gitee.com/chenxiaosonggitee/tmp/blob/master/gnu-linux/nfs/nfsv3-cannot-drop-cache/nfsv3-cannot-drop-cache-vmcore-20251202.md)。

占用缓存最多的inode地址为`0xffff9d9eeca42da0`，找出超级块地址:
```sh
crash> struct inode.i_sb 0xffff9d9eeca42da0
  i_sb = 0xffff9dae81c1d000,
```

在挂载信息中找不到这个超级块地址:
```sh
crash> mount | grep ffff9dae81c1d000
```

根据以下在虚拟机中验证可知，在导出vmcore之前，环境已经执行过`umount -l`。

查看第一个page，可以看到private标记没有清除:
```sh
crash> kmem fffffae836418f40
      PAGE         PHYSICAL      MAPPING       INDEX CNT FLAGS
fffffae836418f40 ad9063d000 ffff9d9eeca42f10  54e470e  2 197ffffc000102a error,uptodate,lru,private
```

# 构造复现 {#reproduce}

合入补丁[0001-reproduce-4.19-null-ptr-deref-in-nfs_updatepage.patch](https://gitee.com/chenxiaosonggitee/blog/blob/master/course/nfs/src/0001-reproduce-4.19-null-ptr-deref-in-nfs_updatepage.patch)。

```sh
mount -t nfs -o vers=3 192.168.53.211:/tmp/s_test /mnt
```

测试步骤:
```sh
echo something > something
echo something_else > something_else
echo something_else_again > something_else_again
# 为什么不直接用 echo something > /mnt/file 呢，因为用ps无法查看到echo进程
cat something > /mnt/file &
cat something_else > /mnt/file &
cat something_else_again > /mnt/file &
```

## vmcore解析

[详细的crash命令输出请点击这里查看](https://gitee.com/chenxiaosonggitee/tmp/blob/master/gnu-linux/nfs/nfsv3-cannot-drop-cache/nfsv3-cannot-drop-cache-vmcore-reproduce.md)。

我们看到page的flags中的private没有清除:
```sh
crash> kmem ffffea000434e4c0
      PAGE       PHYSICAL      MAPPING       INDEX CNT FLAGS
ffffea000434e4c0 10d393000 ffff8881037967f0        0  3 17ffffc000102b locked,error,uptodate,lru,private
```

执行完`echo 3 > /proc/sys/vm/drop_caches`后，还是一样。

# 正常情况调试 {#normal-debug}

挂载:
```sh
mount -t nfs -o vers=3 192.168.53.209:/tmp/s_test /mnt
```

[用户态程序`test.c`请点击这里查看](https://gitee.com/chenxiaosonggitee/tmp/blob/master/gnu-linux/nfs/nfsv3-cannot-drop-cache/test.c)。

编译运行:
```sh
dd if=/dev/random of=/mnt/file bs=1M count=1024 # 文件大小1G
echo 3 > /proc/sys/vm/drop_caches
gcc test.c
./a.out & # 读100M数据
cd /mnt # 进入挂载点
```

## vmcore解析

参考[《内核调试方法》](https://chenxiaosong.com/course/kernel/debug.html#kdump-crash)在虚拟机中导出vmcore。

[详细的crash命令输出请点击这里查看](https://gitee.com/chenxiaosonggitee/tmp/blob/master/gnu-linux/nfs/nfsv3-cannot-drop-cache/nfsv3-cannot-drop-cache-vmcore-debug.md)。

查看地址空间中有`25728`个page，每个page有4K大小，总共`100M`:
```sh
crash> struct address_space.nrpages 0xffff88810437dd38
  nrpages = 25728, # 执行完 echo 3 > /proc/sys/vm/drop_caches 后 nrpages 为 0
```

执行`umount -l`后重新再`mount`（挂载参数一样，路径可以不同），`mount`命令输出中包含inode所在的super block，`files`命令也可以找到打开这个文件的进程:
```sh
crash> mount | grep ffff88812ae61800
ffff8881002ce880 ffff88812ae61800 nfs    192.168.53.209:/tmp/s_test /mnt

crash> foreach files -R mnt
PID: 923      TASK: ffff8881045bcd40  CPU: 14   COMMAND: "a.out"
ROOT: /    CWD: /root 
 FD       FILE            DENTRY           INODE       TYPE PATH
  3 ffff88800ee72a80 ffff888004e1c000 ffff88810437dbc8 REG  /mnt/file
```

执行`umount -l`后重新再`mount`（挂载参数不同），`mount`命令输出中不包含inode所在的super block，`files`命令也找不到打开文件的进程:
```sh
crash> mount | grep ffff88812ae61800 # 找不到
crash> foreach files -R mnt # 没有找到
```

# 找出缓存大于特定值的文件

麒麟服务器v10没有vmtouch，可以[在这里下载vmtouch rpm包](https://mirrors.tuna.tsinghua.edu.cn/epel/8/Everything/x86_64/Packages/v/vmtouch-1.3.1-1.el8.x86_64.rpm)。

```sh
mount_point=/mnt
export size_threshold_mb=100

find ${mount_point} -type f -print0 | xargs -0 -n1 -P16 sh -c '
    for file do
        out=$(vmtouch -v "$file")
        pages=$(echo "$out" | awk "/Resident Pages:/ {print \$3}" | cut -d/ -f1)
        mb=$((pages*4096/1024/1024))
        if [ "$mb" -gt ${size_threshold_mb} ]; then
            echo "$file Cached_MB=${mb}"
        fi
    done
  ' sh
```

# 代码分析 {#code-analysis}

其他相关的分析请查看以两个链接:

- [4.19 nfs_updatepage()空指针解引用问题](https://chenxiaosong.com/course/nfs/issue/4.19-null-ptr-deref-in-nfs_updatepage.html)
- [4.19 nfs_wb_page() soft lockup的问题](https://chenxiaosong.com/course/nfs/issue/4.19-nfs-soft-lockup-in-nfs_wb_page.html)

page设置private的地方:
```c
nfs_inode_add_request
  SetPagePrivate(req->wb_page);
```

page清除private的地方:
```c
nfs_write_error_remove_page
  // 在这里打印出inode地址
  req->wb_context->dentry->d_inode
  // 出问题的代码合入补丁 22876f540bdf NFS: Don't call generic_error_remove_page() while holding locks
  // 以下函数不会调用
  generic_error_remove_page
    truncate_inode_page
      truncate_cleanup_page
        do_invalidatepage
          nfs_invalidate_page
            nfs_wb_page_cancel
              nfs_inode_remove_request
                // 由于没调用generic_error_remove_page()
                // 所以不会执行到这里，也不会清除private标记
                ClearPagePrivate(head->wb_page);
```

调用`nfs_write_error_remove_page()`的地方:
```c
// done
nfs_async_write_error

// todo
nfs_page_async_flush // 这个在软锁问题那里分析过，也有可能有些流程会不触发软锁
```

调用`nfs_async_write_error()`的地方:
```c
// done
nfs_async_write_reschedule_io

// done
.error_cleanup
```

调用`nfs_async_write_reschedule_io()`的地方:
```c
// done，pnfs不涉及
ff_layout_reset_write
  .reschedule_io
```

调用`.error_cleanup`的地方:
```c
// todo
nfs_pageio_cleanup_request

// todo
nfs_pageio_error_cleanup

// todo
nfs_pageio_resend
```

# 解决方案

回退补丁[14bebe3c90b3 NFS: Don't interrupt file writeout due to fatal errors](https://lore.kernel.org/all/20190407175912.23528-20-trond.myklebust@hammerspace.com/)。

<!--
```sh
git log --grep=nfs_inode_remove_request --oneline --date=short --format="%cd %h %s %an <%ae>"
# 2025-08-19 76d2e3890fb1 NFS: Fix a race when updating an existing write Trond Myklebust <trond.myklebust@hammerspace.com>
# 2024-07-08 b571cfcb9dca nfs: don't reuse partially completed requests in nfs_lock_and_join_requests Christoph Hellwig <hch@lst.de>
# 2023-10-11 6a6d4644ce93 NFS: Fix potential oops in nfs_inode_remove_request() Scott Mayhew <smayhew@redhat.com>
# 2023-09-28 dd1b2026323a nfs: decrement nrequests counter before releasing the req Jeff Layton <jlayton@kernel.org>
# 2020-01-15 b8946d7bfb94 NFS: Revalidate the file mapping on all fatal writeback errors Trond Myklebust <trondmy@gmail.com>
# 2019-10-02 33ea5aaa87cd nfs: Fix nfsi->nrequests count error on nfs_inode_remove_request ZhangXiaoxu <zhangxiaoxu5@huawei.com>
# 2019-08-19 06c9fdf3b9f1 NFS: On fatal writeback errors, we need to call nfs_inode_remove_request() Trond Myklebust <trond.myklebust@hammerspace.com>
```
-->

