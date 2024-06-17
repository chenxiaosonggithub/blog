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
