
# 0. 模拟器与虚拟机

Bochs：x86硬件平台的开源模拟器，帮助文档少，只能模拟x86处理器。

QEMU：quick emulation，高速度、跨平台的开源模拟器，能模拟x86、arm等处理器，与Linux的KVM配合使用，能达到与真实机接近的速度。

第1类虚拟机监控程序：直接在主机硬件上运行，直接向硬件调度资源，速度快。如Linux的KVM（免费）、Windows的Hyper-V（收费）。

第2类虚拟机监控程序：在常规操作系统上以软件层或应用的形式运行，速度慢。如Vmware Workstation、Oracal VirtualBox。

# 1. 根文件系统

## 1.1. 脚本

进入目录[src/kernel-environment](https://gitee.com/chenxiaosonggitee/blog/tree/master/src/kernel-environment)，选择相应的cpu架构，如[src/kernel-environment/x86_64](https://gitee.com/chenxiaosonggitee/blog/tree/master/src/kernel-environment/x86_64)。执行[src/kernel-environment/x86_64/create-raw.sh](https://gitee.com/chenxiaosonggitee/blog/blob/master/src/kernel-environment/x86_64/create-raw.sh)生成raw格式的镜像，这个脚本会调用到[src/kernel-environment/create-debian.sh](https://gitee.com/chenxiaosonggitee/blog/blob/master/src/kernel-environment/create-debian.sh)，是从[syzkaller的脚本](https://github.com/google/syzkaller/blob/master/tools/create-image.sh)经过修改而来。

注意riscv64架构的镜像，可以直接下载[ubuntu2204](https://ubuntu.com/download/risc-v)（选择[QEMU emulator]）。

生成raw格式镜像后，再执行以下命令转换为qcow2格式：
```sh
# -p 显示进度， -f 源镜像格式， -O 转换后的格式， 后面再紧接的是：源文件名称，转换后的文件名称
qemu-img convert -p -f raw -O qcow2 image.raw image.qcow2
```

再执行脚本[src/kernel-environment/link-scripts.sh](https://gitee.com/chenxiaosonggitee/blog/blob/master/src/kernel-environment/link-scripts.sh)把脚本链接到相应的目录，执行[src/kernel-environment/x86_64/update-base.sh](https://gitee.com/chenxiaosonggitee/blog/blob/master/src/kernel-environment/x86_64/update-base.sh)启动虚拟机更新镜像，再执行[src/kernel-environment/x86_64/create-qcow2.sh](https://gitee.com/chenxiaosonggitee/blog/blob/master/src/kernel-environment/x86_64/create-qcow2.sh)生成指向基础镜像的qcow2镜像。

介绍完脚本，下面再介绍一下具体的命令。

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

## 1.3. 虚拟机处理

在系统启动界面登录进去后（而不是以ssh登录），默认的窗口大小不会自动调整，需要手动调整：
```sh
stty size # 可以先在其他窗口查看大小
echo "stty rows 54 cols 229" > stty.sh
. stty.sh
```

当启用了9p文件系统，就可以把宿主机的modules目录共享给虚拟机，具体参考[Documentation/9psetup](https://wiki.qemu.org/Documentation/9psetup)。虚拟机中执行脚本[src/kernel-environment/mod-cfg.sh](https://gitee.com/chenxiaosonggitee/blog/blob/master/src/kernel-environment/mod-cfg.sh)挂载和链接模块目录，注意`/lib/modules/$(uname -r)`是软链接，无法使用`modprobe <ko名>`命令，只能使用`inmod <ko的绝对路径>`。

root免密登录，`/etc/ssh/sshd_config` 修改以下内容:
```
PermitRootLogin yes
PasswordAuthentication yes
PermitEmptyPasswords yes
```

进入fedora虚拟机后：
```sh
# fedora 启动的时候等待： A start job is running for /dev/zram0，解决办法：删除 zram 的配置文件
mv /usr/lib/systemd/zram-generator.conf /usr/lib/systemd/zram-generator.conf.bak
# fedora26 安装 vim 前，先升级
sudo dnf update vim-common vim-minimal -y
# [xfstests-dev](https://git.kernel.org/pub/scm/fs/xfs/xfstests-dev.git/)
yum install libtool libuuid-devel xfsprogs-devel libacl-devel -y
```

## 1.4. 启动

如果你自己编译内核，启动时指定内核，可以参考[这个脚本](https://gitee.com/chenxiaosonggitee/blog/blob/master/src/kernel-environment/x86_64/update-base.sh)（链接中的`x86_64`可以替换成其他架构）中的命令。

如果你的镜像是一个完整的镜像，不想指定内核，就想用镜像本身自带的内核，可以把上面脚本中命令的`-kernel`和`-append`选项删除。

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
```sh
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

在 linux 仓库中执行　`make dtbs` 生成 dtb 文件

ubuntu2204宿主机中创建网络：
```sh
sudo apt-get install uml-utilities -y # tunctl 命令，　centos９没有
qemu-system-arm -net nic,model=? -M vexpress-a15 # 查看支持的虚拟网络
sudo tunctl -b # 按顺序创建 tap0 tap1，每输入一次命令创建一个
sudo tunctl -t tap0 -u sonvhi # 指定名称创建
sudo tunctl -t tap1 -u sonvhi
sudo ip link set tap0 up # 激活
sudo ip link set tap1 up # 激活
sudo tunctl -d tap1 # 删除 tap1
sudo brctl show # 查看网桥
sudo brctl addif virbr0 tap0 # tap0 加入网桥
sudo brctl addif virbr0 tap1 # tap1 加入网桥
sudo brctl delif virbr0 tap0 # tap0 移出网桥

sudo brctl addbr br0 # 新建网桥 br0
sudo brctl delbr br0 # 删除网桥 br0
sudo brctl addif br0 enx381428b8c32c # 注意:无线网卡不行, 必须是以太网卡
sudo brctl addif br0 tap0 # tap0 加入网桥
```

centos9宿主机中没有 `tunctl`的解决办法:
```sh
sudo ip tuntap add tap0 mode tap user sonvhi
sudo ip tuntap del tap0 mode tap
sudo ip tuntap list
```

bullseye aarch64 网络无法使用， `/etc/network/interfaces` 需要把 `eth0` 改成 `enp0s1`(通过`dmesg | grep -i eth`找到`enp0s1`)

# 4. riscv ubuntu2204镜像

riscv64架构的镜像，可以直接下载[ubuntu2204](https://ubuntu.com/download/risc-v)（选择[QEMU emulator]）。

```sh
qemu-system-riscv64 -netdev ? # 宿主机中查看可用的netdev backend类型
```

虚拟机中修改配置：
```sh
systemctl status systemd-modules-load.service # 查看systemd-modules-load服务状态
# 删除systemd-modules-load服务，怕万一后续有用，只做重命名
mv /lib/systemd/system/systemd-modules-load.service /lib/systemd/system/systemd-modules-load.service.bak

cp /etc/fstab /etc/fstab.bak # 备份
vim /etc/fstab # 删除　LABEL=UEFI 一行
```

# 5. openeuler

[openEuler 22.03 LTS SP2（或更新的版本）](https://www.openeuler.org/en/download/?version=openEuler%2022.03%20LTS%20SP2)，Scenario选择“cloud computing”，下载`qcow2.xz`，解压：
```sh
xz -d openEuler-22.03-LTS-SP2-x86_64.qcow2.xz
```

qemu启动参数需要做一些小修改 `-append "... root=/dev/vda2 ..."`。

默认的登录账号是`root`，密码是 `openEuler12#$`。

注意需要打开`vfat`文件系统相关配置，具体查看[《微软文件系统》](http://chenxiaosong.com/fs/microsoft-fs.html)中`vfat`相关的一节。否则会进入emergency mode，如果你实在不想打开`vfat`文件系统相关配置，可以编辑`/etc/fstab`文件删除`/boot`相关的一行，重启系统就可以正常启动了，但不建议哈。