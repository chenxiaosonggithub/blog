[toc]

# 缓存与脏页

```shell
echo 1 > /proc/sys/vm/drop_caches # 清空缓存
/proc/sys/vm/dirty_background_ratio # 默认总内存的 10%
# 脏页最大时长,默认 3000 厘秒 = 30 秒
/proc/sys/vm/dirty_expire_centisecs
/proc/sys/vm/dirty_background_bytes # 单位: 字节
```

# FILE 和 文件描述符

```c
FILE *fp = fopen("file");
int fd = fileno(fp);
fsync(fd);

int fd = open("file", O_CREAT | O_RDWR, 0700);
FILE *fp = fdopen(fd, "r"); // mode 字符串格式请参考 fopen()
```

# perf

```shell
perf ftrace -a -G nfs_getattr > ftrace # 查看调用时间
```

# hung task

```shell
/proc/sys/kernel/hung_task_warning
/proc/sys/kernel/hung_task_panic
/proc/sys/kernel/hung_task_timeout_secs
```

```c
check_hung_task
```

# statfs

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <sys/statfs.h>

int main(int argc, char **argv)
{
        struct statfs st;

        if (statfs("/mnt", &st) < 0) {
                return 1;
        }
        printf("f_blocks:%ld, f_bfree:%ld, f_bavail:%ld\n", st.f_blocks, st.f_bfree, st.f_bavail);
        printf("f_bsize:%ld, f_bsize * (f_blocks:%ld, f_bfree:%ld, f_bavail:%ld)\n", st.f_bsize, st.f_bsize * st.f_blocks, st.f_bsize * st.f_bfree, st.f_bsize * st.f_bavail);

        return 0;
}
```

```shell
# df
Filesystem     1K-blocks      Used Available Use% Mounted on
/dev/ubi0_0       112736     80688     27208  75% /mnt

strace df /mnt # 输出 statfs("/mnt", {f_type=UBIFS_SUPER_MAGIC, f_bsize=4096, f_blocks=28184, f_bfree=8012, f_bavail=6802, f_files=0, f_ffree=0, f_fsid={val=[1363364819, 1127210110]}, f_namelen=255, f_frsize=4096, f_flags=ST_VALID|STT_SYNCHRONOUS|ST_RELATIME}) = 0

# ./a.out
f_blocks:28184, f_bfree:8012, f_bavail:6802
f_bsize:4096, f_bsize * (f_blocks:115441664, f_bfree:32817152, f_bavail:27860992)

strace ./a.out # 输出 statfs("/mnt", {f_type=UBIFS_SUPER_MAGIC, f_bsize=4096, f_blocks=28184, f_bfree=8012, f_bavail=6802, f_files=0, f_ffree=0, f_fsid={val=[1363364819, 1127210110]}, f_namelen=255, f_frsize=4096, f_flags=ST_VALID|STT_SYNCHRONOUS|ST_RELATIME}) = 0
```

27208*1024 = 27860992

# O_DIRECT

当以 `O_DIRECT` 打开文件时，要使用 posix_memalign 申请内存，返回0表示成功。