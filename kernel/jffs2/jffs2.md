[toc]

enable `CONFIG_MTD_BLOCK`

# nandflash

can not mount if `CONFIG_JFFS2_FS_WRITEBUFFER=n`

```shell
# /dev/ubi0_0 on /mnt type ubifs (rw,relatime,sync,assert=read-only,ubi=0,vol=0)
modprobe nandsim id_bytes="0xec,0xa1,0x00,0x15" parts=10,20 # 128M 128KB 2KB, first partition is 10 erase blocks, second partition is 20 erase blocks
# modprobe nandsim id_bytes="0x20,0xa5,0x00,0x15" # 2G 128KB PEB, 2KB page
# modprobe nandsim id_bytes="0x20,0xa5,0x00,0x26" # 4G 256KB 4KB 1KB-sub-page
# modprobe nandsim id_bytes="0x20,0xa7,0x00,0x15" # 4G 256KB 4KB 2KB-sub-page
# modprobe nandsim id_bytes="0x20,0x33,0x00,0x00" # 16M 16KB PEB, 512 page

modprobe mtdblock
dd if=image of=/dev/mtdblock1
mount -t jffs2 -o nodev,nosuid,sync /dev/mtdblock
```

# norflash

```shell
CONFIG_MTD_MTDRAM=m
CONFIG_MTDRAM_TOTAL_SIZE=4096
CONFIG_MTDRAM_ERASE_SIZE=128

modprobe mtdram
mtdinfo -a
```
