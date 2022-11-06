[toc]

# 环境

```shell
CONFIG_BLK_DEV_NULL_BLK=m # null_blk 模块

modprobe null_blk
# modprobe -r null_blk
mkdir /sys/kernel/config/nullb/test
# rmdir /sys/kernel/config/nullb/test # 删除目录
echo 1 > /sys/kernel/config/nullb/test/memory_backed # 使用内存
echo 100 > /sys/kernel/config/nullb/test/size # 单位：MB
echo 1 > /sys/kernel/config/nullb/test/power # 上电
mkfs.ext4 -F /dev/nullb1
mount /dev/nullb1 /mnt/
```