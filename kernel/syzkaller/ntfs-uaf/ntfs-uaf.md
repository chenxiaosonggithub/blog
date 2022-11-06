[toc]

https://syzkaller.appspot.com/bug?id=80913ff3e4962a46fcce7ffd4125fdd1b8e11171

```shell
[   49.758108] ==================================================================
[   49.758903] BUG: KASAN: use-after-free in ntfs_ucsncmp+0x123/0x130
[   49.759617] Read of size 2 at addr ffff8880751acee8 by task a.out/879

[   49.760594] CPU: 7 PID: 879 Comm: a.out Not tainted 5.19.0-rc4-next-20220630-00001-gcc5218c8bd2c-dirty #7
[   49.761628] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.16.0-0-gd239552ce722-prebuilt.qemu.org 04/01/2014
[   49.762838] Call Trace:
[   49.763176]  <TASK>
[   49.763481]  dump_stack_lvl+0x1c0/0x2b0
[   49.763976]  print_address_description.constprop.0.cold+0xd4/0x484
[   49.765183]  print_report.cold+0x55/0x232
[   49.766207]  kasan_report+0xbf/0xf0
[   49.767170]  ntfs_ucsncmp+0x123/0x130
[   49.767641]  ntfs_are_names_equal.cold+0x2b/0x41
[   49.768209]  ntfs_attr_find+0x43b/0xb90
[   49.768714]  ntfs_attr_lookup+0x16d/0x1e0
[   49.769229]  ntfs_read_locked_attr_inode+0x4aa/0x2360
[   49.769839]  ntfs_attr_iget+0x1af/0x220
[   49.772048]  ntfs_read_locked_inode+0x246c/0x5120
[   49.773808]  ntfs_iget+0x132/0x180
[   49.775265]  load_system_files+0x1cc6/0x3480
[   49.778051]  ntfs_fill_super+0xa66/0x1cf0
[   49.778556]  mount_bdev+0x38d/0x460
[   49.780133]  legacy_get_tree+0x10d/0x220
[   49.780622]  vfs_get_tree+0x93/0x300
[   49.781083]  do_new_mount+0x2da/0x6d0
[   49.783044]  path_mount+0x496/0x19d0
[   49.784998]  __x64_sys_mount+0x284/0x300
[   49.786563]  do_syscall_64+0x3b/0xc0
[   49.787039]  entry_SYSCALL_64_after_hwframe+0x46/0xb0
[   49.787646] RIP: 0033:0x7f3f2118d9ea
[   49.788098] Code: 48 8b 0d a9 f4 0b 00 f7 d8 64 89 01 48 83 c8 ff c3 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 49 89 ca b8 a5 00 00 00 0f 05 <48> 3d 01 f0 ff ff 73 01 c3 48 8b 0d 76 f4 0b 00 f7 d8 64 89 01 48
[   49.789982] RSP: 002b:00007ffc269deac8 EFLAGS: 00000202 ORIG_RAX: 00000000000000a5
[   49.790822] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007f3f2118d9ea
[   49.791604] RDX: 0000000020000000 RSI: 0000000020000100 RDI: 00007ffc269dec00
[   49.792234] RBP: 00007ffc269dec80 R08: 00007ffc269deb00 R09: 00007ffc269dec44
[   49.792864] R10: 0000000000000000 R11: 0000000000000202 R12: 000055f81ab1d220
[   49.793486] R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000
[   49.794123]  </TASK>

[   49.794564] The buggy address belongs to the physical page:
[   49.795078] page:0000000085430378 refcount:1 mapcount:1 mapping:0000000000000000 index:0x555c6a81d pfn:0x751ac
[   49.795926] memcg:ffff888101f7e180
[   49.796262] anon flags: 0xfffffc00a0014(uptodate|lru|mappedtodisk|swapbacked|node=0|zone=1|lastcpupid=0x1fffff)
[   49.797127] raw: 000fffffc00a0014 ffffea0001bf2988 ffffea0001de2448 ffff88801712e201
[   49.797805] raw: 0000000555c6a81d 0000000000000000 0000000100000000 ffff888101f7e180
[   49.798477] page dumped because: kasan: bad access detected

[   49.799181] Memory state around the buggy address:
[   49.799622]  ffff8880751acd80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[   49.800255]  ffff8880751ace00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[   49.800890] >ffff8880751ace80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[   49.801515]                                                           ^
[   49.802107]  ffff8880751acf00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[   49.802745]  ffff8880751acf80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[   49.803376] ==================================================================
```

```shell
apt install ntfs-3g -y # mkfs.ntfs
fdisk /dev/sda # 新建分区 /dev/sda1
apt remove ntfs-3g -y # 必须要卸载　ntfs-3g，否则会使用 fuse 挂载
```

```c
mount
  path_mount
    do_new_mount
      vfs_get_tree
        legacy_get_tree
          mount_bdev
            ntfs_fill_super
              ntfs_setup_allocators
              load_system_files
                load_and_init_attrdef
                  ntfs_malloc_nofs
                ntfs_iget
                  ntfs_read_locked_inode
                    ntfs_attr_iget
                      ntfs_read_locked_attr_inode
                        MFT_RECORD *m = map_mft_record(base_ni)
                          map_mft_record_page
                            page = ntfs_map_page // 分配1个page
                            return page_address(page) + ofs
                        ntfs_attr_get_search_ctx
                          ntfs_attr_search_ctx *ctx = kmem_cache_alloc // ntfs_attr_search_ctx 字段 MFT_RECORD* 和 ATTR_RECORD*
                          ntfs_attr_init_search_ctx
                            .attr = (ATTR_RECORD*)((u8*)mrec + le16_to_cpu(mrec->attrs_offset))
                        ntfs_attr_lookup
                          ntfs_attr_find
                            ntfs_are_names_equal
                              ntfs_ucsncmp
                                c2 = le16_to_cpu(s2[i]);

ntfs_attr_size_bounds_check // 挂载时没执行到
ntfs_cluster_alloc // 挂载时没执行到

#define PAGE_SHIFT              12
#define PAGE_SIZE               (_AC(1,UL) << PAGE_SHIFT) // 4096
#define PAGE_MASK               (~(PAGE_SIZE-1)) // 0xffffff000

#define PAGE_ALIGN(addr) ALIGN(addr, PAGE_SIZE) // ALIGN(addr, 4096)
#define ALIGN(x, a)             __ALIGN_KERNEL((x), (a)) // __ALIGN_KERNEL((addr), (4096))
#define __ALIGN_KERNEL(x, a)            __ALIGN_KERNEL_MASK(x, (typeof(x))(a) - 1) // __ALIGN_KERNEL_MASK(addr, (4096) - 1) = __ALIGN_KERNEL_MASK(addr, 4095)
#define __ALIGN_KERNEL_MASK(x, mask)    (((x) + (mask)) & ~(mask)) // (((addr) + (4095)) & ~(4095)) = (((addr) + (0xfff)) & 0xffffff000)
```