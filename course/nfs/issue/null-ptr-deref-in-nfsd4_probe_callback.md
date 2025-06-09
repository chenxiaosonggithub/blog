# 问题描述

环境信息:
```sh
crash> sys
      KERNEL: usr/lib/debug/lib/modules/4.19.90-52.39.v2207.ky10.aarch64/vmlinux
    DUMPFILE: vmcore  [PARTIAL DUMP]
        CPUS: 32
        DATE: Wed May 28 02:04:57 CST 2025
      UPTIME: 06:43:45
LOAD AVERAGE: 4.08, 4.00, 3.83
       TASKS: 4811
    NODENAME: k8s-node01
     RELEASE: 4.19.90-52.39.v2207.ky10.aarch64
     VERSION: #4 SMP Wed Jun 5 15:52:50 CST 2024
     MACHINE: aarch64  (unknown Mhz)
      MEMORY: 64 GB
       PANIC: "Unable to handle kernel NULL pointer dereference at virtual address 0000000000000000"
```

[点击这里查看日志](https://gitee.com/chenxiaosonggitee/tmp/blob/master/nfs/null-ptr-deref-in-nfsd4_probe_callback-vmcore.md)。

# vmcore分析

```sh
rpm2cpio kernel-debuginfo-4.19.90-52.39.v2207.ky10.aarch64.rpm | cpio -div
crash usr/lib/debug/lib/modules/4.19.90-52.39.v2207.ky10.aarch64/vmlinux vmcore
crash> mod -s nfsd
crash> mod -s sunrpc
```

[查看崩溃的栈](https://gitee.com/chenxiaosonggitee/tmp/blob/master/nfs/null-ptr-deref-in-nfsd4_probe_callback-vmcore.md):
```sh
crash> bt
#10 [ffff80043786fb50] __queue_work at ffff000048111010
...
#12 [ffff80043786fbf0] nfsd4_probe_callback at ffff000042a231e8 [nfsd]
```

[反汇编](https://gitee.com/chenxiaosonggitee/tmp/blob/master/nfs/null-ptr-deref-in-nfsd4_probe_callback-vmcore.md):
```sh
crash> dis -rl ffff000042a231e8
...
/usr/src/debug/kernel-4.19.90/linux-4.19.90-52.39.v2207.ky10.aarch64/fs/nfsd/nfs4callback.c: 1214
0xffff000042a231d8 <nfsd4_probe_callback+56>:   adrp    x1, 0xffff000042a55000 <nfsdstats+120>
/usr/src/debug/kernel-4.19.90/linux-4.19.90-52.39.v2207.ky10.aarch64/./include/linux/workqueue.h: 533
...

crash> dis -rl ffff000048111010
...
/usr/src/debug/kernel-4.19.90/linux-4.19.90-52.39.v2207.ky10.aarch64/kernel/workqueue.c: 1400
0xffff000048111010 <__queue_work+176>:  cbnz    x0, 0xffff000048111100 <__queue_work+416>
```

所以崩溃发生在`nfsd4_run_cb() -> queue_work() -> queue_work_on() -> __queue_work()`。

再结合:
```sh
crash> struct pool_workqueue -o
struct pool_workqueue {
    [0] struct worker_pool *pool;
```

日志中的`... at virtual address 0000000000000000`表明解引用的是`struct pool_workqueue`结构体的第一个成员，所以是在执行到以下代码时发生空指针解引用:
```c
// kernel/workqueue.c: 1400
1400         if (last_pool && last_pool != pwq->pool) { // pwq为NULL
```

# 代码分析

```c
svc_process
  svc_process_common
    nfsd_dispatch // versp->vs_dispatch()
      nfsd4_proc_compound // proc->pc_func()
        nfsd4_create_session // op->opdesc->op_func()
          nfsd4_init_conn
            nfsd4_probe_callback_sync
              nfsd4_probe_callback
                nfsd4_run_cb
                  queue_work // include/linux/workqueue.h
                    queue_work_on
                      __queue_work
                        if (last_pool && last_pool != pwq->pool) { // pwq为NULL
```

# 补丁

```sh
git log origin/master --oneline --date=short --format="%cd %h %s %an <%ae>" --grep=nfsd4_run_cb 
未合入 2025-03-10 1054e8ffc5c4 nfsd: prevent callback tasks running concurrently Jeff Layton <jlayton@kernel.org>
未合入 2025-03-10 230ca758453c nfsd: put dl_stid if fail to queue dl_recall Li Lingfeng <lilingfeng3@huawei.com>
未合入 2025-02-10 036ac2778f7b NFSD: fix hang in nfsd4_shutdown_callback Dai Ngo <dai.ngo@oracle.com>
未合入 2024-03-01 c1ccfcf1a9bf NFSD: Reschedule CB operations when backchannel rpc_clnt is shut down Chuck Lever <chuck.lever@oracle.com>
未合入 2024-02-05 5ea9a7c5fe41 nfsd: don't take fi_lock in nfsd_break_deleg_cb() NeilBrown <neilb@suse.de>
未合入 2022-12-12 3bc8edc98bd4 nfsd: under NFSv4.1, fix double svc_xprt_put on rpc_create failure Dan Aloni <dan.aloni@vastdata.com>
未合入 2022-09-26 b95239ca4954 nfsd: make nfsd4_run_cb a bool return function Jeff Layton <jlayton@kernel.org>
已合入 2020-03-27 1a33d8a284b1 svcrdma: Fix leak of transport addresses Chuck Lever <chuck.lever@oracle.com>
```

```sh
git log origin/master --oneline --date=short --format="%cd %h %s %an <%ae>" --grep=nfsd4_probe_callback
未合入 2021-09-17 02579b2ff8b0 nfsd: back channel stuck in SEQ4_STATUS_CB_PATH_DOWN Dai Ngo <dai.ngo@oracle.com>
```

```sh
git log origin/master --oneline --date=short --format="%cd %h %s %an <%ae>" --grep=nfsd4_create_session
未合入 2024-11-18 d08bf5ea649c NFSD: Remove dead code in nfsd4_create_session() Chuck Lever <chuck.lever@oracle.com>
未合入 2024-03-01 e4469c6cc69b NFSD: Fix the NFSv4.1 CREATE_SESSION operation Chuck Lever <chuck.lever@oracle.com>
```

