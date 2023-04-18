[toc]

```shell
[   10.708686] ata1: PATA max MWDMA2 cmd 0x1f0 ctl 0x3f6 bmdma 0xc100 irq 14
[   10.709679] ata2: PATA max MWDMA2 cmd 0x170 ctl 0x376 bmdma 0xc108 irq 15
[   10.716087] Rounding down aligned max_sectors from 4294967295 to 4294967288
[   10.718125] db_root: cannot open: /etc/target
[   10.719743] slram: not enough parameters.
[   10.723474] general protection fault, probably for non-canonical address 0xdffffc00000000ad: 0000 [#1] PREEMPT SMP KASAN NOPTI
[   10.725358] KASAN: null-ptr-deref in range [0x0000000000000568-0x000000000000056f]
[   10.726634] CPU: 11 PID: 1 Comm: swapper/0 Not tainted 5.19.0-rc4-next-20220630-00001-gcc5218c8bd2c #1
[   10.728172] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.16.0-0-gd239552ce722-prebuilt.qemu.org 04/01/2014
[   10.730017] RIP: 0010:mtd_check_of_node+0x142/0x410
[   10.730911] Code: 38 06 00 00 48 81 fb 60 fe ff ff 74 82 e8 86 52 59 fc 48 8d bb 68 05 00 00 48 b8 00 00 00 00 00 fc ff df 48 89 fa 48 c1 ea 03 <80> 3c 02 00 0f 85 61 02 00 00 48 8b ab 68 05 00 00 48 85 ed 0f 84
[   10.732507] RSP: 0018:ffffc9000012fc28 EFLAGS: 00010212
[   10.732507] RAX: dffffc0000000000 RBX: 0000000000000000 RCX: 0000000000000000
[   10.732507] RDX: 00000000000000ad RSI: ffffffff8533b6ba RDI: 0000000000000568
[   10.732507] RBP: 0000000000000400 R08: 0000000000000001 R09: ffff8881048db882
[   10.732507] R10: ffffed102091b710 R11: ffff888100d10040 R12: ffff88810359c000
[   10.732507] R13: 0000000005a00000 R14: 1ffff92000025f8d R15: 0000000000000011
[   10.732507] FS:  0000000000000000(0000) GS:ffff888107d80000(0000) knlGS:0000000000000000
[   10.732507] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   10.732507] CR2: 0000000000000000 CR3: 000000000ca8e000 CR4: 0000000000350ee0
[   10.732507] Call Trace:
[   10.732507]  <TASK>
[   10.732507]  ? device_initialize+0x4c0/0x4c0
[   10.732507]  ? idr_alloc+0xe2/0x130
[   10.732507]  ? mtd_type_show+0xe0/0xe0
[   10.732507]  add_mtd_device+0x88d/0x1160
[   10.732507]  mtd_device_parse_register+0x150/0x300
[   10.732507]  mtdram_init_device+0x296/0x350
[   10.732507]  ? init_phram+0x9e/0x9e
[   10.732507]  init_mtdram+0xea/0x17c
[   10.732507]  ? init_phram+0x9e/0x9e
[   10.732507]  do_one_initcall+0x145/0x860
[   10.732507]  ? rdinit_setup+0x8a/0x8a
[   10.732507]  ? trace_event_raw_event_initcall_level+0x1f0/0x1f0
[   10.732507]  ? parse_one+0x400/0x4e0
[   10.732507]  ? write_comp_data+0x2a/0x80
[   10.732507]  do_initcalls+0x1fa/0x23f
[   10.732507]  kernel_init_freeable+0x2fc/0x342
[   10.732507]  ? rest_init+0x300/0x300
[   10.732507]  kernel_init+0x1f/0x230
[   10.732507]  ? rest_init+0x300/0x300
[   10.732507]  ret_from_fork+0x22/0x30
[   10.732507]  </TASK>
[   10.732507] Modules linked in:
[   10.761615] ---[ end trace 0000000000000000 ]---
[   10.762476] RIP: 0010:mtd_check_of_node+0x142/0x410
[   10.763384] Code: 38 06 00 00 48 81 fb 60 fe ff ff 74 82 e8 86 52 59 fc 48 8d bb 68 05 00 00 48 b8 00 00 00 00 00 fc ff df 48 89 fa 48 c1 ea 03 <80> 3c 02 00 0f 85 61 02 00 00 48 8b ab 68 05 00 00 48 85 ed 0f 84
[   10.766323] RSP: 0018:ffffc9000012fc28 EFLAGS: 00010212
[   10.767263] RAX: dffffc0000000000 RBX: 0000000000000000 RCX: 0000000000000000
[   10.768473] RDX: 00000000000000ad RSI: ffffffff8533b6ba RDI: 0000000000000568
[   10.769722] RBP: 0000000000000400 R08: 0000000000000001 R09: ffff8881048db882
[   10.770932] R10: ffffed102091b710 R11: ffff888100d10040 R12: ffff88810359c000
[   10.772142] R13: 0000000005a00000 R14: 1ffff92000025f8d R15: 0000000000000011
[   10.773376] FS:  0000000000000000(0000) GS:ffff888107d80000(0000) knlGS:0000000000000000
[   10.774732] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   10.775728] CR2: 0000000000000000 CR3: 000000000ca8e000 CR4: 0000000000350ee0
[   10.776940] Kernel panic - not syncing: Fatal exception
[   10.778120] Kernel Offset: disabled
[   10.778782] ---[ end Kernel panic - not syncing: Fatal exception ]---
```