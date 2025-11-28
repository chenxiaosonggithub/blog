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

[更详细的输出请点击这里查看](https://gitee.com/chenxiaosonggitee/tmp/blob/master/gnu-linux/nfs/openeuler-enfs-null-ptr-deref-in-xprt_switch_get-vmcore.md)。

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

第一次挂载后，创建的`clnt_uuid_info`放到链表中，这时如果把`enfs`模块给移除了，再进行卸载nfs时就不会执行到`enfs_release_rpc_clnt()`，
`clnt_uuid_info`就不会从链表中删除。

第二次挂载后，内核线程`shard_update_loop()`就会遍历到第一次挂载时创建的`clnt_uuid_info`，就会发生use-after-free了。

```c
// 挂载时
nfs3_create_server
  nfs_create_server
    nfs_init_server
      nfs_get_client
        nfs_init_client
          nfs_create_multi_path_client
            // 应该和nfs_alloc_client()一样，在client初始化后调用try_module_get()持有模块引用计数
            nfs_multipath_router_get // 执行完这里后模块引用计数为1
              // 应该在这里加载模块，参考get_nfs_version()
            nfs_multipath_client_info_init // ops->client_info_init
              nfs_multipath_client_mount_info_init
            nfs_multipath_router_put // 执行完这里后模块引用计数又变为0了
    nfs_probe_fsinfo
      nfs3_proc_fsinfo
        do_proc_fsinfo
          nfs3_rpc_wrapper
            rpc_call_sync
              rpc_run_task
                rpc_execute
                  __rpc_execute
                    call_start
                      rpc_task_set_transport
                        rpc_multipath_ops_set_transport
                          enfs_set_transport
                            shard_set_transport
                              get_uuid_from_task
                                enfs_insert_clnt_root
                                  // 加入到链表中
                                  list_add_tail(&info->next,

// 卸载时
nfs_free_server
  rpc_shutdown_client
    rpc_multipath_ops_releas_clnt
      /*
       * 如果已经执行了modprobe -r enfs
       * 就不会调用enfs_release_rpc_clnt()
       * clnt_uuid_info还在链表中
       */
      rpc_multipath_ops_get
      enfs_release_rpc_clnt
        enfs_delete_clnt_shard_cache
          list_del(&info->next)
  nfs_put_client
    nfs_free_client
      nfs_free_multi_path_client
        nfs_multipath_client_info_free // ops->client_info_free
        // 应该在这里释放模块引用计数

// 再次挂载后60s
shard_update_loop // 在enfs_shard_init创建线程
  enfs_timeout_ms(..., interval_ms == 60s)
  query_update_all_clnt
    /*
     * 这里会遍历到上次挂载创建的clnt_uuid_info
     * 发生use-after-free
     */
    list_for_each_entry(info,
    shard_update_work
      xprt_switch_get
        kref_get_unless_zero
          refcount_inc_not_zero
            atomic_read
              raw_atomic_read
                arch_atomic_read // panic的栈跑到这里
```

# 代码修改

`fs/nfs/enfs/shard_route.c`只有以下函数在其他文件中有调用:
```c
int enfs_shard_init(void)
void enfs_shard_exit(void)
int enfs_delete_clnt_shard_cache(struct rpc_clnt *clnt)
void enfs_print_uuid(struct enfs_file_uuid *file_uuid)
void shard_set_transport(struct rpc_task *task, struct rpc_clnt *clnt)
int enfs_debug_match_cmd(char *str, size_t len)
void enfs_query_xprt_shard(struct rpc_clnt *clnt, struct rpc_xprt *xprt)
struct shard_view_ctrl *enfs_shard_ctrl_init(void)
```

# 解决方案

[请查看pr](https://gitee.com/openeuler/kernel/pulls/17205/commits)。

