[toc]

# 复现

`ioctl.c`:
```c
#define _GNU_SOURCE

#include <stdio.h>
#include <errno.h>
#include <sys/syscall.h>
#include <sys/types.h>
#include <string.h>
#include <fcntl.h>
#include <stdint.h>
#include <unistd.h>
#include <linux/xattr.h>
#include <asm-generic/ioctl.h>

int main()
{
        char str[64] = {0};
        int res = 0, fd = 0;

        fd = syscall(__NR_open, "/mnt", O_RDONLY|O_DIRECTORY);
        printf("open fd: %d, errno: %d\n", fd, errno);

        memcpy((void *)str, "\x01\xff\x00\x00\x00\x00\x03\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x08\x00\x00\x00\xc6\x2a\xf7", 25);
        res = syscall(__NR_ioctl, fd, _IOC(_IOC_READ|_IOC_WRITE, 0x58, 0x2c, 0x20), str);
        printf("ioctl res: %d, errno: %d\n", res, errno);

        return 0;
}
```

```c
#define _GNU_SOURCE

#include <stdio.h>
#include <errno.h>
#include <sys/syscall.h>
#include <sys/types.h>
#include <string.h>
#include <fcntl.h>
#include <stdint.h>
#include <unistd.h>
#include <linux/xattr.h>
#include <asm-generic/ioctl.h>

int main()
{
        int res = 0;

        res = syscall(__NR_setxattr, "/mnt", "trusted.overlay.upper", NULL, 0, XATTR_CREATE);
        printf("setxattr res: %d, errno: %d\n", res, errno);

        return 0;
}
```

```shell
umount /mnt
fallocate -l 50M image
mkfs.xfs -f image
mount image /mnt

gcc -o setxattr setxattr.c
gcc -o ioctl ioctl.c

./ioctl &
sleep 1
./setxattr
```

# 代码流程

```c
ioctl
  vfs_ioctl
    xfs_file_ioctl
      case XFS_IOC_GETBMAPA // cmd=cmd@entry=3223345196,
      xfs_ioc_getbmap
        xfs_getbmap

setxattr
  path_setxattr
    setxattr
      do_setxattr
        vfs_setxattr
          __vfs_setxattr_locked
            __vfs_setxattr_noperm
              __vfs_setxattr
                xfs_xattr_set
                  xfs_attr_change
                    xfs_attr_set
                      xfs_bmap_add_attrfork
                        xfs_bmap_set_attrforkoff
```