[toc]

# 2.6.11

## ext2

```c
ext2_fill_super
  sb->s_fs_info = sbi // ext2_sb_info
  bh = sb_bread
    __bread
  sbi->s_sbh = bh
  sbi->s_group_desc = kmalloc
  sbi->s_debts = kmalloc
  sbi->s_group_desc[i] = sb_bread
  root = iget(sb, EXT2_ROOT_INO)
  sb->s_root = d_alloc_root

ext2_new_inode
  inode = new_inode(dir->i_sb)
    list_add(&inode->i_list, &inode_in_use)
    list_add(&inode->i_sb_list, &sb->s_inodes)
  find_group_orlov / find_group_other
  bitmap_bh = read_inode_bitmap
  mark_buffer_dirty
  sync_dirty_buffer // MS_SYNCHRONOUS
  gdp->bg_free_inodes_count--
  gdp->bg_used_dirs_count++ // directory
  sbi->s_debts[group]--
  sb->s_dirt = 1
  mark_buffer_dirty(bh2)
  // 给 inode ei 赋值
  insert_inode_hash
  ext2_init_acl
  mark_inode_dirty
  ext2_preread_inode

ext2_free_inode
  clear_inode
    invalidate_inode_buffers
    wait_on_inode
    inode->i_sb->s_op->clear_inode // ext2 do not have
    bd_forget
    inode->i_state = I_CLEAR
  block_group = (ino - 1) / EXT2_INODES_PER_GROUP(sb)
  bitmap_bh = read_inode_bitmap
  ext2_release_inode
    desc->bg_free_inodes_count++
    desc->bg_used_dirs_count--
    sb->s_dirt = 1
    mark_buffer_dirty
  mark_buffer_dirty(bitmap_bh)
  sync_dirty_buffer // MS_SYNCHRONOUS

ext2_get_block
  ext2_alloc_branch
    ext2_alloc_block
      ext2_new_block

ext2_truncate
  ext2_free_data
    ext2_free_blocks
      bitmap_bh = read_block_bitmap
      ext2_clear_bit_atomic
      group_release_blocks
        desc->bg_free_blocks_count = cpu_to_le16(free_blocks + count
        sb->s_dirt = 1
        mark_buffer_dirty(bh)
      sync_dirty_buffer // MS_SYNCHRONOUS
```

## ext3

```c
// .write
do_sync_write
  // .aio_write
  ext3_file_write
    generic_file_aio_write
      __generic_file_aio_write_nolock
        generic_file_buffered_write
          // a_ops->prepare_write
          ext3_prepare_write
            ext3_journal_start
              ext3_journal_start_sb
                journal_start
                  new_handle // 第一次创建
                  current->jouranl_info = handle
            block_prepare_write // 准备文件页的缓冲区和缓冲区首部
              __block_prepare_write
                // get_block
                ext3_get_block
                  ext3_get_block_handle
                    ext3_alloc_branch
                      ext3_alloc_block
                        ext3_new_block
                          ext3_journal_get_write_access
                            __ext3_journal_get_write_access
                              journal_get_write_access
                                journal_add_journal_head
                                  // BUFFER_FNS(JBD, jbd) // linux/jbd.h
                                  // test_bit(BH_JBD, &(bh)->b_state)
                                  if(!buffer_jbd(bh))
                                  new_jh = journal_alloc_journal_head
                                do_get_write_access
                          ext3_journal_dirty_metadata
                            __ext3_journal_dirty_metadata
                              // 把元数据缓冲区移到活动事务的适当脏链表中, 并在日志中记录
                              journal_dirty_metadata
            if (ext3_should_journal_data()) // journal 模式 mount
            walk_page_buffers
              do_journal_get_write_access
                ext3_journal_get_write_access
                  __ext3_journal_get_write_access
                    journal_get_write_access
          // a_ops->commit_write
          ext3_journalled_commit_write // journal模式
            walk_page_buffers
              commit_write_fn
                ext3_journal_dirty_metadata
                  __ext3_journal_dirty_metadata
                    journal_dirty_metadata
            ext3_journal_stop
              __ext3_journal_stop
                journal_stop
          // a_ops->commit_write
          ext3_ordered_commit_write // order 模式
            walk_page_buffers
              ext3_journal_dirty_data
                journal_dirty_data
            generic_commit_write
            ext3_journal_stop
          // a_ops->commit_write
          ext3_writeback_commit_write // writeback 模式
            generic_commit_write
            ext3_journal_stop

_SYSCALL(_NR_mount, sys_mount)
  sys_mount
    do_mount
      do_new_mount
        do_kern_mount
          // type->get_sb
          ext3_get_sb
            get_sb_bdev
              // fill_super
              ext3_fill_super
                ext3_load_journal
                  ext3_get_journal
                  journal_load
                    journal_reset
                      journal_start_thread
                        // kernel_thread(kjournald,
                        kjournald
                          journal_commit_transaction
```

