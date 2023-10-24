[toc]

问题现象: 写数据时检测到 NFS_CONTEXT_BAD， 报错 EBADF

# NFS_CONTEXT_BAD 处理流程

解压文件时，检测到ctx->open_flags有NFS_CONTEXT_BAD标记，返回EBADF错误。

```c
SYSCALL_DEFINE3(write
  ksys_write
    vfs_write
      new_sync_write
        call_write_iter
          // file->f_op->write_iter
          nfs_file_write
            nfs_start_io_write
              down_write // 写锁
            generic_perform_write
              // a_ops->write_end
              nfs_write_end
                nfs_updatepage
                  nfs_writepage_setup
                    nfs_setup_write_request
                      nfs_create_request
                        __nfs_create_request
                          if (test_bit(NFS_CONTEXT_BAD, &ctx->open_flags))
                          return ERR_PRT(-EBADF)
            nfs_end_io_write
              up_write // 释放写锁
            if (nfs_need_check_write) // 条件满足
            nfs_wb_all // 同步写，写数据慢的原因
```

文件打开还未关闭，重启nfs server后会执行到nfs4_reclaim_open_state函数， 进而设置NFS_CONTEXT_BAD标记
```c
kthread
  nfs4_run_state_manager
    nfs4_state_manager
      test_bit(NFS4CLNT_LEASE_EXPIRED, ...)
      nfs4_reclaim_lease
        nfs4_establish_lease
          // ops->establish_clid
          nfs41_init_cliented
            nfs4_proc_exchange_id
            nfs4_proc_create_session
      test_bit(NFS4CLNT_RECLAIM_REBOOT, ...)
      nfs4_do_reclaim
        nfs4_purge_state_owners
          list_for_each_entry_safe // 遍历 close 时加到state_owners_lru的元素
          nfs4_remove_state_owner_locked
        // 文件打开还没关闭，重启server后会执行到这里
        nfs4_reclaim_open_state
          __nfs4_reclaim_open_state // 在这里进行故障注入
          nfs4_state_mark_recovery_failed
            nfs4_state_mark_open_context_bad
              set_bit(NFS_CONTEXT_BAD)
      nfs4_state_end_reclaim_reboot
        nfs4_reclaim_complete
          // ops->reclaim_complete
          nfs41_proc_reclaim_complete
```

只会在 `nfs4_state_mark_open_context_bad` 中设置 `NFS_CONTEXT_BAD` 标记，只有在 nfs server 重启后状态恢复才会执行到，而文件的 `struct nfs_open_context` 在文件关闭后就销毁了，再次打开文件后 `struct nfs_open_context` 重新分配，流程如下：
```c
open
  do_sys_open
    do_sys_openat2
      do_filp_open
        path_openat
          open_last_lookups
            lookup_open
              atomic_open // 挂载后第一次打开文件时执行到这里
                nfs_atomic_open
                  create_nfs_open_context
                    alloc_nfs_open_context // 初始化 struct nfs_open_context
          do_open
            vfs_open
              do_dentry_open
                nfs4_file_open // 挂载后第二次打开文件执行到这里
                  alloc_nfs_open_context // 初始化 struct nfs_open_context
```

server重启时的处理流程：
```c
kthread
  worker_thread
    process_one_work
      rpc_async_schedule
        __rpc_execute
          rpc_exit_task
            nfs41_sequence_call_done
              nfs41_sequence_done
                nfs41_sequence_process
                  status = res->sr_status
                  case -NFS4ERR_BADSESSION: // 10052
                  goto session_recover;
                  nfs4_schedule_session_recovery
                    // 触发 nfs4_reset_session
                    set_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state)
                    nfs4_schedule_state_manager
                      kthread_run(nfs4_run_state_manager, ...)

kthread
  nfs4_run_state_manager
    nfs4_state_manager
      test_and_clear_bit(NFS4CLNT_SESSION_RESET, )
      nfs4_reset_session
        nfs4_proc_destroy_session
        case -NFS4ERR_BADSESSION
        status = nfs4_proc_create_session // NFS4ERR_STALE_CLIENTED 10022
        nfs4_handle_reclaim_lease_error
          case -NFS4ERR_STALE_CLIENTED
          nfs4_state_start_reclaim_reboot
            nfs4_state_mark_reclaim_helper
              nfs4_reset_seqids
                // mark_reclaim
                nfs4_state_mark_reclaim_reboot
                  // 触发 nfs4_do_reclaim
                  set_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state)
          // 触发 nfs4_proc_exchange_id 和 nfs4_proc_create_session
          set_bit(NFS4CLNT_LEASE_EXPIRED, clp->cl_state)

```

# nfs4_state_owner 处理流程

