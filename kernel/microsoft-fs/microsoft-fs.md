[toc]

# vfat

```shell
CONFIG_NLS_ISO8859_1=y

apt install dosfstools -y
mkfs.vfat /dev/sda1
useradd -s /bin/bash -d /home/test -m test
# 文件的权限固定为 653(777-124)
mount -t vfat -o umask=124,uid=1000,gid=1000 /dev/sda1 /mnt

chown root file # Operation not permitted
```

```c
openat
  do_sys_open
    do_sys_openat2
      do_filp_open
        path_openat
          open_last_lookups
            lookup_open
              vfat_create
                fat_build_inode
                  fat_fill_inode
```

# ntfs3

```shell
mkfs.ntfs /dev/sda1
# 文件的权限固定为 653(777-124)
mount -t ntfs3 -o umask=124,uid=1000,gid=1000 /dev/sda1 /mnt
```

```c
openat
  do_sys_open
    do_sys_openat2
      do_filp_open
        path_openat
          open_last_lookups
            lookup_open
              atomic_open
                ntfs_atomic_open
                  ntfs_create_inode
                    inode_init_owner
```

