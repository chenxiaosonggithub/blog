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

[点击这里查看日志](https://gitee.com/chenxiaosonggitee/tmp/blob/master/nfs/null-ptr-deref-in-nfsd4_probe_callback-vmcore.md#dmesg)。

# vmcore分析

```sh
rpm2cpio kernel-debuginfo-4.19.90-52.39.v2207.ky10.aarch64.rpm | cpio -div
crash usr/lib/debug/lib/modules/4.19.90-52.39.v2207.ky10.aarch64/vmlinux vmcore
crash> mod -s nfsd
crash> mod -s sunrpc
```

[查看崩溃的栈](https://gitee.com/chenxiaosonggitee/tmp/blob/master/nfs/null-ptr-deref-in-nfsd4_probe_callback-vmcore.md#bt):
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
                queue_work // include/linux/workqueue.h
                  queue_work_on
                    __queue_work
                      if (last_pool && last_pool != pwq->pool) { // pwq为NULL
```

