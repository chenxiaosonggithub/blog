[toc]

# 反向ssh

https://cloud.tencent.com/developer/article/1722055

内网电脑 A 通过公网 server 登录到另一个内网电脑 B

内网电脑B autossh:
```shell
# https://www.harding.motd.ca/autossh/ # centos9源码安装
sudo apt install autossh -y # ubuntu2204
```

```shell
ssh -NfR 55555:localhost:22 root@chenxiaosong.com # 在内网电脑 B 上执行, chenxiaosong.com 为公网 server
ssh chenxiaosong.com # 在内网电脑 A 上执行, 登录到公网 server
ssh -p 12345 root@localhost # 在公网 server 上执行, 登录到内网电脑 B
```

在内网电脑 B 中设置开机启动 ssh-reverse, `/lib/systemd/system/ssh-reverse.service`:
```shell
[Unit]
Description=ssh reverse
StartLimitIntervalSec=0

[Service]
Type=forking
ExecStart=autossh -M 55556 -Nf -R 55555:localhost:22 -R 8888:localhost:8888 root@chenxiaosong.com
Restart=always
RestartSec=1

[Install]
WantedBy=multi-user.target
```
```shell
sudo -i # 切换成 root, 因为开机运行 ssh-reverse 是 root 用户
ssh-keygen
ssh-copy-id root@chenxiaosong.com

sudo setenforce 0 # centos9
sudo vim /etc/selinux/config # centos9 改成 SELINUX=permissive
sudo systemctl enable ssh-reverse
sudo systemctl restart ssh-reverse
```

server:
```shell
vim /etc/ssh/sshd_config # GatewayPorts yes
systemctl restart sshd # 重启ssh
```

内网电脑 B, 在`/etc/bashrc`或`/etc/bash.bashrc`(通过`/etc/profile`查看到底是哪个文件)中添加：
```shell
AUTOSSH_POLL=60
```

# 内网穿透

ssh反向隧道还可以用于内网穿透，比如把内网linux的mysql端口暴露到公网上：
```shell
# ssh -R <公网服务器IP>:<公网端口>:localhost:<MySQL端口> <公网服务器用户名>@<公网服务器IP>
ssh -R hk.chenxiaosong.com:22222:localhost:3306 root@hk.chenxiaosong.com
ssh -N -R 22222:localhost:3306 root@hk.chenxiaosong.com # -M：启用控制台功能, -N：不执行远程命令
# ssh -N -R 远程端口1:目标主机1:目标端口1 -R 远程端口2:目标主机2:目标端口2 用户名@远程主机
ssh -N -R 3306:localhost:3306 -R 6379:localhost:6379 -R 5001:localhost:5001 -R 5002:localhost:5002 root@hk.chenxiaosong.com # 多个映射
```

通过访问`hk.chenxiaosong.com`的`22222`端口就能访问到内网mysql的`3306`端口。

# efi grub 选择系统

```shell
cd /boot/efi/EFI/centos # centos为启动盘
blkid # 打印 uuid
vim grub.cfg # 更改 uuid, set prefix=($dev)/　后接正确的路径
vim /etc/default/grub # GRUB_TIMEOUT=5

grub2-mkconfig -o /boot/grub2/grub.cfg # centos9
grub-mkconfig -o /boot/grub/grub.cfg # ubuntu2204
```

# ubuntu 22.04

```shell
sudo apt install openssh-server -y
sudo apt install build-essential -y
sudo apt-get install qemu qemu-kvm virt-manager qemu-system -y # 可能需要重启才能以非root用户启动virt-manager
sudo apt install flex bison -y
sudo apt-get install libelf-dev libssl-dev -y # 内核源码编译依赖的库
sudo apt install libncurses-dev -y # make menuconfig
apt-get install bc -y # 内核编译报错/bin/sh: 1: bc: not found
    
sudo apt install ibus*wubi* -y # 要重启
sudo apt install bridge-utils -y # 不确定是否虚拟机需要的
sudo apt-get install fuse -y # V2Ray-Desktop-v2.4.0-linux-x86_64.AppImage 无法运行
sudo apt install tmux -y

sudo apt install samba -y
sudo systemctl restart smbd.service

sudo useradd -s /bin/bash -d /home/test -m test
# sudo userdel -r test # 删除用户

sudo apt install libc6-i386 libgl1:i386 -y # steam

sudo hostnamectl set-hostname Threadripper-Ubuntu2204

sudo apt install gcc-arm-linux-gnueabi gcc-arm-linux-gnueabihf -y

sudo apt install gcc-riscv64-linux-gnu -y

sudo apt install exfat-utils -y

# https://launchpad.net/~wireshark-dev/+archive/ubuntu/stable
sudo add-apt-repository ppa:wireshark-dev/stable
sudo apt update
sudo apt install wireshark -y
```

