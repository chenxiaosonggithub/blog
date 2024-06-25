除前面我们介绍过的GDB调试方法只适用于虚拟机中，我们平时看代码学习时可以用一下，如果是在工作中客户遇到的问题，GDB调试方法就用不上了，这时就需要用到其他调试方法了。

# `ftrace`

名字来源于 function trace。

<!--
https://cloud.tencent.com/developer/article/1429041

```shell
#!/bin/bash
func_name=do_dentry_open

cd /sys/kernel/debug/tracing/
echo nop > current_tracer
echo 0 > tracing_on
echo $$ > set_ftrace_pid # 当前脚本程序的pid
echo function_graph > current_tracer
echo $func_name > set_graph_function
echo 1 > tracing_on
exec "$@" # 用 $@ 进程替换当前shell进程，并且保持PID不变, 注意后面的命令不会执行

cat trace > ftrace_output # 在脚本中这个命令不会执行
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
CONFIG_DYNAMIC_FTRACE=y
```

`/sys/kernel/debug/tracing/`目录下的常见tracer和event如下：

- `available_tracers`: 支持的跟踪器。
- `available_events`: 支持的事件。
- `current_tracer`: 当前正在使用的跟踪器，默认为`nop`。
- `trace`: 用`cat`命令查看跟踪信息。
- `tracing_on`: 开启或暂停。
- `options`: 选项。

## `irqsoff`

跟踪中断延迟。

```sh
cd /sys/kernel/debug/tracing/
echo 0 > options/function-trace # 为了减少延迟
echo irqsoff > current_tracer
echo 1 > tracing_on
... # 停一会儿，收集日志
echo 0 > tracing_on
cat trace_pipe | less
```

## `function`和`function_graph`

跟踪函数。

```sh
cd /sys/kernel/debug/tracing/
cat available_filter_functions # 查看可跟踪的函数
echo 0 > tracing_on
cat set_ftrace_pid
echo 1234 > set_ftrace_pid # 指定pid
echo ext2_readdir > set_graph_function # 跟踪某个函数
# echo function > current_tracer
echo function_graph > current_tracer # 更加直观
echo 1 > tracing_on
... # 收集日志
echo 0 > tracing_on
cat trace_pipe | less
```

还可以指定要跟踪和不跟踪的函数，需要打开配置`CONFIG_DYNAMIC_FTRACE`：
```sh
echo func1 func2 > set_ftrace_filter # 要跟踪的函数
echo func3 func4 > set_ftrace_notrace # 不跟踪的函数
echo 'ext2_*' >> set_ftrace_filter # ext2_ 开头的函数
echo '*ext4*' >> set_ftrace_notrace # 包含ext4的函数
echo > set_ftrace_notrace # 清空
```

## `tracepoint`

比如我们要打开`ext2_dio_read_begin`函数的tracepoint：
```sh
cd /sys/kernel/debug/tracing/
echo nop > current_tracer
echo 1 > tracing_on
cat available_events  | grep ext2
echo ext2:ext2_dio_read_begin > set_event
# find events/ -name "*ext2*" # 也可以查找函数所在位置，比较慢
# echo 1 > events/ext2/ext2_dio_read_begin/enable # 使能函数的tracepoint
# echo ext2:* > set_event # 所有的ext2跟踪点

echo 1234567890 > /mnt/file-in # ext2文件系统
dd if=/mnt/file-in of=/mnt/file-out iflag=direct bs=1 count=10
cat trace_pipe
```

到相应`tracepoint`的目录下，设置跟踪条件：
```sh
cd /sys/kernel/debug/tracing/
cd events/ext2/ext2_dio_read_begin
ls # enable  filter  format  hist  id  trigger
```

## `trace-cmd`和`kernelshark`

```sh
sudo apt install trace-cmd -y
sudo apt install kernelshark -y # 图形界面
```

使用按照`reset -> record -> stop -> report`:
```sh
trace-cmd record -h # 查看帮助
trace-cmd record -e 'ext2_dio_read_begin' # 输出文件 trace.dat
kernelshark trace.dat #  图形化查看数据
```

## `trace_marker`

```sh
cd /sys/kernel/debug/tracing/
echo nop > current_tracer # 必须要是nop
echo 1 > tracing_on
echo "hello trace_marker" > trace_marker
echo 0 > tracing_on
cat trace_pipe | less
```

# `kprobe`

