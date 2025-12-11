# 问题描述

nfsv3占用缓存太多。

# vmcore解析

- [`nfs-cannot-drop-cache-vmcore-1.md`](https://gitee.com/chenxiaosonggitee/tmp/blob/master/gnu-linux/nfs/nfsv3-cannot-drop-cache-vmcore-1.md)
- [`nfs-cannot-drop-cache-vmcore-2.md`](https://gitee.com/chenxiaosonggitee/tmp/blob/master/gnu-linux/nfs/nfsv3-cannot-drop-cache-vmcore-2.md)

# 虚拟机中调试 {#vm-debug}

挂载:
```sh
mount -t nfs -o vers=3 192.168.53.209:/tmp/s_test /mnt
```

用户态程序`test.c`:
```c
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <stdlib.h>

int main() {
    const char *filename = "/mnt/file";
    int buf_size = 100 * 1024 * 1024; // 读100M
    char *buffer = malloc(buf_size);
    ssize_t bytes_read;
    
    // 打开文件
    int fd = open(filename, O_RDONLY, 0644);
    if (fd == -1) {
        perror("无法打开文件");
        return 1;
    }

    printf("文件已打开 (fd=%d)\n", fd);
    
    // 读取并显示文件前4096字节
    lseek(fd, 0, SEEK_SET);
    bytes_read = read(fd, buffer, buf_size - 1);
    if (bytes_read > 0) {
        buffer[bytes_read] = '\0';
        printf("读了 %zd 字节:\n", bytes_read);
    }
    // 无限循环等待
    while (1) {
        sleep(1);
    }
    
    // 这行代码永远不会执行
    close(fd);
    return 0;
}
```

编译运行:
```sh
dd if=/dev/random of=/mnt/file bs=1M count=1024
echo 3 > /proc/sys/vm/drop_caches
gcc test.c
./a.out &
cd /mnt # 进入挂载点
```

## vmcore解析

参考[《内核调试方法》](https://chenxiaosong.com/course/kernel/debug.html#kdump-crash)在虚拟机中导出vmcore。

vmcore解析如下:
```sh
crash> ps | grep a.out
      966     703   7  ffff888011fe4d40  IN   2.0   104952   104032  a.out

crash> files 966
PID: 966      TASK: ffff888011fe4d40  CPU: 7    COMMAND: "a.out"
ROOT: /    CWD: /root
 FD       FILE            DENTRY           INODE       TYPE PATH
  ...
  3 ffff888006b21740 ffff88810430e600 ffff888112352ec8 REG  /mnt/file

crash> struct inode.i_mapping ffff888112352ec8
  i_mapping = 0xffff888112353038,

crash> struct address_space.nrpages 0xffff888112353038
  nrpages = 25728, # 执行完 echo 3 > /proc/sys/vm/drop_caches 后为 0

crash> struct address_space.i_mmap 0xffff888112353038
  i_mmap = {
    rb_root = {
      rb_node = 0x0
    },
    rb_leftmost = 0x0
  },

crash> foreach files -R mnt
PID: 966      TASK: ffff888011fe4d40  CPU: 7    COMMAND: "a.out"
ROOT: /    CWD: /root 
 FD       FILE            DENTRY           INODE       TYPE PATH
  3 ffff888006b21740 ffff88810430e600 ffff888112352ec8 REG  /mnt/file
```

## 查看文件缓存

https://mirrors.tuna.tsinghua.edu.cn/epel/8/Everything/x86_64/Packages/v/vmtouch-1.3.1-1.el8.x86_64.rpm

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

