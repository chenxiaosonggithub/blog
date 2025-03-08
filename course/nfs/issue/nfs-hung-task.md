# 问题描述

nfs client使用nfsv4.2挂载，[4.19内核 hung task日志](https://gitee.com/chenxiaosonggitee/tmp/blob/master/nfs/nfs-hung-task-log.txt)。

# 构造复现

nfs server构造收到打开文件的请求后不回复的情况，代码修改如下:
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

为了方便，我们用一台机器既做server又做client。测试命令如下:
```sh
mount -t nfs localhost:/ /mnt
echo something > /mnt/file &
echo something > /mnt/file & # 会打印出pid 576
```

等待120秒后就会打印出以下信息:
```sh
[  246.880095] INFO: task bash:576 blocked for more than 120 seconds.
[  246.882393]       Not tainted 4.19.325+ #3
[  246.883871] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  246.886660] bash            D    0   576    515 0x00000000
[  246.888639] Call Trace:
[  246.889567]  __schedule+0x260/0x6e0
[  246.890836]  schedule+0x36/0x80
[  246.891996]  rwsem_down_write_failed+0x19b/0x2c0
[  246.895079]  call_rwsem_down_write_failed+0x17/0x30
[  246.896870]  down_write+0x2d/0x40
[  246.898067]  do_last+0x3c5/0x8b0
[  246.900833]  path_openat+0x8b/0x2c0
[  246.903326]  do_filp_open+0x91/0x130
[  246.907467]  do_sys_open+0x16f/0x200
[  246.908748]  __x64_sys_openat+0x1f/0x30
[  246.910124]  do_syscall_64+0x64/0x1e0
[  246.912958]  entry_SYSCALL_64_after_hwframe+0x5c/0xc1
```

