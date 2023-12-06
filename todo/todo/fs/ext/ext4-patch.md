[toc]

# fc750a3b44bd jbd2: avoid transaction reuse after reformatting

这个补丁的目的是：格式化时指定 lazy_journal_init=1， checksum seed 改变导致 csum校验失败。

这个补丁也能解决：写 4K page 时断电，描述块page没写完整（硬件上以512为单位），csum错误

```c
mount
  do_mount
    path_mount
      do_new_mount
        vfs_get_tree
          ext4_get_tree
            get_tree_bdev
              ext4_fill_super
                __ext4_fill_super
                  ext4_load_journal
                    jbd2_journal_load
                      jbd2_journal_recover
                        // 异常关机后恢复，３个阶段
                        // 扫描阶段：主要的作用是找到日志的起点和终点，注意日志空间可看做一个环形结构
                        do_one_pass(journal, &info, PASS_SCAN)
                          case JBD2_DESCRIPTOR_BLOCK // 描述块
                          if (!jbd2_descriptor_block_csum_verify // 检查 checksum, 如果csum错误
                          ; // 如果csum错误，扫描阶段不报错，因为可能 lazy journal init
                          need_check_commit_time = true // 如果csum错误
                          if (!need_check_commit_time) // 如果csum没有错误, 以及其他的条件满足
                          calc_chksums // TODO: 这是干啥的？

                          case JBD2_COMMIT_BLOCK // 提交块
                          if (need_check_commit_time) // 需要检查提交块的时间
                          ; // 如果时间不是递增，则判断为旧的 journal block, 不报错
                          if (pass == PASS_SCAN // 是日志扫描阶段
                          jbd2_commit_block_csum_verify
                          last_trans_commit_time = commit_time
                          next_commit_ID++

                          case JBD2_REVOKE_BLOCK // 取消块
                          jbd2_descriptor_block_csum_verify
                          need_check_commit_time = true // 如果csum错误
```

# TODO: ext4: convert symlink external data block mapping to bdev

https://patchwork.ozlabs.org/project/linux-ext4/patch/20220418063735.2067766-1-yi.zhang@huawei.com/

`ext4_symlink_inode_operations` 中的 `get_link` 方法，需要在 symlink 路径名长度大于60时才会访问到
```c
newstat
  vfs_stat
    vfs_fstatat
      vfs_statx
        filename_lookup
          path_lookupat(..., flags | LOOKUP_RCU, ...)
            lookup_last
              walk_component
                step_into
                  pick_link
                    if (nd->flags & LOOKUP_RCU) // 条件满足
                    page_get_link(NULL, inode, ...)

readlink
  do_readlinkat
    vfs_readlink
      page_get_link

open
  do_sys_open 
    do_sys_openat2
      do_filp_open
        path_openat
          open_last_lookups
            step_into
              pick_link
                page_get_link
```

# ext4: fix bug_on in ext4_writepages

https://patchwork.ozlabs.org/project/linux-ext4/patch/20220516122634.1690462-1-yebin10@huawei.com/

```shell
mkfs.ext4 -O inline_data -b 4096 -F /dev/sda
mount /dev/sda /mnt
echo 1 > /mnt/file # 小文件
# 大文件，60个字符好像不够, 注意是追加 >>, 否则用 > 会删除文件重新创建
echo 123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890 >> /mnt/file
fallocate -l 10M /mnt/file
sync
```

```c
// 创建小文件，再追加大量数据
write
  ksys_write
    vfs_write
      new_sync_write
        call_write_iter
          ext4_file_write_iter
            ext4_buffered_write_iter
              generic_perform_write
                ext4_da_write_begin
                  ext4_da_write_inline_data_begin
                    ext4_da_convert_inline_data_to_extent // 先创建小文件，再追加大量数据, 执行到这里
                      SetPageDirty(page)
                      ext4_clear_inode_state(inode, EXT4_STATE_MAY_INLINE_DATA)

// fallocate命令注入故障
fallocate
  ksys_fallocate
    vfs_fallocate
      ext4_fallocate
        ext4_convert_inline_data
          ext4_convert_inline_data_nolock
            error = ext4_map_blocks
            // 注入故障
            if (strcmp(current->comm, "fallocate") == 0)
            error = -ENOSPC
            goto out_restore
            ext4_restore_inline_data
              ext4_set_inode_state(inode, EXT4_STATE_MAY_INLINE_DATA)

// 回写触发 bug on
kthread
  process_one_work
    wb_workfn
      wb_do_writeback
        wb_check_old_data_flush
          wb_writeback
            __writeback_inodes_wb
              writeback_sb_inodes
                __writeback_single_inode
                  do_writepages
                    ext4_writepages
                      if (ext4_has_inline_data(inode))
                      BUG_ON(ext4_test_inode_state(inode, EXT4_STATE_MAY_INLINE_DATA))
                      ext4_destroy_inline_data
```