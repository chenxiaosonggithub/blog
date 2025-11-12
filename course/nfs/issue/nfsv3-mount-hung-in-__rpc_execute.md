# 问题描述

```
root      351771  0.0  0.0 214144  1132 pts/1    S+   11:06   0:00 mount -t nfs -o vers=3 ${server_ip}:/svr/export /root/test1
root      351772  0.0  0.0  77644 66332 pts/1    D+   11:06   0:00 /sbin/mount.nfs ${server_ip}:/svr/export /root/test1 -o rw,vers=3
```

查看栈信息:
```sh
=============== 进程 351772 线程 351772 mount.nfs 栈信息 ===============
[<0>] rpc_wait_bit_killable+0x1e/0x90 [sunrpc]
[<0>] __rpc_execute+0xe0/0x3e0 [sunrpc]
[<0>] rpc_run_task+0x109/0x150 [sunrpc]
[<0>] rpc_call_sync+0x50/0x90 [sunrpc]
[<0>] nfs3_rpc_wrapper.constprop.11+0x2f/0x90 [nfsv3]
[<0>] do_proc_fsinfo+0x57/0xb0 [nfsv3]
[<0>] nfs3_proc_fsinfo+0x1b/0x50 [nfsv3]
[<0>] nfs_probe_fsinfo+0xa7/0x4d0 [nfs]
[<0>] nfs_create_server+0x91/0x1b0 [nfs]
[<0>] nfs3_create_server+0xb/0x30 [nfsv3]
[<0>] nfs_try_mount+0x14f/0x2c0 [nfs]
[<0>] nfs_fs_mount+0x62d/0xdc0 [nfs]
[<0>] mount_fs+0x35/0x160
[<0>] vfs_kern_mount.part.26+0x54/0x120
[<0>] do_mount+0x5c2/0xc60
[<0>] ksys_mount+0x80/0xd0
[<0>] __x64_sys_mount+0x21/0x30
[<0>] 0xffffffffc085d868
[<0>] 0xffffffffc085f246
[<0>] do_syscall_64+0x5b/0x1d0
[<0>] entry_SYSCALL_64_after_hwframe+0x44/0xa9
[<0>] 0xffffffffffffffff
=======================================================
```

# 代码分析

```c

```

