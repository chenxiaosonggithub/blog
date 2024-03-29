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
