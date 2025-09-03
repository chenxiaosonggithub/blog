# 代码分析

```c
mount
  path_mount
    do_new_mount
      vfs_get_tree
        nfs_get_tree
          nfs_try_get_tree
            nfs_try_mount_request
              nfs3_create_server
                nfs_create_server
                  nfs_probe_fsinfo
                    nfs3_proc_fsinfo // clp->rpc_ops->fsinfo
                      do_proc_fsinfo
                        nfs3_rpc_wrapper
                          rpc_call_sync
                            rpc_run_task
                              rpc_task_set_client
                                rpc_task_set_transport
                                  rpc_multipath_ops_set_transport
                                    enfs_set_transport // mops->set_transport
                                      shard_set_transport
                                        get_uuid_from_task
                                          // 这里task->tk_msg.rpc_proc为空
                              rpc_task_set_rpc_message // 直到这里才设置task->tk_msg.rpc_proc
                              rpc_execute
                                __rpc_execute
                                  call_start
                                    rpc_task_set_transport
                                      rpc_multipath_ops_set_transport
                                        enfs_set_transport // mops->set_transport
                                          shard_set_transport
                                            get_uuid_from_task
                                              insert_and_update_shard
                                                query_and_update_shard
                                                  dorado_query_lsId
            nfs_get_tree_common
              nfs_get_root
                nfs3_proc_get_root
                  do_proc_get_root // 这里会再发送fsinfo请求

// 遍历nfs_server
list_for_each_entry(pos, &nn->nfs_volume_list, master_link)

vfs_kern_mount
  fs_context_for_mount
    alloc_fs_context
      nfs_init_fs_context // fc->fs_type->init_fs_context
        ctx->mntfh = nfs_alloc_fhandle();
        fc->fs_private = ctx
        fc->ops = &nfs_fs_context_ops
  put_fs_context
    nfs_fs_context_free // fc->ops->free(fc)
      nfs_free_fhandle(ctx->mntfh)

nfs3_xdr_enc_getattr3args

nfs3_xdr_dec_fsinfo3res
```

