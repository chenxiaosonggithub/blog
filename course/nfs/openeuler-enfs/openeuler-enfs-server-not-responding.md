# 问题描述

按以下步骤操作，报错`nfs: server 192.168.53.210 not responding, timed out`:
```sh
mount -t nfs -o vers=3,localaddrs=192.168.53.209~192.168.53.46,remoteaddrs=192.168.53.210~192.168.53.47 192.168.53.210:/tmp/s_test /mnt/
modprobe -r enfs
modprobe enfs # 报错 nfs: server 192.168.53.210 not responding, timed out
```

# 代码分析

```c
enfs_multipath_init
  pm_ping_init
    pm_ping_start
      pm_ping_routine // kthread_run(pm_ping_routine,
        pm_ping_loop_sunrpc_net
          pm_ping_loop_rpclnt
            pm_ping_execute_xprt_test
              pm_ping_add_work
                pm_ping_execute_work // INIT_WORK(&work_info->ping_work,
                  rpc_clnt_test_xprt
                    rpc_call_null_helper
                      // 调试时可以判断task->tk_msg.rpc_proc->p_proc
                      .rpc_proc = &rpcproc_null, // rpcproc_null.p_proc不赋值默认为NFS3PROC_NULL
                      rpc_run_task

mount
  path_mount
    do_new_mount
      vfs_get_tree
        nfs_get_tree
          nfs_try_get_tree
            nfs_try_mount_request
              nfs3_create_server
                nfs_create_server
                  nfs_init_server
                    nfs_get_client
                      nfs_init_client
                        nfs_create_rpc_client
                          rpc_create
                            rpc_create_xprt
                              rpc_multipath_ops_create_clnt
                                enfs_create_multi_xprt
                                  enfs_multipath_create_thread
                                    enfs_fill_empty_iplist

```

