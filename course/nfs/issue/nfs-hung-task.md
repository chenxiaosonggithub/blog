# 问题描述

nfs client使用nfsv4.2挂载，[4.19内核 hung task日志](https://gitee.com/chenxiaosonggitee/tmp/blob/master/nfs/nfs-hung-task-log.txt)。

# 4.19构造复现

在4.19内核上做修改。

nfs server构造收到打开文件的请求后不回复的情况，代码修改如下:
```sh
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -46,6 +46,7 @@
 #include "acl.h"
 #include "pnfs.h"
 #include "trace.h"
+#include <linux/delay.h>
 
 #ifdef CONFIG_NFSD_V4_SECURITY_LABEL
 #include <linux/security.h>
@@ -356,6 +356,11 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
        struct nfsd_net *nn = net_generic(net, nfsd_net_id);
        bool reclaim = false;
 
+       while (1) {
+               printk("%s:%d, sleep\n", __func__, __LINE__);
+               msleep(20 * 1000);
+       }
+
        dprintk("NFSD: nfsd4_open filename %.*s op_openowner %p\n",
                (int)open->op_fname.len, open->op_fname.data,
                open->op_openowner);
```

为了方便，我们用一台机器既做server又做client。测试命令如下:
```sh
# 需要先启动nfs server服务才能挂载成功
mount -t nfs localhost:/ /mnt
echo something > /mnt/file & # 进程575
echo something > /mnt/file & # 进程576
ls /mnt/file & # 进程577
```

等待120秒后就会打印出以下信息:
```sh
[  246.880095] INFO: task bash:576 blocked for more than 120 seconds.
[  246.882393]       Not tainted 4.19.325+ #3
[  246.883871] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  246.886660] bash            D    0   576    515 0x00000000
[  246.888639] Call Trace:
[  246.889567]  __schedule+0x260/0x6e0
[  246.890836]  schedule+0x36/0x80
[  246.891996]  rwsem_down_write_failed+0x19b/0x2c0
[  246.895079]  call_rwsem_down_write_failed+0x17/0x30
[  246.896870]  down_write+0x2d/0x40
[  246.898067]  do_last+0x3c5/0x8b0
[  246.900833]  path_openat+0x8b/0x2c0
[  246.903326]  do_filp_open+0x91/0x130
[  246.907467]  do_sys_open+0x16f/0x200
[  246.908748]  __x64_sys_openat+0x1f/0x30
[  246.910124]  do_syscall_64+0x64/0x1e0
[  246.912958]  entry_SYSCALL_64_after_hwframe+0x5c/0xc1

[15115.362616][  2] INFO: task ls:577 blocked for more than 120 seconds.
[15115.364908][  2]       Not tainted 4.19.90-25+ #74
[15115.366576][  2] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[15115.369399][  2] ls              D    0   999    510 0x00000000
[15115.371439][  2] Call Trace:
[15115.372467][  2]  __schedule+0x2a2/0x800
[15115.373831][  2]  schedule+0x36/0x80
[15115.375090][  2]  rwsem_down_read_failed+0x11c/0x180
[15115.376805][  2]  call_rwsem_down_read_failed+0x18/0x30
[15115.378610][  2]  down_read+0x20/0x40
[15115.379885][  2]  walk_component+0x1eb/0x320
[15115.381371][  2]  path_lookupat+0x82/0x230
[15115.382796][  2]  filename_lookup+0xae/0x1b0
[15115.389022][  2]  user_path_at_empty+0x3a/0x50
[15115.390565][  2]  vfs_statx+0x77/0xf0
[15115.391847][  2]  __se_sys_statx+0x4b/0x90
[15115.396350][  2]  __x64_sys_statx+0x25/0x30
[15115.397804][  2]  do_syscall_64+0x64/0x1e0
[15115.400865][  2]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
```

等待rpc回复的进程:
```sh
cat /proc/575/stack
[<0>] __rpc_wait_for_completion_task+0x2d/0x30
[<0>] nfs4_run_open_task+0x12c/0x1b0
[<0>] _nfs4_open_and_get_state+0x6f/0x430
[<0>] _nfs4_do_open.isra.0+0x17c/0x490
[<0>] nfs4_do_open+0xd3/0x1f0
[<0>] nfs4_atomic_open+0xe7/0x100
[<0>] nfs_atomic_open+0x1d7/0x720
[<0>] atomic_open+0x96/0x260
[<0>] lookup_open+0x316/0x550
[<0>] do_last+0x3df/0x8b0
[<0>] path_openat+0x8b/0x2c0
[<0>] do_filp_open+0x91/0x130
[<0>] do_sys_open+0x16f/0x200
[<0>] __x64_sys_openat+0x1f/0x30
[<0>] do_syscall_64+0x64/0x1e0
[<0>] entry_SYSCALL_64_after_hwframe+0x44/0xa9
```

# 4.19代码分析

```c
do_last
  lookup_open
    inode_lock
      down_write // 写锁
    atomic_open
      nfs_atomic_open
        nfs4_atomic_open
          nfs4_do_open
            _nfs4_do_open
              _nfs4_open_and_get_state
                nfs4_run_open_task
                  .flags = RPC_TASK_ASYNC, // 异步
                  rpc_run_task
                    rpc_execute
                      rpc_make_runnable // 异步执行
                  __rpc_wait_for_completion_task // 等待nfs server回复后唤醒

do_sys_open
  do_filp_open
    path_openat
      do_last
        down_write // 写锁
          call_rwsem_down_write_failed
            rwsem_down_write_failed
              schedule // 让出cpu，超过120秒后报hung_task

__rpc_execute
  call_start // nfs4 proc OPEN (async)
  call_reserve // (status 0)
  call_reserveresult // (status 0)
  call_refresh // (status 0)
  call_refreshresult // (status 0)
  call_allocate // (status 0)
  call_bind // (status 0)
  call_connect // xprt xxxxxxx is connected
  call_transmit // (status 0)
  call_status // (status -110) ETIMEDOUT
  // 第一次调用到call_timeout()
  call_timeout // (minor)
  call_bind // (status 0)
  call_connect // xprt xxxxxxx is connected
  call_transmit // (status 0)
  call_status // (status -110) ETIMEDOUT
  call_timeout // (major)
    // 第二次调用到call_timeout()时才会打印，每个任务只会打印一次
    printk(KERN_NOTICE "%s: server %s not responding, still trying\n"
```

```c
lookup_slow
  down_read // 读锁
    call_rwsem_down_read_failed
      rwsem_down_read_failed
        schedule // 让出cpu，超过120秒后报hung_task
```

# 调试 {#debug}

[参考《nfs client调试脚本》](https://chenxiaosong.com/course/nfs/debug.html#client-script)

如果不想打开日志开头，只想看一下有多少个rpc任务在排队，可以只执行以下命令:
```sh
echo 0 > /proc/sys/sunrpc/rpc_debug
```

