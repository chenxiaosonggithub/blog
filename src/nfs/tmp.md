# 问题描述

TODO

# vmcore解析

解压提取`vmlinux`和`ko`文件：
```sh
rpm2cpio kernel-debuginfo-4.19.90-23.23.v2101.ky10.x86_64.rpm | cpio -div
```

加载`ko`文件：
```sh
crash> mod -s nfs kernel-debuginfo-4.19.90-23.23.v2101.ky10.x86_64/usr/lib/debug/lib/modules/4.19.90-23.23.v2101.ky10.x86_64/kernel/fs/nfs/nfs.ko.debug
crash> mod -s nfsv3 kernel-debuginfo-4.19.90-23.23.v2101.ky10.x86_64/usr/lib/debug/lib/modules/4.19.90-23.23.v2101.ky10.x86_64/kernel/fs/nfs/nfsv3.ko.debug # 不用加载
crash> mod -s nfsv4 kernel-debuginfo-4.19.90-23.23.v2101.ky10.x86_64/usr/lib/debug/lib/modules/4.19.90-23.23.v2101.ky10.x86_64/kernel/fs/nfs/nfsv4.ko.debug
```

打印`rsync`的所有进程，其中`IN`代表`TASK_INTERRUPTIBLE`，`UN`代表`TASK_UNINTERRUPTIBLE`，具体看[include/linux/sched.h](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h)。
```sh
crash> ps rsync
   PID    PPID  CPU       TASK        ST  %MEM     VSZ    RSS  COMM
  152322      1   5  ffff91fd87239780  IN   0.0  213108   1592  rsync
  3621271  152322   7  ffff91fd6d044680  UN   0.7  409284 128232  rsync
  3632440  152322   5  ffff91fde98a1780  UN   1.0  410648 181880  rsync
  3644149  152322   0  ffff91fe2c35de00  UN   1.0  410052 183764  rsync
  3655486  152322   5  ffff91fd8f1ac680  UN   1.0  410948 184780  rsync
  3667062  152322   5  ffff91fe2d47c680  UN   1.0  409860 183572  rsync
  3678549  152322   3  ffff91fe2f851780  UN   1.0  410072 182824  rsync
  3690262  152322   4  ffff91fddd830000  UN   1.0  409832 182816  rsync
  3701961  152322   4  ffff91fd8723c680  UN   1.0  410392 182852  rsync
  3713720  152322   7  ffff91fe12449780  UN   1.0  410080 183720  rsync
  3725136  152322   3  ffff91fb2af01780  UN   1.0  410104 183060  rsync
  3736677  152322   1  ffff91fb1d6e9780  UN   1.0  409856 182816  rsync
  3748012  152322   5  ffff91fe27069780  UN   1.0  410108 183348  rsync
  3759132  152322   0  ffff91fab0c0de00  UN   1.0  407016 180696  rsync
  3770908  152322   7  ffff91fde4e95e00  UN   1.0  411200 184848  rsync
  3782024  152322   7  ffff91fde9f82f00  UN   1.0  411028 184848  rsync
  3794329  152322   5  ffff91fb26acaf00  UN   1.0  409796 182864  rsync
  3805549  152322   7  ffff91fab7445e00  UN   1.0  410084 182880  rsync
  3817313  152322   2  ffff91fab0c0af00  UN   1.0  410084 183448  rsync
  3828467  152322   7  ffff91fd8f1aaf00  UN   1.0  410600 183164  rsync
  3840283  152322   6  ffff91fe2d5a5e00  UN   1.0  410384 183152  rsync
```

其中有18个状态为`UN`的进程的栈如下：
```sh
crash> bt 3621271
PID: 3621271  TASK: ffff91fd6d044680  CPU: 7   COMMAND: "rsync"
 #0 [ffffa932d099fa90] __schedule at ffffffffa749c4a6
 #1 [ffffa932d099fb30] schedule at ffffffffa749cb48
 #2 [ffffa932d099fb38] rwsem_down_read_failed at ffffffffa74a02fc
 #3 [ffffa932d099fbe0] call_rwsem_down_read_failed at ffffffffa74939d4
 #4 [ffffa932d099fc28] down_read at ffffffffa749f703
 #5 [ffffa932d099fc30] lookup_slow at ffffffffa6ed42f7
 #6 [ffffa932d099fc58] walk_component at ffffffffa6ed47d4
 #7 [ffffa932d099fcb8] path_lookupat at ffffffffa6ed4f5e
 #8 [ffffa932d099fd18] filename_lookup at ffffffffa6ed8866
 #9 [ffffa932d099fe40] vfs_statx at ffffffffa6ecc593
#10 [ffffa932d099fe98] __do_sys_newlstat at ffffffffa6eccbd9
#11 [ffffa932d099ff38] do_syscall_64 at ffffffffa6c0430b
#12 [ffffa932d099ff50] entry_SYSCALL_64_after_hwframe at ffffffffa7600088
    RIP: 00007f612a9e5575  RSP: 00007fff67b25fd8  RFLAGS: 00000246
    RAX: ffffffffffffffda  RBX: 0000000000000000  RCX: 00007f612a9e5575
    RDX: 00007fff67b26100  RSI: 00007fff67b26100  RDI: 00007fff67b26190
    RBP: 0000000000000000   R8: 00007fff67b261bf   R9: 0000000000000000
    R10: 0000000000000001  R11: 0000000000000246  R12: 00007fff67b26190
    R13: 00007fff67b26100  R14: 0000000000000002  R15: 0000000000010004
    ORIG_RAX: 0000000000000006  CS: 0033  SS: 002b
```

