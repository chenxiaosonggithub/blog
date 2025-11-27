# 问题描述

nfsv3占用缓存太多。

# vmcore解析

请查看[`nfs-cannot-drop-cache-vmcore.md`](https://gitee.com/chenxiaosonggitee/tmp/blob/master/nfs/nfs-cannot-drop-cache-vmcore.md)。

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

int main() {
    const char *filename = "/mnt/file";
    char buffer[4096];
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
    bytes_read = read(fd, buffer, sizeof(buffer) - 1);
    if (bytes_read > 0) {
        buffer[bytes_read] = '\0';
        printf("文件前 %zd 字节:\n%s\n", bytes_read, buffer);
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
gcc test.c
./a.out &
cd /mnt # 进入挂载点
```

参考[《内核调试方法》](https://chenxiaosong.com/course/kernel/debug.html#kdump-crash)在虚拟机中导出vmcore。

vmcore解析如下:
```sh
crash> ps | grep a.out
     1027     710   7  ffff888110e119c0  IN   0.0     2548     1508  a.out
crash> files 1027
PID: 1027     TASK: ffff888110e119c0  CPU: 7    COMMAND: "a.out"
ROOT: /    CWD: /root
 FD       FILE            DENTRY           INODE       TYPE PATH
  ...
  3 ffff88810a8f8c00 ffff8881004840c0 ffff888104e06048 REG  /mnt/file

crash> struct inode.i_mapping ffff888104e06048
  i_mapping = 0xffff888104e061b8,

crash> struct address_space.nrpages 0xffff888104e061b8
  nrpages = 4, # 有预读，4个page

crash> struct address_space.i_mmap 0xffff888104e061b8
  i_mmap = {
    rb_root = {
      rb_node = 0x0
    },
    rb_leftmost = 0x0
  },

crash> foreach files -R mnt
PID: 710      TASK: ffff888110e13380  CPU: 1    COMMAND: "bash"
ROOT: /    CWD: /mnt 

PID: 1027     TASK: ffff888110e119c0  CPU: 9    COMMAND: "a.out"
ROOT: /    CWD: /root 
 FD       FILE            DENTRY           INODE       TYPE PATH
  3 ffff88810a8f8c00 ffff8881004840c0 ffff888104e06048 REG  /mnt/file
```