# mainline

## 磁盘数据结构

```
+-------------------------------------------------------------------------------------------------------------------------------------+
| boot block |                                         block group 0                                                 | block group 1  |
+-------------------------------------------------------------------------------------------------------------------------------------+
|            | super block   | group descriptors | data block bitmap | inode bitmap  | inode table   | data blocks   | ......         |
+-------------------------------------------------------------------------------------------------------------------------------------+
|            | 1 block       | n blocks          | 1 block           | 1 block       | n blocks      | n blocks      | ......         |
+-------------------------------------------------------------------------------------------------------------------------------------+
```

## 日志布局

```
+--------------------------------------------------------------------------------------+
| super block | revoke block | description block | data block  | commit block | ...... |
+--------------------------------------------------------------------------------------+
|             | transaction  | transaction       | transaction | transaction  |        |
+--------------------------------------------------------------------------------------+
```

## 日志恢复流程

```c
task_work_run
  __cleanup_mnt
    cleanup_mnt
      deactivate_super
        deactivate_locked_super
          kill_block_super
            generic_shutdown_super
              ext4_put_super
                jbd2_journal_destroy
                  jbd2_log_do_checkpoint
                    jbd2_cleanup_journal_tail
                      __jbd2_update_log_tail
                        jbd2_journal_update_sb_log_tai
                  jbd2_mark_journal_empty
                    sb->s_start = 0 // 正常卸载

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
                          while (1) {
                          jread(&bh, journal, next_log_block) // 读取下一个　block
                          if (tmp->h_magic != cpu_to_be32(JBD2_MAGIC_NUMBER) // 判断 magic

                          case JBD2_DESCRIPTOR_BLOCK // 描述块
                          jbd2_descriptor_block_csum_verify // 检查 checksum
                          if (pass != PASS_REPLAY) { // 不是日志重演阶段
                          continue // 跳过此描述符记录的数据块

                          case JBD2_COMMIT_BLOCK // 提交块
                          if (pass == PASS_SCAN // 是日志扫描阶段
                          jbd2_commit_block_csum_verify
                          next_commit_ID++

                          case JBD2_REVOKE_BLOCK // 取消块
                          if (pass != PASS_REVOKE) { // 不是日志取消阶段
                          continue
                          } // while end
                        // 取消阶段：主要的作用是找到 revoke 块，并把信息读入内存的　revoke hash table
                        do_one_pass(journal, &info, PASS_REVOKE)
                          while (1) {
                          jread(&bh, journal, next_log_block) // 读取下一个　block
                          if (tmp->h_magic != cpu_to_be32(JBD2_MAGIC_NUMBER) // 判断 magic

                          case JBD2_DESCRIPTOR_BLOCK // 描述块
                          jbd2_descriptor_block_csum_verify // 检查 checksum
                          if (pass != PASS_REPLAY) { // 不是日志重演阶段
                          continue // 跳过此描述符记录的数据块

                          case JBD2_COMMIT_BLOCK // 提交块
                          if (pass == PASS_SCAN // 不是日志扫描阶段
                          next_commit_ID++

                          case JBD2_REVOKE_BLOCK // 取消块
                          if (pass != PASS_REVOKE) { // 是日志取消阶段
                          scan_revoke_records // 读取一个 revoke 记录
                            jbd2_journal_set_revoke
                              insert_revoke_hash // 插入 hash 表中
                          } // while end
                        // 重演阶段：主要的作用是根据描述符块的指示，将日志中的数据块写回到磁盘的原始位置上
                        do_one_pass(journal, &info, PASS_REPLAY)
                          while (1) {
                          jread(&bh, journal, next_log_block) // 读取下一个　block
                          if (tmp->h_magic != cpu_to_be32(JBD2_MAGIC_NUMBER) // 判断 magic

                          case JBD2_DESCRIPTOR_BLOCK // 描述块
                          jbd2_descriptor_block_csum_verify // 检查 checksum
                          if (pass != PASS_REPLAY) { // 是日志重演阶段
                          jread(&obh, journal, io_block)
                          read_tag_block(journal, &tag) // 根据 tag 信息读取每一个数据块
                          memcpy(nbh->b_data, obh->b_data, journal->j_blocksize) // 将数据 copy 到磁盘对应的 bh 中

                          case JBD2_COMMIT_BLOCK // 提交块
                          if (pass == PASS_SCAN // 不是日志扫描阶段
                          next_commit_ID++

                          case JBD2_REVOKE_BLOCK // 取消块
                          if (pass != PASS_REVOKE) { // 不是日志取消阶段
                          continue
                          } // while end
kthread
  kjournald2
    jbd2_journal_commit_transaction
      jbd2_journal_update_sb_log_tail
        sb->s_start    = cpu_to_be32(tail_block)
        jbd2_write_superblock // 执行完后关机，启动后重新挂载，就会执行到do_one_pass
      jbd2_block_tag_csum_set
        tag3->t_checksum = cpu_to_be32(csum32)
      jbd2_descriptor_block_csum_set
        tag->t_checksum = cpu_to_be32(csum32)
      jbd2_update_log_tail // if (update_tail)
        __jbd2_update_log_tail
          jbd2_journal_update_sb_log_tail
            sb->s_start    = cpu_to_be32(tail_block)
            jbd2_write_superblock // 频繁写，会执行到这里
```

