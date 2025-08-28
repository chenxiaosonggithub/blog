分析过程参考[openeuler issue](https://gitee.com/openeuler/kernel/issues/I4DD74)。

# [`dfe1fe75e00e NFSv4: Fix deadlock between nfs4_evict_inode() and nfs4_opendata_get_inode()`](https://patchwork.kernel.org/project/linux-nfs/patch/20210601173634.243152-1-trondmy@kernel.org/)

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

回收inode时，在`evict()`中等待delegreturn请示异步执行完成:
```c
evict
  nfs4_evict_inode
    clear_inode
      // 标记 inode 正在被释放，导致open时在find_inode()中等待
      inode->i_state = I_FREEING | I_CLEAR;
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
              rpc_wait_bit_killable // 在这里等异步执行完成，后面的代码未执行
        nfs_free_delegation
  remove_inode_hash
    __remove_inode_hash
      spin_lock(&inode_hash_lock);
      hlist_del_init_rcu(&inode->i_hash);
      spin_unlock(&inode_hash_lock);
  wake_up_bit(&inode->i_state, __I_NEW); // 唤醒open时find_inode()中的等待
  destroy_inode
    __destroy_inode
    nfs_destroy_inode // inode->i_sb->s_op->destroy_inode
      nfs_i_callback

// 内核线程发送rpc请求
__rpc_execute
  rpc_prepare_task
    nfs4_delegreturn_prepare // .rpc_call_prepare
      nfs4_setup_sequence
        nfs4_slot_tbl_draining
          test_bit(NFS4_SLOT_TBL_DRAINING
        // 睡着了，所以evict()在__rpc_wait_for_completion_task()中等
        rpc_sleep_on
```

打开文件时生成inode，等待`evict()`中唤醒`__I_NEW`标记:
```c
nfs4_atomic_open
  nfs4_do_open
    _nfs4_do_open
      nfs4_opendata_alloc
      _nfs4_open_and_get_state
        _nfs4_proc_open
        _nfs4_opendata_to_nfs4_state
          nfs4_opendata_find_nfs4_state
            nfs4_opendata_get_inode
              nfs_fhget
                iget5_locked
                  ilookup5
                    ilookup5_nowait
                      spin_lock(&inode_hash_lock);  // 加锁
                      find_inode
                        nfs_find_actor // test(inode, data)
                        // 在evict()中被标记
                        if (inode->i_state & (I_FREEING|I_WILL_FREE)) // 条件满足
                        __wait_on_freeing_inode  // 如果找到匹配的 inode，等待可以新建该inode
                          bit_waitqueue(&inode->i_state, __I_NEW); // 在evict()中唤醒
      // 后面的代码未执行
      nfs4_opendata_put // 由于等待 inode 被释放，因此如下的流程未执行，即有 slot 正在被使用
        nfs4_opendata_free
          nfs4_sequence_free_slot
            nfs41_sequence_free_slot
              nfs41_release_slot
                slot->seq_done
                nfs4_free_slot
                  __clear_bit(slotid, tbl->used_slots);
                  nfs4_slot_tbl_drain_complete // 唤醒nfs4_drain_slot_tbl()的的等待
```

内核线程设置slot标记，等待open请求完成清空slot:
```c
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

`evict()`、`open()`、`nfs4_run_state_manager()`互相等待唤醒，造成了死锁。

# [`c3aba897c6e6 NFSv4: Fix second deadlock in nfs4_evict_inode()`](https://patchwork.kernel.org/project/linux-nfs/patch/20210601173634.243152-2-trondmy@kernel.org/)

请看上一个补丁的分析。

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
                // 优先当前优先级的 task，且为避免资源消耗，当前优先级最多处理 nr 个后，开始处理下一个优先级
                queue->tasks[queue->priority];
                // 处理下一个队列的任务
                q = q - 1;
                // 反转到最高优先级的队列进行处理
                q = &queue->tasks[queue->maxpriority];
                // 没有任务要处理，重置当前正在处理的优先级及nr
                rpc_reset_waitqueue_priority
                // 检查优先级，如果当前优先级发生了切换，重置优先级及nr
                rpc_set_waitqueue_priority
            nfs41_assign_slot // func(task, data)
              // 正在清空slot时，只有特权task才会返回true
              if (nfs4_slot_tbl_draining(tbl) && !args->sa_privileged)
            rpc_wake_up_task_on_wq_queue_action_locked
              __rpc_do_wake_up_task_on_wq
                rpc_make_runnable
                  queue_work(wq, &task->u.tk_work); // 异步任务投入运行
                  wake_up_bit(&task->tk_runstate, RPC_TASK_QUEUED);     // 同步任务唤醒__rpc_execute()中的等待
```

```c
nfs4_setup_sequence
  tbl  = client->cl_slot_tbl == NULL // cl_slot_tbl只有4.0才会在nfs40_init_client()初始化
  tbl = &session->fc_slot_table
  nfs4_alloc_slot // 找不到空闲的slot
  rpc_sleep_on_priority
```

如下情况下可能会导致同样的死锁问题：
```c
nfs4_session.fc_slot_table.slot_tbl_waitq.priority = 1
nfs4_session.fc_slot_table.slot_tbl_waitq.tasks[0] = {}
nfs4_session.fc_slot_table.slot_tbl_waitq.tasks[1] = {GETATTR, OPEN ...}
nfs4_session.fc_slot_table.slot_tbl_waitq.tasks[2] = {}
nfs4_session.fc_slot_table.slot_tbl_waitq.tasks[3] = {DELEGRETURN}
```

由于 `tasks[1]` 中为非特权的 task，因此在 `nfs41_assign_slot()` 检查时返回false，进一步导致所有的任务都无法分配slot，就更谈不上释放 slot。进而可能导致无法唤醒 `tasks[3]` 中的任务。

# [`fcb170a9d825 SUNRPC: Fix the batch tasks count wraparound.`](https://patchwork.kernel.org/project/linux-nfs/patch/20210626075042.805548-2-zhangxiaoxu5@huawei.com/)

```c
__rpc_find_next_queued_priority
  // 第一次进入， queue->nr = 1
  if (!list_empty(q) && --queue->nr)  // 执行完后 queue->nr == 1
  goto new_queue; // 只有当前优先级队列上有任务,优先级不变
  rpc_set_waitqueue_priority
    queue->priority != priority // 优先级未发生变化，未更新 queue->nr

__rpc_find_next_queued_priority
  // 第二次进入，queue->nr = 0
  if (!list_empty(q) && --queue->nr) // 此处溢出，queue->nr == 255
    goto out;
```

在 session draining 的时候，由于无法对非特权优先级的任务分配 slot，slot 释放后，普通优先级的任务无法再分配slot，更无法再次释放 slot。
该场景下，如果 slot 的个数小于 255，则所有的 slot 释放后， nr 都不可能减为0，从而导致高优先级的任务无法唤醒。

进一步导致该问题。

另外，如果 slot 的个数小于当前优先级的批处理任务的个数，则同样会导致上述问题。

