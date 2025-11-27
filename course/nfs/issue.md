我刚做内核时，最开始定位的就是nfs问题，在这里把所有解决过的问题列出来。

# openEuler的nfs+问题分析

[点击这里查看openEuler的nfs+问题分析](https://chenxiaosong.com/course/nfs/openeuler-enfs.html#issue)。

# nfs问题分析

- [多个NFS客户端使用相同的hostname导致clientid过期](https://chenxiaosong.com/course/nfs/issue/nfs-clients-same-hostname-clientid-expire.html)
- [4.19 nfs没实现iterate_shared()导致的遍历目录无法并发问题](https://chenxiaosong.com/course/nfs/issue/4.19-nfs-no-iterate_shared.html)
- [4.19 nfs_updatepage()空指针解引用问题](https://chenxiaosong.com/course/nfs/issue/4.19-null-ptr-deref-in-nfs_updatepage.html)
- [aarch64架构 4.19 nfs_readpage_async()空指针解引用问题](https://chenxiaosong.com/course/nfs/issue/4.19-aarch64-null-ptr-deref-in-nfs_readpage_async.html)
- [4.19 nfs_readpage_async()空指针解引用问题](https://chenxiaosong.com/course/nfs/issue/4.19-null-ptr-deref-in-nfs_readpage_async.html)
- [4.19 nfs4_put_stid()报warning紧接着panic的问题](https://chenxiaosong.com/course/nfs/issue/4.19-warning-in-nfs4_put_stid-and-panic.html)
- [4.19 __nfs3_proc_setacls()空指针解引用问题](https://chenxiaosong.com/course/nfs/issue/4.19-null-ptr-deref-in-__nfs3_proc_setacls.html)
- [nfs df命令执行时间长的问题](https://chenxiaosong.com/course/nfs/issue/nfs-df-long-time.html)
- [4.19 nfs_wb_page() soft lockup的问题](https://chenxiaosong.com/course/nfs/issue/4.19-nfs-soft-lockup-in-nfs_wb_page.html)
- [nfsiostat命令queue时间长的问题](https://chenxiaosong.com/course/nfs/issue/nfsiostat-queue-long-time.html)
- [nfs_ctx_key_to_expire()引用计数泄露和空指针解引用的问题](https://chenxiaosong.com/course/nfs/issue/null-ptr-deref-in-nfs_ctx_key_to_expire.html)
- [Connectathon NFS tests测试用例失败问题](https://chenxiaosong.com/course/nfs/issue/cthon-nfs-tests.html)
- [4.19 __rpc_execute() soft lockup的问题](https://chenxiaosong.com/course/nfs/issue/4.19-nfs-soft-lockup-in-__rpc_execute.html)
- [nfs hung task问题](https://chenxiaosong.com/course/nfs/issue/nfs-hung-task.html)
- [4.19内核执行ll时间比4.12内核(suse)长的问题](https://chenxiaosong.com/course/nfs/issue/4.19-ll-time-longer-than-suse-4.12.html)
- [4.19内核nfs_unlock_request()报BUG()的问题](https://chenxiaosong.com/course/nfs/issue/4.19-bug-in-nfs_unlock_request.html)
- [sunrpc __rpc_execute()出现ERESTARTSYS的问题](https://chenxiaosong.com/course/nfs/issue/4.19-__rpc_execute-ERESTARTSYS.html)
- [4.19 nfs rdma协议不支持的问题](https://chenxiaosong.com/course/nfs/issue/4.19-rdma-not-supported.html)
- [nfs-ganesha不支持导出tmpfs的问题](https://chenxiaosong.com/course/nfs/issue/ganesha-not-support-tmpfs.html)
- [umount nfs报错device is busy的问题](https://chenxiaosong.com/course/nfs/issue/nfs-umount-device-is-busy.html)
- [统计nfsv3同步写的时间](https://chenxiaosong.com/course/nfs/issue/stat-nfsv3-sync-write-time.html)
- [nfsd4_probe_callback()空指针解引用问题](https://chenxiaosong.com/course/nfs/issue/null-ptr-deref-in-nfsd4_probe_callback.html)
- [nfsv3 NLM请求超时的问题](https://chenxiaosong.com/course/nfs/issue/lockd-server-not-responding.html)
- [nfsv3挂载卡在nlmclnt_init()的问题](https://chenxiaosong.com/course/nfs/issue/nfs-mount-hung-in-nlmclnt_init.html)
- [nfsv3选项一样时挂载hung住的问题](https://chenxiaosong.com/course/nfs/issue/nfsv3-mount-hung-with-same-option.html)
- [nfsv3缓存占用太多的问题](https://chenxiaosong.com/course/nfs/issue/nfsv3-cannot-drop-cache.html)

