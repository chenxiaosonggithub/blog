下面介绍Linux内核编译环境和测试环境的搭建过程，当然我也为各位朋友准备好了已经安装好的虚拟机镜像，只需下载运行即可。


<!-- public begin -->
[点击这里从百度网盘下载对应平台的虚拟机镜像](https://chenxiaosong.com/baidunetdisk)，
<!-- public end -->
`x86_64`（也就是你平时用来安装windows系统的电脑，或者2020年前的苹果电脑）选择`ubuntu-x64_64.zip`，`arm64`（2020年末之后的苹果电脑）选择`ubuntu-aarch64.zip`。虚拟机运行后，登录界面的密码是`1`。

# 安装Linux发行版

安装Linux发行版，你可以选择以下几种方式:

- 在物理机上直接安装安装Linux发行版。这是工作时比较推荐的一种安装方法，可以最大程度的利用硬件资源。
- 在容器（如docker）中安装Linux发行版。这种方式也能最大程度的利用硬件资源，还能快速恢复开发环境。
- 在虚拟机上安装Linux发行版。在学习阶段推荐这种方式安装，因为一旦系统出现什么问题可以快速恢复。

## 虚拟机软件

接下来介绍几个常用的虚拟机软件。Windows系统推荐使用VirtualBox，arm64苹果系统推荐使用UTM。
<!-- public begin -->
如果你在看VMware虚拟机相关的视频，[请转为查看这个视频](https://www.bilibili.com/video/BV1Ss421T7KY/);
<!-- public end -->

- [VirtualBox](https://www.virtualbox.org/)。首先在[VirtualBox下载界面](https://www.virtualbox.org/wiki/Downloads)下载对应平台的安装包，比如如果要在Windows系统下安装VirtualBox，点击**Windows hosts**下载安装包。VirtualBox的安装过程很简单，只需根据安装提示操作即可。VirtualBox安装完成后，下载**VirtualBox 7.0.14 Oracle VM VirtualBox Extension Pack**安装插件（`管理 -> 工具 -> 扩展包管理器`），启动虚拟机后，`设备 -> 安装增强功能` 会挂载一个iso文件，把整个文件夹复制出来，执行`./autorun.sh`脚本，就能使用增强功能了，如自动调整屏幕大小和屏幕分辨率选项增加等。[arm芯片的版本](https://isapplesiliconready.com/app/Virtualbox)好像只有[7.0.8版本](https://download.virtualbox.org/virtualbox/7.0.8/)才有。
  - 报错`VirtualBox can't operate in VMX root mode.(VERR_VMX_IN_VMX_ROOT_MODE).`: 执行`sudo modprobe -r kvm_intel`（`sudo lsmod | grep kvm`查找）重新开启虚拟机既可。
- [VMware](https://www.vmware.com/)。[下载点击这篇文章](https://blogs.vmware.com/teamfusion/2024/05/fusion-pro-now-available-free-for-personal-use.html)，注册登录账号，下载时的信息填写类似`Address 1: 1ONE, City: SACRAMENTO, Postal code: 942030001, Country/Territory: United States, State or province: California`。安装过程很简单，只需根据提示操作即可。
<!-- public begin -->
Linux下安装VMware时需要注意的是`/tmp`目录的挂载不能在`/etc/fstab`文件中指定`noexec`，还需要安装gcc较新的版本（如`VMware-Workstation-Full-17.5.1-23298084.x86_64.bundle`在ubuntu2204下安装时要安装gcc12，默认安装的是gcc11）。桥接配置在`Edit -> Virtual Network Editor`。
<!-- public end -->
- [Virtual Machine Manager](https://virt-manager.org/)。这个虚拟机软件只用在Linux平台上，如果你物理机上安装的操作系统是Linux，那么使用这个软件运行虚拟机就比较合适。比如在Ubuntu上使用命令`sudo apt-get install qemu qemu-kvm virt-manager qemu-system -y`安装（需要重启才能以非root用户启动）。
- [UTM](https://mac.getutm.app/)。只针对苹果电脑系统，从[github](https://docs.getutm.app/installation/macos/)下载安装包。建议在配置比较高（尤其是内存）的苹果电脑上使用，如果配置比较低可能会遇到一些问题。从[github](https://docs.getutm.app/installation/macos/)上下载安装包。导入虚拟机时，选择"创建一个新虚拟机" -> "虚拟化" -> "其他" -> 打勾"Skip ISO boot"，"Storage"选择小一点的容量（如`1G`），创建虚拟机后打开配置，"VirtIO驱动器" -> "删除"，然后再"新建" -> "导入"，可以选择`vmdk`或`qcow2`等格式，会统一转换成`qcow2`格式，保存后生效。安装后的虚拟机文件在`~/Library/Containers/com.utmapp.UTM/Data/Documents`目录下，默认Finder中不显示这个目录，可以在家目录下打开`Show View Options -> Show Library Folder`。需要注意一下，网络如果选择`共享网络`会出现不稳定断网的情况，建议选择`桥接（高级）`，选择`桥接`时如果宿主机的网络切换了（如连了另一个wifi）虚拟机中的网络也要断开重连一下。如果出现虚拟机网络经常断开的情况，可以尝试宿主机换一个稳定的网络。

配置虚拟机时，Windows系统cpu核数查看方法: 任务管理器->性能->CPU，苹果电脑cpu核数查看方法: `sysctl hw.ncpu`或`sysctl -n machdep.cpu.core_count`，Linux系统cpu核数查看方法`lscpu`。

如果你用的是Linux下的Virtual Machine Manager，串口调试的方法如下：
```sh
virsh list # 找到虚拟机名称
virsh console <虚拟机名称> # 执行完下面的echo命令后能在这里看到输出
echo "hello" > /dev/ttyS0 # 在虚拟机中执行，也有可能是 ttyS1, ttyS2 ...，执行完后能在virsh console中看到输出
vim /boot/grub/grub.cfg
# 在grub.cfg文件中相应启动选项的 linux   /vmlinuz-5.10.0-8-generic 开头的一行最后加 console=ttyS0,115200 loglevel=8
# 注意不是initrd开头的那一行
# 重新启动后，virsh console <虚拟机名称> 就能看到虚拟机中的dmesg打印了
```

## 安装Ubuntu发行版

Linux发行版很多，我们选择一个使用人数相对较多的[Ubuntu发行版](https://ubuntu.com/)。[x86_64的ubuntu22.04](https://releases.ubuntu.com/22.04/)，[arm64的ubuntu22.04](http://cdimage.ubuntu.com/jammy/daily-live/current/)下载。[x86_64的ubuntu20.04](https://releases.ubuntu.com/20.04/)，[arm64的ubuntu20.04](https://ftpmirror.your.org/pub/ubuntu/cdimage/focal/daily-live/current/)

安装内核编译和测试所需软件:
```sh
sudo apt install git -y # 代码管理工具
sudo apt install build-essential -y # 编译所需的常用软件，如gcc等
sudo apt-get install qemu qemu-kvm qemu-system -y # qemu虚拟机相关软件
sudo apt-get install virt-manager -y # docker中不需要安装，虚拟机图形界面，会安装iptables，可能需要重启才能以非root用户启动virt-manager，当然对于内核开发来说安装这个软件是为了生成自动生成virbr0网络接口
sudo apt install flex bison bc kmod pahole -y # 内核编译所需软件
sudo apt-get install libelf-dev libssl-dev libncurses-dev -y # 内核源码编译依赖的库
sudo apt install zstd -y
```

交叉编译所需软件:
```sh
sudo apt-get install u-boot-tools -y
sudo apt install binutils-aarch64-linux-gnu -y # aarch64-linux-gnu-addr2line 等工具
sudo apt install gcc-aarch64-linux-gnu -y # aarch64-linux-gnu-gcc
sudo apt install gcc-arm-linux-gnueabi gcc-arm-linux-gnueabihf -y # arm32的交叉编译软件
sudo apt install gcc-riscv64-linux-gnu -y # riscv交叉编译软件
```

特定版本的交叉编译软件:
```sh
sudo apt install gcc-9-aarch64-linux-gnu -y # 指定版本的交叉编译软件
mv /usr/bin/aarch64-linux-gnu-gcc /usr/bin/aarch64-linux-gnu-gcc.bak # 原来的版本重命名
ln -s /usr/bin/aarch64-linux-gnu-gcc-9 /usr/bin/aarch64-linux-gnu-gcc # 指向特定版本
```

openeuler编译rpm包所需软件:
```sh
dnf install git rsync rpm-build -y
dnf install -y asciidoc audit-libs-devel binutils-devel elfutils-devel java-devel ncurses-devel newt-devel numactl-devel pciutils-devel perl-generators python3-docutils xmlto glibc-kernheaders kernel-headers
dnf install -y java-1.8.0-*-devel # 4.19内核
dnf install -y dwarves # 麒麟服务器v10无法安装，要在公司内网下载rpm安装
# rpm -i dwarves-1.25-1.ky10.x86_64.rpm  dwarves-debuginfo-1.25-1.ky10.x86_64.rpm  dwarves-debugsource-1.25-1.ky10.x86_64.rpm  libdwarves1-1.25-1.ky10.x86_64.rpm  libdwarves1-devel-1.25-1.ky10.x86_64.rpm # --force
```

<!-- TODO: 源码安装crash, emacs -->

<!-- public begin -->
## docker环境

除了在vmware虚拟机中搭建开发环境，还可以在docker中搭建开发环境。注意qemu的权限配置[请参考后面的“qemu配置”相关的章节](https://chenxiaosong.com/course/kernel/environment.html#qemu-config)。

### NAT模式

参考[中文翻译QEMU Documentation/Networking/NAT](https://chenxiaosong.com/src/translation/qemu/qemu-networking-nat.html)。

qemu命令行的网络参数修改成（`model`和`macaddr`可以自己指定）:
```sh
-net tap \
-net nic,model=virtio,macaddr=00:11:22:33:44:01 \
```

注意在虚拟机中，不要手动配置ip，要运行`systemctl restart networking.service`自动获取ip地址（可能还需要修改`/etc/network/interfaces`）。

### 桥接模式（TODO）

宿主机中桥接模式配置:
```sh
apt install bridge-utils -y # brctl命令
brctl addbr br0
brctl stp br0 on
brctl addif br0 eth0
# brctl delif br0 eth0
ip addr del dev eth0 172.17.0.2/16 # 清除ip
ifconfig br0 172.17.0.2/16 up # 或 ifconfig virbr0 172.17.0.2 netmask 172.17.0.1 up
route add default gw 172.17.0.1
sysctl net.ipv4.ip_forward=1 # 或 echo 1 > /proc/sys/net/ipv4/ip_forward
```

虚拟机中:
```sh
ip addr add 172.17.0.3/16 dev ens2
# ip addr del dev ens2 172.17.0.3/16 # 删除ip
ip link set dev ens2 up
# ip link set dev ens2 down
# 网关可不配置
# route del default dev ens2
# route add default gw 172.17.0.1 # ip route add default via 172.17.0.1 dev ens2
```

手动配置ip没法访问外网，暂时还不知道要怎么弄，如果有知道的朋友可以指导我一下。
<!-- public end -->

# 代码管理和编辑工具

## vscode

浏览代码的编辑器每个人都有自己的喜好，就像我用的是小众的emacs，Linux下也有很多人用vim和vscode。

当然，自己用得称手的兵器才是好兵器，别人的建议也只是建议，还是得根据自己的习惯选择最适合自己的编辑器工具。

建议使用[vscode客户端](https://code.visualstudio.com/)打开远程的文件时, 可以使用 [remote-ssh](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh)插件。

## code-server

为了尽可能的方便，可以使用code-server在网页上浏览和编辑代码，当然你也可以使用自己习惯的代码浏览和编辑工具。

[code-server源码](https://github.com/coder/code-server)托管在GitHub，安装命令:
```sh
curl -fsSL https://code-server.dev/install.sh | sh
```

<!-- public begin -->
[安装过程中输出的提示信息](https://gitee.com/chenxiaosonggitee/tmp/blob/master/kernel/code-server-install-log.txt)。
<!-- public end -->

或者下载[对应系统的安装包](https://github.com/coder/code-server/releases)。

设置开机启动:
```sh
sudo systemctl enable --now code-server@$USER
```

配置文件是`${HOME}/.config/code-server/config.yaml`，当不需要密码时修改成`auth: none`。

修改完配置后，需要再重启服务:
```sh
sudo systemctl restart code-server@$USER
```

然后打开浏览器输入`http://localhost:8888`（`8888`是`${HOME}/.config/code-server/config.yaml`配置文件中配置的端口）。

有些格式的文件可能不会自动换行显示，可以勾选`View -> Word Wrap`。

注意，和vscode客户端不一样，vscode server装插件时有些插件无法搜索到，需要手动安装`.vsix`文件，
但现在[vscode网站](https://marketplace.visualstudio.com/vscode)上已经无法下载`.vsix`文件了，需要通过源码编译。
下面以[vscode-gnu-global插件](https://github.com/jaycetyle/vscode-gnu-global)
（github仓库链接可在[vscode网站](https://marketplace.visualstudio.com/items?itemName=jaycetyle.vscode-gnu-global)上找到）为例说明编译过程:
```sh
# 先安装nodejs，包含编译插件需要用到的node和npm命令
wget https://nodejs.org/dist/v22.15.0/node-v22.15.0-linux-x64.tar.xz # 也可在 https://nodejs.org/zh-cn/download 获得其他版本的链接
tar xvf node-v22.15.0-linux-x64.tar.xz # 可解压到指定路径
cd node-v22.15.0-linux-x64/
export PATH=$(pwd)/bin:$PATH # 这时就能找到node和npm命令了
node -v
npm -v
# nodejs安装成功了，就可以开始编译打包.vsix文件了
git clone https://github.com/jaycetyle/vscode-gnu-global.git
cd vscode-gnu-global
npm install # 安装依赖
npm i vsce -g
vsce package # 生成.vsix文件成功
```

<!-- public begin -->
常用插件:
<!-- public end -->

- C语言（尤其是内核代码）推荐使用插件[C/C++ GNU Global](https://marketplace.visualstudio.com/items?itemName=jaycetyle.vscode-gnu-global)。使用命令`sudo apt install global -y`安装gtags插件，Linux内核代码使用命令`make gtags`生成索引文件。

<!-- public begin -->
- C++语言推荐使用插件[C/C++](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools)或[clangd](https://marketplace.visualstudio.com/items?itemName=llvm-vs-code-extensions.vscode-clangd)。浏览C/C++代码时，建议这两个插件和[C/C++ GNU Global](https://marketplace.visualstudio.com/items?itemName=jaycetyle.vscode-gnu-global)选一个，不要安装多个。

- Vue.js推荐使用插件[Vetur](https://marketplace.visualstudio.com/items?itemName=octref.vetur)、[Vue Peek](https://marketplace.visualstudio.com/items?itemName=dariofuzinato.vue-peek)、[ESLint](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint)、[Bracket Pair Colorizer 2](https://marketplace.visualstudio.com/items?itemName=CoenraadS.bracket-pair-colorizer-2)、[VueHelper](https://marketplace.visualstudio.com/items?itemName=oysun.vuehelper)

- markdown插件[Markdown Preview Enhanced](https://marketplace.visualstudio.com/items?itemName=shd101wyy.markdown-preview-enhanced)
<!-- public end -->

<!-- public begin -->
## Woboq CodeBrowser

https://github.com/KDAB/codebrowser
<!-- public end -->

## git管理代码

请查看[《git分布式版本控制系统》](https://chenxiaosong.com/course/gnu-linux/git.html)。

# 代码编译

## 获取代码

用git下载内核代码，仓库链接可以点击[内核网站](https://kernel.org/)上对应版本的`[browse] -> summary`查看，我们下载[mainline](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git)版本的代码:
```sh
git clone https://kernel.googlesource.com/pub/scm/linux/kernel/git/torvalds/linux.git # 国内使用googlesource仓库链接比较快
```

也可以在[/pub/linux/kernel/](https://mirrors.edge.kernel.org/pub/linux/kernel/)下载某个版本代码的压缩包。

如果系统上的时间不对，可能要执行`find . -type f -exec touch {} +`。

## 编译步骤

建议新建一个`build`目录，把所有的编译输出存放在这个目录下，注意
<!-- public begin -->
[`.config`](https://gitee.com/chenxiaosonggitee/tmp/blob/master/config/x86_64-config)
<!-- public end -->
<!-- private begin -->
`src/x86_64/config`
<!-- private end -->
文件复制到`build/.config`。`.config`配置文件至少要打开以下配置（建议通过`make O=build menuconfig`命令修改）:
```sh
CONFIG_EXT4_FS
CONFIG_XFS_FS
CONFIG_VIRTIO_BLK
CONFIG_VIRTIO_NET
CONFIG_SCSI_VIRTIO
CONFIG_BINFMT_MISC
CONFIG_NET_9P
CONFIG_NET_9P_VIRTIO
CONFIG_9P_FS
CONFIG_9P_FS_POSIX_ACL
CONFIG_BLK_DEV_LOOP
CONFIG_BLK_DEV_SD
CONFIG_BLK_DEV_NVME
```

如果想减少编译时间，可以尝试关闭`CONFIG_DEBUG_KERNEL`。

<!-- public begin -->
```sh
rm build -rf && mkdir build
cp ../tmp/config/x86_64-config build/.config
```
<!-- public end -->

可以使用`make help | less`查看帮助，常用编译和安装命令如下:
```sh
make O=build menuconfig # 交互式地配置内核的编译选项，.config文件放在build目录下
make O=build olddefconfig -j`nproc`
make O=build bzImage -j`nproc` # x86_64
make LD=ld.lld O=build bzImage -j`nproc` # 可以试试用ld.lld链接加快速度
make O=build Image -j`nproc` # aarch64，比如2020年末之后的arm芯片的苹果电脑上vmware fusion安装的ubuntu
make LD=ld.lld O=build modules -j`nproc` # 如果上面的bzImage或Image加了LD=ld.lld，这里也要加
mkdir -p build/boot && make O=build install INSTALL_PATH=boot -j`nproc`
# INSTALL_MOD_STRIP=1代表不含调试信息，不写INSTALL_MOD_STRIP=1代表含有调试信息
make O=build modules_install INSTALL_MOD_STRIP=1 INSTALL_MOD_PATH=mod -j`nproc`
make O=build INSTALL_MOD_STRIP=1 tar-pkg -j`nproc` # 将boot/和ko打包成.tar
```

在`x86_64`下，如果是交叉编译其他架构，`ARCH`的值为`arch/`目录下相应的架构，编译命令是:
```sh
make ARCH=i386 O=build bzImage # x86 32bit
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi-  O=build zImage # armel, arm eabi(embeded abi) little endian, 传参数用普通寄存器
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- O=build zImage # armhf, arm eabi(embeded abi) little endian hard float, 传参数用fpu的寄存器，浮点运算性能更高
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- O=build Image
make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- O=build Image
```

也可以在一个仓库下编译多个体系结构，如:
<!-- public begin -->
```sh
rm x86_64-build -rf && mkdir x86_64-build
cp ../tmp/config/x86_64-config x86_64-build/.config

rm aarch64-build -rf && mkdir aarch64-build
cp ../tmp/config/aarch64-config aarch64-build/.config
```
<!-- public end -->
```sh
make O=x86_64-build menuconfig
make O=x86_64-build bzImage -j`nproc`
make O=x86_64-build modules -j`nproc`
mkdir -p x86_64-build/boot && make O=x86_64-build install INSTALL_PATH=boot -j`nproc`
make O=x86_64-build modules_install INSTALL_MOD_STRIP=1 INSTALL_MOD_PATH=mod -j`nproc`
zip -r boot.zip x86_64-build/boot/
rm x86_64-build/mod/lib/modules/xxxx/build
rm x86_64-build/mod/lib/modules/xxxx/source


make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- O=aarch64-build menuconfig
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- O=aarch64-build Image -j`nproc`
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- O=aarch64-build modules -j`nproc`
mkdir -p aarch64-build/boot && make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- O=aarch64-build install INSTALL_PATH=boot -j`nproc`
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- O=aarch64-build modules_install INSTALL_MOD_STRIP=1 INSTALL_MOD_PATH=mod -j`nproc`
```

## llvm编译

参考[使用 Clang/LLVM 构建 Linux](https://docs.kernel.org/translations/zh_CN/kbuild/llvm.html)。

```sh
sudo apt install -y lld clang ccache llvm

make LLVM=1 CC="ccache clang" O=x86_64-build olddefconfig -j`nproc` && \
make LLVM=1 CC="ccache clang" O=x86_64-build bzImage -j`nproc` && \
make LLVM=1 CC="ccache clang" O=x86_64-build modules -j`nproc` && \
make LLVM=1 CC="ccache clang" O=x86_64-build modules_install INSTALL_MOD_PATH=mod -j`nproc`
```

相比gcc，llvm好像更慢。

## 可能的编译问题

- 老版本（如v5.17）编译如果报错`FAILED: load BTF from vmlinux: Invalid argument`，可以尝试关闭`CONFIG_DEBUG_INFO_BTF`配置。
- 如果报错`arch/x86/entry/.tmp_thunk_64.o: warning: objtool: missing symbol table`，可以尝试合入补丁`1d489151e9f9 objtool: Don't fail on missing symbol table`。

## 独立模块编译

举个例子，把Linux内核仓库下的`fs/ext2`复制出来，修改`Makefile`文件:
```sh
CONFIG_EXT2_FS := m
CONFIG_EXT2_FS_XATTR := y
CONFIG_EXT2_FS_POSIX_ACL := y
CONFIG_EXT2_FS_SECURITY := y

EXTRA_CFLAGS += -DCONFIG_EXT2_FS=1 -DCONFIG_EXT2_FS_XATTR=1 \
                -DCONFIG_EXT2_FS_POSIX_ACL=1 -DCONFIG_EXT2_FS_SECURITY=1

obj-$(CONFIG_EXT2_FS) += ext2.o

ext2-y := balloc.o dir.o file.o ialloc.o inode.o \
          ioctl.o namei.o super.o symlink.o trace.o

# For tracepoints to include our trace.h from tracepoint infrastructure
CFLAGS_trace.o := -I$(src)

ext2-$(CONFIG_EXT2_FS_XATTR)     += xattr.o xattr_user.o xattr_trusted.o
ext2-$(CONFIG_EXT2_FS_POSIX_ACL) += acl.o
ext2-$(CONFIG_EXT2_FS_SECURITY)  += xattr_security.o

KDIR    := /root/code/linux/x86_64-build/
PWD     := $(shell pwd)

# 设置交叉编译工具链的前缀和目标架构
CROSS_COMPILE := aarch64-linux-gnu-
ARCH := arm64

all:
	$(MAKE) -C $(KDIR) M=$(PWD) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) modules
clean:
	$(MAKE) -C $(KDIR) M=$(PWD) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) clean
```

然后编译:
```sh
make # 生成ko文件
make clean # 清除编译结果
```

注意minix文件系统的`Makefile`中的`minix-objs`要改成`minix-y`。

## 内核文档编译 {#kernel-doc-build}

参考[简介 — The Linux Kernel documentation](https://www.kernel.org/doc/html/latest/translations/zh_CN/doc-guide/sphinx.html)。

如果你的环境还没安装依赖软件，运行``make O=build SPHINXOPTS=-v htmldocs -j`nproc` ``后可能报以下错误:
```sh
Documentation/Makefile:41: 找不到 'sphinx-build' 命令。请确保已安装 Sphinx 并在 PATH 中，或设置 SPHINXBUILD make 变量以指向 'sphinx-build' 可执行文件的完整路径。

检测到的操作系统：DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=22.04
DISTRIB_CODENAME=jammy
DISTRIB_DESCRIPTION="Ubuntu 22.04.2 LTS"。
警告：最好安装 "convert"。
警告：最好安装 "dot"。
警告：最好安装 "dvipng"。
错误：请安装 "ensurepip"，否则构建将无法工作。
警告：最好安装 "fonts-noto-cjk"。
警告：最好安装 "latexmk"。
警告：最好安装 "rsvg-convert"。
警告：最好安装 "texlive-lang-chinese"。
警告：最好安装 "xelatex"。
你应该运行：

        sudo apt-get install imagemagick graphviz dvipng python3-venv fonts-noto-cjk latexmk librsvg2-bin texlive-lang-chinese texlive-xetex

Sphinx 需要通过以下方式安装：
1) 通过 pip/pypi：

        /usr/bin/python3 -m venv sphinx_2.4.4
        . sphinx_2.4.4/bin/activate
        pip install -r ./Documentation/sphinx/requirements.txt

    如果你想退出虚拟环境，可以使用：
        deactivate

2) 作为包安装：

        sudo apt-get install python3-sphinx

    请注意，Sphinx >= 3.0 会在同名用于多个类型（函数、结构、枚举等）时产生误报警告。这是已知的 Sphinx 错误。更多详情，请查看：
        https://github.com/sphinx-doc/sphinx/pull/8313

由于缺少 2 个必需依赖项，无法构建，位于 ./scripts/sphinx-pre-install 第 997 行。

make[2]: *** [Documentation/Makefile:43：htmldocs] 错误 2
make[1]: *** [/home/linux/code/linux/Makefile:1692：htmldocs] 错误 2
make: *** [Makefile:234：__sub-make] 错误 2
```

根据提示安装所需软件:
```sh
sudo apt-get install imagemagick graphviz dvipng python3-venv fonts-noto-cjk latexmk librsvg2-bin texlive-lang-chinese texlive-xetex -y
sudo apt-get install python3-sphinx -y
```

再次编译:
```sh
make O=build SPHINXOPTS=-v htmldocs -j`nproc` # -v 获得更详细的输出。
# make O=build cleandocs # 删除生成的文档
```

## 一些额外的补丁

如果你要更方便的使用一些调试的功能，就要加一些额外的补丁。

- 降低编译优化等级，默认的内核编译优化等级太高，用GDB调试时不太方便，有些函数语句被优化了，无法打断点，这时就要降低编译优化等级。做好的虚拟机中已经打上了降低编译优化等级的补丁。
<!-- public begin -->
比如`x86_64`架构下可以在[`x86_64`](https://gitee.com/chenxiaosonggitee/blog/tree/master/course/kernel/src/x86_64)目录下选择对应版本的补丁，更多详细的内容请查看GDB调试相关的章节。
<!-- public end -->
- `dump_stack()`输出的栈全是问号的解决办法。如果你使用`dump_stack()`输出的栈全是问号，可以 revert 补丁 `f1d9a2abff66 x86/unwind/orc: Don't skip the first frame for inactive tasks`。主线已经有补丁做了 revert: `230db82413c0 x86/unwind/orc: Fix unreliable stack dump with gcov`。
<!-- public begin -->
- 肯定还有一些其他有用的补丁，后面再补充哈。
<!-- public end -->

## 发行版替换内核

用发行版``/boot/config-`uname -r` ``配置文件，删除`CONFIG_SYSTEM_TRUSTED_KEYS`和`CONFIG_SYSTEM_REVOCATION_KEYS`配置值，在编译环境上编译安装后，删除`build/mod/lib/modules/xxx/build`和`build/mod/lib/modules/xxx/source`链接文件，然后压缩（文件太多，不压缩复制会很慢）打包复制到待测环境上。

把`build/mod/lib/modules/xxx/`复制到待测环境上的`/lib/modules/`路径，把`build/boot/`目录下的文件复制到待测环境上的`/boot/`路径下。

```sh
# centos, 麒麟server
mkinitrd /boot/initrd.img-xxx xxx # 生成`initrd.img`，其中`xxx`为内核版本
grub2-mkconfig -o /boot/grub2/grub.cfg
vim /boot/efi/EFI/kylin/grub.cfg # arm64
vim /boot/grub2/grub.cfg # x86
sync

# ubuntu，麒麟desktop
mkinitramfs -o /boot/initrd.img-xxx xxx # 生成`initrd.img`，其中`xxx`为内核版本
update-grub
# 麒麟桌面系统要在把`grub.cfg`新生成的启动项里的`security=kysec`改成`security= `（注意后面有空格）
vim /boot/grub/grub.cfg # x86
vim /boot/efi/boot/grub/grub.cfg # arm64
sync
```

麒麟server 4.19安装内核rpm包的步骤:
```sh
# 如果报错grub2-editenv: error: environment block too small.，就执行grub2-editenv create
# kernel-devel-4.19.* kernel-headers-4.19.* 可不安装
rpm -i kernel-4.19.* kernel-core-4.19.* kernel-modules-* --force
cat /boot/grub2/grubenv # 查看默认启动项
view /boot/efi/EFI/kylin/grub.cfg # aarch64 从这里复制 Kylin Linux Advanced Server (4.19.90-23.29.v2101.fortest.ky10.aarch64) V10 (Lance)
view /boot/grub2/grub.cfg # x86_64从这里复制
grub2-set-default "Kylin Linux Advanced Server (4.19.90-23.29.v2101.fortest.ky10.aarch64) V10 (Lance)" # 更改默认启动项
cat /boot/grub2/grubenv # 查看是否更改成功
sync # 确保落盘
```

# 使用QEMU测试内核代码

前面介绍完了编译环境，编译出的代码我们不能直接在编译环境上运行，还要再启动qemu虚拟机运行我们编译好的内核。

## 模拟器与虚拟机

Bochs: x86硬件平台的开源模拟器，帮助文档少，只能模拟x86处理器。

QEMU: quick emulation，高速度、跨平台的开源模拟器，能模拟x86、arm等处理器，与Linux的KVM配合使用，能达到与真实机接近的速度。

第1类虚拟机监控程序: 直接在主机硬件上运行，直接向硬件调度资源，速度快。如Linux的KVM（免费）、Windows的Hyper-V（收费）。

第2类虚拟机监控程序: 在常规操作系统上以软件层或应用的形式运行，速度慢。如Vmware Workstation、Oracal VirtualBox。

本教程中，我们使用qemu来测试运行内核代码。

## 制作测试用的qcow2镜像的脚本

测试编译好的内核我们不直接用发行版的iso镜像安装的系统，而是使用脚本生成比较小的镜像（不含有图形界面）。
<!-- public begin -->
进入目录[`kernel`](https://gitee.com/chenxiaosonggitee/blog/tree/master/course/kernel)，
<!-- public end -->
选择相应的cpu架构，如
<!-- public begin -->
[`x86_64`](https://gitee.com/chenxiaosonggitee/blog/tree/master/course/kernel/src/x86_64)
<!-- public end -->
<!-- private begin -->
`src/x86_64`
<!-- private end -->
目录。执行
<!-- public begin -->
[`create-raw.sh`](https://gitee.com/chenxiaosonggitee/blog/blob/master/course/kernel/src/x86_64/create-raw.sh)
<!-- public end -->
<!-- private begin -->
`create-raw.sh`
<!-- private end -->
生成raw格式的镜像，这个脚本会调用到
<!-- public begin -->
[`create-debian.sh`](https://gitee.com/chenxiaosonggitee/blog/blob/master/course/kernel/src/create-debian.sh)
<!-- public end -->
<!-- private begin -->
`src/create-debian.sh`
<!-- private end -->
，是从[syzkaller的脚本](https://github.com/google/syzkaller/blob/master/tools/create-image.sh)经过修改而来。

注意riscv64架构的镜像，可以直接下载[ubuntu2204](https://ubuntu.com/download/risc-v)（选择[QEMU emulator]），[使用文档](https://wiki.ubuntu.com/RISC-V/QEMU?_gl=1*5kle2i*_gcl_au*MTE0MzIzMjgyMi4xNzE3NTA4NjU1&_ga=2.54580847.51388592.1718933588-66008337.1718933588)。

生成raw格式镜像后，再执行以下命令转换成占用空间更小的qcow2格式:
```sh
# -p 显示进度， -f 源镜像格式， -O 转换后的格式， 后面再紧接的是: 源文件名称，转换后的文件名称
qemu-img convert -p -f raw -O qcow2 image.raw image.qcow2
```

再执行脚本
<!-- public begin -->
[`link-scripts.sh`](https://gitee.com/chenxiaosonggitee/blog/blob/master/course/kernel/src/link-scripts.sh)
<!-- public end -->
<!-- private begin -->
`src/link-scripts.sh`
<!-- private end -->
把脚本链接到相应的目录，执行
<!-- public begin -->
[`update-base.sh`](https://gitee.com/chenxiaosonggitee/blog/blob/master/course/kernel/src/x86_64/update-base.sh)
<!-- public end -->
<!-- private begin -->
`update-base.sh`
<!-- private end -->
启动虚拟机更新镜像（如再安装一些额外的软件），镜像更新完后关闭虚拟机，再执行
<!-- public begin -->
[`create-qcow2.sh`](https://gitee.com/chenxiaosonggitee/blog/blob/master/course/kernel/src/x86_64/create-qcow2.sh)
<!-- public end -->
<!-- private begin -->
`create-qcow2.sh`
<!-- private end -->
生成指向基础镜像的qcow2镜像。

## 通过iso安装发行版

也可以在Virtual Machine Manager中通过iso文件安装发行版，安装完成后的qcow2镜像要用命令行启动，安装时不使用LVM，而是把磁盘的某个分区挂载到根路径`/`。

在 Virtual Machine Manager 中创建 qcow2 格式，会马上分配所有空间，所以需要在命令行中创建 qcow2:
```sh
qemu-img create -f qcow2 image.qcow2 512G
file image.qcow2 # 查看文件的格式
```

可以再生成一个qcow2文件`image2.qcow2`，指向安装好的镜像`image.qcow2`，`image.qcow2`作为备份文件， 注意<有些版本的qemu-img>要求源文件和目标文件都要指定绝对路径
```sh
qemu-img create -F qcow2 -b /path/image.qcow2 -f qcow2 /path/image2.qcow2 #  -F 源文件格式
```

iso安装发行版本后，默认是`/dev/vda1`（`-device virtio-scsi-pci`）挂载到根路径`/`，如果要重新制作成`/dev/vda`挂载到根分区`/`，可以把qcow2文件里的内容复制出来，qcow2格式镜像的挂载:
```sh
sudo apt-get install qemu-utils -y # 要先安装工具软件
sudo modprobe nbd max_part=8 # 加载nbd模块
sudo qemu-nbd --connect=/dev/nbd0 image.qcow2 # 连接镜像
sudo fdisk /dev/nbd0 -l # 查看分区
sudo mount /dev/nbd0p1 mnt/ # 挂载分区
sudo umount mnt # 操作完后，卸载分区
sudo qemu-nbd --disconnect /dev/nbd0 # 断开连接
sudo modprobe -r nbd # 移除模块
```

当然也可以把qcow2转换成raw格式，然后把raw格式文件里的内容复制出来:
```sh
qemu-img convert -p -f qcow2 -O raw image.qcow2 image.raw
```

ubuntu24.04报错`dmesg`中`virtio_net virtio0 enp0s1: renamed from eth0`，解决办法:
```sh
sudo vim /etc/netplan/50-cloud-init.yaml # 把网络接口名改成enp0s1
sudo netplan apply
```

## 源码安装qemu

- [qemu仓库](https://gitlab.com/qemu-project/qemu)
- [linux编译文档](https://wiki.qemu.org/Hosts/Linux)

关于各个Linux发行版怎么安装qemu，可以参考[qemu官网](https://www.qemu.org/download/#linux)的介绍，下面主要介绍一下源码的安装方式，源码安装方式可以使用qemu的最新特性。

先安装Ubuntu编译qemu所需的软件:
```sh
sudo apt-get install -y git libglib2.0-dev libfdt-dev libpixman-1-dev zlib1g-dev ninja-build python3-venv
# 下面是推荐安装的软件
sudo apt-get install -y git-email libaio-dev libbluetooth-dev libcapstone-dev libbrlapi-dev libbz2-dev libcap-ng-dev libcurl4-gnutls-dev libgtk-3-dev libibverbs-dev libjpeg8-dev libncurses5-dev libnuma-dev librbd-dev librdmacm-dev libsasl2-dev libsdl2-dev libseccomp-dev libsnappy-dev libssh-dev libvde-dev libvdeplug-dev libvte-2.91-dev libxen-dev liblzo2-dev valgrind xfslibs-dev libnfs-dev libiscsi-dev
```

<!-- public begin -->
CentOS发行版安装编译qemu所需的软件:
```sh
sudo dnf install glib2-devel -y
sudo dnf install iasl -y
sudo dnf install pixman-devel -y
sudo dnf install libcap-ng-devel -y
sudo dnf install libattr-devel -y

# centos 9才需要， http://re2c.org/
git clone https://github.com/skvadrik/re2c.git
./autogen.sh
./configure  --prefix=${HOME}/chenxiaosong/sw/re2c
make && make install

# centos 要安装 ninja, https://ninja-build.org/
git clone https://github.com/ninja-build/ninja.git && cd ninja
./configure.py --bootstrap

# centos9, https://sparse.docs.kernel.org/en/latest/
git clone git://git.kernel.org/pub/scm/devel/sparse/sparse.git
make
```
<!-- public end -->

再下载编译qemu:
```sh
git clone https://gitlab.com/qemu-project/qemu.git
cd qemu
git submodule init
git submodule update --recursive
mkdir build
cd build/
../configure --enable-kvm --enable-virtfs --prefix=/home/sonvhi/chenxiaosong/sw/qemu/
make -j`nproc`
```

## qemu配置 {#qemu-config}

非root用户没有权限的解决办法:
```sh
# 源码安装的
sudo chown root libexec/qemu-bridge-helper
sudo chmod u+s libexec/qemu-bridge-helper
# apt安装的
sudo chown root /usr/lib/qemu/qemu-bridge-helper
sudo chmod u+s /usr/lib/qemu/qemu-bridge-helper

groups | grep kvm
sudo usermod -aG kvm $USER
su - $USER # 或退出shell重新登录, 但在tmux中不起作用
```

允许使用`virbr0`网络接口:
```sh
# 源码安装的
mkdir -p etc/qemu
vim etc/qemu/bridge.conf # 添加 allow virbr0
# apt安装的
sudo mkdir -p /etc/qemu/
sudo vim /etc/qemu/bridge.conf # 添加 allow virbr0
```

修改`virbr0`网段:
```sh
virsh net-list # 查看网络情况
virsh net-edit default # 编辑
virsh net-destroy default
virsh net-start default
```

## qemu运行qcow2镜像

制作好的Ubuntu虚拟机镜像
<!-- public begin -->
（从百度网盘中下载的）
<!-- public end -->
中的`${HOME}/qemu-kernel/start.sh`脚本中每个选项的可选值可以使用以下命令查看:
```sh
qemu-system-aarch64 -cpu ?
qemu-system-x86_64 -machine ?
```

如果自己编译内核，启动时指定内核，需要指定`-kernel`和`-append`选项。

如果你的镜像是一个完整的镜像（比如通过iso安装），不想指定内核，就想用镜像本身自带的内核，可以把`-kernel`和`-append`选项删除。

qemu启动后，按快捷键`ctrl+a c`（先按`ctrl+a`松开后再按`c`）再输入`quit`强制退出qemu，但不建议强制退出。

在系统启动界面登录进去后（而不是以ssh登录），默认的窗口大小不会自动调整，需要手动调整:
```sh
stty size # 可以先在其他窗口查看大小
echo "stty rows 54 cols 229" > stty.sh
. stty.sh
```

当启用了9p文件系统，就可以把宿主机的modules目录（当然也可以是其他任何目录）共享给虚拟机，
具体参考[Documentation/9psetup](https://wiki.qemu.org/Documentation/9psetup)。虚拟机中执行脚本
[`mod-cfg.sh`](https://gitee.com/chenxiaosonggitee/blog/blob/master/course/kernel/src/script/mod-cfg.sh)
（直接运行`bash mod-cfg.sh`可以查看使用帮助）挂载和链接模块目录。也可以用
[`parse-cmdline.sh`](https://gitee.com/chenxiaosonggitee/blog/blob/master/course/kernel/src/script/parse-cmdline.sh)
解析`/proc/cmdline`中的参数。

root免密登录，`/etc/ssh/sshd_config`（注意不是`ssh_config`） 修改以下内容:
```
PermitRootLogin yes
PasswordAuthentication yes
PermitEmptyPasswords yes
```

<!-- public begin -->
曾经使用过fedora发行版，这里记录一下fedora的一些笔记。进入fedora虚拟机后:
```sh
vim /etc/fstab # 删除 /boot/efi 一行
# fedora 启动的时候等待: A start job is running for /dev/zram0，解决办法: 删除 zram 的配置文件
mv /usr/lib/systemd/zram-generator.conf /usr/lib/systemd/zram-generator.conf.bak
# fedora26 安装 vim 前，先升级
sudo dnf update vim-common vim-minimal -y
```

注意fedora中账号密码输完后要用`ctrl+j`，不要用回车。
<!-- public end -->

## 多个网卡 {#qemu-multi-nic}

最方便的就是在virt-manager虚拟机中测试，在图形界面上添加多个网卡。

qemu命令行启动虚拟机时，多个网卡的启动参数如下:
```sh
-net tap \
-net nic,model=virtio,macaddr=00:11:22:33:44:01 \
-net nic,model=virtio,macaddr=00:11:22:33:44:61 \
```

启动后，在虚拟机中用`ifconfig -a`可以看到另一个网卡`ens3`，debian还需要经过以下修改:
```sh
echo -e "auto ens3\niface ens3 inet dhcp" >> /etc/network/interfaces # ens3请换成你环境上的网卡名
systemctl restart networking
```

# 使用GDB调试内核代码 {#gdb}

<!-- public begin -->
我刚开始是做用户态开发的，习惯了利用gdb调试来理解那些写得不好的用户态代码，尤其是公司内部一些不开源的比狗屎还难看的用户态代码（当然其中也包括我自己写的狗屎一样的代码）。

转方向做了Linux内核开发后，也尝试用qemu+gdb来调试内核代码。
<!-- public end -->

要特别说明的是，内核的大部分代码是很优美的，并不需要太依赖qemu+gdb这一调试手段，更建议通过阅读代码来理解。但某些写得不好的内核模块如果利用qemu+gdb将能使我们更快的熟悉代码。

这里只介绍`x86_64`下的qemu+gdb调试，其他cpu架构以此类推，只需要做些小改动。

如果是其他cpu架构，要安装:
```sh
sudo apt install gdb-multiarch -y
```

## 编译选项和补丁

首先确保修改以下配置:
```sh
CONFIG_DEBUG_SECTION_MISMATCH=y # 防止内联
CONFIG_DEBUG_INFO=y # 调试信息
CONFIG_DEBUG_KERNEL=y # 调试信息
CONFIG_GDB_SCRIPTS=y # gdb python
DEBUG_INFO_REDUCED=n # 关闭
CONFIG_FRAME_POINTER=y # Makefile 中选择GCC编译选项
CONFIG_RANDOMIZE_BASE = n # 关闭地址随机化
```

可以使用
<!-- public begin -->
我常用的[x86_64的内核配置文件](https://gitee.com/chenxiaosonggitee/tmp/blob/master/config/x86_64-config)。
<!-- public end -->
<!-- private begin -->
`src/x86_64/config`
<!-- private end -->
配置文件。


<!-- public begin -->
gcc的编译选项`O1`优化等级不需要修改就可以编译通过。`O0`优化等级无法编译（尝试`CONFIG_JUMP_LABEL=n`还是不行），要修改汇编代码，有兴趣的朋友可以和我一直尝试。
<!-- public end -->
`Og`优化等级经过修改可以编译通过，`x86_64`合入目录
<!-- public begin -->
[`course/kernel/src/x86_64`](https://gitee.com/chenxiaosonggitee/blog/tree/master/course/kernel/src/x86_64)
<!-- public end -->
<!-- private begin -->
`src/x86_64`
<!-- private end -->
对应版本的补丁。建议使用`Og`优化等级编译，既能满足gdb调试需求，也能尽量少的修改代码。

另外，也建议把需要调试的函数的`inline`关键字去掉。

## QEMU命令选项

qemu启动虚拟机时，要添加以下几个选项:
```sh
-append "nokaslr ..." # 防止地址随机化，编译内核时关闭配置 CONFIG_RANDOMIZE_BASE
-S # 挂起 gdbserver
-gdb tcp::5555 # 端口5555, 使用 -s 选项表示用默认的端口1234
-s # 相当于 -gdb tcp::1234 默认端口1234，不建议用，最好指定端口
```

完整的启动命令查看制作好的Ubuntu虚拟机镜像
<!-- public begin -->
（从百度网盘中下载的）
<!-- public end -->
中的`${HOME}/qemu-kernel/start.sh`脚本。

## GDB命令

启动GDB:
```sh
gdb build/vmlinux
```

如果是其他架构:
```sh
gdb --tui build/vmlinux # --tui: Use a terminal user interface.
(gdb) set architecture aarch64
```

进入GDB界面后:
```sh
(gdb) target remote:5555 # 对应qemu命令中的-gdb tcp::5555
(gdb) b func_name # 普通断点
(gdb) hb func_name # 硬件断点，有些函数普通断点不会停下, 如: nfs4_atomic_open，降低优化等级后没这个问题
```

gdb命令的用法和用户态程序的调试大同小异。

## GDB辅助调试功能

使用内核提供的[GDB辅助调试功能](https://github.com/torvalds/linux/blob/master/Documentation/dev-tools/gdb-kernel-debugging.rst)可以更方便的调试内核（如打印断点处的进程名和进程id等）。

内核最新版本（2024.04）使用以下命令开启GDB辅助调试功能，注意最新版本编译出的脚本无法调试4.19和5.10的代码:
```sh
echo "set auto-load safe-path /" > ~/.gdbinit # 设置自动加载共享库文件的安全路径
echo "source ${HOME}/.gdb-linux/vmlinux-gdb.py" >> ~/.gdbinit
make O=build scripts_gdb # 在内核仓库目录下执行
rm -rf ${HOME}/.gdb-linux/
mkdir ${HOME}/.gdb-linux/
cp build/scripts/gdb/* ${HOME}/.gdb-linux/ -rf # 在内核仓库目录下执行
cp scripts/gdb/vmlinux-gdb.py ${HOME}/.gdb-linux/ # 在内核仓库目录下执行
sed -i '/sys.path.insert/s/^/# /' ${HOME}/.gdb-linux/vmlinux-gdb.py # 将sys.path.insert所在的行注释掉
sed -i '/sys.path.insert/a\sys.path.insert(0, "'${HOME}'/.gdb-linux")' ${HOME}/.gdb-linux/vmlinux-gdb.py # 插入 sys.path.insert(0, "${HOME}/.gdb-linux")
```

内核5.10使用以下命令开启GDB辅助调试功能，也可以调试内核4.19代码，但无法调试内核最新的代码:
```sh
echo "set auto-load safe-path /" > ~/.gdbinit # 设置自动加载共享库文件的安全路径
echo "source ${HOME}/.gdb-linux-5.10/vmlinux-gdb.py" >> ~/.gdbinit
make O=build scripts_gdb # 在5.10内核仓库目录下执行
rm -rf ${HOME}/.gdb-linux-5.10/
mkdir ${HOME}/.gdb-linux-5.10/
cp build/scripts/gdb/* ${HOME}/.gdb-linux-5.10/ -rf # 在5.10内核仓库目录下执行
cp scripts/gdb/vmlinux-gdb.py ${HOME}/.gdb-linux-5.10/ # 在5.10内核仓库目录下执行
sed -i '/sys.path.insert/s/^/# /' ${HOME}/.gdb-linux-5.10/vmlinux-gdb.py # 将sys.path.insert所在的行注释掉
sed -i '/sys.path.insert/a\sys.path.insert(0, "'${HOME}'/.gdb-linux-5.10")' ${HOME}/.gdb-linux-5.10/vmlinux-gdb.py # 插入 sys.path.insert(0, "${HOME}/.gdb-linux-5.10")
```

重新启动GDB就可以使用GDB辅助调试功能:
```sh
(gdb) apropos lx # 查看有哪些命令
(gdb) p $lx_current().pid # 打印断点所在进程的进程id
(gdb) p $lx_current().comm # 打印断点所在进程的进程名
```

## GDB打印结构体偏移

结构体定义有时候加了很多宏判断，再考虑到内存对齐之类的因素，通过看代码很难确定结构体中某一个成员的偏移大小，使用gdb来打印就很直观。

如结构体`struct cifsFileInfo`:
```c
struct cifsFileInfo {
    struct list_head tlist;
    ...
    struct tcon_link *tlink;
    ...
    char *symlink_target;
};
```

想要确定`tlink`的偏移，可以使用以下命令:
```sh
gdb ./cifs.ko # ko文件或vmlinux
(gdb) p &((struct cifsFileInfo *)0)->tlink
```

`(struct cifsFileInfo *)0`: 这是将整数值 `0` 强制类型转换为指向 `struct cifsFileInfo` 类型的指针。这实际上是创建一个指向虚拟内存地址 `0` 的指针，该地址通常是无效的。这是一个计算偏移量的技巧，因为偏移量的计算不依赖于结构体的实际实例。

`(0)->tlink`: 指向虚拟内存地址 `0` 的指针的成员`tlink`。

`&(0)->tlink`: `tlink`的地址，也就是偏移量。

## ko模块代码调试

使用`gdb vmlinux`启动gdb后，如果调用到ko模块里的代码，这时候就不能直接对ko模块的代码进行打断点之类的操作，因为找不到对应的符号。

这时就要把符号加入进来。首先，查看被调试的qemu虚拟机中的各个段地址:
```sh
cd /sys/module/ext4/sections/ # ext4 为模块名
cat .text .data .bss # 输出各个段地址
```

在gdb窗口中加载ko文件:
```sh
(gdb) add-symbol-file <ko文件位置> <text段地址> -s .data <data段地址> -s .bss <bss段地址>
(gdb) info files # 也可用info target，查看添加的ko
(gdb) remove-symbol-file /这里要写完整的绝对路径/linux/x86_64-build/fs/smb/client/cifs.ko
```

可以在虚拟机中直接运行脚本获得要输入的完整gdb命令: [`bash add-symbol-file-full-cmd.sh`](https://gitee.com/chenxiaosonggitee/blog/tree/master/course/kernel/src/script/add-symbol-file-full-cmd.sh)。

这时就能开心的对ko模块中的代码进行打断点之类的操作了。

