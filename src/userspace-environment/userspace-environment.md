这篇文章记录一下各个常用Linux发行版的软件安装与配置，方便日后查阅。

# BIOS设置

我用的主板是和Linus同款的“技嘉Aorus”，有时会抽风恢复默认的BIOS出厂设置，在BIOS的“easy mode”中把“X.M.P. Disabled”改为“X.M.P.-DDR4-3600 18-22-22-42-64-1.35V”。然后点击右下角的“Advanced Mode(F2)”进入“Advanced Mode”，“Tweaker -> Advanced CPU Settings -> SVM Mode”改为 “Enabled”开启硬件虚拟化配置。

另外再记录一下联想台式机进bios是按f1键。

# 双系统grub设置

grub的配置文件：[src/userspace-environment/boot-efi-EFI](https://gitee.com/chenxiaosonggitee/blog/tree/master/src/userspace-environment/boot-efi-EFI)，在操作系统中的路径为`/boot/efi/EFI/{ubuntu,centos}/grub.cfg`。

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

arm64版本下载：[ubuntu官方下载](http://cdimage.ubuntu.com/jammy/daily-live/current/), [南京大学开源镜像站](http://mirror.nju.edu.cn/ubuntu-cdimage/jammy/daily-live/current/)。

常用的软件安装：
```sh
sudo apt install build-essential -y # 编译所需的常用软件，如gcc等
sudo apt-get install qemu qemu-kvm virt-manager qemu-system -y # 虚拟机相关软件，可能需要重启才能以非root用户启动virt-manager
sudo apt install flex bison -y # 内核编译所需
sudo apt-get install libelf-dev libssl-dev -y # 内核源码编译依赖的库
sudo apt install libncurses-dev -y # make menuconfig所依赖的库
apt-get install bc -y # 内核编译报错/bin/sh: 1: bc: not found
sudo apt install bridge-utils -y # brctl命令
sudo apt-get install kmod -y # 编译内核报错： Warning: 'make modules_install' requires /sbin/depmod.
apt install pahole -y # 编译内核报错： .tmp_vmlinux.btf: pahole (pahole) is not available

apt install bash-completion -y # docker 中git不会自动补全
sudo apt install openssh-server -y # 默认桌面版本ubuntu不会安装ssh server
sudo apt install ibus*wubi* -y # 安装五笔，要重启才可用
sudo apt-get install fuse -y # v2ray的Linux桌面版本 V2Ray-Desktop-v2.4.0-linux-x86_64.AppImage 无法运行
sudo apt install tmux -y # Tmux（缩写自"Terminal Multiplexer"）是一个在命令行界面下运行的终端复用工具，我主要是用tmux的会话附加和分离功能
sudo apt install lxterminal -y # 这玩意儿比ubuntu默认的terminal更好用，是树莓派系统上默认的terminal

sudo apt install binutils-aarch64-linux-gnu -y # aarch64-linux-gnu-addr2line 等工具
sudo apt install gcc-aarch64-linux-gnu -y # aarch64-linux-gnu-gcc

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

默认`poweroff`和`reboot`等命令可以以非root权限运行，容易误操作，这些命令都软链接到`/bin/systemctl`, 可以用以下命令修改权限：
```sh
sudo chmod 700 /bin/systemctl
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

# 树莓派

从[Operating system images](https://www.raspberrypi.com/software/operating-systems/#raspberry-pi-os-64-bit)下载“Raspberry Pi OS with desktop and recommended software”。

向SD卡烧录系统：
```sh
sudo dd bs=4M if=解压之后的img of=/dev/sdb
```

图形界面的树莓派系统的常用软件安装：
```sh
# 解决git无法显示中文
git config --global core.quotepath false

# 安装五笔，需要重启
sudo apt-get update -y
sudo apt install ibus*wubi* -y

# 安装firefox
# sudo apt update -y
# sudo apt-get install iceweasel -y

sudo apt update -y
# 安装emacs
sudo apt install emacs -y
# 安装gvim
sudo apt install vim-gtk3 -y
```

含代理服务器选项，chrome浏览器启动命令：
```sh
chromium-browser --proxy-server="https=127.0.0.1:1080;http=127.0.0.1:1080;ftp=127.0.0.1:1080"
```

# 麒麟系统

<!-- 公司内网，服务器版本： https://172.30.13.199/release/Release/build/os/ISO/, 桌面版本： https://builder.kylin.com/ -->

填写[产品试用申请](https://www.kylinos.cn/support/trial.html)，以下是各个版本的下载地址：

- [Kylin-Server-V10-SP3-General-Release-2303-X86_64.iso](https://distro-images.kylinos.cn:8802/web_pungi/download/share/vYTMm38Pkaq0KRGzg9pBsWf2c16FUwJL/)
- [Kylin-Desktop-V10-SP1-General-Release-2303-X86_64.iso](https://distro-images.kylinos.cn:8802/web_pungi/download/share/b4vmX7qEk90dyBrFfS5ANpGngaW2hZUK/)
- [Kylin-Desktop-V10-SP1-HWE-Release-2303-X86_64.iso](https://distro-images.kylinos.cn:8802/web_pungi/download/share/hXaJrnQWscuN2YtS7VAZizRP0EFbH4y3/)
- [Kylin-Desktop-V10-SP1-General-Release-2303-ARM64.iso](https://distro-images.kylinos.cn:8802/web_pungi/download/share/M8UbGlg2WyeHnANzv0srJOEjC9R7ZXDx/)
- [Kylin-Desktop-V10-SP1-General-Release-2303-MIPS64el.iso](https://distro-images.kylinos.cn:8802/web_pungi/download/share/jWbeB9k6FLvySThKilrgX5QUd0cwYtHo/)
- [Kylin-Desktop-V10-SP1-General-Release-2303-LoongArch64.iso](https://distro-images.kylinos.cn:8802/web_pungi/download/share/k1TnrIxSJ5dt47bzAeiOF0upRslgV9hE/)
- [Kylin-Desktop-V10-SP1-General-Release-2303-SW64.iso](https://distro-images.kylinos.cn:8802/web_pungi/download/share/XiGHY0EBQSC8ehIqzfPwaxsRu72vo5VT/)
- [Kylin-Desktop-V10-SP1-2303-update1-Wayland-Release-General-kirin9006c-20230703-ARM64.iso](https://distro-images.kylinos.cn:8802/web_pungi/download/share/d8ug4oiGAQFR7lKsLYOa2tmS9jrW3XT1/)

注意麒麟系统在arm芯片的macos上无法用vmware fusion安装，可以用[UTM](https://github.com/utmapp/UTM)安装，从[github](https://docs.getutm.app/installation/macos/)上下载安装包。安装虚拟机时cpu、内存、硬盘不要分配太大，比如我用的是M2的Macbook Air（8G内存，8核，256G硬盘），只需分配2核cpu、2G内存（已验证分配4G无法安装）、64G硬盘。安装后的虚拟机文件在`~/Library/Containers/com.utmapp.UTM/Data/Documents`目录下，默认Finder中不显示这个目录，可以在家目录下打开`Show View Options -> Show Library Folder`。

# arcolinux

[ArcoLinux](https://arcolinux.com/)是[Arch Linux](https://archlinux.org/)的衍生发行版。

# vscode

[code-server源码](https://github.com/coder/code-server)

安装命令:
```sh
curl -fsSL https://code-server.dev/install.sh | sh
```

安装成功后，输出以下日志：
```sh
Ubuntu 22.04.2 LTS
Installing v4.11.0 of the amd64 deb package from GitHub.

+ mkdir -p ~/.cache/code-server
+ curl -#fL -o ~/.cache/code-server/code-server_4.11.0_amd64.deb.incomplete -C - https://github.com/coder/code-server/releases/download/v4.11.0/code-server_4.11.0_amd64.deb
######################################################################## 100.0%
+ mv ~/.cache/code-server/code-server_4.11.0_amd64.deb.incomplete ~/.cache/code-server/code-server_4.11.0_amd64.deb
+ sudo dpkg -i ~/.cache/code-server/code-server_4.11.0_amd64.deb
Selecting previously unselected package code-server.
(Reading database ... 226525 files and directories currently installed.)
Preparing to unpack .../code-server_4.11.0_amd64.deb ...
Unpacking code-server (4.11.0) ...
Setting up code-server (4.11.0) ...

deb package has been installed.

To have systemd start code-server now and restart on boot:
  sudo systemctl enable --now code-server@$USER
Or, if you don't want/need a background service you can run:
  code-server

Deploy code-server for your team with Coder: https://github.com/coder/coder
```

如果要修改密码等配置，请修改配置文件`${HOME}/.config/code-server/config.yaml`。

注意，和vscode客户端不一样，vscode server装插件时有些插件无法搜索到，这时就需要在[vscode网站](https://marketplace.visualstudio.com/vscode)上下载`.vsix`文件，手动安装。

常用插件：

- C语言（尤其是内核代码）推荐使用插件[C/C++ GNU Global](https://marketplace.visualstudio.com/items?itemName=jaycetyle.vscode-gnu-global)。

- C++语言推荐使用插件[C/C++](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools)或[clangd](https://marketplace.visualstudio.com/items?itemName=llvm-vs-code-extensions.vscode-clangd)。

- Vue.js推荐使用插件[Vetur](https://marketplace.visualstudio.com/items?itemName=octref.vetur)、[Vue Peek](https://marketplace.visualstudio.com/items?itemName=dariofuzinato.vue-peek)、[ESLint](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint)、[Bracket Pair Colorizer 2](https://marketplace.visualstudio.com/items?itemName=CoenraadS.bracket-pair-colorizer-2)、[VueHelper](https://marketplace.visualstudio.com/items?itemName=oysun.vuehelper)

当想在[vscode客户端](https://code.visualstudio.com/)打开远程的文件时, 可以使用 [remote-ssh](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh)插件.


