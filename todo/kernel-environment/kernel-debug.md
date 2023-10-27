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

