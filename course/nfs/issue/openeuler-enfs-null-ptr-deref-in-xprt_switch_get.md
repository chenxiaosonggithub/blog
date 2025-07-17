# 问题描述

测试复现时所用的代码版本是`4467208a8b55 !17003  net_sched: red: fix a race in __red_change()`。

环境信息:
```sh
crash> sys
      KERNEL: x86_64-build/vmlinux  [TAINTED]
    DUMPFILE: ../../../chenxiaosong/zvmcore  [PARTIAL DUMP]
        CPUS: 16 [OFFLINE: 15]
        DATE: Wed Jul  9 17:01:31 CST 2025
      UPTIME: 00:03:46
LOAD AVERAGE: 0.06, 0.03, 0.01
       TASKS: 250
    NODENAME: syzkaller
     RELEASE: 6.6.0+
     VERSION: #25 SMP PREEMPT_DYNAMIC Wed Jul  9 16:27:17 CST 2025
     MACHINE: x86_64  (3700 Mhz)
      MEMORY: 4 GB
       PANIC: "Kernel panic - not syncing: Fatal exception"
```

日志如下:
```sh
[  226.610543] BUG: kernel NULL pointer dereference, address: 0000000000000104
...
[  226.621932] RIP: 0010:xprt_switch_get+0x1a/0x60
...
[  226.644646] Call Trace:
[  226.645323]  <TASK>
[  226.645918]  shard_update_work.constprop.0+0x71/0x220 [enfs]
[  226.647443]  shard_update_loop+0x219/0x290 [enfs]
[  226.650128]  kthread+0xfb/0x130
[  226.652008]  ret_from_fork+0x40/0x60
[  226.653997]  ret_from_fork_asm+0x1b/0x30
...
[  226.680809] ---[ end Kernel panic - not syncing: Fatal exception ]---
```

# 复现步骤

nfs+的使用请查看[《openEuler的nfs+》](https://chenxiaosong.com/course/nfs/openeuler-enfs.html)。

```sh
mount -t nfs -o vers=3,localaddrs=192.168.53.57~192.168.53.214,remoteaddrs=192.168.53.68~192.168.53.225 192.168.53.225:/tmp/s_test /mnt/
modprobe -r enfs
umount /mnt
mount -t nfs -o vers=3,localaddrs=192.168.53.57~192.168.53.214,remoteaddrs=192.168.53.68~192.168.53.225 192.168.53.225:/tmp/s_test /mnt/
# 再过60秒就会panic，必现的哦
```

# vmcore解析

[更详细的输出请点击这里查看](https://gitee.com/chenxiaosonggitee/tmp/blob/master/nfs/openeuler-enfs-null-ptr-deref-in-xprt_switch_get-vmcore.md)。

```sh
crash> dis -l xprt_switch_get
/home/sonvhi/chenxiaosong/code/openeuler-kernel/x86_64-build/../net/sunrpc/xprtmultipath.c: 187
0xffffffff81fa3170 <xprt_switch_get>:   endbr64 
0xffffffff81fa3174 <xprt_switch_get+4>: nopl   0x0(%rax,%rax,1)
/home/sonvhi/chenxiaosong/code/openeuler-kernel/x86_64-build/../net/sunrpc/xprtmultipath.c: 188
0xffffffff81fa3179 <xprt_switch_get+9>: test   %rdi,%rdi
0xffffffff81fa317c <xprt_switch_get+12>:        je     0xffffffff81fa31c6 <xprt_switch_get+86>
/home/sonvhi/chenxiaosong/code/openeuler-kernel/x86_64-build/../net/sunrpc/xprtmultipath.c: 187
0xffffffff81fa317e <xprt_switch_get+14>:        push   %rbp
0xffffffff81fa317f <xprt_switch_get+15>:        mov    %rsp,%rbp
0xffffffff81fa3182 <xprt_switch_get+18>:        push   %rbx
0xffffffff81fa3183 <xprt_switch_get+19>:        mov    %rdi,%rbx # 将寄存器 %rdi 中的值复制到寄存器 %rbx 中
/home/sonvhi/chenxiaosong/code/openeuler-kernel/x86_64-build/../include/linux/kref.h: 111
0xffffffff81fa3186 <xprt_switch_get+22>:        lea    0x4(%rdi),%rdi # 将寄存器 %rdi 的值增加 4（通过地址计算实现，不访问内存）
/home/sonvhi/chenxiaosong/code/openeuler-kernel/x86_64-build/../arch/x86/include/asm/atomic.h: 23
0xffffffff81fa318a <xprt_switch_get+26>:        mov    0x4(%rbx),%edx # 将内存地址 %rbx + 4 处的 32 位值加载到寄存器 %edx 中
```

x86_64下整数参数使用的寄存器依次为: RDI，RSI，RDX，RCX，R8，R9，所以`xprt_switch_get()`的第一个参数是`%rdi`，
通过`mov %rdi,%rbx`把值赋给`%rbx`，而从`bt`输出中可以看到`RBX: 0000000000000100`，再结合`xps_kref`的偏移:
```sh
crash> struct rpc_xprt_switch -o
struct rpc_xprt_switch {
   [0] spinlock_t xps_lock;
   [4] struct kref xps_kref;
...
}
```

所以空指针解引用发生在`xps->xps_kref`。

# 代码分析

```c
shard_update_loop // 在enfs_shard_init创建线程
  query_update_all_clnt
    shard_update_work
      xprt_switch_get
        kref_get_unless_zero
          refcount_inc_not_zero
            atomic_read
              raw_atomic_read
                arch_atomic_read

nfs_multipath_client_info_free
  nfs_multipath_client_info_free_work // INIT_WORK(&clp_info->work

// 挂载时
enfs_insert_clnt_root
  list_add_tail(&info->next

// 卸载时
enfs_delete_clnt_shard_cache
  list_del(&info->next)

nfs_alloc_client
  try_module_get(clp->cl_nfs_mod->owner)

nfs_create_multi_path_client
  nfs_multipath_client_info_init(&client->cl_multipath_data, ...) // ops->client_info_free
    *enfs_info = kzalloc()

nfs_free_multi_path_client
  nfs_multipath_client_info_free // ops->client_info_free
```

