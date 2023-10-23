[toc]

# 问题描述

4.19.90-23.8.v2101内核在`nfs_updatepage`函数中发生空指针解引用。

社区类似问题的邮件: [nfs_page_async_flush returning 0 for fatal errors on writeback](https://lore.kernel.org/linux-nfs/6cbd9cf8-49e9-868e-6452-1da2498c1358@oracle.com/)

相关补丁集: [Fix up soft mounts for NFSv4.x](https://lore.kernel.org/all/20190407175912.23528-1-trond.myklebust@hammerspace.com/)

# 代码流程分析

因为合入了[`14bebe3c90b3 NFS: Don't interrupt file writeout due to fatal errors`](https://lore.kernel.org/all/20190407175912.23528-20-trond.myklebust@hammerspace.com/)补丁，`nfs_page_async_flush`函数中在发生致命错误时`page->mapping`被设置为空，而`nfs_page_async_flush`函数这时不返回错误码，导致`nfs_setup_write_request`函数中执行到`nfs_inode_add_request`函数，发生了空指针解引用。
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
                      // 尝试搜索已经存在的request，如果已存在就更新，并返回非NULL
                      nfs_try_to_update_request // return NULL
                        nfs_wb_page // return 0
                          nfs_writepage_locked // return 0
                            nfs_do_writepage // return 0
                              // 合入补丁 14bebe3c90b3 NFS: Don't interrupt file writeout due to fatal errors 后返回 0
                              nfs_page_async_flush // return 0
                                nfs_error_is_fatal_on_server // 发生致命错误时
                                generic_error_remove_page
                                  truncate_inode_page
                                    delete_from_page_cache
                                      __delete_from_page_cache
                                        page_cache_tree_delete
                                          page->mapping = NULL
                      if (req != NULL) // 条件不满足
                      // 如果不存在就新创建一个request
                      nfs_create_request
                      // 将request与inode关联起来
                      nfs_inode_add_request // 如果 nfs_page_async_flush 不返回0则不执行
                        spin_lock(&mapping->private_lock) // mapping 为 NULL，发生空指针解引用

```

# 修复方案

回退补丁[`14bebe3c90b3 NFS: Don't interrupt file writeout due to fatal errors`](https://lore.kernel.org/all/20190407175912.23528-20-trond.myklebust@hammerspace.com/)。

回退补丁后，`nfs_page_async_flush`函数中在发生致命错误时返回错误码，`nfs_setup_write_request`函数中不会执行到`nfs_inode_add_request`函数，从而解决空指针解引用问题。

# 补丁分析

补丁[`14bebe3c90b3 NFS: Don't interrupt file writeout due to fatal errors`](https://lore.kernel.org/all/20190407175912.23528-20-trond.myklebust@hammerspace.com/)所属的补丁集中还有以下几个相关的补丁：

[`22876f540bdf NFS: Don't call generic_error_remove_page() while holding locks`](https://lore.kernel.org/all/20190407175912.23528-21-trond.myklebust@hammerspace.com/)

[`6fbda89b257f NFS: Replace custom error reporting mechanism with generic one`](https://lore.kernel.org/all/20190407175912.23528-23-trond.myklebust@hammerspace.com/)

## 最新的代码分析

补丁集合入后，在最新的代码中, 当`nfs_page_async_flush`中产生致命错误时，因为`nfs_page_assign_folio`中赋值了新的`folio`，`nfs_inode_add_request`中的`mapping`不会为空，从而不会发生空指针引用的问题。

```c
nfs_setup_write_request
  nfs_try_to_update_request
    nfs_wb_folio
      nfs_writepage_locked
        nfs_do_writepage
          nfs_page_async_flush
            nfs_write_error // 只记录错误，想留给fsync报给用户态
  nfs_page_create_from_folio
    nfs_page_create
    nfs_page_assign_folio
      req->wb_folio = folio // 这个地方保证了不会产生内存泄漏
    nfs_inode_add_request
      // 注意这个地方是从folio中取出address_space
      struct address_space *mapping = folio_file_mapping(folio)
      // 这个地方的mapping一定不会是NULL
      spin_lock(&mapping->private_lock)
```

## 补丁`14bebe3c90b3 NFS: Don't interrupt file writeout due to fatal errors`

补丁[`14bebe3c90b3 NFS: Don't interrupt file writeout due to fatal errors`](https://lore.kernel.org/all/20190407175912.23528-20-trond.myklebust@hammerspace.com/)里描述的：不立刻上报回写错误，而是让`fsync`上报。

要说明一下，maintainer自己都没想好这个机制有没问题，具体可以参考我去年发的[一组被maintainer剽窃的补丁](https://patchwork.kernel.org/project/linux-nfs/list/?series=628066&state=%2A&archive=both)，以及[maintainer剽窃后却没解决问题的补丁](https://patchwork.kernel.org/project/linux-nfs/list/?series=631225&state=%2A&archive=both)，这里就不做过多展开。
