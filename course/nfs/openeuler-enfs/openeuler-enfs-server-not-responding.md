# 问题描述

按以下步骤操作，报错`nfs: server 192.168.53.210 not responding, timed out`:
```sh
mount -t nfs -o vers=3,localaddrs=192.168.53.209~192.168.53.46,remoteaddrs=192.168.53.210~192.168.53.47 192.168.53.210:/tmp/s_test /mnt/
modprobe -r enfs
modprobe enfs # 报错 nfs: server 192.168.53.210 not responding, timed out
```

<!--
# 调试

```c
// server
#include <mydebug.h>

#define proc_null_mydebug_print                        \
	if (rqstp->rq_proc == 0) {      \
		mydebug_print("xid:%x\n", rqstp->rq_xid);       \
	}

#define proc_null_mydebug_dump_stack                   \
	if (task->tk_msg.rpc_proc->p_proc == 0) {       \
		mydebug_dump_stack();   \
	}

// client
#include <mydebug.h>

#define proc_null_mydebug_print                        \
	if (task->tk_msg.rpc_proc->p_proc == 0) {       \
		mydebug_print("task:%px\n", task);      \
	}

#define proc_null_mydebug_dump_stack                   \
	if (task->tk_msg.rpc_proc->p_proc == 0) {       \
		mydebug_dump_stack();   \
	}
```
-->

# 代码分析

client端的null包的发送流程如下:
```c
enfs_multipath_init
  pm_ping_init
    pm_ping_start
      pm_ping_routine // kthread_run(pm_ping_routine,
        pm_ping_loop_sunrpc_net
          pm_ping_loop_rpclnt
            rpc_clnt_iterate_for_each_xprt
              pm_ping_execute_xprt_test // fn
                pm_ping_add_work
                  pm_ping_execute_work // INIT_WORK(&work_info->ping_work,
                    rpc_clnt_test_xprt(..., &pm_ping_set_status_ops, ..., RPC_TASK_ASYNC...) // 异步
                      rpc_call_null_helper(..., RPC_TASK_SOFT...) // rpc请求不会一直尝试
                        // 调试时可以判断task->tk_msg.rpc_proc->p_proc
                        .rpc_proc = &rpcproc_null, // rpcproc_null.p_proc不赋值默认为NFS3PROC_NULL
                        .callback_ops = &pm_ping_set_status_ops
                        rpc_run_task
                          rpc_new_task
                            rpc_init_task
                              task->tk_ops = task_setup_data->callback_ops = pm_ping_set_status_ops
                              if (task->tk_ops->rpc_call_prepare != NULL) // 条件不满足
                              task->tk_action == NULL
                          rpc_call_start
                            task->tk_action = call_start

xprt_create_transport
  rpc_multipath_ops_create_xprt
    enfs_create_xprt_ctx // create_xprt
      enfs_alloc_xprt_ctx
        xprt_set_reserve_context
          buf->reserve_context

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
                                    enfs_xprt_ippair_create
                                      enfs_combine_addr
                                        enfs_configure_xprt_to_clnt
                                          print_enfs_multipath_addr
                                          rpc_clnt_add_xprt
                                            enfs_add_xprt_setup // setup
                                              xprt_get_reserve_context
```

在`call_status()`中超时打印:
```c
call_start
call_reserve
call_reserveresult
call_refresh
call_refreshresult
call_allocate
call_encode
call_transmit
call_transmit_status
call_status
  status = task->tk_status == -ETIMEDOUT
  rpc_check_timeout
    "%s: server %s not responding, timed out\n",

```

在nfs server中打印xid，发现没有执行到`svc_process()`中。
```c
nfsd
  svc_recv
    // 打印 rqstp->rq_xid
    svc_process
      rqstp->rq_xid = *p++;
      svc_process_common
        nfsd_init_request // progp->pg_init_request
          svc_generic_init_request // 不确定，后面再调试看看
            ret->dispatch = versp->vs_dispatch
        nfsd_dispatch // process.dispatch()
          nfssvc_decode_voidarg // proc->pc_decode
          nfsd3_proc_null // proc->pc_func
          nfssvc_encode_voidres // proc->pc_encode
      svc_send
        svc_tcp_sendto // xprt->xpt_ops->xpo_sendto
```

