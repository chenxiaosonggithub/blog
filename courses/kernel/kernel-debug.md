除前面我们介绍过的GDB调试方法只适用于虚拟机中，我们平时看代码学习时可以用一下，如果是在工作中客户遇到的问题，GDB调试方法就用不上了，这时就需要用到其他调试方法了。

# `kdump`和`crash`

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

# `crash`常用命令

## `help`命令

用于查看命令的用法。

```sh
crash> help # 查看支持的所有命令

crash> help bt # 查看具体命令（bt）的用法
```

## `bt`命令

```sh
crash> bt # 查看崩溃瞬间正在运行的进程的内核栈

crash> bt <pid> # 查看指定pid进程的栈

# -F[F]：类似于 -f，不同之处在于当适用时以符号方式显示堆栈数据；如果堆栈数据引用了 slab cache 对象，将在方括号内显示 slab cache 的名称；在 ia64 架构上，将以符号方式替代参数寄存器的内容。如果输入 -F 两次，并且堆栈数据引用了 slab cache 对象，将同时显示地址和 slab cache 的名称在方括号中。
crash> bt -F
crash> bt -FF

# -f：显示堆栈帧中包含的所有数据；此选项可用于确定传递给每个函数的参数；在 ia64 架构上，将显示参数寄存器的内容。
crash> bt -f
```

其他选项：

- `-t`: 显示文本符号。
- `-l`: 显示文件名、行号。

## `dis`命令

```sh
# -l: 显示源代码行号
# -s: 显示源代码
crash> dis function_name # 输出函数的反汇编结果
```

## `mod`命令

```sh
crash> mod # 显示所有模块的信息
crash> mod -s <module name> <ko path> # 加载
crash> mod -d <module name> # 删除
crash> mod -S # 从某个特定目录加载所有模块，默认从/lib/modules/`uname -r` 目录
```

# `ftrace`

<!--
https://cloud.tencent.com/developer/article/1429041

```shell
#!/bin/bash
func_name=do_dentry_open

echo nop > /sys/kernel/debug/tracing/current_tracer
echo 0 > /sys/kernel/debug/tracing/tracing_on
echo $$ > /sys/kernel/debug/tracing/set_ftrace_pid # 当前脚本程序的pid
echo function_graph > /sys/kernel/debug/tracing/current_tracer
echo $func_name > /sys/kernel/debug/tracing/set_graph_function
echo 1 > /sys/kernel/debug/tracing/tracing_on
exec "$@" # 用 $@ 进程替换当前shell进程，并且保持PID不变, 注意后面的命令不会执行

cat /sys/kernel/debug/tracing/trace > ftrace_output
```
-->
```sh
CONFIG_FTRACE=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_FUNCTION_TRACER=y
CONFIG_IRQSOFF_TRACER=y
CONFIG_SCHED_TRACER=y
# CONFIG_ENABLE_DEFAULT_TRACERS # 这个好像必须要关闭
CONFIG_FTRACE_SYSCALLS=y
CONFIG_PREEMPT_TRACER=y
```

`/sys/kernel/debug/tracing/`目录下的常见tracer和event如下：

- `available_tracers`: 支持的跟踪器。
- `available_events`: 支持的事件。
- `current_tracer`: 当前正在使用的跟踪器，默认为`nop`。
- `trace`: 用`cat`命令查看跟踪信息。
- `tracing_on`: 开启或暂停。
- `options`: 选项。

# `kprobe`

- [csdn luckyapple1028](https://blog.csdn.net/luckyapple1028?type=blog)

## `tracepoint`

比如我们要打开`ext2_dio_read_begin`函数的tracepoint：
```sh
find /sys/kernel/debug/tracing/events/ -name "*ext2*" # 查找函数所在位置
echo 1 > /sys/kernel/debug/tracing/events/nfs/ext2_dio_read_begin/enable # 使能函数的tracepoint
```

## `kprobe`命令

kprobe的使用如下：
```sh
# 可以用 kprobe 跟踪的函数
cat /sys/kernel/debug/tracing/available_filter_functions

# x86_64函数参数用到的寄存器：RDI, RSI, RDX, RCX, R8, R9
# aarch64函数参数用到的寄存器：X0 ~ X7
# wb_bytes 在 nfs_page 结构体中的偏移为 56， x32代表32位（4字节），注意 rdi 寄存器要写成 di
echo 'p:p_nfs_end_page_writeback nfs_end_page_writeback wb_bytes=+56(%di):x32' >> /sys/kernel/debug/tracing/kprobe_events
echo 1 > /sys/kernel/debug/tracing/events/kprobes/p_nfs_end_page_writeback/enable
echo stacktrace > /sys/kernel/debug/tracing/events/kprobes/p_nfs_end_page_writeback/trigger
echo '!stacktrace' > /sys/kernel/debug/tracing/events/kprobes/p_nfs_end_page_writeback/trigger
echo 0 > /sys/kernel/debug/tracing/events/kprobes/p_nfs_end_page_writeback/enable
echo '-:p_nfs_end_page_writeback' >> /sys/kernel/debug/tracing/kprobe_events

# kretprobe，可以跟踪函数返回值
# 注意要用单引号
echo 'r:r_nfs4_atomic_open nfs4_atomic_open ret=$retval' >> /sys/kernel/debug/tracing/kprobe_events
echo 1 > /sys/kernel/debug/tracing/events/kprobes/r_nfs4_atomic_open/enable
echo stacktrace > /sys/kernel/debug/tracing/events/kprobes/r_nfs4_atomic_open/trigger
echo '!stacktrace' > /sys/kernel/debug/tracing/events/kprobes/r_nfs4_atomic_open/trigger
echo 0 > /sys/kernel/debug/tracing/events/kprobes/r_nfs4_atomic_open/enable
echo '-:r_nfs4_atomic_open' >> /sys/kernel/debug/tracing/kprobe_events

echo 0 > /sys/kernel/debug/tracing/trace # 清除trace信息
cat /sys/kernel/debug/tracing/trace_pipe
```

## 插入`kprobe`模块

参考<!-- public begin -->[kprobes](https://gitee.com/chenxiaosonggitee/blog/blob/master/courses/kernel/kprobes)<!-- public end --><!-- private begin -->`kernel/kprobes`里的例子<!-- private end -->。

# `systemtap`

- [Systemtap tutorial](https://sourceware.org/systemtap/)
- [systemtap源码](https://sourceware.org/git/?p=systemtap.git;a=tree)
- [源码中的例子](https://sourceware.org/git/?p=systemtap.git;a=tree;f=testsuite/systemtap.examples;h=816fa8005086a2fcec91a82883aec4956a1ae96c;hb=HEAD)

基于`kprobe`，典型的应用是列出前几个调用次数最多的系统调用。

安装：
```sh
sudo apt install systemtap -y
sudo dnf install systemtap -y
```

使用：
`hello-world.stp`文件如下：
```sh
probe begin
{
  print ("hello world\n")
  exit ()
}
```

运行：
```sh
stap hello-world.stp
# 报错： Incorrect version or missing kernel-devel package, use: dnf install kernel-devel-6.8.5-301.fc40.x86_64

dnf install kernel-devel-6.8.5-301.fc40.x86_64 -y

stap hello-world.stp # 再次运行
hello world

# 或者编译成ko再运行
stap -m helloword hello-word.stp
staprun helloword.ko
```