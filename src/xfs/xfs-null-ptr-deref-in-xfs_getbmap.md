[001c179c4e26 xfs: fix NULL pointer dereference in xfs_getbmap()](https://lore.kernel.org/all/20220727085230.4073478-1-chenxiaosong2@huawei.com/)

```sh
1. shell命令: fallocate -l 100M image
2. shell命令: mkfs.xfs -f image
3. shell命令: mount image /mnt
4. c程序: setxattr("/mnt", "trusted.overlay.upper", NULL, 0, XATTR_CREATE)
5. c程序:
    char arg[32] = "\x01\xff\x00\x00\x00\x00\x03\x00\x00\x00\x00\x00\x00"
                   "\x00\x00\x00\x00\x00\x08\x00\x00\x00\xc6\x2a\xf7";
    fd = open("/mnt", O_RDONLY|O_DIRECTORY);
    ioctl(fd, _IOC(_IOC_READ|_IOC_WRITE, 0x58, 0x2c, 0x20), arg);
```

```c
         ioctl               |       setxattr
 ----------------------------|---------------------------
 xfs_getbmap                 |
   xfs_ifork_ptr             |
     xfs_inode_has_attr_fork |
       ip->i_forkoff == 0    |
     return NULL             |
   ifp == NULL               |
 ----------------------------|---------------------------
                             | xfs_bmap_set_attrforkoff
                             |   ip->i_forkoff > 0
 ----------------------------|---------------------------
   xfs_inode_has_attr_fork   |
     ip->i_forkoff > 0       |
   ifp == NULL               |
   ifp->if_format            |
```