## lazy init

```c
// ext4文件系统默认开启lazy init功能。该功能开启时，会发起一个线程持续地初始化ext4文件系统的metadata，从而延迟metadata初始化。关闭lazy init功能后，格式化的时间会大幅度地延长。关闭 lazy init: mkfs.ext4 -E lazy_itable_init=0,lazy_journal_init=0 -b 4096 -F /dev/sda
kthread
  ext4_lazyinit_thread
    ext4_run_li_request
      ext4_init_inode_table
        __ext4_journal_start_sb
          jbd2__journal_start
```

## metadata 写入过程

```c
// echo "a" > /mnt/file, 部分流程
open
  do_sys_open
    do_sys_openat2
      do_filp_open
        path_openat
          do_open
            handle_truncate
              do_truncate
                notify_change
                  ext4_setattr
                    __ext4_journal_start
                      __ext4_journal_start_sb
                        jbd2__journal_start
                    ext4_orphan_add
                      __ext4_journal_get_write_access
                        jbd2_journal_get_write_access
                      ext4_reserve_inode_write
                        __ext4_journal_get_write_access
                          jbd2_journal_get_write_access
                      __ext4_handle_dirty_metadata
                        jbd2_journal_dirty_metadata
                      ext4_mark_iloc_dirty
                        ext4_do_update_inode
                          __ext4_handle_dirty_metadata
                            jbd2_journal_dirty_metadata
                    __ext4_mark_inode_dirty
                      ext4_reserve_inode_write
                        __ext4_journal_get_write_access
                          jbd2_journal_get_write_access
                      ext4_mark_iloc_dirty
                        ext4_do_update_inode
                          __ext4_handle_dirty_metadata
                            jbd2_journal_dirty_metadata
                    __ext4_journal_stop
                      jbd2_journal_stop
                    ext4_truncate

// cat /mnt/file
read
  ksys_read
    vfs_read
      new_sync_read
        call_read_iter
          ext4_file_read_iter
            generic_file_read_iter
              filemap_read
                file_accessed
                  touch_atime
                    inode_update_time
                      generic_update_time
                        __mark_inode_dirty
                          ext4_dirty_inode
                            __ext4_journal_start
                              __ext4_journal_start_sb
                                jbd2__journal_start
                            __ext4_mark_inode_dirty
                              ext4_reserve_inode_write
                                __ext4_journal_get_write_access
                                  jbd2_journal_get_write_access
                              ext4_mark_iloc_dirty
                                ext4_do_update_inode
                                  __ext4_handle_dirty_metadata
                                    jbd2_journal_dirty_metadata
                            __ext4_journal_stop
                              jbd2_journal_stop

// 创建大文件， dd if=/dev/zero of=/mnt/file bs=1M count=1024
process_one_work
  wb_workfn
    wb_do_writeback
      wb_check_old_data_flush
        wb_writeback
          __writeback_sb_inodes
            __writeback_single_inode
              do_writepages
                mpage_map_and_submit_extent
                  mpage_map_one_extent
                    ext4_map_blocks
                      ext4_ext_map_blocks
                        ext4_ext_insert_extent
                          ext4_ext_create_new_leaf
                            ext4_ext_grow_indepth
                              __ext4_journal_get_create_access
                                jbd2_journal_get_create_access

```

