# 1. 根文件系统

## 1.1. 脚本

进入目录[src/kernel-environment](https://github.com/chenxiaosonggithub/blog/tree/master/src/kernel-environment)，选择相应的cpu架构，如[src/kernel-environment/x86_64](https://github.com/chenxiaosonggithub/blog/tree/master/src/kernel-environment/x86_64)。执行[src/kernel-environment/x86_64/create-raw.sh](https://github.com/chenxiaosonggithub/blog/blob/master/src/kernel-environment/x86_64/create-raw.sh)生成raw格式的镜像，这个脚本会调用到[src/kernel-environment/create-debian.sh](https://github.com/chenxiaosonggithub/blog/blob/master/src/kernel-environment/create-debian.sh)，是从[syzkaller的脚本](https://github.com/google/syzkaller/blob/master/tools/create-image.sh)经过修改而来。

注意riscv64架构的镜像，可以直接下载[ubuntu2204](https://ubuntu.com/download/risc-v)（选择[QEMU emulator]）。

生成raw格式镜像后，再执行以下命令转换为qcow2格式：
```sh
# -p 显示进度， -f 源镜像格式， -O 转换后的格式， 后面再紧接的是：源文件名称，转换后的文件名称
qemu-img convert -p -f raw -O qcow2 image.raw image.qcow2
```

再执行脚本[src/kernel-environment/link-scripts.sh](https://github.com/chenxiaosonggithub/blog/blob/master/src/kernel-environment/link-scripts.sh)把脚本链接到相应的目录，执行[src/kernel-environment/x86_64/update-base.sh](https://github.com/chenxiaosonggithub/blog/blob/master/src/kernel-environment/x86_64/update-base.sh)启动虚拟机更新镜像，再执行[src/kernel-environment/x86_64/create-qcow2.sh](https://github.com/chenxiaosonggithub/blog/blob/master/src/kernel-environment/x86_64/create-qcow2.sh)生成指向基础镜像的qcow2镜像。

## 1.2. 镜像制作

如果要用作qemu虚拟机镜像，发行版安装时，不要使用LVM：

以下是一些常用的命令：
```sh
# 在 Virtual Machine Manager 中创建 qcow2 格式，会马上分配所有空间，所以需要在命令行中创建 qcow2
qemu-img create -f qcow2 image.qcow2 512G
# 确认文件的格式
file image.raw
# -p 显示进度， -f 源镜像格式， -O 转换后的格式， 后面再紧接的是：源文件名称，转换后的文件名称
qemu-img convert -p -f raw -O qcow2 image.raw image.qcow2
# 添加allow virbr0
sudo vim /etc/qemu/bridge.conf
# 备份, -F 源文件格式, 注意<有些版本的qemu-img>要求源文件和目标文件都要指定绝对路径
qemu-img create -F qcow2 -b /path/base.qcow2 -f qcow2 /path/image.qcow2
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

# 1.3. 虚拟机处理

进入fedora虚拟机后：
```sh
# fedora 启动的时候等待： A start job is running for /dev/zram0，解决办法：删除 zram 的配置文件
mv /usr/lib/systemd/zram-generator.conf /usr/lib/systemd/zram-generator.conf.bak
# fedora26 安装 vim 前，先升级
sudo dnf update vim-common vim-minimal -y
```

当启用了9p文件系统，就可以把宿主机的modules目录共享给虚拟机，具体参考[Documentation/9psetup](https://wiki.qemu.org/Documentation/9psetup)。虚拟机中执行脚本[src/kernel-environment/mod-cfg.sh](https://github.com/chenxiaosonggithub/blog/blob/master/src/kernel-environment/mod-cfg.sh)挂载和链接模块目录。


# 2. qemu安装与配置

## 2.1. 源码安装 qemu

先安装编译qemu所需的软件：
```sh
# ubuntu 22.04
sudo apt-get install libattr1-dev libcap-ng-dev -y
sudo apt install ninja-build -y
sudo apt-get install libglib2.0-dev -y
sudo apt-get install libpixman-1-dev -y

# centos 9
sudo dnf install glib2-devel -y
sudo dnf install iasl -y
sudo dnf install pixman-devel -y
sudo dnf install libcap-ng-devel -y
sudo dnf install libattr-devel -y

# centos 9才需要，　http://re2c.org/
git clone https://github.com/skvadrik/re2c.git
./autogen.sh
./configure  --prefix=/home/sonvhi/chenxiaosong/sw/re2c
make && make install

# centos 要安装 ninja, https://ninja-build.org/
git clone https://github.com/ninja-build/ninja.git && cd ninja
./configure.py --bootstrap

# centos9, https://sparse.docs.kernel.org/en/latest/
git clone git://git.kernel.org/pub/scm/devel/sparse/sparse.git
make
```

再下载编译qemu：
```sh
git clone https://gitlab.com/qemu-project/qemu.git
git submodule init
git submodule update --recursive
mkdir build
cd build/
../configure --enable-kvm --enable-virtfs --prefix=/home/sonvhi/chenxiaosong/sw/qemu/
```

## 2.2. qemu配置

非root用户没有权限的解决办法：
```shell
# 如果是apt安装的，文件位置 /usr/lib/qemu/qemu-bridge-helper
sudo chown root libexec/qemu-bridge-helper
sudo chmod u+s libexec/qemu-bridge-helper
groups | grep kvm
sudo usermod -aG kvm $USER
su - $USER # 或退出shell重新登录, 但在tmux中不起作用

mkdir etc/qemu -p
# 如果是apt安装的，文件位置 /etc/qemu/bridge.conf
vim etc/qemu/bridge.conf # 添加　allow virbr0
```

# 3. arm32架构

