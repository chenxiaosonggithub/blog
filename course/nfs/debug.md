本文介绍一下我尝试过的nfs定位问题的常用方法，非权威，欢迎指正。

# 日志 {#log}

发生问题时，报错日志肯定是很有用的信息，大部分发行版都会把日志放在`/var/log/messages*`文件中，默认情况下，nfs只会打印错误信息。
但有些时候，我们需要一些调试日志信息，这时就要打开nfs和rpc的调试开关。注意要使用调试开关的功能，编译时需要打开配置`CONFIG_SUNRPC_DEBUG`。

几个打印相关的宏定义是`dprintk()`、`dprintk_cont()`、`dprintk_rcu()`、`dprintk_rcu_cont`，下面以`dprintk()`为例讲一下这个宏定义的展开:
```c
// include/linux/sunrpc/debug.h
dprintk(fmt, ...)
  dfprintk(FACILITY, fmt, ##__VA_ARGS__)
    ifdebug(fac)
      // include/linux/sunrpc/debug.h
      if (unlikely(rpc_debug & RPCDBG_FACILITY))
      // include/linux/nfs_fs.h
      if (unlikely(nfs_debug & NFSDBG_FACILITY))
      // fs/nfsd/nfsd.h
      if (nfsd_debug & NFSDDBG_FACILITY)
      // include/linux/lockd/debug.h
      if (unlikely(nlm_debug & NLMDBG_FACILITY))
    printk(KERN_DEFAULT fmt, ##__VA_ARGS__);
```

当然也可直接调用`dfprintk()`、`dfprintk_cont()`、`dfprintk_rcu()`、`dfprintk_rcu_cont()`。

以下是打开全部日志的命令，注意这将会打印大量日志，请先把`/var/log/messages*`复制保存到其他位置，避免错误日志被覆盖:
```sh
echo 0xFFFF > /proc/sys/sunrpc/nfs_debug # NFSDBG_ALL
echo 0x7fff > /proc/sys/sunrpc/rpc_debug # RPCDBG_ALL
echo 0x7FFF > /proc/sys/sunrpc/nfsd_debug # NFSDDBG_ALL
echo 0x7fff > /proc/sys/sunrpc/nlm_debug # NLMDBG_ALL
```

如果你缩小了定位的范围，可以只打开某些日志:
```sh
echo 0x0008 > /proc/sys/sunrpc/nfs_debug # NFSDBG_PAGECACHE
echo 0x0040 > /proc/sys/sunrpc/rpc_debug # RPCDBG_SCHED
echo 0x0400 > /proc/sys/sunrpc/nfsd_debug # NFSDDBG_PNFS
echo 0x0008 > /proc/sys/sunrpc/nlm_debug # NLMDBG_SVCLOCK
```

写`/proc/sys/sunrpc/rpc_debug`文件时会打印出很多rpc任务:
```sh
-pid- flgs status -client- --rqstp- -timeout ---ops--
57533 4201      0 159b39a4   (null)        0 43ff7b9f nfsv4 WRITE a:rpc_prepare_task [sunrpc] q:ForeChannel Slot table
```

相关代码流程如下:
```c
proc_dodebug
  // 只有写 rpc_debug 文件才会打印rpc任务
  if (strcmp(table->procname, "rpc_debug") == 0)
  rpc_show_tasks
    list_for_each_entry(clnt, &sn->all_clients,
    list_for_each_entry(task, &clnt->cl_tasks, // 存在任务才会打印
    rpc_show_header
    rpc_show_task
```

### `mydebug`模块打印

