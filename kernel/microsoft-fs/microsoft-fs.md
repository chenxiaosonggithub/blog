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

# ntfs3

```shell

```