## 日志写入流程 -- 事务提交

```c
kthread
  kjournald2
    jbd2_journal_commit_transaction
      commit_transaction = journal->j_running_transaction
      commit_transaction->t_state = T_LOCKED
      while (commit_transaction->t_reserved_list) {// 处理 reserved list,未使用，可释放
      } // while end
      __jbd2_journal_clean_checkpoint_list // 处理checkpoint list
      jbd2_journal_switch_revoke_table // 释放事务中剩余 buffer 额度
      commit_transaction->t_state = T_FLUSH
      journal->j_committing_transaction = commit_transaction // 全局正在提交事务
      journal_submit_data_buffers // 写入文件数据到磁盘
      jbd2_journal_write_revoke_records // 提交取消块记录, 放入 log_bufs 队列
      commit_transaction->t_state = T_COMMIT
      while (commit_transaction->t_buffers) {
      descriptor = jbd2_journal_get_descriptor_buffer // 构造描述符
      wbuf[bufs++] = descriptor;
      jbd2_file_log_bh(&log_bufs, descriptor // 描述符放入 log_bufs 队列
      jbd2_journal_write_metadata_buffer // 复制元数据缓冲区
        __jbd2_journal_file_buffer(jh_in, transaction, BJ_Shadow); // 原bh(老的元数据)放入shadow队列
      jbd2_file_log_bh(&io_bufs, wbuf // 元数据缓冲区放入 io_bufs 队列
      submit_bh(REQ_OP_WRITE, REQ_SYNC, bh) // 提交描述符和元数据
      } // while end
      commit_transaction->t_state = T_COMMIT_DFLUSH
      while (!list_empty(&io_bufs)) {
      wait_on_buffer(bh)
      jbd2_journal_file_buffer(jh, commit_transaction, BJ_Forget // 放入 forget 队列
      } // while end
      while (!list_empty(&log_bufs)) {  // 等待取消块和描述符块写入完成
      commit_transaction->t_state = T_COMMIT_JFLUSH;
      journal_submit_commit_record // 写提交块
      journal_wait_on_commit_record // 等待提交块写入完成
      while (commit_transaction->t_forget) { // 处理　forget 队列
      __jbd2_journal_insert_checkpoint(jh, commit_transaction); // 视情况加入事务的 checkpoint list
      } while end
      if (journal->j_checkpoint_transactions == NULL) { } else { } // 并把事务加入journal的checkpoint队列
      commit_transaction->t_state = T_COMMIT_CALLBACK
      ; // 更新本事务的统计信息
      commit_transaction->t_state = T_FINISHED
      ; // 更新　journal 全局统计信息
```
