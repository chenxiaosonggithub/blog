# ubuntu22.04环境

我平时工作用的是ubuntu桌面系统。

常用的软件安装：
```sh
sudo apt install build-essential -y # 编译所需的常用软件，如gcc等
sudo apt-get install qemu qemu-kvm virt-manager qemu-system -y # 虚拟机相关软件，可能需要重启才能以非root用户启动virt-manager
sudo apt install flex bison -y # 内核编译所需
sudo apt-get install libelf-dev libssl-dev -y # 内核源码编译依赖的库
sudo apt install libncurses-dev -y # make menuconfig所依赖的库
apt-get install bc -y # 内核编译报错/bin/sh: 1: bc: not found

apt install bash-completion -y # docker 中git不会自动补全
sudo apt install openssh-server -y # 默认桌面版本ubuntu不会安装ssh server
sudo apt install ibus*wubi* -y # 安装五笔，要重启才可用
sudo apt install bridge-utils -y # 不确定是否为虚拟机需要的
sudo apt-get install fuse -y # v2ray的Linux桌面版本 V2Ray-Desktop-v2.4.0-linux-x86_64.AppImage 无法运行
sudo apt install tmux -y # Tmux（缩写自"Terminal Multiplexer"）是一个在命令行界面下运行的终端复用工具，我主要是用tmux的会话附加和分离功能

sudo apt install gcc-arm-linux-gnueabi gcc-arm-linux-gnueabihf -y # arm32的交叉编译软件
sudo apt install gcc-riscv64-linux-gnu -y # riscv交叉编译软件
sudo apt install exfat-utils -y # exfat文件系统所需的工具

# 安装查看tcpdump工具收集的网络包的wireshark： https://launchpad.net/~wireshark-dev/+archive/ubuntu/stable
sudo add-apt-repository ppa:wireshark-dev/stable
sudo apt update
sudo apt install wireshark -y

sudo apt install samba -y # 在virt-manager中安装windows或macos时，与Linux宿主机共享文件用samba（就是cifs或smb）比较方便
sudo systemctl restart smbd.service # 重启cifs server

sudo apt install bridge-utils -y # TODO: 不确定是否为虚拟机需要的

# 安装游戏软件stem时需要安装的依赖软件，但steam里的游戏在ubuntu下根本跑不动（我在戴尔笔记本xps13上试过cs非常卡）
sudo apt install libc6-i386 libgl1:i386 -y # for steam
```

设置hostname:
```sh
sudo hostnamectl set-hostname Threadripper-Ubuntu2204
```

新建或删除用户：
```sh
sudo useradd -s /bin/bash -d /home/test -m test # 新建用户test
sudo userdel -r test # 删除用户test，-r选项代表同时删除用户的家目录和相关文件
```

# centos 9

centos的开发软件生态比ubuntu还是稍微差一些，尤其是桌面系统。

常用软件安装：
```shell
sudo dnf groupinstall "development tools" -y # 编译常用软件
sudo dnf install qemu-kvm virt-manager libvirt -y # 虚拟机相关软件
sudo systemctl restart libvirtd # 需要重启libvirtd，否则虚拟机有些功能无法使用
sudo dnf install ncurses-devel -y # 内核编译所需

# centos9需要通过源码安装bridge-utils，https://wiki.linuxfoundation.org/networking/bridge
git clone -b main git://git.kernel.org/pub/scm/network/bridge/bridge-utils.git
cd bridge-utils
autoconf
./configure
```

设置hostname:
```sh
sudo hostnamectl set-hostname Threadripper-CentOS9
```

默认centos9是打开selinux的，但个人用户没有那么高的安全需求时，可以关闭selinux:
```sh
sudo vim /etc/selinux/config # centos9 改成 SELINUX=disabled
```

自动挂载磁盘，修改配置文件`/etc/fstab`，添加：
```sh
# 最后２个参数（0 0）的意义： dump, fsck
UUID=b7aa1308-f57e-4f28-834c-c463237a8383 /home/sonvhi/sonvhi/   ext4    errors=remount-ro    0       0
```

# fedora

fedora更新太频繁了，不稳定，不建议用作开发的系统。

安装软件：
```shell
sudo yum install openssl dwarves zstd ncurses-devel -y # 内核编译所需
```


