[toc]

# 内核

```shell
mkdir -p /mnt/dst
mkdir -p /mnt/cache_dir/dentry_cache/cloud
setfattr -n user.hmdfs_cache -v "/" /mnt/cache_dir/dentry_cache/cloud/cloud_2f # '/'对应的dentryfile
setfattr -n user.hmdfs_cache -v "/dir/" /mnt/cache_dir/dentry_cache/cloud/cloud_16e1fe # '/dir/'对应的dentryfile
mkdir -p /mnt/src
mount -t hmdfs -o merge,local_dst=/mnt/dst,cache_dir=/mnt/cache_dir /mnt/src /mnt/dst


```

```c
mount
  do_mount
    path_mount
      do_new_mount
        vfs_get_tree
          legacy_get_tree
            hmdfs_mount
              mount_nodev
                hmdfs_fill_super
                  hmdfs_cfn_load
                    hmdfs_do_load
                      store_one
                        load_cfn
                          __find_cfn

openat(mode=0, flags=<optimized out>, filename=0x563e18a6a260 "/mnt/dst/device_view/cloud/", dfd=-100)
  do_sys_open
    do_sys_openat2
      do_filp_open
        path_openat
          do_open
            vfs_open
              do_dentry_open
                hmdfs_dir_open_cloud // error = open(inode, f);
                  get_cloud_cache_file
                    find_cfn
                      __find_cfn

getdents64
  iterate_dir
    hmdfs_iterate_cloud

statx (buffer=0x7ffd70865710, mask=606, flags=256, filename=0x7ffd70865840 "/mnt/dst/device_view/cloud/file", dfd=-100)
  do_statx
    vfs_statx
      user_path_at
        user_path_at_empty
          filename_lookup
            lookup_last
              walk_component
                lookup_slow
                  __lookup_slow
                    hmdfs_lookup_cloud
                      hmdfs_lookup_cloud_dentry
                        hmdfs_lookup_by_cloud
                          lookup_cloud_dentry
                            get_cloud_cache_file
                              find_cfn
                                __find_cfn

getxattr (size=0, value=0x0 <fixed_percpu_data>, name=0x561f9f54cff3 "system.posix_acl_access", pathname=0x7ffebe802930 "/mnt/dst/device_view/cloud/file")
  path_getxattr
    user_path_at
      user_path_at_empty
        filename_lookup
          lookup_last
            walk_component
              lookup_slow
                __lookup_slow
                  hmdfs_lookup_cloud
                    hmdfs_lookup_cloud_dentry
                      hmdfs_lookup_by_cloud
                        lookup_cloud_dentry
                          get_cloud_cache_file
                            find_cfn
                              __find_cfn
```

name hash 处理流程：
```c
hmdfs_dentry_hash

cache_file_persistent
  cache_file_name_generate
    path_hash
```

```c
hmdfs_root_lookup // hmdfs_root_ops.lookup
  hmdfs_lookup_cloud_merge

hmdfs_device_lookup // hmdfs_device_ops.lookup
  init_hmdfs_dentry_info
  fill_device_inode_cloud

hmdfs_root_iterate // hmdfs_root_fops.iterate

hmdfs_device_iterate // hmdfs_device_fops.iterate

hmdfs_dev_d_release // hmdfs_dev_dops.d_release
  hmdfs_clear_cache_dents

struct file_operations hmdfs_dev_file_fops_cloud

struct address_space_operations hmdfs_dev_file_aops_cloud // 成员函数全部赋值为 NULL

struct file_operations hmdfs_dev_dir_ops_cloud

hmdfs_sb_info
  struct list_head cloud_cache

hmdfs_dir_open_cloud // hmdfs_dev_dir_ops_cloud.open
  get_cloud_cache_file
    hmdfs_get_dentry_relative_path
      hmdfs_dentry_path_raw
        hmdfs_get_root_dentry_type
    find_cfn
    hmdfs_add_cache_list

hmdfs_put_super // hmdfs_sops.put_super
  hmdfs_cfn_destroy
    __destroy_cfn

hmdfs_fill_super
  hmdfs_cfn_load
    hmdfs_do_load
      dentry_open
      store_one
        filp_open
        load_cfn
          head = &sbi->cloud_cache
          __find_cfn
          list_add_tail

struct inode_operations hmdfs_dev_dir_inode_ops_cloud

struct inode_operations hmdfs_dev_file_iops_cloud


hmdfs_lookup_cloud // hmdfs_dev_dir_inode_ops_cloud.lookup
  init_hmdfs_dentry_info

struct inode_operations hmdfs_file_iops_cloud_merge

struct inode_operations hmdfs_dir_iops_cloud_merge
```

# dentryfiletool

https://gitee.com/chenxiaosonggitee/dentryfiletool


