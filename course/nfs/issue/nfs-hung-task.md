# 问题描述

nfs client使用nfsv4.2挂载，[4.19内核 hung task日志](https://gitee.com/chenxiaosonggitee/tmp/blob/master/nfs/nfs-hung-task-log.txt)。

# 调试

为了方便，我们用一台机器既做server又做client。

nfs server的代码的修改如下:
```sh
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -356,6 +356,11 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
        struct nfsd_net *nn = net_generic(net, nfsd_net_id);
        bool reclaim = false;
 
+       while (1) {
+               printk("%s:%d, sleep\n", __func__, __LINE__);
+               msleep(20 * 1000);
+       }
+
        dprintk("NFSD: nfsd4_open filename %.*s op_openowner %p\n",
                (int)open->op_fname.len, open->op_fname.data,
                open->op_openowner);
```

测试命令如下:
```sh
mount -t nfs localhost:/ /mnt
echo something > /mnt/file
cat /mnt/file & # 会打印出pid 576
```

等待120秒后就会打印出以下信息:
```sh
[  246.880061] INFO: task cat:576 blocked for more than 120 seconds.
[  246.882144]       Not tainted 4.19.325+ #3
[  246.883524] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  246.886101] cat             D    0   576    525 0x00000000
[  246.887926] Call Trace:
[  246.888775]  __schedule+0x260/0x6e0
[  246.889959]  schedule+0x36/0x80
[  246.891034]  rwsem_down_read_failed+0x11c/0x180
[  246.892561]  call_rwsem_down_read_failed+0x18/0x30
[  246.894162]  down_read+0x20/0x40
[  246.895269]  do_last+0x623/0x8b0
[  246.897915]  path_openat+0x8b/0x2c0
[  246.900264]  do_filp_open+0x91/0x130
[  246.904124]  do_sys_open+0x16f/0x200
[  246.905339]  __x64_sys_openat+0x1f/0x30
[  246.906634]  do_syscall_64+0x64/0x1e0
[  246.909318]  entry_SYSCALL_64_after_hwframe+0x5c/0xc1
```

