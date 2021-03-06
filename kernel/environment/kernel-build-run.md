[toc]

# `dump_stack` 的输出都是问号的解决办法

```shell
# 回退这个补丁
f1d9a2abff66 x86/unwind/orc: Don't skip the first frame for inactive tasks
```

# 根文件系统

fedora server 安装时， 根文件系统一定不能使用 LVM

```shell
sudo apt-get install libelf-dev libssl-dev -y
# 在 Virtual Machine Manager 中创建 qcow2 格式，会马上分配所有空间，所以需要在命令行中创建 qcow2
qemu-img create -f qcow2 fedora34-server.qcow2 512G
# -p 显示进度， -f 源镜像格式， -O 转换后的格式， 后面再紧接的是：源文件名称，转换后的文件名称
qemu-img convert -p -f raw -O qcow2 fedora34-server.raw fedora34-server.qcow2
# allow virbr0
sudo vim /etc/qemu/bridge.conf
# 备份, -F 源文件格式, 注意有些qemu-img版本源文件和目标文件都要指定绝对路径
qemu-img create -F qcow2 -b /home/sonvhi/chenxiaosong/qemu-kernel/base_image/fedora26-server.qcow2 -f qcow2 image.qcow2
```

```shell
# fedora 启动的时候等待： A start job is running for /dev/zram0，解决办法：删除 zram 的配置文件
mv /usr/lib/systemd/zram-generator.conf /usr/lib/systemd/zram-generator.conf.bak

# fedora26 安装 vim 前，先升级
sudo dnf update vim-common vim-minimal -y
```

# 9p

9p: https://wiki.qemu.org/Documentation/9psetup

```
CONFIG_NET_9P=y
CONFIG_NET_9P_VIRTIO=y
CONFIG_NET_9P_DEBUG=y (Optional)
CONFIG_9P_FS=y
CONFIG_9P_FS_POSIX_ACL=y
CONFIG_PCI=y
CONFIG_VIRTIO_PCI=y
```

# 启动时指定ip

```shell
[root@192 ~]# cat /lib/systemd/system/qemu-vm-setup.service
[Unit]
Description=QEMU VM Setup

[Service]
Type=oneshot
ExecStart=/root/qemu-vm-setup.sh

[Install]
WantedBy=default.target
```

```shell
[root@192 ~]# cat qemu-vm-setup.sh 
#!/bin/sh

dev=$(ip link show | awk '/^[0-9]+: en/ {sub(":", "", $2); print $2}')
ip=$(awk '/IP=/ { print gensub(".*IP=([0-9.]+).*", "\\1", 1) }' /proc/cmdline)

if test -n "$ip"
then
	gw=$(echo $ip | sed 's/[.][0-9]\+$/.1/g')
	ip addr add $ip/24 dev $dev
	ip link set dev $dev up
	ip route add default via $gw dev $dev
fi
```

# 挂载 qcow2

https://www.jianshu.com/p/6b977c02bfb2

```shell
sudo apt-get install qemu-utils -y

sudo modprobe nbd max_part=8
sudo qemu-nbd --connect=/dev/nbd0 fedora26-server.qcow2 
sudo fdisk /dev/nbd0 -l
sudo mount /dev/nbd0p1 mnt/
sudo umount mnt
sudo qemu-nbd --disconnect /dev/nbd0
sudo modprobe -r nbd
```

# xfstests环境

```shell
yum install libtool -y
yum install libuuid-devel -y
yum install xfsprogs-devel -y
yum install libacl-devel -y
```

# 免密ssh

```shell
# 在物理机中
ssh-keygen
ssh-copy-id root@192.168.122.87
```

# 源码安装 qemu

源码安装 qemu：
```shell
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

git clone https://gitlab.com/qemu-project/qemu.git
git submodule init
git submodule update --recursive
mkdir build
cd build/
../configure --enable-kvm --enable-virtfs --prefix=/home/sonvhi/chenxiaosong/sw/qemu/

# 非root用户没有权限的解决办法
sudo chown root libexec/qemu-bridge-helper
sudo chmod u+s libexec/qemu-bridge-helper
sudo usermod -a -G kvm sonvhi # 访问 /dev/kvm, 好像无效
sudo chmod 666 /dev/kvm

mkdir etc/qemu -p
vim etc/qemu/bridge.conf # 添加　allow virbr0
```

