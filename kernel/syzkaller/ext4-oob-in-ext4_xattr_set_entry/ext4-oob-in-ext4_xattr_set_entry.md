[toc]

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

        fd = openat(AT_FDCWD, "/mnt", O_RDONLY|O_DIRECTORY);

        mknodat(fd, "device", S_IFBLK|000, 0x700); // makedev(0x7, 0), loop0 设备

        res = syscall(__NR_lsetxattr, "/mnt", "system.posix_acl_access", "\2\0\0\0\1\0\0\0\0\0\0\0\4\0\0\0\0\0\0\0\20\0\0\0\0\0\0\0 \0\0\0\0\0\0", 36, 0);
        printf("lsetxattr system res: %d, errno: %d\n", res, errno);

        fd = openat(fd, "device", O_RDWR|O_CREAT|O_NOCTTY|O_APPEND|O_DIRECT|O_NOATIME, 000);

        write(fd, ..., 35840); // 相当于写loop设备，写裸盘

        res = syscall(__NR_lsetxattr, "/mnt", "security.SMACK64TRANSMUTE", NULL, 0, 0);
        printf("lsetxattr security res: %d, errno: %d\n", res, errno);

        return 0;
}
```

```shell
gcc main.c
umount /mnt
mkfs.ext4 -F image
mount image /mnt
./a.out
getfattr /mnt -e hex -n system.posix_acl_access
getfattr /mnt -e hex -n security.SMACK64TRANSMUTE
getfattr /mnt -e text -n system.posix_acl_access
getfattr /mnt -e text -n security.SMACK64TRANSMUTE
```

```c
lsetxattr
  path_setxattr
    setxattr
      do_setxattr
        vfs_setxattr
          __vfs_setxattr_locked
            __vfs_setxattr_noperm
              __vfs_setxattr
                ext4_xattr_security_set
                  ext4_xattr_set
                    ext4_xattr_set_handle
                      if (!value) { // 条件不满足
                      } else {
                      error = ext4_xattr_ibody_set(handle, inode, &i, &is);
                      } else if (error == -ENOSPC) {  
                      ext4_xattr_block_set
                        if (s->base) { // 条件满足
                        if (header(s->base)->h_refcount == cpu_to_le32(1)) { // 条件满足和不满足都会出问题
                        s->first = ENTRY(header(s->base)+1) = s->base + sizeof(struct ext4_xattr_header) = s->base + 32
                        if (!s->not_found && s->here->e_value_inum) { // 条件不满足
                        ext4_xattr_set_entry
                          } else if (s->not_found) {
                          size_t size = EXT4_XATTR_LEN(name_len) = 32
                          size_t rest = last - here + sizeof(__u32) = ffff888011a9a820 - ffff888011a9a830 + 4 = -16 + 4 = -12 = 18446744073709551604
                          memmove((void *)here + size, here, rest)
```