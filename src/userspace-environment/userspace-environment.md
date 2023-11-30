[点击这里跳转到陈孝松个人主页:chenxiaosong.com](http://chenxiaosong.com/)。

这篇文章记录一下各个常用Linux发行版的软件安装与配置，方便日后查阅。

# BIOS设置

我用的主板是和Linus同款的“技嘉Aorus”，有时会抽风恢复默认的BIOS出厂设置，在BIOS的“easy mode”中把“X.M.P. Disabled”改为“X.M.P.-DDR4-3600 18-22-22-42-64-1.35V”。然后点击右下角的“Advanced Mode(F2)”进入“Advanced Mode”，“Tweaker -> Advanced CPU Settings -> SVM Mode”改为 “Enabled”开启硬件虚拟化配置。

# 双系统grub设置

grub的配置文件：[src/userspace-environment/boot-efi-EFI](https://github.com/chenxiaosonggithub/blog/tree/master/src/userspace-environment/boot-efi-EFI)，在操作系统中的路径为`/boot/efi/EFI/{ubuntu,centos}/grub.cfg`。

centos9 grub设置：
```sh
blkid # 打印 uuid
vim /boot/efi/EFI/centos/grub.cfg # 更改 uuid, set prefix=($dev)/　后接正确的路径
grub2-mkconfig -o /boot/grub2/grub.cfg # centos9使用的是grub2
```

ubuntu22.04 grub设置，修改配置`/boot/efi/EFI/ubuntu/grub.cfg`：
```sh
search.fs_uuid 22bac2d6-b556-4158-8244-fba87a8a34c3 root # 用 blkid 查看 uuid
set prefix=($root)'/boot/grub'
configfile $prefix/grub.cfg
```

更改启动界面选择系统的超时时间：
```sh
vim /etc/default/grub # GRUB_TIMEOUT=5
```

# ubuntu22.04

我平时工作用的是ubuntu桌面系统。

常用的软件安装：
```sh
sudo apt install build-essential -y # 编译所需的常用软件，如gcc等
sudo apt-get install qemu qemu-kvm virt-manager qemu-system -y # 虚拟机相关软件，可能需要重启才能以非root用户启动virt-manager
sudo apt install flex bison -y # 内核编译所需
sudo apt-get install libelf-dev libssl-dev -y # 内核源码编译依赖的库
sudo apt install libncurses-dev -y # make menuconfig所依赖的库
apt-get install bc -y # 内核编译报错/bin/sh: 1: bc: not found
sudo apt install bridge-utils -y # brctl命令

apt install bash-completion -y # docker 中git不会自动补全
sudo apt install openssh-server -y # 默认桌面版本ubuntu不会安装ssh server
sudo apt install ibus*wubi* -y # 安装五笔，要重启才可用
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

strings /lib/x86_64-linux-gnu/libc.so.6 |grep GLIBC_ # 查看glibc的版本，docker中无法编译有些低版本的内核代码

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

如果没有挂载`/tmp`目录，可以修改`/etc/fstab`文件：
```sh
# defaults: 使用默认的挂载选项。
# noatime: 不更新文件的访问时间戳。
# nosuid: 不允许设置文件的 SUID 位。
# nodev: 不允许设备文件。
# noexec: 不允许执行二进制文件。
# mode=1777: 设置目录的权限为 1777，确保它是可写的临时目录。
tmpfs /tmp tmpfs defaults,noatime,nosuid,nodev,noexec,mode=1777,size=20G 0 0
```

如果内存比较小，可以添加swap：
```sh
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
ls -lh /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo swapon -s
sudo vi /etc/fstab # 在/etc/fstab最后一行添加 /swapfile  none  swap  sw  0  0
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


