[toc]

```shell
apt install btrfs-progs -y # debian

mkfs.btrfs -f -L 'test' /dev/sda /dev/sdb
btrfs filesystem show
mount /dev/sda /mnt
btrfs filesystem df /mnt

btrfs quota enable /mnt
btrfs subvolume create /mnt/subvol1
btrfs subvolume delete /mnt/subvol1
btrfs subvolume snapshot /mnt/subvol1 /mnt/snapshot1
```
