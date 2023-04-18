[toc]

https://syzkaller.appspot.com/bug?id=c0e6183d33a904a5b7e3d5dedf877c5139b11a53

```shell
[   89.740478][  T937] ------------[ cut here ]------------
[   89.741064][  T937] kernel BUG at fs/ntfs/dir.c:86!     
[   89.741594][  T937] invalid opcode: 0000 [#1] PREEMPT SMP KASAN NOPTI
[   89.742268][  T937] CPU: 6 PID: 937 Comm: a.out Not tainted 5.19.0-next-20220808 #6 
[   89.743358][  T937] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.16.0-0-gd239552ce722-prebuilt.qemu.org 04/01/2014
[   89.744547][  T937] RIP: 0010:ntfs_lookup_inode_by_name+0xd57/0x2ca0                 
[   89.745395][  T937] Code: 01 00 00 e8 ab 73 c7 fe 48 8b 7c 24 28 49 8d 5c 24 07 e8 0c 33 21 ff 48 c7 44 24 28 00 00 00 00 e9 39 fb ff ff e8 89 73 c7 fe <0f> 0b e8 82 73 c7 fe 0f 0b e8 7b 73 c7 fe 48 8b 74 24 68 4c 89 e1
[   89.747406][  T937] RSP: 0018:ffffc900055ef9f8 EFLAGS: 00010293                      
[   89.748077][  T937] RAX: 0000000000000000 RBX: 0000000000008000 RCX: 0000000000000000
[   89.748945][  T937] RDX: ffff8881041b0000 RSI: ffffffff82c76f57 RDI: 0000000000000003
[   89.749781][  T937] RBP: ffff88807c92e000 R08: 0000000000000001 R09: ffff888075f91ccf           
[   89.750585][  T937] R10: ffffed100ebf2399 R11: ffffc900055ef5b0 R12: ffff88807f760050
[   89.751399][  T937] R13: ffff88807c92e180 R14: ffff88807f760000 R15: ffff88807c92e000
[   89.752215][  T937] FS:  00007f47d0ea3540(0000) GS:ffff888107b00000(0000) knlGS:0000000000000000
[   89.753130][  T937] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   89.753820][  T937] CR2: 00007fe715c88b18 CR3: 0000000079a88000 CR4: 0000000000350ee0
[   89.754635][  T937] Call Trace:                    
[   89.754992][  T937]  <TASK>
[   89.756494][  T937]  load_system_files+0x2199/0x3620
[   89.759447][  T937]  ntfs_fill_super+0xa66/0x1cf0
[   89.759990][  T937]  mount_bdev+0x359/0x420
[   89.761657][  T937]  legacy_get_tree+0x10d/0x220
[   89.762175][  T937]  vfs_get_tree+0x93/0x300
[   89.762668][  T937]  do_new_mount+0x2de/0x6e0
[   89.764872][  T937]  path_mount+0x49a/0x1840
[   89.766421][  T937]  __x64_sys_mount+0x288/0x310
[   89.768136][  T937]  do_syscall_64+0x3b/0xc0
[   89.768632][  T937]  entry_SYSCALL_64_after_hwframe+0x63/0xcd
[   89.769284][  T937] RIP: 0033:0x7f47d0ddb9ea
[   89.769761][  T937] Code: 48 8b 0d a9 f4 0b 00 f7 d8 64 89 01 48 83 c8 ff c3 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 49 89 ca b8 a5 00 00 00 0f 05 <48> 3d 01 f0 ff ff 73 01 c3 48 8b 0d 76 f4 0b 00 f7 d8 64 89 01 48
[   89.771679][  T937] RSP: 002b:00007ffef3034c78 EFLAGS: 00000206 ORIG_RAX: 00000000000000a5
[   89.772539][  T937] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007f47d0ddb9ea
[   89.773355][  T937] RDX: 0000000020000000 RSI: 0000000020000100 RDI: 00007ffef3034db0
[   89.774160][  T937] RBP: 00007ffef3034e30 R08: 00007ffef3034cb0 R09: 00007ffef3034df4
[   89.774972][  T937] R10: 0000000000000000 R11: 0000000000000206 R12: 00005625cd8d5160
[   89.775783][  T937] R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000
[   89.776606][  T937]  </TASK>
[   89.776936][  T937] Modules linked in:
[   89.777421][  T937] ---[ end trace 0000000000000000 ]---
```

```c
load_system_files
  load_and_init_quota
    ntfs_lookup_inode_by_name

ntfs_extend_init
  if (!S_ISDIR(inode->i_mode)) {
  err = -EINVAL;
```