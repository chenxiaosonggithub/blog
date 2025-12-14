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

# 虚拟机中调试 {#vm-debug}

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

# 尝试构造

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

# 代码分析 {#code-analysis}

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
  // 合入 6fbda89b257f NFS: Replace custom error reporting mechanism with generic one
  // 合入 06c9fdf3b9f1 NFS: On fatal writeback errors, we need to call nfs_inode_remove_request()
  // 才会执行以下函数
  nfs_inode_remove_request
    ClearPagePrivate(head->wb_page);
```

# 补丁

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

