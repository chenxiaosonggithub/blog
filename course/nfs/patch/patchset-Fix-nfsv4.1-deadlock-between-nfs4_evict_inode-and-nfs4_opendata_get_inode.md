分析过程参考[openeuler issue](https://gitee.com/openeuler/kernel/issues/I4DD74)。

# [`dfe1fe75e00e NFSv4: Fix deadlock between nfs4_evict_inode() and nfs4_opendata_get_inode()`](https://patchwork.kernel.org/project/linux-nfs/patch/20210601173634.243152-2-trondmy@kernel.org/)

## 问题描述

在使用 fsstress 压测时，注入网络故障：如断网/丢包，触发进程卡死。

打开文件生成 inode 时，等待相同的 inode 被释放掉。此时 slot 未释放:
```sh
[root@localhost crash]# cat /proc/4241/stack 
[<0>] __wait_on_freeing_inode+0xe2/0x130
[<0>] find_inode+0xcc/0x160
[<0>] ilookup5_nowait+0x7a/0xc0
[<0>] ilookup5+0x3b/0xe0
[<0>] iget5_locked+0x2e/0xc0
[<0>] nfs_fhget+0x10b/0x7f0
[<0>] _nfs4_opendata_to_nfs4_state+0x4de/0x500
[<0>] nfs4_do_open.constprop.37+0x630/0xe60
[<0>] nfs4_atomic_open+0x12/0x30
[<0>] nfs_atomic_open+0x24c/0x8c0
[<0>] path_openat+0xad4/0x1de0
[<0>] do_filp_open+0xab/0x150
[<0>] do_sys_open+0x252/0x340
[<0>] __x64_sys_open+0x25/0x30
[<0>] do_syscall_64+0xa1/0x440
[<0>] entry_SYSCALL_64_after_hwframe+0x44/0xa9
```

释放 inode 的进程正在等待 delegation 返回完成:
```sh
[root@localhost crash]# cat /proc/56/stack 
[<0>] rpc_wait_bit_killable+0x26/0x100
[<0>] __rpc_wait_for_completion_task+0x37/0x40
[<0>] _nfs4_proc_delegreturn+0x373/0x490
[<0>] nfs4_proc_delegreturn+0x8e/0x1d0
[<0>] nfs_do_return_delegation+0x36/0x60
[<0>] nfs_inode_return_delegation_noreclaim+0x3b/0x50
[<0>] nfs4_evict_inode+0x3d/0xc0
[<0>] evict+0x114/0x300
[<0>] dispose_list+0x68/0xa0
[<0>] prune_icache_sb+0x62/0x90
[<0>] super_cache_scan+0x169/0x210
[<0>] do_shrink_slab+0x166/0x400
[<0>] shrink_slab+0xfa/0x470
[<0>] shrink_node+0x154/0x690
[<0>] kswapd+0x37f/0xad0
[<0>] kthread+0x169/0x1a0
[<0>] ret_from_fork+0x1f/0x30
```

nfs 状态异常，等待 slot的任务完成后被清空，即等待 4241 号进程完成:
```sh
[root@localhost crash]# cat /proc/6624/stack 
[<0>] nfs4_drain_slot_tbl+0x8e/0xa0
[<0>] nfs4_begin_drain_session.isra.4+0x61/0x70
[<0>] nfs4_run_state_manager+0x48f/0xdf0
[<0>] kthread+0x169/0x1a0
[<0>] ret_from_fork+0x1f/0x30
```

## 代码分析

```c
// 回收inode
evict
  nfs4_evict_inode
    nfs_inode_return_delegation_noreclaim
      nfs_do_return_delegation
        nfs4_proc_delegreturn
          _nfs4_proc_delegreturn
            .flags = RPC_TASK_ASYNC, // 异步
            rpc_run_task
              rpc_new_task
                rpc_alloc_task
                rpc_init_task
                  task->tk_action = rpc_prepare_task
              rpc_execute // 在内核线程异步执行
            __rpc_wait_for_completion_task
              rpc_wait_bit_killable // 在这里等

// 内核线程
__rpc_execute
  rpc_prepare_task
    nfs4_delegreturn_prepare // .rpc_call_prepare
      nfs4_setup_sequence
        nfs4_slot_tbl_draining
          test_bit(NFS4_SLOT_TBL_DRAINING
        // 睡着了，所以evict()在__rpc_wait_for_completion_task()中等
        rpc_sleep_on

nfs4_run_state_manager
  nfs4_state_manager
    nfs4_bind_conn_to_session
      nfs4_begin_drain_session
        nfs4_drain_slot_tbl
          set_bit(NFS4_SLOT_TBL_DRAINING,
          reinit_completion
          // 等待slot清空，下面的代码未执行
          wait_for_completion_interruptible // 在nfs4_slot_tbl_drain_complete()中唤醒
    nfs4_end_drain_session
      nfs4_end_drain_slot_table
        test_and_clear_bit(NFS4_SLOT_TBL_DRAINING,
```

# [`c3aba897c6e6 NFSv4: Fix second deadlock in nfs4_evict_inode()`](https://patchwork.kernel.org/project/linux-nfs/patch/20210601173634.243152-1-trondmy@kernel.org/)

# [`5483b904bf33 SUNRPC: Should wake up the privileged task firstly.`](https://patchwork.kernel.org/project/linux-nfs/patch/20210626075042.805548-3-zhangxiaoxu5@huawei.com/)

```c
nfs41_sequence_free_slot
  nfs41_release_slot
    nfs41_wake_and_assign_slot
      __nfs41_wake_and_assign_slot
        rpc_wake_up_first
          rpc_wake_up_first_on_wq(nfs41_assign_slot)
            __rpc_find_next_queued
              __rpc_find_next_queued_priority
            nfs41_assign_slot // func(task, data)
              nfs4_slot_tbl_draining
            rpc_wake_up_task_on_wq_queue_action_locked
```

```c
nfs4_setup_sequence
  tbl  = client->cl_slot_tbl == NULL // cl_slot_tbl只有4.0才会在nfs40_init_client()初始化
  tbl = &session->fc_slot_table
  nfs4_alloc_slot // 找不到空闲的slot
  rpc_sleep_on_priority
```

```c
nfs4_session.fc_slot_table.slot_tbl_waitq.priority = 1
nfs4_session.fc_slot_table.slot_tbl_waitq.tasks[0] = {}
nfs4_session.fc_slot_table.slot_tbl_waitq.tasks[1] = {GETATTR, OPEN ...}
nfs4_session.fc_slot_table.slot_tbl_waitq.tasks[2] = {}
nfs4_session.fc_slot_table.slot_tbl_waitq.tasks[3] = {DELEGRETURN}
```

# [`fcb170a9d825 SUNRPC: Fix the batch tasks count wraparound.`](https://patchwork.kernel.org/project/linux-nfs/patch/20210626075042.805548-2-zhangxiaoxu5@huawei.com/)

