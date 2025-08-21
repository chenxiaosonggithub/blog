# 问题描述

内核版本:
```sh
uname -a
  # Linux xxxx 4.19.90-24.4.v2101.ky10.x86_64 #1 SMP Mon May 24 12:14:55 CST 2021 x86_64 x86_64 x86_64 GNU/Linux
```

加了`nolock`选项可以挂载成功:
```sh
mount -t nfs -o vers=3,nolock 192.168.53.225:/tmp/s_test /mnt
```

不加`nolock`选项，挂载卡住:
```sh
mount -t nfs -o vers=3 192.168.53.225:/tmp/s_test /mnt
```

查看进程栈:
```sh
cat /proc/64997/stack
[<0>] nlmclnt_init+0x1d/0xa0 [lockd]
[<0>] nfs_start_lockd+0xd7/0x110 [nfs]
[<0>] nfs_init_server+0x1a1/0x2d0 [nfs]
[<0>] nfs_create_server+0x57/0x1b0 [nfs]
[<0>] nfs3_create_server+0xb/0x30 [nfsv3]
[<0>] nfs_try_mount+0x14f/0x2c0 [nfs]
[<0>] nfs_fs_mount+0x627/0xdc0 [nfs]
[<0>] mount_fs+0x35/0x160
[<0>] vfs_kern_mount.part.28+0x54/0x120
[<0>] do_mount+0x5c2/0xc60
[<0>] ksys_mount+0x80/0xd0
[<0>] __x64_sys_mount+0x21/0x30
[<0>] do_syscall_64+0x5b/0x1d0
[<0>] entry_SYSCALL_64_after_hwframe+0x44/0xa9
```

# 调试 {#debug}

