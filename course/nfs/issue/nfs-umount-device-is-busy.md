# 问题描述

卸载nfs挂载点时报错`device is busy`，但用`lsof | grep <挂载点>`和`fuser -m <挂载点>`都无法找到使用挂载点的进程。

# 内核打开文件 {#kernl-open-file}

在内核空间打开文件，用`lsof <挂载点>`和`fuser -m <挂载点>`无法找到进程。

源码文件如下:

- [`kernel-open-file.c`](https://gitee.com/chenxiaosonggitee/blog/blob/master/course/nfs/src/kernel-open-file.c)
- [`Makefile`](https://gitee.com/chenxiaosonggitee/blog/blob/master/course/nfs/src/Makefile)

# `mmap()`可以找到进程（没啥卵用，就是尝试一下）

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
lsof <挂载点> # 能找到进程
fuser -m <挂载点> # 能找到进程
```

