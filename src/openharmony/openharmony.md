[toc]

# 内核

```shell
mkdir -p /mnt/dst
mkdir -p /mnt/cache_dir
mkdir -p /mnt/src
mount -t hmdfs -o merge,local_dst=/mnt/dst,cache_dir=/mnt/cache_dir /mnt/src /mnt/dst
```

```c
hmdfs_root_lookup // hmdfs_root_ops.lookup
  hmdfs_lookup_merge

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


