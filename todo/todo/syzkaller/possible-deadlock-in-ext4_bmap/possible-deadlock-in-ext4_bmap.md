[toc]

https://syzkaller.appspot.com/bug?id=e4aaa78795e490421c79f76ec3679006c8ff4cf0

```shell
[  153.622634] ======================================================
[  153.623069] WARNING: possible circular locking dependency detected
[  153.623458] 5.19.0-next-20220810 #8 Not tainted
[  153.623767] ------------------------------------------------------
[  153.624162] a.out/991 is trying to acquire lock:
[  153.624478] ffff8881004eca38 (&sb->s_type->i_mutex_key#7){++++}-{3:3}, at: ext4_bmap+0x53/0x470
[  153.625050] 
               but task is already holding lock:
[  153.625471] ffff88817efc63f8 (&journal->j_checkpoint_mutex){+.+.}-{3:3}, at: jbd2_journal_flush+0x3fe/0x570
[  153.626108] 
               which lock already depends on the new lock.

[  153.626688] 
               the existing dependency chain (in reverse order) is:
[  153.627195] 
               -> #3 (&journal->j_checkpoint_mutex){+.+.}-{3:3}:
[  153.627709]        __lock_acquire+0xaf0/0x17c0
[  153.628036]        lock_acquire.part.0+0x189/0x4a0
[  153.628377]        mutex_lock_io_nested+0x15c/0x1270
[  153.628732]        jbd2_journal_flush+0x14c/0x570
[  153.629073]        __ext4_ioctl+0xb29/0x3330
[  153.629382]        __x64_sys_ioctl+0x19f/0x210
[  153.629697]        do_syscall_64+0x3b/0xc0
[  153.629999]        entry_SYSCALL_64_after_hwframe+0x63/0xcd
[  153.630380] 
               -> #2 (&journal->j_barrier){+.+.}-{3:3}:
[  153.630848]        __lock_acquire+0xaf0/0x17c0
[  153.631172]        lock_acquire.part.0+0x189/0x4a0
[  153.631520]        __mutex_lock+0x154/0x1460
[  153.631827]        jbd2_journal_lock_updates+0x163/0x320
[  153.632209]        ext4_change_inode_journal_flag+0x185/0x540
[  153.632608]        ext4_ioctl_setflags+0x96c/0xba0
[  153.632943]        ext4_fileattr_set+0x304/0x410
[  153.633266]        vfs_fileattr_set+0x3e1/0x550
[  153.633585]        do_vfs_ioctl+0x9be/0x1360
[  153.633896]        __x64_sys_ioctl+0x111/0x210
[  153.634210]        do_syscall_64+0x3b/0xc0
[  153.634518]        entry_SYSCALL_64_after_hwframe+0x63/0xcd
[  153.634908] 
               -> #1 (&sbi->s_writepages_rwsem){++++}-{0:0}:
[  153.635399]        __lock_acquire+0xaf0/0x17c0
[  153.635721]        lock_acquire.part.0+0x189/0x4a0
[  153.636061]        percpu_down_write+0x54/0x3c0
[  153.636382]        ext4_ind_migrate+0x23c/0x840
[  153.636732]        ext4_ioctl_setflags+0x9d9/0xba0
[  153.637063]        ext4_fileattr_set+0x304/0x410
[  153.637394]        vfs_fileattr_set+0x3e1/0x550
[  153.637718]        do_vfs_ioctl+0x9be/0x1360
[  153.638021]        __x64_sys_ioctl+0x111/0x210
[  153.638337]        do_syscall_64+0x3b/0xc0
[  153.638641]        entry_SYSCALL_64_after_hwframe+0x63/0xcd
[  153.639020] 
               -> #0 (&sb->s_type->i_mutex_key#7){++++}-{3:3}:
[  153.639528]        check_prev_add+0x163/0x20c0
[  153.639848]        validate_chain+0xa26/0xdc0
[  153.640167]        __lock_acquire+0xaf0/0x17c0
[  153.640494]        lock_acquire.part.0+0x189/0x4a0
[  153.640835]        down_read+0x9d/0x470
[  153.641112]        ext4_bmap+0x53/0x470
[  153.641398]        bmap+0xb2/0x130
[  153.641658]        jbd2_journal_bmap+0xad/0x190
[  153.641980]        __jbd2_journal_erase+0x3bd/0x6d0
[  153.642325]        jbd2_journal_flush+0x48d/0x570
[  153.642656]        __ext4_ioctl+0xb29/0x3330
[  153.642961]        __x64_sys_ioctl+0x19f/0x210
[  153.643274]        do_syscall_64+0x3b/0xc0
[  153.643574]        entry_SYSCALL_64_after_hwframe+0x63/0xcd
[  153.643958] 
               other info that might help us debug this:

[  153.644520] Chain exists of:
                 &sb->s_type->i_mutex_key#7 --> &journal->j_barrier --> &journal->j_checkpoint_mutex

[  153.645397]  Possible unsafe locking scenario:

[  153.645821]        CPU0                    CPU1
[  153.646123]        ----                    ----
[  153.646425]   lock(&journal->j_checkpoint_mutex);
[  153.646748]                                lock(&journal->j_barrier);
[  153.647166]                                lock(&journal->j_checkpoint_mutex);
[  153.647631]   lock(&sb->s_type->i_mutex_key#7);
[  153.647963] 
                *** DEADLOCK ***

[  153.648420] 2 locks held by a.out/991:
[  153.648696]  #0: ffff88817efc6170 (&journal->j_barrier){+.+.}-{3:3}, at: jbd2_journal_lock_updates+0x163/0x320
[  153.649353]  #1: ffff88817efc63f8 (&journal->j_checkpoint_mutex){+.+.}-{3:3}, at: jbd2_journal_flush+0x3fe/0x570
[  153.650008] 
               stack backtrace:
[  153.650346] CPU: 4 PID: 991 Comm: a.out Not tainted 5.19.0-next-20220810 #8
[  153.650800] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.16.0-0-gd239552ce722-prebuilt.qemu.org 04/01/2014
[  153.651497] Call Trace:
[  153.651695]  <TASK>
[  153.651873]  dump_stack_lvl+0x1c0/0x2b0
[  153.652169]  check_noncircular+0x26c/0x320
[  153.653139]  check_prev_add+0x163/0x20c0
[  153.653449]  validate_chain+0xa26/0xdc0
[  153.654371]  __lock_acquire+0xaf0/0x17c0
[  153.654678]  lock_acquire.part.0+0x189/0x4a0
[  153.656479]  down_read+0x9d/0x470
[  153.657672]  ext4_bmap+0x53/0x470
[  153.658237]  bmap+0xb2/0x130
[  153.658761]  jbd2_journal_bmap+0xad/0x190
[  153.660055]  __jbd2_journal_erase+0x3bd/0x6d0
[  153.661345]  jbd2_journal_flush+0x48d/0x570
[  153.661664]  __ext4_ioctl+0xb29/0x3330
[  153.664496]  __x64_sys_ioctl+0x19f/0x210
[  153.664795]  do_syscall_64+0x3b/0xc0
[  153.665076]  entry_SYSCALL_64_after_hwframe+0x63/0xcd
[  153.665431] RIP: 0033:0x7ff0270b39b9
[  153.665700] Code: 00 c3 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 48 89 f8 48 89 f7 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff 73 01 c3 48 8b 0d a7 54 0c 00 f7 d8 64 89 01 48
[  153.666784] RSP: 002b:00007ffd3214bd08 EFLAGS: 00000217 ORIG_RAX: 0000000000000010
[  153.667268] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007ff0270b39b9
[  153.667723] RDX: 0000000020000000 RSI: 000000004004662b RDI: 0000000000000004
[  153.668182] RBP: 00007ffd3214bd20 R08: 00007ffd3214bd20 R09: 00007ffd3214bd20
[  153.668639] R10: 00007ffd3214bd20 R11: 0000000000000217 R12: 000055bd7359b190
[  153.669099] R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000
[  153.669570]  </TASK>
```