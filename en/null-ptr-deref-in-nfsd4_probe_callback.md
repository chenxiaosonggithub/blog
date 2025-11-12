[中文分析过程请点击这里查看](https://chenxiaosong.com/course/nfs/issue/null-ptr-deref-in-nfsd4_probe_callback.html)。

# Environment

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

# Issue

We had a null-ptr-deref in `nfsd4_probe_callback()`:
```sh
crash> dmesg
[24225.575708] nfsd: last server has exited, flushing export cache
[24225.580242] NFSD: starting 90-second grace period (net f0000030)
[24225.738349] Unable to handle kernel NULL pointer dereference at virtual address 0000000000000000
...
[24225.803480] Call trace:
[24225.804639]  __queue_work+0xb4/0x558
[24225.805949]  queue_work_on+0x88/0x90
[24225.807306]  nfsd4_probe_callback+0x4c/0x58 [nfsd]
[24225.807458] NFSD: starting 90-second grace period (net f0000030)
[24225.808896]  nfsd4_probe_callback_sync+0x20/0x38 [nfsd]
[24225.808909]  nfsd4_init_conn.isra.57+0x8c/0xa8 [nfsd]
[24225.815204]  nfsd4_create_session+0x5b8/0x718 [nfsd]
[24225.817711]  nfsd4_proc_compound+0x4c0/0x710 [nfsd]
[24225.819329]  nfsd_dispatch+0x104/0x248 [nfsd]
[24225.820742]  svc_process_common+0x348/0x808 [sunrpc]
[24225.822294]  svc_process+0xb0/0xc8 [sunrpc]
[24225.823760]  nfsd+0xf0/0x160 [nfsd]
[24225.825006]  kthread+0x134/0x138
[24225.826336]  ret_from_fork+0x10/0x18
[24225.827722] Code: aa1c03e0 97ffffba aa0003e2 b5000780 (f9400262)
[24225.829444] SMP: stopping secondary CPUs
[24225.838583] Starting crashdump kernel...
[24225.842579] Bye!
```

# Analysis from vmcore

[Click here to view the complete vmcore information](https://github.com/chenxiaosonggithub/tmp/blob/master/nfs/null-ptr-deref-in-nfsd4_probe_callback-vmcore.md).

## `dmesg`

`"NFSD: starting 90-second grace period"` was printed twice in a very short period.

```sh
crash> dmesg
[24225.575708] nfsd: last server has exited, flushing export cache
[24225.580242] NFSD: starting 90-second grace period (net f0000030)
[24225.738349] Unable to handle kernel NULL pointer dereference at virtual address 0000000000000000
...
[24225.807458] NFSD: starting 90-second grace period (net f0000030)
...
[24225.838583] Starting crashdump kernel...
[24225.842579] Bye!
```

## `bt` {#bt}

```sh
crash> bt
PID: 2772769  TASK: ffff8004296f7d00  CPU: 24  COMMAND: "nfsd"
 #0 [ffff80043786f5b0] machine_kexec at ffff0000480a2e8c
 #1 [ffff80043786f610] __crash_kexec at ffff0000481ba948
 #2 [ffff80043786f780] crash_kexec at ffff0000481baa58
 #3 [ffff80043786f7b0] die at ffff00004808f65c
 #4 [ffff80043786f7f0] die_kernel_fault at ffff0000480b1ef0
 #5 [ffff80043786f820] __do_kernel_fault at ffff0000480b1bc4
 #6 [ffff80043786f850] do_page_fault at ffff000048c7a650
 #7 [ffff80043786f930] do_translation_fault at ffff000048c7ab44
 #8 [ffff80043786f960] do_mem_abort at ffff0000480812c4
 #9 [ffff80043786fb40] el1_ia at ffff000048082f0c
     PC: ffff000048111014  [__queue_work+180]
     LR: ffff00004811100c  [__queue_work+172]
     SP: ffff80043786fb50  PSTATE: 60c00085
    X29: ffff80043786fb50  X28: ffff80042b644ef8  X27: ffff000049f44aa8
    X26: ffff0000498b3000  X25: 0000000000000400  X24: ffff80042c343400
    X23: 0000000000000018  X22: ffff000049f44a88  X21: ffff000049480018
    X20: 0000000000000017  X19: 0000000000000000  X18: 0000000000000001
    X17: 0000fffd9fe76608  X16: ffff000048368b48  X15: 0000ffffd5c4cfa8
    X14: 0000000000000000  X13: 0000000032306564  X12: 6f6e2d73386b0a00
    X11: 00000a101cde0100  X10: 0000000000000004   X9: 0000000000000000
     X8: ffff80042e54b000   X7: 951ff3846835fec9   X6: 0000000000000002
     X5: 0000000000000000   X4: ffff8001d5fdd298   X3: 0000000000000000
     X2: 0000000000000000   X1: 000000007fffffff   X0: 0000000000000000
#10 [ffff80043786fb50] __queue_work at ffff000048111010
#11 [ffff80043786fbc0] queue_work_on at ffff00004811153c
#12 [ffff80043786fbf0] nfsd4_probe_callback at ffff000042a231e8 [nfsd]
#13 [ffff80043786fc10] nfsd4_probe_callback_sync at ffff000042a23214 [nfsd]
#14 [ffff80043786fc30] nfsd4_init_conn at ffff000042a16178 [nfsd]
#15 [ffff80043786fc60] nfsd4_create_session at ffff000042a18aa4 [nfsd]
#16 [ffff80043786fcd0] nfsd4_proc_compound at ffff000042a07504 [nfsd]
#17 [ffff80043786fd40] nfsd_dispatch at ffff0000429f1ed0 [nfsd]
#18 [ffff80043786fd80] svc_process_common at ffff000042588d34 [sunrpc]
#19 [ffff80043786fe00] svc_process at ffff0000425892a4 [sunrpc]
#20 [ffff80043786fe20] nfsd at ffff0000429f1884 [nfsd]
#21 [ffff80043786fe70] kthread at ffff00004811a870
```

## Disassemble `__queue_work()` {#disassemble-__queue_work}

```sh
crash> dis -l __queue_work
...
/usr/src/debug/kernel-4.19.90/linux-4.19.90-52.39.v2207.ky10.aarch64/kernel/workqueue.c: 577
# unbound_pwq_by_node() -> rcu_dereference_raw()
0xffff000048110ff8 <__queue_work+152>:	sxtw	x0, w0
0xffff000048110ffc <__queue_work+156>:	add	x0, x0, #0x22
/usr/src/debug/kernel-4.19.90/linux-4.19.90-52.39.v2207.ky10.aarch64/./include/linux/compiler.h: 310
# rcu_dereference_raw() -> READ_ONCE() -> __READ_ONCE() -> __read_once_size()
0xffff000048111000 <__queue_work+160>:	ldr	x19, [x24,x0,lsl #3] # ==> pwq == X19: 0000000000000000
...
/usr/src/debug/kernel-4.19.90/linux-4.19.90-52.39.v2207.ky10.aarch64/kernel/workqueue.c: 1400
0xffff000048111010 <__queue_work+176>:	cbnz	x0, 0xffff000048111100 <__queue_work+416>
0xffff000048111014 <__queue_work+180>:	ldr	x2, [x19] # ==> dereference pwq->pool
```

## Where the code crashed

Crashed in `__queue_work()`, `pwq == NULL`:
```c
  1360 static void __queue_work(int cpu, struct workqueue_struct *wq,
  1361                          struct work_struct *work)
  ...
  1399         last_pool = get_work_pool(work);
> 1400         if (last_pool && last_pool != pwq->pool) { ==> pwq == NULL
  1401                 struct worker *worker;
```

## `callback_wq` {#callback_wq}

```sh
crash> dis -l __queue_work
...
0xffff000048110f74 <__queue_work+20>:	mov	x24, x1 # x1 == second arg `wq`
...
```

`x24` hasn’t been overwritten, so the value of `wq`(second arg of `__queue_work()`) is `X24: ffff80042c343400`, it is value of `callback_wq`.
```sh
crash> struct workqueue_struct ffff80042c343400
struct workqueue_struct {
...
  dfl_pwq = 0x0, # has already been freed
...
```

But the current value of `callback_wq` is different from `X24`:
```sh
crash> rd callback_wq
ffff000042a55a70:  ffff80010eb50600
```

# Solution

Merge the following patches:

- [`[PATCH 08/20] 3409e4f1e8f2 NFSD: Make it possible to use svc_set_num_threads_sync`](https://lore.kernel.org/all/163816148557.32298.11233238491435215789.stgit@noble.brown/)

