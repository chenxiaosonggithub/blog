# 问题描述

卸载nfsv3挂载点时报错`device is busy`，但用`lsof +D <挂载点>`和`fuser -m <挂载点>`都无法找到使用挂载点的进程。

# 调试

用以下命令打开nfs日志开关（参考[《nfs调试方法》](https://chenxiaosong.com/course/nfs/debug.html#log)）:
```sh
echo 0xFFFF > /proc/sys/sunrpc/nfs_debug
# echo 0 > /proc/sys/sunrpc/nfs_debug # 在生产环境中关闭日志请执行这个命令
```

kprobe抓进程信息（参考[《内核调试方法》](https://chenxiaosong.com/course/kernel/debug#kprobe)）:
```sh
kprobe_func_name=nfs_file_open # 或者 nfs_file_read
cd /sys/kernel/debug/tracing/
cat available_filter_functions | grep ${kprobe_func_name}
echo 1 > tracing_on
echo "p:p_${kprobe_func_name} ${kprobe_func_name}" >> kprobe_events
echo 1 > events/kprobes/p_${kprobe_func_name}/enable
echo stacktrace > events/kprobes/p_${kprobe_func_name}/trigger # 打印栈
# echo '!stacktrace' > events/kprobes/p_${kprobe_func_name}/trigger # 关闭栈
# echo 0 > events/kprobes/p_${kprobe_func_name}/enable
# echo "-:p_${kprobe_func_name}" >> kprobe_events
echo 0 > trace # 清除trace信息
cat trace_pipe
```

# 用户态快速打开关闭文件 {#userspace-open-file-short-time}

挂载:
```sh
mount -t nfs -o vers=3 localhost:/tmp /mnt
```

在用户态通过创建两个线程，不断打开又关闭文件，编译运行[`thread-open-file-short-time.c`](https://gitee.com/chenxiaosonggitee/blog/blob/master/course/nfs/src/thread-open-file-short-time.c):
```sh
gcc -o thread-open-file-short-time thread-open-file-short-time.c -lpthread
./thread-open-file-short-time
```

这时无法卸载nfs，且用`lsof +D <挂载点>`和`fuser -m <挂载点>`都无法找到使用挂载点的进程:
```sh
umount /mnt # umount.nfs: /mnt: device is busy
lsof +D /mnt # 找不到进程
fuser -m /mnt # 找不到进程
```

用上面的kprobe trace抓到以下信息:
```sh
thread-open-fil-956   [010] ....  7723.365916: p_nfs_file_open: (nfs_file_open+0x0/0x60 [nfs])
```

`956`是线程id，用以下命令查看完整的进程名:
```sh
ps -eLf | grep 956
```

# 内核打开文件 {#kernl-open-file}

## 构造

在内核空间打开文件，用`lsof +D <挂载点>`和`fuser -m <挂载点>`无法找到进程。

源码文件如下:

- [`kernel-open-file.c`](https://gitee.com/chenxiaosonggitee/blog/blob/master/course/nfs/src/kernel-open-file.c)
- [`Makefile`](https://gitee.com/chenxiaosonggitee/blog/blob/master/course/nfs/src/Makefile)

挂载:
```sh
mount -t nfs -o vers=3 localhost:/tmp /mnt
```

加载ko，打开并读文件`/mnt/dir/file`，注意这个操作不要在生产环境中尝试:
```sh
mkdir /mnt/dir -p
echo something > /mnt/dir/file # 创建文件
echo 3 > /proc/sys/vm/drop_caches
insmod kernel-open-file.ko
```

日志请查看[`nfs-umount-device-is-busy-log.txt`](https://gitee.com/chenxiaosonggitee/tmp/blob/master/gnu-linux/nfs/nfs-umount-device-is-busy-log.txt):
```sh
...
[  122.567308] NFS: open file(dir/file)
...
[  122.571219] NFS: read(dir/file, 4096@0)
...
```

这时我们卸载nfs挂载点就能得到一样的报错信息，且无法找到使用挂载点的进程:
```sh
umount /mnt # umount.nfs: /mnt: device is busy
lsof +D /mnt # 找不到进程
fuser -m /mnt # 找不到进程
```

移除ko后，在内核关闭了文件，就能正常卸载nfs挂载点了:
```sh
rmmod kernel_open_file # 在内核中关闭文件
umount /mnt # 正常卸载，不报错
```

## 代码分析

系统调用的跟踪调试请查看[《文件系统延迟卸载》](https://chenxiaosong.com/course/kernel/fs.html#lazy-umount)。

只有在用户空间打开文件时会把文件描述符放到`files_struct -> fdt`中:
```c
openat
  do_sys_open
    do_sys_openat2
      fd_install
        rcu_assign_pointer(fdt->fd[fd], file);
```

在内核空间打开文件时，不会把文件描述符加到`fdtable`中，`fuser -m`和`lsof +D`无法遍历到文件描述符，所以无法找到打开文件的进程。

可以用[`kprobe-fd_install.c`](https://gitee.com/chenxiaosonggitee/blog/blob/master/course/nfs/src/kprobe-fd_install.c)调试，
其中`mydebug_dump_stack()`相关的用法可以查看[《mydebug模块》](https://chenxiaosong.com/course/kernel/debug.html#mydebug)。

<!--
# `mmap()`可以找到进程 {#mmap-open-file}

下面的内容对你没啥卵用，不用看了。只是我吃饱撑的尝试一下，顺便再记录一下。

`mmap.c`:
```c
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
    // 打开文件，修改挂载点
    int fd = open("/mnt/file", O_RDONLY);
    if (fd == -1) {
        perror("open");
        exit(EXIT_FAILURE);
    }

    // 获取文件信息
    struct stat file_stat;
    if (fstat(fd, &file_stat) == -1) {
        perror("fstat");
        close(fd);
        exit(EXIT_FAILURE);
    }

    // 检查文件是否为空
    if (file_stat.st_size == 0) {
        fprintf(stderr, "File is empty\n");
        close(fd);
        exit(EXIT_FAILURE);
    }

    // 内存映射文件
    void *mapped = mmap(NULL, file_stat.st_size, PROT_READ, MAP_PRIVATE, fd, 0);
    if (mapped == MAP_FAILED) {
        perror("mmap");
        close(fd);
        exit(EXIT_FAILURE);
    }

    // 映射成功后即可关闭文件描述符
    close(fd);

    // 将文件内容输出到标准输出
    if (fwrite(mapped, 1, file_stat.st_size, stdout) != file_stat.st_size) {
        fprintf(stderr, "Error writing to stdout\n");
    }

    printf("will loop\n");
    while (1) {
        ;
    }

    // 解除内存映射
    if (munmap(mapped, file_stat.st_size) == -1) {
        perror("munmap");
        exit(EXIT_FAILURE);
    }

    return EXIT_SUCCESS;
}
```

```sh
gcc -o mmap mmap.c
./mmap &
lsof +D <挂载点> # 能找到进程
fuser -m <挂载点> # 能找到进程
```

说了不用看了，你还看。
-->

