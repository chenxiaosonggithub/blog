# 打印

## 内核态server打印

smb server打印函数是`ksmbd_debug()`，相关代码如下:
```c
ksmbd_debug
  // 拼接成 KSMBD_DEBUG_ALL 等宏定义
  if (ksmbd_debug_types & KSMBD_DEBUG_##type)

// 使用宏拼接
CLASS_ATTR_RW(debug)
  struct class_attribute class_attr_debug = __ATTR_RW(debug)
    __ATTR(debug, 0644, debug_show, debug_store)
      .attr = {.name = __stringify(debug),
        __stringify_1(x)
          #debug ==> /sys/class/ksmbd-control/debug文件
      .show   = debug_show,
      .store  = debug_store,

// 还是宏拼接
ATTRIBUTE_GROUPS(ksmbd_control_class)
  ksmbd_control_class_group
  .attrs = ksmbd_control_class_attrs
  __ATTRIBUTE_GROUPS(ksmbd_control_class)
    ksmbd_control_class_groups[] // 引用这个变量的是ksmbd_control_class
    &ksmbd_control_class_group,

static struct class ksmbd_control_class = {
        .name           = "ksmbd-control", ==> /sys/class/ksmbd-control/目录
        .class_groups   = ksmbd_control_class_groups,
};
```

通过读写`/sys/class/ksmbd-control/debug`文件控制，但我们一般不直接操作这个文件，而是用以下命令控制打印的开关:
```sh
ksmbd.control --help # 查看帮助
# COMPONENT的值有: `all', `smb', `auth', `vfs', `oplock', `ipc', `conn', or `rdma'
ksmbd.control --debug=vfs
ksmbd.control --debug= # 不加COMPONENT可以查看当前的状态
```

在熟悉代码阶段，可以默认把日志开关全部打开:
```sh
--- a/fs/smb/server/server.c
+++ b/fs/smb/server/server.c
@@ -22,7 +22,7 @@
 #include "crypto_ctx.h"
 #include "auth.h"
 
-int ksmbd_debug_types;
+int ksmbd_debug_types = KSMBD_DEBUG_ALL;
 
 struct ksmbd_server_config server_conf;
```

## 用户态server打印 {#samba-print}

[用户态server仓库](https://gitlab.com/samba-team/samba)。

修改配置文件`/etc/samba/smb.conf`:
```sh
[global]
# 默认是0
log level = 4
# 日志文件路径
log file = /usr/local/samba/var/log.%m
```

常用的几个`log level`有以下几个:
```c
#define DEBUG_ERR     DBGLVL_ERR     // 0      /* error conditions */
#define DEBUG_WARNING DBGLVL_WARNING // 1      /* warning conditions */
#define DEBUG_NOTICE  DBGLVL_NOTICE  // 3      /* normal, but significant, condition */
#define DEBUG_INFO    DBGLVL_INFO    // 5      /* informational message */
#define DEBUG_DEBUG   DBGLVL_DEBUG   // 10     /* debug-level message */
```

当然，代码中还有使用`DEBUG(11, ...)`、`DEBUG(15, ...)`、`DEBUG(18, ...)`、`DEBUG(19, ...)`等等，最大可用的`log level`为:
```c
#define MAX_DEBUG_LEVEL 1000
```

`log level`的解析在`debug_parse_param()`函数中。

打印函数堆栈用`log_stack_trace()`，比如打印`smbd_parent_loop()`的调用栈的补丁[`0001-dump-stack-of-smbd_parent_loop.patch`](https://gitee.com/chenxiaosonggitee/blog/blob/master/course/smb/src/0001-dump-stack-of-smbd_parent_loop.patch)。

`/usr/local/samba/var/log.smbd`日志文件中的打印结果如下:
```sh
[2025/05/27 22:06:24.110919,  0] ../../lib/util/fault.c:261(log_stack_trace)
  BACKTRACE:
   #0 log_stack_trace + 0x28 [ip=0x7f61f4a4098a] [sp=0x7ffc42cae650]
   #1 smbd_parent_loop + 0x93 [ip=0x409d78] [sp=0x7ffc42caef50]
   #2 main + 0x1a27 [ip=0x40ce2c] [sp=0x7ffc42caef80]
   #3 __libc_start_call_main + 0x78 [ip=0x7f61f480f088] [sp=0x7ffc42caf320]
   #4 __libc_start_main + 0x8b [ip=0x7f61f480f14b] [sp=0x7ffc42caf3c0]
   #5 _start + 0x25 [ip=0x405e95] [sp=0x7ffc42caf420]
