我刚接触内核领域主要研究的方向是网络文件系统（nfs、cifs），对块文件系统的了解并不多，所以就从代码量比较小的minix文件系统学起。

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

# 支持长文件名

我们来看一个有趣的问题：让minix文件系统（v3）支持最大长度4095字节的文件名。

当我们使用`touch`命令创建一个4090字节长度的文件时，会执行到`minix_lookup`函数。而当创建一个4091字节长度的文件时，不会执行到`minix_lookup`函数，说明在`vfs`已经拦截了。

所以当要支持4095字节长度时，要在`vfs`做修改。而大部分文件系统支持的最大文件名长度为255字节，所以我们可以这样设计：当文件名（普通文件和文件夹）大于255字节时，在`vfs`对文件名做hash计算，当文件名（普通文件和文件夹）大于minix v3文件系统最大支持的60字节时（详细代码请看`minix_fill_super`函数），在minix文件系统对文件名做hash计算。

