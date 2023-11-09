[toc]

# 环境

内核编译：
```shell
Device Drivers -> Memory Technology Device (MTD) support -> Enable UBI - Unsorted block images
File systems -> Miscellaneous filesystems -> UBIFS file system support
MTD_NAND_NANDSIM=m
CONFIG_MTD_NAND_ECC_SW_HAMMING=y
CONFIG_MTD_NAND_ECC_SW_BCH=y
CONFIG_MTD_PARTITIONED_MASTER=y
```

软件安装：
```shell
yum install zlib zlib-devel -y
yum install lzo-devel -y
yum install libzstd-devel -y
yum install openssl-devel -y

yum install mtd-utils -y # 安装后，可能找不到 ubimkvol，可以使用源码安装

git clone git://git.infradead.org/mtd-utils.git # 源码安装
./autogen.sh # 不能到 build　目录下执行
./configure
make
```

挂载：
```shell
# /dev/ubi0_0 on /mnt type ubifs (rw,relatime,sync,assert=read-only,ubi=0,vol=0)
modprobe nandsim id_bytes="0xec,0xa1,0x00,0x15" # 128M 128KB 2KB
# modprobe nandsim id_bytes="0x20,0xa5,0x00,0x15" # 2G 128KB PEB, 2KB page
# modprobe nandsim id_bytes="0x20,0xa5,0x00,0x26" # 4G 256KB 4KB 1KB-sub-page
# modprobe nandsim id_bytes="0x20,0xa7,0x00,0x15" # 4G 256KB 4KB 2KB-sub-page
# modprobe nandsim id_bytes="0x20,0x33,0x00,0x00" # 16M 16KB PEB, 512 page
modprobe ubi mtd="0,4096" #fm_autoconvert # 0,4096 表示 ubi0 设备 header 长度 4096。 1,2048 表示 表示 ubi1设备 header 长度 2048
ubimkvol -N vol_a -m -n 0 /dev/ubi0
modprobe ubifs
mount -o sync -t ubifs /dev/ubi0_0 /mnt/
dd if=/dev/mtd0 of=image.bin # 导出镜像

modprobe -r ubifs && modprobe -r ubi
nandwrite /dev/mtd0 image.bin # 把 image.bin 写入 /dev/mtd0
modprobe ubi mtd="0,4096"
mount -t ubifs /dev/ubi0_0 /mnt/
```

```shell
modprobe nandsim id_bytes="0x20,0xa5,0x00,0x26"
flash_erase /dev/mtd0 0 0
nandwrite /dev/mtd0 image.bin
modprobe ubi
ubiattach -m 0 -O 4096
for each in $(ls /sys/kernel/debug/ubifs)
do
  echo 1 > /sys/kernel/debug/ubifs/${each}
done
mount -t ubifs /dev/ubi0_0 /mnt
```

```shell
cat /sys/class/ubi/ubi0/mtd_num
mtd_debug read /dev/mtd0 0x0 64 /tmp/flash_test # 前64个字节copy到文件
flash_erase /dev/mtd0 0 0 # 擦除整个设备
hexdump -n 32 /dev/mtd0 # 读取前 32 个字节
```

qemu 启动时模拟(不建议):
```shell
CONFIG_MTD_PHRAM=y
-append 后加 phram=tst_mtd,0,64Mi 模拟64M flash, 具体见 drivers/mtd/devices/phram.c
```

gdb调试：
```shell
cd /sys/module/ubifs/sections/
cat .text .data .bss
add-symbol-file /home/sonvhi/chenxiaosong/code/x86_64-linux/mod/lib/modules/5.18.0+/kernel/fs/ubifs/ubifs.ko 0xffffffffa0210000 -s .data 0xffffffffa02ff000 -s .bss 0xffffffffa0320780
```

# modprobe ubi mtd="0,2048"

```c
ubi_init
  ubi_attach_mtd_dev
    ubi_attach
      scan_all
        scan_peb
          ubi_io_read_ec_hdr
          ubi_io_read_vid_hdr
            p = vidb->buffer
            ubi_io_read(, ..., p, ...) // 读 lnum 等信息
        ubi_eba_init
          ubi_eba_create_table // 初始化为 unmapped
          entry->pnum = aeb->pnum
```

# mount

```c
mount
  do_mount
    path_mount
      do_new_mount
        vfs_get_tree
          legacy_get_tree
            ubifs_mount
              ubifs_fill_super
                mount_ubifs
                  ubifs_read_superblock
                    ubifs_read_sb_node
                      ubifs_read_node
                  ubifs_read_master
                    dbg_old_index_check_init
                      ubifs_read_node
```

# cat

```c
read
  ksys_read
    vfs_read
      new_sync_read
        call_read_iter
          generic_file_read_iter
            filemap_read
              filemap_get_pages
                filemap_create_folio
                  filemap_read_folio
                    ubifs_read_folio
                      do_readpage
                        read_block
                          ubifs_tnc_lookup
                            ubifs_tnc_locate
                              ubifs_tnc_read_node
                                ubifs_read_node_wbuf
                                  ubifs_read_node
                                    ubifs_leb_read
                                      ubi_read
                                        ubi_leb_read
                                          ubi_eba_read_leb
                                            ubi_io_read_data
                                              ubi_io_read
```

# echo

```c
// -o sync 挂载
open
  do_sys_open
    do_sys_openat2
      do_filp_open
        path_openat
          do_open
            handle_truncate
              do_truncate
                notify_change
                  ubifs_setattr
                    do_truncation
                      ubifs_jnl_truncate
                        write_head
                          ubifs_wbuf_sync_nolock
                            ubifs_leb_write
                              ubi_leb_write
                                ubi_eba_write_leb
                                  ubi_io_write_data
                                    ubi_io_write

write
  ksys_write
    vfs_write
      new_sync_write
        call_write_iter
          ubifs_write_iter
            generic_file_write_iter
              generic_write_sync
                vfs_fsync_range
                  ubifs_fsync
                    file_write_and_wait_range
                      __filemap_fdatawrite_range
                        filemap_fdatewrite_wbc
                          do_writepages
                            generic_writepages
                              write_cache_pages
                                __writepage
                                  ubifs_writepage
                                    if (page->index < end_index) { // 条件不满足
                                    ubifs_write_inode
                                      ubifs_jnl_write_inode
                                        write_head
                                          ubifs_wbuf_sync_nolock
                                            ubifs_leb_write
                                              ubi_leb_write
                                                ubi_eba_write_leb
                                                  ubi_io_write_data
                                                    ubi_io_write
                                    do_writepage
                                      ubifs_jnl_write_data
                    ubifs_sync_wbufs_by_inode
                      ubifs_wbuf_sync_nolock
                        ubifs_leb_write
                          ubi_leb_write
                            ubi_eba_write_leb
                              ubi_io_write_data
                                ubi_io_write
                        
```

# sync

```c
// -o sync 挂载时
sync
  ksys_sync
    iterate_supers
      sync_fs_one_sb
        ubifs_sync_fs
          ubifs_run_commit
            do_commit
              ubifs_log_post_commit
                ubifs_leb_unmap
                  ubi_leb_unmap
                    ubi_eba_unmap_leb
```
