# kdump和crash

## fedora环境

安装工具：
```sh
sudo dnf install kexec-tools -y
sudo dnf install crash -y
```

修改`/etc/default/grub`文件，在`GRUB_CMDLINE_LINUX=`一行的最后添加以下内容：
```sh
GRUB_CMDLINE_LINUX="... crashkernel=512M" # 根据内存大小来决定
```

然后重新生成grub配置：
```sh
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
sudo reboot # 重启才会生效
```

开启kdump服务：
```sh
sudo systemctl enable kdump.service # 设置成开机启动
sudo systemctl start kdump.service # 启动
sudo systemctl status kdump.service # 查看状态
```

如果系统有问题发生崩溃，会在`/var/crash`目录下生成`vmcore`文件。

为了验证kdump功能是否可用，我们可以手动触发：
```sh
sudo su root
echo 1 > /proc/sys/kernel/sysrq
echo c > /proc/sysrq-trigger
```

安装`kernel-debuginfo`软件包：
```sh
sudo dnf --enablerepo=fedora-debuginfo install kernel-debuginfo
```

启动crash:
```sh
crash /var/crash/${ip}-${date-time}/vmcore /usr/lib/debug/lib/modules/vmlinux
```

## ubuntu环境

安装工具：
```sh
sudo apt-get update -y
sudo apt install linux-crashdump -y
sudo apt install crash -y
```

修改`/etc/default/grub`文件，在`GRUB_CMDLINE_LINUX=`一行的最后添加以下内容：
```sh
GRUB_CMDLINE_LINUX="... crashkernel=512M" # 根据内存大小来决定
```

然后重新生成grub配置：
```sh
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

注意ubuntu server（如ubuntu22.04.4）的`/boot/grub/grub.cfg`中的`crashkernel`后的值是`512M-:192M`，要删掉后面的`-:192M`，否则无法生成`vmcore`。

再重启系统：
```
sudo reboot # 重启才会生效
```

开启kdump服务：
```sh
sudo systemctl enable kdump-tools.service # 设置成开机启动
sudo systemctl start kdump-tools.service # 启动
sudo systemctl status kdump-tools.service # 查看状态
```

如果系统有问题发生崩溃，会在`/var/crash`目录下生成`vmcore`文件。

为了验证kdump功能是否可用，我们可以手动触发：
```sh
sudo su root
echo 1 > /proc/sys/kernel/sysrq
echo c > /proc/sysrq-trigger
```

安装`kernel-debuginfo`软件包（必须要是ubuntu server才能找到对应内核版本的软件包），参考[Debug symbol packages](https://ubuntu.com/server/docs/debug-symbol-packages)：
```sh
sudo apt install ubuntu-dbgsym-keyring -y
echo "deb http://ddebs.ubuntu.com $(lsb_release -cs) main restricted universe multiverse
deb http://ddebs.ubuntu.com $(lsb_release -cs)-updates main restricted universe multiverse
deb http://ddebs.ubuntu.com $(lsb_release -cs)-proposed main restricted universe multiverse" | \
sudo tee -a /etc/apt/sources.list.d/ddebs.list
sudo apt-get update -y
sudo apt install linux-image-`uname -r`-dbgsym -y
```

启动crash:
```sh
crash /var/crash/${date-time}/dump.${date-time} /usr/lib/debug/boot/vmlinux-`uname -r`
```

## qemu环境

在qemu环境中运行，不需要安装`kdump`工具。有些发行版默认发生oops时不会panic，需要修改配置（注意这样修改重启后会还原）：
```sh
echo 1 > /proc/sys/kernel/panic_on_oops # 注意不能用 vim 编辑
cat /proc/sys/kernel/panic_on_oops # 确认是否生效
```

按`ctrl + a c`打开QEMU控制台，使用以下命令导出vmcore：
```sh
(qemu) dump-guest-memory /your_path/vmcore
```

除了panic时导出vmcore，还可以手动触发导出vmcore，这在一些场景下收集信息非常有用：
```sh
# 这个命令启用了 Magic SysRq 键。Magic SysRq 键提供了一组能够直接与内核进行交互的调试和故障排除功能。
# 当启用 Magic SysRq 后，您可以使用 Magic SysRq 键与其他键组合来触发特定的操作
echo 1 > /proc/sys/kernel/sysrq
# 这个命令触发了 Magic SysRq 键中的 "c" 操作。在 Magic SysRq 中，"c" 表示让内核立即进行系统内核转储。
# 这对于在系统发生严重故障时收集调试信息非常有用。
echo c > /proc/sysrq-trigger
```

启动crash：
```sh
# 启动crash
crash vmlinux vmcore

# 加载ko模块：
crash> help mod # 帮助命令
crash> mod -s <module name> <ko path> # 加载
crash> mod -d <module name> # 删除
```

## 源码安装crash

如果内核版本不是最新的（比如4.19或5.10），那么发行版的包管理器安装的crash就可以用，但如果内核版本是最新的，可能就需要通过源码安装crash：
```sh
git clone https://github.com/crash-utility/crash.git
apt-get install autoconf automake libtool -y
cd crash
make -j64 # 如果下载gdb很慢，可以先在其他地方先下载好，放到相应的位置
# make target=ARM64 -j64 # 交叉编译能解析arm64 vmcore的crash
```

