[toc]

# 镜像制作

如果要用作qemu虚拟机镜像，发行版安装时，不要使用LVM：

以下是一些常用的命令：
```sh
# 在 Virtual Machine Manager 中创建 qcow2 格式，会马上分配所有空间，所以需要在命令行中创建 qcow2
qemu-img create -f qcow2 image.qcow2 512G
# 确认两个文件的格式
file image.raw image.qcow2
# -p 显示进度， -f 源镜像格式， -O 转换后的格式， 后面再紧接的是：源文件名称，转换后的文件名称
qemu-img convert -p -f raw -O qcow2 image.raw image.qcow2
# 添加allow virbr0
sudo vim /etc/qemu/bridge.conf
# 备份, -F 源文件格式, 注意<有些版本的qemu-img>要求源文件和目标文件都要指定绝对路径
qemu-img create -F qcow2 -b /path/image.qcow2 -f qcow2 /path/image.qcow2
```

qcow2格式镜像的挂载：
```shell
sudo apt-get install qemu-utils -y # 安装工具软件
sudo modprobe nbd max_part=8 # 加载nbd模块
sudo qemu-nbd --connect=/dev/nbd0 image.qcow2 # 连接镜像
sudo fdisk /dev/nbd0 -l # 查看分区
sudo mount /dev/nbd0p1 mnt/ # 挂载分区
sudo umount mnt # 操作完后，卸载分区
sudo qemu-nbd --disconnect /dev/nbd0 # 断开连接
sudo modprobe -r nbd # 移除模块
```

# 虚拟机处理

进入fedora虚拟机后：
```sh
# fedora 启动的时候等待： A start job is running for /dev/zram0，解决办法：删除 zram 的配置文件
mv /usr/lib/systemd/zram-generator.conf /usr/lib/systemd/zram-generator.conf.bak
# fedora26 安装 vim 前，先升级
sudo dnf update vim-common vim-minimal -y
```

当启用了9p文件系统，就可以把宿主机的modules目录共享给虚拟机，具体参考[Documentation/9psetup](https://wiki.qemu.org/Documentation/9psetup)。
