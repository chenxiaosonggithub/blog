[toc]

问题描述: powerpc下不断的在5.10和2.6.34间来回升降级，在5.10启动时 rm 有问题的ext4文件或文件夹, 报错 corrupted inode

```c
// rm 文件报corrupted inode错误流程
unlinkat
  do_unlinkat
    iput
      iput_final
        evict
          ext4_evict_inode
            if (inode->i_nlink) // 条件不满足， i_nlink为0, 可以释放
            err = ext4_truncate = -EFSCORRUPTED
              ext4_ind_truncate
                ext4_free_data
                  ext4_clear_blocks
                    ext4_free_blocks
                      ext4_mb_clear_bb
                        dquot_free_block
                          dquot_free_space
                            mark_inode_dirty_sync
                              __mark_inode_dirty
                                ext4_dirty_inode
                                  __ext4_mark_inode_dirty
                                    ext4_mark_iloc_dirty
                                      ext4_do_update_inode
                                        ext4_fill_raw_inode
                                          ext4_inode_blocks_set
                                            if (i_blocks <= ~0U) // 条件不满足, iblocks = 0xfffffffffffffffa(8字节)， ~0U = 0xffffffff(4字节)
                                            if (!ext4_has_feature_huge_file(sb)) // 没有开启大文件属性
                                            return -EFSCORRUPTED
                                    ext4_error_inode_err
              ext4_mark_inode_dirty
                __ext4_mark_inode_dirty
                  ext4_mark_iloc_dirty
                    ext4_do_update_inode
                  ext4_error_inode_err
            goto stop_handle // truncate 失败， 停止处理

// 写数据更新 inode->i_blocks 的过程
write
  vfs_write
    __vfs_write
      ext4_file_write_iter
        __generic_file_write_iter
          generic_perform_write
            ext4_write_begin
              ext4_block_write_begin
                ext4_get_block
                  _ext4_get_block
                    ext4_map_blocks
                      ext4_ind_map_blocks
                        ext4_mb_new_blocks
                          __dquot_alloc_space
                            inode_add_bytes
                              __inode_add_bytes // 更新 i_blocks

// truncate 文件更新 inode->i_blocks 的过程
open
  do_sys_open
    do_filp_open
      path_openat
        do_truncate
          notify_change
            ext4_setattr
              ext_truncate
                ext4_ind_truncate
                  ext4_free_data
                    ext4_clear_blocks
                      ext4_free_blocks
                        __dquot_free_space
                          inode_sub_bytes
                            __inode_sub_bytes // 更新 i_blocks
```

```shell
# 设置immutable属性， root账号也无法删除, 报错Operation not permitted
chattr +i file
lsattr file
chattr -i file # 去除immutable属性后，可以删除文件成功
```

初始化 inode 号的过程：
```c
// ls
newstat
  vfs_fstatat
    vfs_statx
      filename_lookup
        path_lookupat
          walk_component
            lookup_slow
              __lookup_slow
                ext4_lookup
                  __ext4_iget
                    ext4_inode_blocks

// cat
open
  do_sys_open
    do_sys_openat2
      do_filp_open
        path_openat
          open_last_lookups
            lookup_open
              ext4_lookup
                __ext4_iget
                  ext4_inode_blocks
```

`touch file`:
```c
open
  do_sys_open
    do_sys_openat2
      do_filp_open
        path_openat
          open_last_lookups
            lookup_open
              ext4_create
                __ext4_new_inode
                  ext4_ext_tree_init
                    __ext4_mark_inode_dirty
                      ext4_mark_iloc_dirty
                        ext4_do_update_inode
                          ext4_fill_raw_inode
                            ext4_inode_blocks_set
                              inode->i_blocks == 0
                  __ext4_mark_inode_dirty
                    ext4_mark_iloc_dirty
                      ext4_do_update_inode
                        ext4_fill_raw_inode
                          ext4_inode_blocks_set
                            inode->i_blocks == 0
                ext4_add_nondir
                  ext4_add_entry
                    add_dirent_to_buf
                      __ext4_mark_inode_dirty
                        ext4_mark_iloc_dirty
                          ext4_do_update_inode
                            ext4_fill_raw_inode
                              ext4_inode_blocks_set
                                inode->i_blocks == 2
                  __ext4_mark_inode_dirty
                    ext4_mark_iloc_dirty
                      ext4_do_update_inode
                        ext4_fill_raw_inode
                          ext4_inode_blocks_set
                            inode->i_blocks == 0

utimensat
  do_utimes
    do_utimes_fd
      vfs_utimes
        notify_change
          ext4_setattr
            mark_inode_dirty
              __mark_inode_dirty
                ext4_dirty_inode
                  __ext4_mark_inode_dirty
                    ext4_mark_iloc_dirty
                      ext4_do_update_inode
                        ext4_fill_raw_inode
                          ext4_inode_blocks_set
                            inode->i_blocks == 0
```

`rm file -rf`
```c
unlinkat
  do_unlinkat
    iput
      iput_final
        evict
          ext4_evict_inode
            __ext4_mark_inode_dirty
              ext4_mark_iloc_dirty
                ext4_do_update_inode
                  ext4_fill_raw_inode
                    ext4_inode_blocks_set
                      inode->i_blocks == 2
            ext4_truncate
              ext4_ext_truncate
                __ext4_mark_inode_dirty
                  ext4_mark_iloc_dirty
                    ext4_do_update_inode
                      ext4_fill_raw_inode
                        ext4_inode_blocks_set
                          inode->i_blocks == 2
                ext4_ext_remove_space
                  ext4_ext_rm_leaf
                    ext4_remove_blocks
                      ext4_free_blocks
                        ext4_mb_clear_bb
                          dquot_free_block
                            dquot_free_space
                              mark_inode_dirty_sync
                                __mark_inode_dirty
                                  ext4_dirty_inode
                                    __ext4_mark_inode_dirty
                                      ext4_mark_iloc_dirty
                                        ext4_do_update_inode
                                          ext4_fill_raw_inode
                                            ext4_inode_blocks_set
                                              inode->i_blocks == 0
                    __ext4_ext_dirty
                      __ext4_mark_inode_dirty
                        ext4_mark_iloc_dirty
                          ext4_do_update_inode
                            ext4_fill_raw_inode
                              ext4_inode_blocks_set
                                inode->i_blocks == 0
```