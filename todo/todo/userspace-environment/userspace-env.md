[toc]

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

# 源码安装软件

## 源码编译 emacs

https://github.com/emacs-mirror/emacs/blob/master/INSTALL

```shell
./autogen.sh
mkdir build && cd build
../configure --prefix=xxx --with-xxx=no
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