# 源码安装 gcc

下载gcc：https://ftp.gnu.org/gnu/gcc/

下载依赖(gmp-6.2.1.tar.bz2  mpc-1.2.1.tar.gz  mpfr-4.1.0.tar.bz2)： https://gcc.gnu.org/pub/gcc/infrastructure/

```shell
yum install texinfo gmp-devel mpfr-devel -y # centos6
sudo apt install libmpfr-dev libgmp-dev libmpc-dev libzstd-dev -y # ubuntu22.04

# 源码安装依赖库
../configure --prefix=/home/sonvhi/chenxiaosong/sw/gmp-6.2.1
../configure --prefix=/home/sonvhi/chenxiaosong/sw/mpfr-4.1.0 --with-gmp=/home/sonvhi/chenxiaosong/sw/gmp-6.2.1
../configure --prefix=/home/sonvhi/chenxiaosong/sw/mpc-1.2.1 --with-gmp=/home/sonvhi/chenxiaosong/sw/gmp-6.2.1 --with-mpfr=/home/sonvhi/chenxiaosong/sw/mpfr-4.1.0/

../configure --prefix=/home/sonvhi/chenxiaosong/sw/gcc --enable-languages=c,c++ --disable-multilib --with-gmp=/home/sonvhi/chenxiaosong/sw/gmp-6.2.1 --with-mpfr=/home/sonvhi/chenxiaosong/sw/mpfr-4.1.0/ --with-mpc=/home/sonvhi/chenxiaosong/sw/mpc-1.2.1/ # --enable-threads=posix --with-system-zlib
```

# 源码安装 multipath-tools

```shell
yum install json-c-devel -y
yum install userspace-rcu-devel -y
git clone https://github.com/opensvc/multipath-tools.git
```

# debian rootfs

参考:
https://blog.csdn.net/chengbeng1745/article/details/81271024
https://www.twblogs.net/a/5e5f6067bd9eee211685777c

arm32 在 linux 仓库中执行　`make dtbs` 生成 dtb 文件

`/etc/ssh/sshd_config` 修改以下内容:
```
PermitRootLogin yes
PasswordAuthentication yes
PermitEmptyPasswords yes
```

物理机中创建网络：
```shell
sudo apt-get install uml-utilities -y # tunctl 命令，　centos９没有
qemu-system-arm -net nic,model=? -M vexpress-a15 # 查看支持的虚拟网络
sudo tunctl -b # 按顺序创建 tap0 tap1
sudo tunctl -t tap0 -u sonvhi
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

centos9中没有 `tunctl`:
```shell
sudo ip tuntap add tap0 mode tap user sonvhi
sudo ip tuntap del tap0 mode tap
sudo ip tuntap list
```

bullseye aarch64 `/etc/network/interfaces` 需要把 `eth0` 改成 `enp0s1`(通过`dmesg | grep -i eth`找到`enp0s1`)

```shell
apt-get install qemu qemu-kvm bridge-utils qemu-system -y
```

# mod_cfg.sh

```shell
if [ "$1" = "" ]
then
        echo "please specify version"
        exit 1
fi
mnt_point=/tmp/9p
mkdir $mnt_point
mkdir /lib/modules -p
mount -t 9p -o trans=virtio 9p $mnt_point
knl_vers=$(uname -r)
target=${mnt_point}/code/$1/mod/lib/modules/${knl_vers}
link_name=/lib/modules/${knl_vers}
rm ${link_name} -rf
ln -s ${target} ${link_name}
```

# docker

```shell
docker image ls
docker run --rm -v "$PWD":/usr/src/myapp -w /usr/src/myapp centos-7.5-kernel:latest make
docker run -0-rm it -v $PWD:/usr/src/myapp -w /usr/src/myapp centos-7.5-kernel:latest bash # 进入docker bash
```