- [Documentation/trace](https://github.com/torvalds/linux/tree/master/Documentation/trace)
- [csdn luckyapple1028](https://blog.csdn.net/luckyapple1028?type=blog)

## `kprobe` on `ftrace`

kprobe的使用如下：
```sh
cd /sys/kernel/debug/tracing/
# 可以用 kprobe 跟踪的函数
cat available_filter_functions

# x86_64函数参数用到的寄存器：RDI, RSI, RDX, RCX, R8, R9
# aarch64函数参数用到的寄存器：X0 ~ X7
# f_mode 在 file 结构体中的偏移为 20, x32代表32位（4字节），注意 rdi 寄存器要写成 di
echo 'p:p_ext2_readdir ext2_readdir file=+20(%di):x32' >> kprobe_events
echo 1 > events/kprobes/p_ext2_readdir/enable
echo stacktrace > events/kprobes/p_ext2_readdir/trigger
echo '!stacktrace' > events/kprobes/p_ext2_readdir/trigger
echo 0 > events/kprobes/p_ext2_readdir/enable
echo '-:p_ext2_readdir' >> kprobe_events

# kretprobe，可以跟踪函数返回值
# 注意要用单引号
echo 'r:r_ext2_readdir ext2_readdir ret=$retval' >> kprobe_events
echo 1 > events/kprobes/r_ext2_readdir/enable
echo stacktrace > events/kprobes/r_ext2_readdir/trigger
echo '!stacktrace' > events/kprobes/r_ext2_readdir/trigger
echo 0 > events/kprobes/r_ext2_readdir/enable
echo '-:r_ext2_readdir' >> kprobe_events

echo 0 > trace # 清除trace信息
cat trace_pipe
```

## 插入`kprobe`模块

参考<!-- public begin -->[kprobes](https://gitee.com/chenxiaosonggitee/blog/blob/master/courses/kernel/kprobes)<!-- public end --><!-- private begin -->`kernel/kprobes`里的例子<!-- private end -->。

# 打印

## `printk`

8个打印等级：
```c
#define KERN_EMERG      KERN_SOH "0"    /* 系统不可用 */              
#define KERN_ALERT      KERN_SOH "1"    /* 需要立刻处理 */
#define KERN_CRIT       KERN_SOH "2"    /* 紧急 */             
#define KERN_ERR        KERN_SOH "3"    /* 错误 */                
#define KERN_WARNING    KERN_SOH "4"    /* 警告 */              
#define KERN_NOTICE     KERN_SOH "5"    /* 重要提示 */
#define KERN_INFO       KERN_SOH "6"    /* 提示 */                   
#define KERN_DEBUG      KERN_SOH "7"    /* 调试信息 */            
```

默认配置是等级高于`CONFIG_CONSOLE_LOGLEVEL_DEFAULT`会打印，qemu启动时可以指定`append="... loglevel=8`。

`/proc/sys/kernel/printk`文件中的内容含义如下：
```c
int console_printk[4] = {                                             
        CONSOLE_LOGLEVEL_DEFAULT,       /* 控制台输出等级 */        
        MESSAGE_LOGLEVEL_DEFAULT,       /* 默认消息输出等级 */
        CONSOLE_LOGLEVEL_MIN,           /* 最低输出等级 */
        CONSOLE_LOGLEVEL_DEFAULT,       /* 默认控制台输出等级，启动时 */
};                                                                    
```

常用的输出函数有`print_hex_dump()`和`dump_stack()`。

`include/asm-generic/bug.h`文件中的`BUG_ON(condition)`当满足条件（`condition == true`）时会panic。`WARN_ON(condition)`当满足条件（`condition == true`）时不会panic，只会打印信息。

## 动态打印

打开配置`CONFIG_DYNAMIC_DEBUG`。

```sh
cd /sys/kernel/debug/dynamic_debug/
cat control | less # 查看所有的动态打印
echo 'file fs/ext4/extents.c +p' > control # 打开文件中所有的动态打印
echo 'module ext4 -p' > control # 关闭ext4模块所有动态打印
echo 'func ext4_ext_binsearch +p' > control # 打开某个函数的打印
echo -n '*ext4* -p' > control # 关闭文件路径中包含ext4的打印
echo -n '+p' > control # 所有打印
```

系统启动相关的代码（如`smpboot`），需要在启动时传递参数：
```sh
# p: 打开
# f: 函数名
# l: 行号
# m: 模块名
# t: 线程id
qemu-system-x86_64 -append "... smpboot.dyndbg=+plftm"
```

也可以修改子系统的`Makefile`，添加以下内容：
```sh
ccflags-y += -DDEBUG
ccflags-y += -DVERBOSE_DEBUG
```

# `kdump`和`crash`

<!-- https://github.com/gatieme/LDD-LinuxDeviceDrivers/blob/master/study/debug/tools/systemtap/01-install/README.md -->

## fedora环境

以fedora40为例。

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
sudo dnf install kernel-devel-`uname -r` -y #  kernel-headers-`uname -r` 可能会找不到
```

启动crash:
```sh
crash /var/crash/${ip}-${date-time}/vmcore /usr/lib/debug/lib/modules/`uname -r`/vmlinux
```

如果要编译外部模块，需要复制`vmlinux`:
```sh
cp /usr/lib/debug/lib/modules/`uname -r`/vmlinux /usr/lib/modules/`uname -r`/build/
```

## ubuntu环境

以ubuntu24.04为例。

安装工具：
```sh
sudo apt-get update -y
sudo apt install linux-crashdump -y
sudo apt install crash -y
```
<!--
重新编译内核:
```sh
cp /boot/config-6.8.0-35-generic build/.config
make O=build menuconfig # 清除 CONFIG_SYSTEM_TRUSTED_KEYS 和 CONFIG_SYSTEM_REVOCATION_KEYS 的值
make O=build -j8
```
-->

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
```sh
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

安装`kernel-debuginfo`软件包（必须要是ubuntu server才能找到对应内核版本的软件包），参考[Debug symbol packages](https://ubuntu.com/server/docs/debug-symbol-packages)，（如果安装下载很慢，[也可以在仓库先下载好](http://ddebs.ubuntu.com/pool/main/l/linux/)）：
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

如果要编译外部模块，需要复制`vmlinux`:
```sh
cp /usr/lib/debug/boot/vmlinux-`uname -r` /usr/lib/modules/`uname -r`/build/
```

## qemu环境

<!-- https://blog.csdn.net/yanghao23/article/details/135892612 -->

qemu启动的命令行最好指定`-append "nokaslr ..."`。

在qemu环境中运行，不需要安装`kdump`工具。有些发行版默认发生oops时不会panic，需要修改配置（注意这样修改重启后会还原）：
```sh
echo 1 > /proc/sys/kernel/panic_on_oops # 注意不能用 vim 编辑
cat /proc/sys/kernel/panic_on_oops # 确认是否生效
```

按`ctrl + a c`打开QEMU控制台，使用以下命令导出vmcore：
```sh
(qemu) dump-guest-memory /your_path/vmcore
(qemu) dump-guest-memory -z /your_path/vmcore # 压缩
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

`x86_64`启动`crash`：
```sh
crash vmlinux vmcore
```

`aarch64`启动`crash`要特殊处理：
```sh
# 先启动gdb打印变量值
(gdb) target remote:5555
(gdb) p /x kimage_voffset # 在我的虚拟机中值为 0xffff80003fe00000
crash vmlinux vmcore -m vabits_actual=48 -m kimage_voffset=0xffff80003fe00000
```

加载ko模块：
```sh
crash> help mod # 帮助命令
crash> mod -s <module name> <ko path> # 加载
crash> mod -d <module name> # 删除
```

## 源码安装crash

如果内核版本不是最新的（比如4.19或5.10），那么发行版的包管理器安装的crash就可以用，但如果内核版本是最新的，可能就需要通过源码安装crash：
```sh
git clone https://github.com/crash-utility/crash.git
sudo apt-get install autoconf automake libtool texinfo -y
cd crash
make -j64 # 如果下载gdb很慢，可以先在其他地方先下载好（如 http://ftp.gnu.org/gnu/gdb/gdb-10.2.tar.gz），放到相应的位置
# make target=ARM64 -j64 # 交叉编译能解析arm64 vmcore的crash
```

## `crash`常用命令

`help`命令:
```sh
crash> help # 查看支持的所有命令
crash> help bt # 查看具体命令（bt）的用法
```

`bt`命令:
```sh
crash> bt # 查看崩溃瞬间正在运行的进程的内核栈
crash> bt <pid> # 查看指定pid进程的栈
# -F[F]：类似于 -f，不同之处在于当适用时以符号方式显示堆栈数据；如果堆栈数据引用了 slab cache 对象，将在方括号内显示 slab cache 的名称；在 ia64 架构上，将以符号方式替代参数寄存器的内容。如果输入 -F 两次，并且堆栈数据引用了 slab cache 对象，将同时显示地址和 slab cache 的名称在方括号中。
crash> bt -F
crash> bt -FF
# -f：显示堆栈帧中包含的所有数据；此选项可用于确定传递给每个函数的参数；在 ia64 架构上，将显示参数寄存器的内容。
crash> bt -f
# 其他选项：
-t: 显示文本符号。
-l: 显示文件名、行号。
```

`dis`命令:
```sh
# -l: 显示源代码行号
# -s: 显示源代码
crash> dis function_name # 输出函数的反汇编结果
```

`mod`命令:
```sh
crash> mod # 显示所有模块的信息
crash> mod -s <module name> <ko path> # 加载
crash> mod -d <module name> # 删除
crash> mod -S # 从某个特定目录加载所有模块，默认从/lib/modules/`uname -r` 目录
```

`sym`命令（解析符号信息）：
```sh
crash> sym -l # 相当于查看 System.map
crash> sym -m ubifs # 查看某个内核模块
crash> sym -q ext2 # 查看包含ext2字符串的符号信息
```

`rd`命令用于读取内存地址的值：
```sh
# -p: 物理地址
# -u: 用户空间虚拟地址
# -d: 10进制
# -s: 显示符号
# -32: 32位宽
# -64: 64位宽
# -a: ascii码
crash> rd 0xffff888005462800 20 # 读20个值
```

`struct`命令：
```sh
crash> struct ext2_inode # 显示结构体定义
crash> struct ext2_inode -o # 偏移
crash> struct ext2_inode ffff88800dc59820 # 解析值
crash> struct ext2_inode.i_mtime ffff88800dc59820 # 某个成员的值
```

`p`命令：
```sh
crash> p jiffies
crash> p ext2_readdir # 输出函数符号地址
crash> p irq_stat # percpu变量，定义在 arch/x86/kernel/irq.c 中
crash> p irq_stat:0 # cpu 0
```

`irq`中断相关信息：
```sh
# -a: 中断亲和性
# -s: 系统中断信息
crash> irq # 所有中断
crash> irq 0 # 第0个中断
crash> irq -b # 下半部
```

`task`命令显示`struct task_struct`和`struct thread_info`的内容：
```sh
crash> task -x # 16进制
```

`vm`命令显示进程地址空间：
```sh
# -p: 虚拟地址和物理地址
# -m: mm_struct
# -R: 搜索
# -v: 所有 vm_area_struct
# -f num: 显示num在vm_flags对应的位
crash> vm # 崩溃瞬间进程
crash> vm 575 # 指定pid
```

`kmem`显示内存信息：
```sh
crash> kmem -i # 系统内存使用情况
crash> kmem -s # slab使用情况
crash> kmem -v # vmalloc
crash> kmem -V # vm_stat
crash> kmem -z # zone
crash> kmem -p # page
crash> kmem -g # page flag
```

`list`命令：
```sh
crash> list super_blocks
# -s: 链表成员
# -h: 链表头地址，这里可以用 p super_blocks 获取
crash> list -s super_block.s_blocksize_bits,s_maxbytes -h 0xffff888005462800
crash> list -h 0xffff888005462800 | wc -l # 链表长度
```

## 例子

构造一个空指针访问的场景：
```sh
diff --git a/fs/ext2/dir.c b/fs/ext2/dir.c
index b335f17f682f..01893352b0bb 100644
--- a/fs/ext2/dir.c
+++ b/fs/ext2/dir.c
@@ -266,6 +266,9 @@ ext2_readdir(struct file *file, struct dir_context *ctx)
        bool need_revalidate = !inode_eq_iversion(inode, file->f_version);
        bool has_filetype;
 
+       file = NULL;
+       file->f_pos = 2;
+
        if (pos > inode->i_size - EXT2_DIR_REC_LEN(1))
                return 0;
```

<!-- ing begin -->

# `oops`

发生`oops`时，除了导出`vmcore`后使用`crash`分析外，还可以用其他方法分析。

编译外部模块时，要在`Makefile`中指定`KBUILD_CFLAGS += -g`参数添加符号信息表。

```sh
# 交叉编译用 aarch64-linux-gnu-objdump

```

# `perf`

## 编译

在内核编译环境上，在内核代码目录下：
```sh
# 根据 make 命令报错提示安装
sudo apt install -y libdw-dev systemtap-sdt-dev libunwind-dev libslang2-dev libperl-dev libzstd-dev libcap-dev libnuma-dev libbabeltrace-ctf-dev libpfm4-dev libtraceevent-dev

cd tools/perf
# export ARCH=arm64
# export CROSS_COMPILE=aarch64-linux-gnu-
make -j8
```

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
<!-- ing end -->