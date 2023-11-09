[toc]

# 环境

```shell
apt install ntfs-3g -y
# 不指定文件系统类型以 fuse 挂载，如果指定 -t ntfs3 则以 ntfs3 挂载
mount /dev/sda1 /mnt
```
