# 最大子目录数

<!-- https://blog.51cto.com/u_11529070/10129653 -->
```sh
mkfs.ext4 -F /dev/sda
tune2fs -l /dev/sda # Filesystem features中有dir_nlink
dumpe2fs -h /dev/sda # 或者用dumpe2fs命令
```

以前ext4默认没开`dir_nlink`选项，子目录数量有限制，查看补丁`f8628a14a27e ext4: Remove 65000 subdirectory limit`。现在ext4默认打开`dir_nlink`选项，没有65000个的限制，具体查看`EXT4_FEATURE_RO_COMPAT_SUPP`宏定义。

ext4文件系统大小支持1EB。


# 支持长文件名

补丁为[`0001-ext2-support-long-file-name.patch`](https://gitee.com/chenxiaosonggitee/blog/blob/master/src/ext/0001-ext2-support-long-file-name.patch)。打开`CONFIG_BLK_DEV_LOOP`配置，用以下命令测试：
```sh
fallocate -l 100M image
mkfs.ext2 -F image
mount image /mnt
touch /mnt/\
<超过256个字节字符串>
```

## bug调试

在写这个功能时，曾经想过在长文件名文件所在目录下创建hash文件，补丁中改为`#define CXS_CREATE_HASHFILE_IN_SAME_DIR	1`，会出现问题。
```c
openat
  do_sys_open
    do_sys_openat2
      do_filp_open
        path_openat
          open_last_lookups
            inode_lock // touch创建文件，加写锁
            lookup_open
              ext2_lookup
                cxs_hash_filename
                  cxs_read_hash_file
                    cxs_open_file
                      filp_open
                        file_open_name
                          do_filp_open
                            path_openat
                              open_last_lookups
                                inode_lock // 这里也是创建文件，也加写锁
                                  down_write
```