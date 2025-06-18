[与社区交流的英文网页](https://chenxiaosong.com/en/nfs/en-null-ptr-deref-in-nfsd4_probe_callback.html)。

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

[点击这里查看日志](https://github.com/chenxiaosonggithub/tmp/blob/master/nfs/null-ptr-deref-in-nfsd4_probe_callback-vmcore.md)。

# vmcore分析

[详细的crash命令的输出请点击这里查看](https://github.com/chenxiaosonggithub/tmp/blob/master/nfs/null-ptr-deref-in-nfsd4_probe_callback-vmcore.md)。

```sh
rpm2cpio kernel-debuginfo-4.19.90-52.39.v2207.ky10.aarch64.rpm | cpio -div
crash usr/lib/debug/lib/modules/4.19.90-52.39.v2207.ky10.aarch64/vmlinux vmcore
crash> mod -s nfsd
crash> mod -s sunrpc
```

## 崩溃的地方

查看崩溃的栈:
```sh
crash> bt
     PC: ffff000048111014  [__queue_work+180]
```

反汇编:
```sh
crash> dis -l __queue_work
...
/usr/src/debug/kernel-4.19.90/linux-4.19.90-52.39.v2207.ky10.aarch64/kernel/workqueue.c: 577
# unbound_pwq_by_node() -> rcu_dereference_raw()
0xffff000048110ff8 <__queue_work+152>:	sxtw	x0, w0
0xffff000048110ffc <__queue_work+156>:	add	x0, x0, #0x22
/usr/src/debug/kernel-4.19.90/linux-4.19.90-52.39.v2207.ky10.aarch64/./include/linux/compiler.h: 310
# rcu_dereference_raw() -> READ_ONCE() -> __READ_ONCE() -> __read_once_size()
0xffff000048111000 <__queue_work+160>:	ldr	x19, [x24,x0,lsl #3] # pwq的值
...
/usr/src/debug/kernel-4.19.90/linux-4.19.90-52.39.v2207.ky10.aarch64/kernel/workqueue.c: 1400
0xffff000048111010 <__queue_work+176>:	cbnz	x0, 0xffff000048111100 <__queue_work+416>
# 将寄存器 X19 中的值作为内存地址，从该地址读取 64 位数据，并将其存入寄存器 X2
0xffff000048111014 <__queue_work+180>:	ldr	x2, [x19] # 访问pwq->pool
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

## `callback_wq`

```sh
crash> rd callback_wq
ffff000042a55a70:  ffff80010eb50600
```

再查看`__queue_work()`的反汇编:
```sh
...
0xffff000048110f74 <__queue_work+20>:	mov	x24, x1 # 将寄存器 x1 中的值复制到寄存器 x24 中
...
0xffff000048110f8c <__queue_work+44>:	ldr	w0, [x24,#256] # 从内存地址 x24 + 256 处加载 32 位数据 到寄存器 w0 中
...
0xffff000048110fdc <__queue_work+124>:	add	x1, x26, #0xb48 # 将寄存器 x26 的值与立即数 0xb48 相加，结果存入寄存器 x1
...
0xffff000048111000 <__queue_work+160>:	ldr	x19, [x24,x0,lsl #3] # 数组array地址: x24 + (x0 << 3), 访问以 8 字节为单位的数组array中，第 x0 个元素，然后把它的值存到 x19
...
```

aarch64架构下整数参数使用的寄存器依次为: `x0~x7`，`__queue_work()`的第二个参数`struct workqueue_struct *wq`的值为`X24: ffff80042c343400`。

和当前的`callback_wq`的值不一样。

```sh
crash> struct workqueue_struct ffff80042c343400
struct workqueue_struct {
...
  dfl_pwq = 0x0, 
...
```

<!--
再查看其中的`flags`成员的值:
```sh
crash> struct workqueue_struct ffff80042c343400 -x
struct workqueue_struct {
  ...
  flags = 0xa0002, # WQ_UNBOUND == 2
  ...
}
```
-->

# 代码分析

在`__queue_work()`中发生空指针解引用:
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
                        if (wq->flags & WQ_UNBOUND) { // 条件满足
                        if (last_pool && last_pool != pwq->pool) { // pwq为NULL
```

`nfsd: last server has exited`短时间打印了两次，说明有两个进程同时执行到`nfsd_last_thread()`:
```c
nfsd_startup_net
  nfsd_startup_generic
    nfsd_users++
    nfs4_state_start
      nfsd4_create_callback_queue
        callback_wq = alloc_ordered_workqueue()

nfsd_last_thread
  nfsd_shutdown_net
    nfs4_state_shutdown_net
      nfs4_state_destroy_net
        destroy_client
          __destroy_client
            nfsd4_shutdown_callback
              flush_workqueue               
    nfsd_shutdown_generic  
      --nfsd_users
      nfs4_state_shutdown               
        nfsd4_destroy_callback_queue    
          destroy_workqueue(callback_wq)
            if (!(wq->flags & WQ_UNBOUND)) { // 条件不满足
            wq->dfl_pwq = NULL
            put_pwq_unlocked
  printk(KERN_WARNING "nfsd: last server has exited, flushing export cache\n")
```

并发的场景如下:
```sh
   task A (cpu 1)    |   task B (cpu 2)     |   task C (cpu 3)
---------------------|----------------------|---------------------------------
nfsd_startup_generic | nfsd_startup_generic |
  nfsd_users == 0    |  nfsd_users == 0     |
  nfsd_users++       |  nfsd_users++        |
  nfsd_users == 1    |                      |
  ...                |                      |
  callback_wq == xxx |                      |
---------------------|----------------------|---------------------------------
                     |                      | nfsd_shutdown_generic
                     |                      |   nfsd_users == 1
                     |                      |   --nfsd_users
                     |                      |   nfsd_users == 0
                     |                      |   ...
                     |                      |   callback_wq == xxx
                     |                      |   destroy_workqueue(callback_wq)
---------------------|----------------------|---------------------------------
                     |  nfsd_users == 1     |
                     |  ...                 |
                     |  callback_wq == yyy  |
```

# 解决方案

合入以下两个补丁:

- `38f080f3cd19 NFSD: Move callback_wq into struct nfs4_client`
- [nfsd: convert the nfsd_users to atomic_t](https://lore.kernel.org/all/20250618104123.398603-1-chenxiaosong@chenxiaosong.com/)

<!--
# 不相关的补丁

不相关的补丁就别看了，对你可能没啥卵用，只是记录一下。

## 查找

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

[`2025-03-10 1054e8ffc5c4 nfsd: prevent callback tasks running concurrently Jeff Layton <jlayton@kernel.org>`补丁分析](https://chenxiaosong.com/course/nfs/patch/patchset-nfsd-dont-allow-concurrent-queueing-of-workqueue-jobs.html)。

这些补丁经过分析都不相关。

## 4.19合补丁

前置补丁:

```sh
12357f1b2c8e nfsd: minor 4.1 callback cleanup
2bbfed98a4d8 nfsd: Fix races between nfsd4_cb_release() and nfsd4_shutdown_callback()
b95239ca4954 nfsd: make nfsd4_run_cb a bool return function
```

4.19可不合的前置补丁:
```sh
# 引入 nfs4_cb_getattr
c5967721e106 NFSD: handle GETATTR conflict with write delegation
# 引入 deleg_reaper
44df6f439a17 NFSD: add delegation reaper to react to low memory condition
# 引入 nfsd4_send_cb_offload
e72f9bc006c0 NFSD: Add nfsd4_send_cb_offload()
# 引入 nfsd4_do_async_copy （其中的部分代码独立成nfsd4_send_cb_offload）
e0639dc5805a NFSD introduce async copy feature
```
-->