请查看[《内核调试方法》](https://chenxiaosong.com/course/kernel/debug.html#mydebug)。

# tracepoint

除了日志，还可以打开tracepoint，尤其是最新主线代码的sunrpc中的`dprintk()`很多都移除了，有些sunrpc相关信息也只能通过tracepoint查看了。tracepoint的使用请查看[《内核调试方法》](https://chenxiaosong.com/course/kernel/debug.html#tracepoint)。

```sh
cd /sys/kernel/debug/tracing/
echo nop > current_tracer
echo 1 > tracing_on
cat available_events  | grep nfs # nfs nfsd nfs_localio
cat available_events  | grep rpc # rpcgss sunrpc
ls events/*nfs* -d
  # events/nfs  events/nfsd  events/nfs_localio
ls events/*rpc* -d
  # events/rpcgss  events/sunrpc
echo nfsd:nfsd_cb_recall_done > set_event # 打开某个tracepoint
echo rpcgss:* > set_event # 打开所有的rpcgss跟踪点
# echo 1 > events/nfsd/nfsd_cb_recall_done/enable # 打开某个tracepoint
# echo 1 > events/rpcgss/enable # 打开所有的rpcgss跟踪点
echo 0 > trace # 清除trace信息
cat trace_pipe
```

# tcpdump抓包 {#tcpdump}

既然nfs涉及到网络，定位问题肯定也少不了网络抓包，甚至在绝大多数情况下，网络抓包能够比日志提供更有用更直观的信息，使用`tcpdump`工具抓包:
```sh
# --interface: 指定要监听的网络接口，any表示所有的网络接口
# --buffer-size: 默认4KB, 单位 KB, 20480 代表 20MB。buffer大一点可以防止抓包数据丢失
tcpdump --interface=<网络接口> --buffer-size=20480 -w out.cap
```

当数据量比较大时，有时会发生抓包数据丢失。配置网络参数，把参数调大可以防止抓包数据丢失:
```sh
sysctl -a | grep net.core.rmem # 查看配置
sysctl net.core.rmem_default=xxx
sysctl net.core.rmem_max=xxx
```

`tcpdump`抓包的文件，可以使用[`wireshark`](https://www.wireshark.org/)分析。如果要查看端口，需要在`preferences -> appearance -> columns`中添加`Src port (unresolved)`和`Dest port (unresolved)`。

# 重新挂载

在生产环境下，如果出现问题，很多时候可能没有很多时间可以保留现场，可能需要重新挂载快速恢复。

请注意，在`umount`之前，务必收集好需要的调试信息，因为很多问题可能一年半载也只会出现那么一次。

`umount <挂载点>`命令如果报错`device is busy`之类的信息，说明挂载点正在使用，可以使用以下命令查看使用挂载点的进程:
```sh
# +D：递归地列出指定目录下所有打开的文件
lsof +D <挂载点>
# -m：表示查询挂载点（而不仅仅是某个文件）
fuser -m <挂载点>
```

可能的原因请查看[《umount nfs报错device is busy的问题》](https://chenxiaosong.com/course/nfs/issue/nfs-umount-device-is-busy.html)。

如果找到的使用挂载点的进程非常重要，kill这些进程会导致重大问题，可以使用以下命令延迟卸载，会导致挂载点在后台被卸载，而不会强制终止进程:
```sh
umount --lazy <挂载点>
```

如果找到的使用挂载点的进程没有那么重要，建议还是kill掉这些进程再卸载，这样才能更彻底的恢复环境:
```sh
kill -SIGKILL <进程号>
umount <挂载点>
```

# crash分析vmcore {#crash-vmcore}

vmcore中的信息有时对分析问题很有帮助。

如果能保留问题环境，先尝试在线调试vmcore:
```sh
crash vmlinux # 在线调试，vmcore是/proc/kcore
```

在生产环境下，如果必须要快速恢复环境，且这个环境是可以接受重启系统，就可以尝试手动导出vmcore:
```sh
echo 1 > /proc/sys/kernel/sysrq
echo c > /proc/sysrq-trigger
```

关于vmcore的更详细内容，请查看[内核调试方法](https://chenxiaosong.com/course/kernel/debug.html#kdump-crash)。

如果要让内核在hungtask或softlockup等情况触发panic，可以执行以下操作:
```sh
sysctl -w kernel.softlockup_panic=1 # -w：表示“写”操作，用来修改内核参数
sysctl -w kernel.hung_task_panic=0
sysctl kernel.softlockup_panic # 查看
# 或者用以下命令
echo 1 > /proc/sys/kernel/softlockup_panic # 和sysctl命令效果一样
echo 0 > /proc/sys/kernel/hung_task_panic
cat /proc/sys/kernel/softlockup_panic # 查看
```

# 非特权源端口挂载

默认情况下，nfs client挂载使用的源端口是小于1024的特权端口（Privileged Ports），需要root权限。

但在某些情况下，无法挂载时，可以尝试使用大于1024的非特权端口挂载，这对排查问题很有帮助。

首先，server端的`/etc/exports`文件中对导出路径增加`insecure`选项，如:
```sh
/tmp/ *(rw,no_root_squash,fsid=0,insecure)
```

重启server端服务:
```sh
systemctl restart nfs-server.service
```

这时client端可以使用所有范围的端口挂载，默认情况下还是使用小于1024的端口，而大于1024的端口要指定挂载选项`noresvport`:
```sh
mount -t nfs -o noresvport ${server_ip}:/ /mnt
```

请注意，使用非特权源端口挂载在一些场景下是不安全的（从server端的配置选项的字面意思`insecure`就能看出），尽量只在调试场景下使用。

在我曾经定位过的nfs问题中，有碰到过路由器或交换机出于产品的某些原因，把小于1024的端口的数据包都给过滤了，当时就是使用非特权源端口挂载的方法排除其他可能性，最终定位出问题。

# 问题定位步骤 {#step}

- 查询挂载参数: `mount | grep nfs`，用于分析代码或复现
- tcpdump抓包: `tcpdump --interface=<网络接口> --buffer-size=20480 -w out.cap`，如果不确定`<网络接口>`可填`any`
- nfs client打开日志开关:
  - `echo 0xFFFF > /proc/sys/sunrpc/nfs_debug # NFSDBG_ALL`
  - `echo 0x7fff > /proc/sys/sunrpc/rpc_debug # RPCDBG_ALL`
  - `echo 0x7fff > /proc/sys/sunrpc/nlm_debug # NLMDBG_ALL, 如果需要定位nfsv3的NLM（网络锁管理协议），还要打开这个，但一般不涉及`
- nfs server打开日志开关:
  - `echo 0x7fff > /proc/sys/sunrpc/rpc_debug # RPCDBG_ALL`
  - `echo 0x7FFF > /proc/sys/sunrpc/nfsd_debug # NFSDDBG_ALL`
  - `echo 0x7fff > /proc/sys/sunrpc/nlm_debug # NLMDBG_ALL, 如果需要定位nfsv3的NLM（网络锁管理协议），还要打开这个，但一般不涉及`
- 跟踪系统调用: `strace -o strace.txt -f -v -s 4096 -tt -T <这里填上要测试的命令>`
- 以上步骤可用[下面章节的“调试脚本”](https://chenxiaosong.com/course/nfs/debug.html#script)自动完成
- 如果可以接受重启系统，就可以尝试手动导出vmcore，具体方法查看[上面的“crash分析vmcore“](https://chenxiaosong.com/course/nfs/debug.html#crash-vmcore)

# 调试脚本 {#script}

## nfs client调试脚本 {#client-script}

client脚本要和server脚本同时执行（如果server也要调试的话）。

```sh
mnt_point=/mnt/ # 修改为nfs挂载点
test_cmd="df ${mnt_point}" # 测试命令
net_interface=any # 网络接口（比如eth0或enp2s0之类的），如果不确定就填any
log_time=60s # 日志收集时长
log_dir=$(pwd)/dmesg-log/ # 日志保存目录
strace_file=$(pwd)/strace.txt
strace_cmd="strace -o ${strace_file} -f -v -s 4096 -tt -T ${test_cmd}" # 用strace跟踪系统调用

cap_file=$(pwd)/nfs_client.cap
tcpdump_cmd="tcpdump --interface=${net_interface} --buffer-size=20480 -w ${cap_file}"

echo "打开nfs日志开头"
${tcpdump_cmd} &
tcpdump_pid=$! # 记录pid
echo "<1> nfs debug log begin: $(date)" > /dev/kmsg # 内核日志记录当前时间
sync
echo 0xFFFF > /proc/sys/sunrpc/nfs_debug # 打开nfs日志
echo 0x7fff > /proc/sys/sunrpc/rpc_debug # 打开rpc日志
# echo 0x7fff > /proc/sys/sunrpc/nlm_debug # 如果需要定位nfsv3的NLM（网络锁管理协议），还要打开这个，但一般不涉及
sleep 1s
${strace_cmd} & # 后台执行
echo "等一段时间以产生足够多的日志"
sleep ${log_time}
echo 0 > /proc/sys/sunrpc/nfs_debug # 关闭
echo 0 > /proc/sys/sunrpc/rpc_debug # 关闭
# echo 0 > /proc/sys/sunrpc/nlm_debug # 如果需要定位nfsv3的NLM（网络锁管理协议），还要打开这个，但一般不涉及
sync
echo "<1> nfs debug log end: $(date)" > /dev/kmsg # 内核日志记录当前时间
kill -SIGINT ${tcpdump_pid} # 退出tcpdump
sync
sleep 5
rm ${log_dir} -rf
mkdir ${log_dir}
cp /var/log/messages* ${log_dir}
cp /var/log/dmesg* ${log_dir}
mv ${cap_file} ${log_dir}
mv ${strace_file} ${log_dir}
echo "日志已保存到 ${log_dir}/ 目录下"
```

## nfs server调试脚本 {#server-script}

server的脚本和client脚本同时执行。

```sh
log_time=60s # 日志收集时长
log_dir=$(pwd)/dmesg-log/ # 日志保存目录
net_interface=any # 网络接口，如果不确定就填any

cap_file=$(pwd)/nfs_server.cap
tcpdump_cmd="tcpdump --interface=${net_interface} --buffer-size=20480 -w ${cap_file}"

echo "打开nfs日志开头"
${tcpdump_cmd} &
tcpdump_pid=$! # 记录pid
echo "<1> nfsd debug log begin: $(date)" > /dev/kmsg # 内核日志记录当前时间
sync
echo 0x7FFF > /proc/sys/sunrpc/nfsd_debug # 打开nfsd日志
echo 0x7fff > /proc/sys/sunrpc/rpc_debug # 打开rpc日志
# echo 0x7fff > /proc/sys/sunrpc/nlm_debug # 如果需要定位nfsv3的NLM（网络锁管理协议），还要打开这个，但一般不涉及
echo "等一段时间以产生足够多的日志"
sleep ${log_time}
echo 0 > /proc/sys/sunrpc/nfsd_debug # 关闭
echo 0 > /proc/sys/sunrpc/rpc_debug # 关闭
# echo 0x7fff > /proc/sys/sunrpc/nlm_debug # 如果需要定位nfsv3的NLM（网络锁管理协议），还要打开这个，但一般不涉及
sync
echo "<1> nfsd debug log end: $(date)" > /dev/kmsg # 内核日志记录当前时间
kill -SIGINT ${tcpdump_pid} # 退出tcpdump
sync
sleep 5
rm ${log_dir} -rf
mkdir ${log_dir}
cp /var/log/messages* ${log_dir}
cp /var/log/dmesg* ${log_dir}
mv ${cap_file} ${log_dir}
echo "日志已保存到 ${log_dir}/ 目录下"
```

## 获取所有线程的栈 {#get-all_stack}

用以下脚本保存所有线程的栈:
```sh
output_file=stacks.txt
# grep_string="mount" # 进程关键字
# full_cmd_result=$(ps aux | grep "${grep_string}" | grep -v "grep ${grep_string}") # 过滤关键字
full_cmd_result=$(ps aux | sed '1d') # 所有进程，输出要删除第一行标题行
pids=$(echo "${full_cmd_result}" | awk '{print $2}')
> ${output_file} # 清空

if [ -z "$pids" ]; then
    echo "没有找到进程"
    exit 0
fi

echo "找到以下进程：" >> ${output_file}
echo "${full_cmd_result}" >> ${output_file}

echo -e "\n获取进程栈信息：" >> ${output_file}
for pid in $pids; do
    if [ -d "/proc/$pid" ]; then
        # 遍历该进程的所有线程
        for task in /proc/$pid/task/*; do
            tid=$(basename "$task")  # 提取线程ID
            echo -e "\n=============== 进程 $pid 线程 $tid $(echo -n "$(</proc/$pid/task/$tid/comm)") 栈信息 ===============" >> ${output_file}
            sudo cat /proc/$pid/task/$tid/stack >> ${output_file}
            echo "=======================================================" >> ${output_file}
        done
    else
        echo "进程 $pid 已退出" >> ${output_file}
    fi
done
```