另外2个进程的栈是：
```sh
crash> bt 3632440
PID: 3632440  TASK: ffff91fde98a1780  CPU: 5   COMMAND: "rsync"
 #0 [ffffa932c498bca0] __schedule at ffffffffa749c4a6
 #1 [ffffa932c498bd40] schedule at ffffffffa749cb48
 #2 [ffffa932c498bd48] rwsem_down_write_failed_killable at ffffffffa74a074d
 #3 [ffffa932c498bdf0] call_rwsem_down_write_failed_killable at ffffffffa7493a53
 #4 [ffffa932c498be30] down_write_killable at ffffffffa749f7b0
 #5 [ffffa932c498be38] iterate_dir at ffffffffa6edccc9
 #6 [ffffa932c498be78] ksys_getdents64 at ffffffffa6eddc30
 #7 [ffffa932c498bf30] __x64_sys_getdents64 at ffffffffa6edde46
 #8 [ffffa932c498bf38] do_syscall_64 at ffffffffa6c0430b
 #9 [ffffa932c498bf50] entry_SYSCALL_64_after_hwframe at ffffffffa7600088
    RIP: 00007f612a9bd757  RSP: 00007fff67b2a338  RFLAGS: 00000246
    RAX: ffffffffffffffda  RBX: 0000562293813e70  RCX: 00007f612a9bd757
    RDX: 0000000000008000  RSI: 0000562293813ea0  RDI: 0000000000000009
    RBP: 0000562293813ea0   R8: 0000000000000000   R9: 0000000000000001
    R10: 0000000000000001  R11: 0000000000000246  R12: ffffffffffffff80
    R13: 0000000000000000  R14: 000056229381be73  R15: 000056229381be60
    ORIG_RAX: 00000000000000d9  CS: 0033  SS: 002b

crash> bt 3748012
PID: 3748012  TASK: ffff91fe27069780  CPU: 5   COMMAND: "rsync"
 #0 [ffffa932c4ea77f8] __schedule at ffffffffa749c4a6
 #1 [ffffa932c4ea7898] schedule at ffffffffa749cb48
 #2 [ffffa932c4ea78a0] rpc_wait_bit_killable at ffffffffc072230e [sunrpc]
 #3 [ffffa932c4ea78b8] __wait_on_bit at ffffffffa749cf94
 #4 [ffffa932c4ea78f0] out_of_line_wait_on_bit at ffffffffa749d071
 #5 [ffffa932c4ea7940] __rpc_execute at ffffffffc0722fd0 [sunrpc]
 #6 [ffffa932c4ea7998] rpc_run_task at ffffffffc0716e69 [sunrpc]
 #7 [ffffa932c4ea79d8] nfs4_call_sync_sequence at ffffffffc0828854 [nfsv4]
 #8 [ffffa932c4ea7a48] _nfs4_proc_readdir at ffffffffc082ab85 [nfsv4]
 #9 [ffffa932c4ea7b58] nfs4_proc_readdir at ffffffffc0834ff6 [nfsv4]
#10 [ffffa932c4ea7bd0] nfs_readdir_xdr_to_array at ffffffffc07e053c [nfs]
#11 [ffffa932c4ea7cd0] nfs_readdir_filler at ffffffffc07e07dd [nfs]
#12 [ffffa932c4ea7cf0] do_read_cache_page at ffffffffa6e16e6a
#13 [ffffa932c4ea7da0] nfs_readdir at ffffffffc07e096c [nfs]
#14 [ffffa932c4ea7e38] iterate_dir at ffffffffa6edcce6
#15 [ffffa932c4ea7e78] ksys_getdents64 at ffffffffa6eddc30
#16 [ffffa932c4ea7f30] __x64_sys_getdents64 at ffffffffa6edde46
#17 [ffffa932c4ea7f38] do_syscall_64 at ffffffffa6c0430b
#18 [ffffa932c4ea7f50] entry_SYSCALL_64_after_hwframe at ffffffffa7600088
    RIP: 00007f612a9bd757  RSP: 00007fff67b2a338  RFLAGS: 00000246
    RAX: ffffffffffffffda  RBX: 000056228f6a5a90  RCX: 00007f612a9bd757
    RDX: 0000000000008000  RSI: 000056228f6a5ac0  RDI: 0000000000000009
    RBP: 000056228f6a5ac0   R8: 0000000000000000   R9: 0000000000000001
    R10: 0000000000000001  R11: 0000000000000246  R12: ffffffffffffff80
    R13: 0000000000000000  R14: 000056228f6ada93  R15: 000056228f6ada80
    ORIG_RAX: 00000000000000d9  CS: 0033  SS: 002b
```