```c
open
  do_sys_open
    do_sys_openat2
      do_filp_open
        path_openat(..., flags | LOOKUP_RCU)
          open_last_lookups
            lookup_open
              // 第二次open, 返回dentry, 不执行atomic_open, 执行do_open中的nfs4_atomic_open
              return dentry // if (dentry->d_inode)
              // 第一次open， 执行atomic_open
              atomic_open
                nfs_atomic_open
                  nfs4_atomic_open
                    nfs4_do_open
                      _nfs4_do_open
                        nfs4_get_state_owner
                          nfs4_insert_state_owner_locked
          do_open
            vfs_open
              do_dentry_open
                nfs4_file_open
                  nfs4_atomic_open
                    nfs4_do_open
                      _nfs4_do_open
                        nfs4_get_state_owner
                          nfs4_insert_state_owner_locked
                          nfs4_gc_state_owners
                        nfs4_opendata_put
                          kref_put
                            nfs4_opendata_free
                              nfs4_put_state_owner // 没执行list_add_tail
                        nfs4_put_state_owner // 没执行list_add_tail
                        return 0

// 关闭文件
____fput
  __fput
    nfs_file_release
      nfs_file_clear_open_context
        put_nfs_open_context_sync
          __put_nfs_open_context
            nfs4_close_context
              nfs4_close_sync
                __nfs4_close
                  nfs4_do_close
                    rpc_put_task
                      rpc_do_put_task
                        rpc_final_put_task
                          rpc_free_task
                            rpc_release_calldata
                              nfs4_free_closedata
                                nfs4_put_open_state
                                  nfs4_put_state_owner // 没执行list_add_tail
                                nfs4_put_state_owner
                                  list_add_tail(&sp->so_lru, &server->state_owners_lru)
```

# sequence 发送流程
```c
kthread
  worker_thread
    process_one_work
      rpc_async_schedule
        __rpc_execute
          rpc_prepare_task
            nfs41_seqence_prepare

kthread
  worker_thread
    process_one_work
      nfs4_renew_state
        // ops->sched_state_renewal
        nfs41_proc_async_sequence
          _nfs41_proc_sequence
            .callback_ops = &nfs41_sequence_ops
            rpc_run_task
              rpc_new_task
                rpc_init_task

kthread
  worker_thread
    process_one_work
      rpc_async_schedule
        __rpc_execute
          call_decode
            rpcauth_unwrap_resp
              rpcauth_unwrap_resp_decode
                nfs4_xdr_dec_sequence
                  decode_sequence
                    status = decode_op_hdr // 10052

kthread
  worker_thread
    process_one_work
      rpc_async_schedule
        __rpc_execute
          rpc_release_task
            rpc_final_put_task
              rpc_free_task
                rpc_release_calldata
                  // ops->rpc_release
                  nfs41_sequence_release
                    nfs4_schedule_state_renewal
                      // 过段时间后重新执行 nfs4_renew_state
                      // timeout = 60000, clp->cl_lease_time = 90000, 
                      mod_delayed_work(..., &clp->cl_renewd, timeout)
```

# 挂载流程

```c
mount
  do_mount
    path_mount
      do_new_mount
        vfs_get_tree
          nfs_get_tree
            nfs4_try_get_tree
              nfs4_create_server
                nfs4_init_server
                  nfs4_set_client
                    nfs_get_client
                      nfs4_alloc_client
                        nfs_alloc_client
                          INIT_LIST_HEAD(&clp->cl_superblocks) // nfs_server 链表
                        // 初始化 nfs4_renew_state delayed_work
                        INIT_DELAYED_WORK(&clp->cl_renewd, nfs4_renew_state)
                nfs4_server_common_setup
                  nfs4_get_rootfh
                    nfs4_proc_get_rootfh
                      nfs4_do_fsinfo
                        nfs4_set_lease_period // 设置 lease 周期 ＝ 90000
                  nfs_probe_server
                    nfs_probe_fsinfo
                      nfs4_proc_fsinfo
                        nfs4_do_fsinfo
                          nfs4_set_lease_period
                  nfs_server_insert_list
                    list_add_tail_rcu(&server->client_link, &clp->cl_superblocks)
              do_nfs4_mount(nfs4_create_server, ...)
                mount_subtree
                  vfs_path_lookup
                    filename_lookup
                      path_lookupat
                        lookup_last
                          walk_component
                            step_info
                              handle_mounts
                                traverse_mounts
                                  __traverse_mounts
                                    follow_automount
                                      nfs_d_automount
                                        nfs4_submount
                                          nfs_do_submount
                                            nfs_clone_server
                                              nfs_probe_server
                                                nfs_probe_fsinfo
                                                  nfs4_proc_fsinfo
                                                    nfs4_do_fsinfo
                                                      _nfs4_do_fsinfo
                                                        nfs4_call_sync
                                                          nfs4_call_sync_sequence
                                                            nfs4_do_call_sync
                                                              nfs4_call_sync_custom // 向server请求数据
                                                      nfs4_set_lease_period
                                              nfs_server_insert_lists
                                                ist_add_tail_rcu(&server->client_link, &clp->cl_superblocks)
```

# nfs server 处理 lease time

```c
// nfs server
ret_from_fork
  kernel_init
    kernel_init_freeable
      do_basic_setup
        do_initcalls
          do_initcall_level
            do_one_initcall
              init_nfsd
                register_pernet_subsys
                  register_pernet_operations
                    __register_pernet_operations
                      ops_init
                        nfsd_init_net
                          nn->nfsd4_lease = 90
// nfs server
unshare
  ksys_unshare
    unshare_nsproxy_namespaces
      create_new_namespaces
        copy_net_ns
          setup_net
            ops_init
              nfsd_init_net

// nfs server
kthread
  nfsd
    svc_process
      svc_process_common
        nfsd_dispatch
          nfsd4_proc_compound
            nfsd4_encode_operation
              nfsd4_encode_getattr
                nfsd4_encode_fattr
                  *p++ = cpu_to_be32(nn->nfsd4_lease)
```

# 参考

[NFS Client in Linux Kernel - Recovery](https://www.jianshu.com/p/a3d2ca945d52)