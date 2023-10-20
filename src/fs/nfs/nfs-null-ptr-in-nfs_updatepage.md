[toc]

社区类似问题的邮件: https://lore.kernel.org/linux-nfs/6cbd9cf8-49e9-868e-6452-1da2498c1358@oracle.com/

相关补丁集: https://lore.kernel.org/all/20190407175912.23528-1-trond.myklebust@hammerspace.com/

# 代码流程分析


```c
write
  ksys_write
    vfs_write
      __vfs_write
        new_sync_write
          nfs_file_write
            generic_perform_write
              nfs_write_end
                nfs_updatepage
                  nfs_writepage_setup
                    nfs_setup_write_request
                      nfs_try_to_update_request // return NULL
                        nfs_wb_page // return 0
                          nfs_writepage_locked // return 0
                            nfs_do_writepage // return 0
                              nfs_page_async_flush // return 0; 14bebe3c90b3 NFS: Don't interrupt file writeout due to fatal errors
                                nfs_error_is_fatal_on_server // 发生致命错误时
                                generic_error_remove_page
                                  truncate_inode_page
                                    delete_from_page_cache
                                      __delete_from_page_cache
                                        page_cache_tree_delete
                                          page->mapping = NULL
                      if (req != NULL) // 条件不满足
                      nfs_inode_add_request // 如果 nfs_page_async_flush 不返回0则不执行
                        spin_lock(&mapping->private_lock)

```

