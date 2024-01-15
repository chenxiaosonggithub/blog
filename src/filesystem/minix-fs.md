最近(2024.01.11)由于要代表公司参加一个考试，我负责准备文件系统相关的题目，就想着把代码量比较小的minux文件系统好好学习一下。

# 使用

虚拟机启动时，不能使用4k盘，qemu启动命令`logical_block_size`和`physical_block_size`参数要使用512：
```sh
-drive file=1,if=none,format=raw,cache=writeback,file.locking=off,id=dd_1 \
-device scsi-hd,drive=dd_1,id=disk_1,logical_block_size=512,physical_block_size=512 \
```

格式化磁盘，具体的选项使用`man mkfs.minix`查看：
```sh
mkfs.minix -3 /dev/sda
```

挂载文件系统：
```sh
mount -t minix /dev/sda /mnt
```

或者格式化文件，通过loop设备挂载，注意这时需要打开`CONFIG_BLK_DEV_LOOP`配置。