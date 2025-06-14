# 问题描述

4.19内核打印:
```sh
lockd: server xx.xx.xx.xx not responding, still trying
```

需要回答以下问题:

- 核外: ftp哪些请求加锁，哪些请求解锁，怎么加锁？
- 核外: 请求加锁是同步锁还是异步锁怎么判断？ 
- lockd有哪些请求？哪些请求超时会报lockd信息？
- 超时时间参数？
- 重传机制？

# 构造

构造内核打印`lockd: server xx.xx.xx.xx not responding, still trying`。

## 内核修改

```c
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -31,6 +31,7 @@
 #include <linux/lockd/nlm.h>
 #include <linux/lockd/lockd.h>
 #include <linux/kthread.h>
+#include <linux/delay.h>
 
 #define NLMDBG_FACILITY                NLMDBG_SVCLOCK
 
@@ -404,6 +405,11 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
        int                     error;
        __be32                  ret;
 
+       while (1) {
+               printk("%s:%d, sleep\n", __func__, __LINE__);
+               msleep(20 * 1000);
+       }
+
        dprintk("lockd: nlmsvc_lock(%s/%ld, ty=%d, pi=%d, %Ld-%Ld, bl=%d)\n",
                                locks_inode(file->f_file)->i_sb->s_id,
                                locks_inode(file->f_file)->i_ino,
```

# 用户态程序

`test.c`:
```c
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/file.h>

int main(int argc, char *argv[]) {
    if (argc != 2) {
        printf("Usage: %s <file_path>\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    const char *file_path = argv[1];
    int fd = open(file_path, O_RDWR);
    if (fd == -1) {
        printf("Error: open %s\n", file_path);
        exit(EXIT_FAILURE);
    }
    printf("open succ %s\n", file_path);
    int res = flock(fd, LOCK_SH); // 或 LOCK_EX
    if (res == -1) {
        printf("Error: flock %s\n", file_path);
        close(fd);
        exit(EXIT_FAILURE);
    }
    printf("lock succ %s\n", file_path);

    // Unlock and close the file
    flock(fd, LOCK_UN);
    close(fd);

    return 0;
}
```

```sh
mount -t nfs -o vers=3 localhost:/tmp /mnt
echo something > /mnt/file # 创建文件
gcc -o test test.c
./test /mnt/file
```