```

另外`log_stack_trace()`中的`backtrace_symbols()`没有和`free()`配套使用，注释中说是`free()`可能产生问题。

## client打印

smb client打印函数有`cifs_dbg()`、`cifs_server_dbg()`、`cifs_tcon_dbg()`、`cifs_info()`，要打开配置`CONFIG_CIFS_DEBUG`才有效，打开`CONFIG_CIFS_DEBUG2`和`CONFIG_CIFS_DEBUG_DUMP_KEYS`能打印更多信息，以`cifs_dbg()`为例代码如下:
```c
cifs_dbg
  cifs_dbg_func(once, ...)
    pr_debug_once / pr_err_once
      printk_once(KERN_DEBUG / printk_once(KERN_ERR // 只打印一次
  cifs_dbg_func(ratelimited, ...)
    pr_debug_ratelimited
      __dynamic_pr_debug // 打开配置 CONFIG_DYNAMIC_DEBUG
    pr_err_ratelimited
      printk_ratelimited
        printk
```

动态打印相关的内容请查看[《内核调试方法》](https://chenxiaosong.com/course/kernel/debug.html#dynamic_print)。

通过以下命令控制开关:
```sh
cd /sys/kernel/debug/dynamic_debug/
cat control | less # 查看所有的动态打印
echo 'file fs/smb/client/cifsfs.c +p' > control # 打开文件中所有的动态打印
echo 'module cifs -p' > control # 关闭cifs模块所有动态打印
echo 'func cifs_copy_file_range +p' > control # 打开某个函数的打印
echo -n '*cifs_smb3* -p' > control # 关闭文件路径中包含cifs_smb3的打印
echo -n '+p' > control # 所有打印
```

### `mydebug`模块打印

但在熟悉代码阶段，一个调试打印这么折腾还限制打印次数，对熟悉代码肯定不友好，所以我在熟悉代码阶段用的是[`mydebug`模块](https://chenxiaosong.com/course/kernel/debug.html#mydebug)，
打上[`mydebug`模块](https://chenxiaosong.com/course/kernel/debug.html#mydebug)的补丁后，
再打上补丁[`0001-smb-client-use-mydebug_print.patch`](https://gitee.com/chenxiaosonggitee/blog/blob/master/course/smb/src/0001-smb-client-use-mydebug_print.patch)。

另外可能还会有一些新增的动态打印（使用`pr_debug()`），可以用以下命令查看并打开动态打印:
```sh
cd /sys/kernel/debug/dynamic_debug/
echo 'module cifs +p' > control # 打开cifs模块所有动态打印
cat control | grep cifs
```

# tracepoint

除了日志，还可以打开tracepoint。tracepoint的使用请查看[《内核调试方法》](https://chenxiaosong.com/course/kernel/debug.html#tracepoint)。

```sh
cd /sys/kernel/debug/tracing/
echo nop > current_tracer
echo 1 > tracing_on
cat available_events  | grep cifs
cat available_events  | grep smb
ls events/*cifs* -d
ls events/*smb* -d # 没有
echo cifs:nfsd_cb_recall_done > set_event # 打开某个tracepoint
echo cifs:* > set_event # 打开所有的cifs跟踪点
# echo 1 > events/cifs/smb3_close_enter/enable # 打开某个tracepoint
# echo 1 > events/cifs/enable # 打开所有的cifs跟踪点
echo 0 > trace # 清除trace信息
cat trace_pipe
```

注意目前（2025.05.21）smb server的代码还没有使用任何的tracepoint，但以后可能会用，你可以使用命令`grep -r trace_ fs/smb/server/`在内核仓库下确认。

# tcpdump抓包

请查看[《nfs调试方法》](https://chenxiaosong.com/course/nfs/debug.html#tcpdump)。

# client端重连

在测试和复现bug时，我们需要构造client端重连的场景。

client挂载指定`-o echo_interval=1`（默认是`60`秒）:
```sh
mount -t cifs -o echo_interval=1 //192.168.53.211/TEST /mnt
```

server端操作:
```sh
# 方法1: 停掉网卡
ifconfig ens2 up # client会打印: CIFS: VFS: \\192.168.53.211 has not responded in 3 seconds. Reconnecting...
# 方法2: 也可以直接停掉服务
systemctl stop smb.service # 用户态samba
systemctl stop ksmbd.service # 内核态ksmbd
```

`server_unresponsive()`中判断当server端`3 * server->echo_interval`时间不回复时，打印`has not responded in %lu seconds. Reconnecting...`。