# centos 9

```shell
sudo dnf groupinstall "development tools" -y
sudo dnf install qemu-kvm virt-manager libvirt -y
sudo systemctl restart libvirtd
sudo dnf install ncurses-devel -y

# https://wiki.linuxfoundation.org/networking/bridge
git clone -b main git://git.kernel.org/pub/scm/network/bridge/bridge-utils.git
cd bridge-utils
autoconf
./configure

sudo hostnamectl set-hostname Threadripper-CentOS9

sudo vim /etc/selinux/config # centos9 改成 SELINUX=disabled

# 最后２个参数的意义：dump, fsck
sudo vim /etc/fstab # UUID=b7aa1308-f57e-4f28-834c-c463237a8383 /home/sonvhi/sonvhi/   ext4    errors=remount-ro 0       0
```

# centos6

```shell
vi /etc/sysconfig/network-scripts/ifcfg-eth0 # 删除　UUID　和　HWADDR
rm /etc/udev/rules.d/70-persistent-net.rules 
```

ubuntu22.04无法ssh到centos6：
```shell
ssh -oHostKeyAlgorithms=+ssh-dss root@192.168.122.14
```

无法安装软件的解决办法：
```shell
vi /etc/yum.repos.d/CentOS-Base.repo # 取消注释 baseurl=, 替换　mirror.centos.org　为　vault.centos.org
yum clean all # 清除原有yum缓存
yum makecache # （刷新缓存），　yum repolist all　或者这条命令
yum repolist all # （查看所有配置可以使用的文件，会自动刷新缓存），yum makecache　或者这条命令

yum groupinstall "Development Tools" -y
yum install ncurses-devel -y
```

# virtualbox

```shell
vboxmanage internalcommands sethduuid Fedora-Workstation-Live-x86_64-34-1.2.vmdk # 多个磁盘的 uuid 一样时无法同时新建虚拟机, 需要更新 uuid
vboxmanage list vms
VBoxManage modifyvm "fedora34" --nested-hw-virt on # 注意：前面一定不能加sudo
```

# virt-manager

Edit -> Preferences -> Enable XML editing 开启 xml 编辑

修改 xml 配置：
```xml
<cpu mode="host-passthrough" check="partial"/>
```

# tmpfs

```shell
sudo mount -t tmpfs -o size=64G syzkaller tmpfs/
```

# 免密ssh

```shell
# 在物理机中
ssh-keygen
ssh-copy-id root@192.168.122.87
```

# 源码安装软件

## 源码编译 emacs

https://github.com/emacs-mirror/emacs/blob/master/INSTALL

```shell
./autogen.sh
mkdir build && cd build
../configure --prefix=xxx --with-xxx=no
```

## 源码安装 strace

```shell
./bootstrap
mkdir build && cd build
../configure --enable-mpers=no
make
```

## 源码安装 gdb

```shell
apt update -y
apt install python-dev -y # is not available
apt install python3-dev -y
apt install libgmp-dev libmpfr-dev -y
apt install texinfo -y

git clone https://sourceware.org/git/binutils-gdb.git
mkdir build && cd build
../configure --with-python=/usr/bin/ --prefix=/home/sonvhi/chenxiaosong/sw/gdb
make -j128
make install
```

## 源码安装 gcc

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

## 源码安装 multipath-tools

```shell
yum install json-c-devel -y
yum install userspace-rcu-devel -y
git clone https://github.com/opensvc/multipath-tools.git
```
