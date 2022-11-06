[toc]

# ftrace

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

# TODO: crash

# tracepoint & kprobe

```shell
find -name /sys/kernel/debug/tracing/events/ nfs_getattr_enter
echo 1 > /sys/kernel/debug/tracing/events/nfs/nfs_getattr_enter/enable

# 可以用 kprobe 跟踪的函数
cat /sys/kernel/debug/tracing/available_filter_functions

# wb_bytes 在 nfs_page 结构体中的偏移为 56， x32代表32位（4字节）
# 注意x86_64第四个参数的寄存器和系统调用不一样（普通函数为 cx，系统调用为 r10），使用 man syscall 查看系统调用参数寄存器, 注意 rdi 寄存器要写成 di
echo 'p:p_nfs_end_page_writeback nfs_end_page_writeback wb_bytes=+56(%di):x32' >> /sys/kernel/debug/tracing/kprobe_events
echo 1 > /sys/kernel/debug/tracing/events/kprobes/p_nfs_end_page_writeback/enable
echo stacktrace > /sys/kernel/debug/tracing/events/kprobes/p_nfs_end_page_writeback/trigger
echo '!stacktrace' > /sys/kernel/debug/tracing/events/kprobes/p_nfs_end_page_writeback/trigger
echo 0 > /sys/kernel/debug/tracing/events/kprobes/p_nfs_end_page_writeback/enable
echo '-:p_nfs_end_page_writeback' > /sys/kernel/debug/tracing/kprobe_events

# 注意要用单引号
echo 'r:r_nfs4_atomic_open nfs4_atomic_open ret=$retval' >> /sys/kernel/debug/tracing/kprobe_events
echo 1 > /sys/kernel/debug/tracing/events/kprobes/r_nfs4_atomic_open/enable
echo stacktrace > /sys/kernel/debug/tracing/events/kprobes/r_nfs4_atomic_open/trigger
echo '!stacktrace' > /sys/kernel/debug/tracing/events/kprobes/r_nfs4_atomic_open/trigger
echo 0 > /sys/kernel/debug/tracing/events/kprobes/r_nfs4_atomic_open/enable
echo '-:r_nfs4_atomic_open' > /sys/kernel/debug/tracing/kprobe_events

echo 0 > /sys/kernel/debug/tracing/trace # 清除trace信息
cat /sys/kernel/debug/tracing/trace_pipe

/sys/kernel/debug/tracing/trace_options # 这个文件是干嘛的？
```

# sunrpc 调试开关

```shell
echo 0x0008 > /proc/sys/sunrpc/nfs_debug # NFSDBG_PAGECACHE        0x0008
echo 0x0002 > /proc/sys/sunrpc/rpc_debug # RPCDBG_CALL             0x0002
echo 0xFFFF > /proc/sys/sunrpc/nfs_debug # NFSDBG_ALL              0xFFFF
echo 0x7fff > /proc/sys/sunrpc/rpc_debug # RPCDBG_ALL              0x7fff
```

# qemu gdb 调试

## 内核编译

```shell
CONFIG_DEBUG_SECTION_MISMATCH=y # 防止内联
CONFIG_DEBUG_INFO=y
CONFIG_DEBUG_KERNEL=y
CONFIG_FRAME_POINTER=y # Makefile 中选择GCC编译选项
CONFIG_GDB_SCRIPTS=y # gdb python
CONFIG_RANDOMIZE_BASE = n
```

`O1`优化等级可以编译通过。

`O0`优化等级无法编译:
尝试`CONFIG_JUMP_LABEL=n`还是不行

`Og`优化等级经过修改可以编译通过

## qemu启动

```shell
-append "nokaslr ..." # 防止地址随机化，编译内核时关闭 CONFIG_RANDOMIZE_BASE
-S # 挂起 gdbserver
-gdb tcp::5555
-s # -gdb tcp::1234, 默认端口1234
```
## gdb 调试

```shell
gdb vmlinux
target remote:5555
b func_name # 普通断点
hb func_name # 硬件断点，有些函数普通断点不会停下, 如: nfs4_atomic_open，降低优化等级后没这个问题
```

使用内核提供的[GDB辅助调试功能](https://www.kernel.org/doc/Documentation/dev-tools/gdb-kernel-debugging.rst)：
```shell
echo "source /home/sonvhi/.gdb-linux/vmlinux-gdb.py" > ~/.gdbinit
mkdir ~/.gdb-linux/
make scripts_gdb # 在 linux 仓库下执行
cp scripts/gdb/* ~/.gdb-linux/ -rf
vim ~/.gdb-linux/vmlinux-gdb.py # sys.path.insert(0, "/home/sonvhi/.gdb-linux")

(gdb) apropos lx
(gdb) p $lx_current().pid
```

gdb 打印结构体偏移：
```shell
gdb ./cifs.ko
(gdb) p &((struct cifsFileInfo *)0)->tlink
```

## module

进入qemu虚拟机中：
```shell
cd /sys/module/ext4/sections/ # ext4 为模块名
cat .text .data .bss
```

在gdb窗口中：
```shell
add-symbol-file <ko文件> <text段地址> -s .data <data段地址> -s .bss <bss段地址>
```

# 源码安装 gdb

```shell
sudo apt install python-dev -y
sudo apt install python3-dev -y
../configure --with-python=/usr/bin/ --prefix=/home/sonvhi/chenxiaosong/sw/gdb
```