脚本查看[《nfs调试方法》](https://chenxiaosong.com/course/nfs/debug.html#get-all_stack)。

找到以下几种栈:
```sh
cat /proc/23462/task/23462/stack
[<0>] nfs_free_server+0x22/0x90 [nfs]
[<0>] nfs_kill_super+0x2b/0x40 [nfs]
[<0>] deactivate_locked_super+0x3f/0x70
[<0>] cleanup_mnt+0x3b/0x80
[<0>] task_work_run+0x8a/0xb0
[<0>] exit_to_usermode_loop+0xeb/0xf0
[<0>] do_syscall_64+0x1a3/0x1d0
[<0>] entry_SYSCALL_64_after_hwframe+0x44/0xa9

cat /proc/65384/task/65384/stack
[<0>] nlmclnt_init+0x1d/0xa0 [lockd]
[<0>] nfs_start_lockd+0xd7/0x110 [nfs]
[<0>] nfs_init_server+0x1a1/0x2d0 [nfs]
[<0>] nfs_create_server+0x57/0x1b0 [nfs]
[<0>] nfs3_create_server+0xb/0x30 [nfsv3]
[<0>] nfs_try_mount+0x14f/0x2c0 [nfs] 
[<0>] nfs_fs_mount+0x627/0xdc0 [nfs]
[<0>] mount_fs+0x35/0x160 
[<0>] vfs_kern_mount.part.28+0x54/0x120
[<0>] do_mount+0x5c2/0xc60
[<0>] ksys_mount+0x80/0xd0
[<0>] __x64_sys_mount+0x21/0x30 
[<0>] do_syscall_64+0x5b/0x1d0
[<0>] entry_SYSCALL_64_after_hwframe+0x44/0xa9

cat /proc/17310/task/17310/stack
[<0>] lockd_up+0x14b/0x350 [lockd]
[<0>] nfs_start_lockd+0xd7/0x110 [nfs]
[<0>] nfs_init_server+0x1a1/0x2d0 [nfs]
[<0>] nfs_create_server+0x57/0x1b0 [nfs]
[<0>] nfs3_create_server+0xb/0x30 [nfsv3]
[<0>] nfs_try_mount+0x14f/0x2c0 [nfs]
[<0>] nfs_fs_mount+0x627/0xdc0 [nfs]
[<0>] mount_fs+0x35/0x160
[<0>] vfs_kern_mount.part.28+0x54/0x120
[<0>] do_mount+0x5c2/0xc60    
[<0>] ksys_mount+0x80/0xd0
[<0>] __x64_sys_mount+0x21/0x30
[<0>] do_syscall_64+0x5b/0x1d0
[<0>] entry_SYSCALL_64_after_hwframe+0x44/0xa9
```

没搜索到`reclaimer()`的栈。

解析:
```sh
rpm2cpio kernel-debuginfo-4.19.90-24.4.v2101.ky10.x86_64.rpm | cpio -div
./scripts/faddr2line usr/lib/debug/lib/modules/4.19.90-24.4.v2101.ky10.x86_64/kernel/fs/lockd/lockd.ko.debug nlmclnt_init+0x1d/0xa0
  # nlmclnt_init+0x1d/0xa0:
  # nlmclnt_init at /usr/src/debug/kernel-4.19.90/linux-4.19.90-24.4.v2101.ky10.x86_64/fs/lockd/clntlock.c:60
  # 60: if (status < 0)，应该是执行到59行: status = lockd_up(nlm_init->net);
./scripts/faddr2line usr/lib/debug/lib/modules/4.19.90-24.4.v2101.ky10.x86_64/kernel/fs/nfs/nfs.ko.debug nfs_free_server+0x22/0x90
  # nfs_free_server+0x22/0x90:
  # nfs_free_server at /usr/src/debug/kernel-4.19.90/linux-4.19.90-24.4.v2101.ky10.x86_64/fs/nfs/client.c:924
  # 924: if (!IS_ERR(server->client_acl))
```

# 代码分析

进程`17310`在`lockd_up_net()`中发生错误，在`lockd_unregister_notifiers()`中一直休眠:
```c
// 进程 17310
nfs_init_server
  nfs_start_lockd
    nlmclnt_init
      lockd_up
        mutex_lock(&nlmsvc_mutex) // 持有锁
        lockd_up_net // 发生错误
        lockd_unregister_notifiers
          // 休眠直到 nlm_ntf_refcnt == 0
          // 当前 nlm_ntf_refcnt 值为 1
          wait_event(nlm_ntf_wq, atomic_read(&nlm_ntf_refcnt) == 0)
        lockd_start_svc // nlm_ntf_refcnt增加，未执行到
          atomic_inc(&nlm_ntf_refcnt)
```

进程 `65384`以及其他执行到`nfs_init_server()`的进程都在`lockd_up()`中等待进程 17310 释放锁:
```c
// 进程 65384
nfs_init_server
  nfs_start_lockd
    nlmclnt_init
      lockd_up
        mutex_lock(&nlmsvc_mutex) // 等待进程 17310 释放锁
```

# 补丁

```sh
2018-10-22 84df9525b0c2 Linux 4.19 Greg Kroah-Hartman <gregkh@linuxfoundation.org>

git log origin/master --oneline --date=short --format="%cd %h %s %an <%ae>" --grep=nlm_ntf_refcnt
git log origin/master --oneline --date=short --format="%cd %h %s %an <%ae>" --grep=nlm_ntf_wq
  # 2021-12-13 5a8a7ff57421 lockd: simplify management of network status notifiers NeilBrown <neilb@suse.de>
  # 2018-03-19 554faf281988 lockd: make nlm_ntf_refcnt and nlm_ntf_wq static Colin Ian King <colin.king@canonical.com>
git log origin/master --oneline --date=short --format="%cd %h %s %an <%ae>" --grep=lockd_unregister_notifiers
  # 2017-11-07 dc3033e16c59 lockd: double unregister of inetaddr notifiers Vasily Averin <vvs@virtuozzo.com>
git log origin/master --oneline --date=short --format="%cd %h %s %an <%ae>" --grep=lockd_up
  # 2021-12-13 865b674069e0 lockd: introduce lockd_put() NeilBrown <neilb@suse.de>
  # 2021-12-13 b73a2972041b lockd: move lockd_start_svc() call into lockd_create_svc() NeilBrown <neilb@suse.de>
  # 2021-12-13 5a8a7ff57421 lockd: simplify management of network status notifiers NeilBrown <neilb@suse.de>
```

<!--
[`[PATCH 00/20 v3] SUNRPC: clean up server thread management`](https://chenxiaosong.com/course/nfs/patch/NFSD-Make-it-possible-to-use-svc_set_num_threads_syn.html)
-->

