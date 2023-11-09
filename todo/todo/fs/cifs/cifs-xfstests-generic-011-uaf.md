[toc]

```shell
./check generic/011
```

```c
creat
  do_sys_open
    do_sys_openat2
      do_filp_open
        path_openat
          open_last_lookups
            lookup_open
              cifs_d_revalidate
                cifs_revalidate_dentry
                  cifs_revalidate_dentry_attr
                    cifs_get_inode_info
                      check_mf_symlink
                        parse_mf_symlink
                          kstrndup
                            __kmalloc_node_track_caller
                        fattr->cf_symlink_target = symlink
              d_alloc_parallel(&nd->last)
                d_alloc
                  __d_alloc
                    memcpy

creat
  do_sys_open
    do_sys_openat2
      do_filp_open
        path_openat
          open_last_lookups
            lookup_open
              cifs_d_revalidate
                cifs_revalidate_dentry
                  cifs_revalidate_dentry_attr
                    cifs_get_inode_info
                      cifs_fattr_to_inode
                        kfree
```
