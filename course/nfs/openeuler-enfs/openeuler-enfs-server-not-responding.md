# 问题描述

按以下步骤操作，报错`nfs: server 192.168.53.210 not responding, timed out`:
```sh
mount -t nfs -o vers=3,localaddrs=192.168.53.209~192.168.53.46,remoteaddrs=192.168.53.210~192.168.53.47 192.168.53.210:/tmp/s_test /mnt/
modprobe -r enfs
modprobe enfs # 报错 nfs: server 192.168.53.210 not responding, timed out
```

# 代码分析

```c
enfs_init_entry init_entry[]
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
```

