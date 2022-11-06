[toc]

# 64c4a37ac04e cifs: potential buffer overflow in handling symlinks

```c
parse_mf_symlink
  sscanf(buf, "XSym\n%04u\n", &link_len) // link_len 可能会很大, 超过允许的最大长度 CIFS_MF_SYMLINK_LINK_MAXLEN ＝ 1024
```

# c6cc4c5a7250 cifs: handle -EINTR in cifs_setattr

```c
utimensat // 可以返回 -EINTR 错误，没明白 commit message 中为什么说不支持返回 -EINTR
  do_utimes
    utimes_common
      notify_change
        cifs_setattr
        // 尝试2次
        } while (is_retryable_error(rc) && retries < 2)
```

# a48137996063 cifs: fix leaked reference on requeued write

TODO: 是否可以把 kref_put 的 release 参数放到 cifs_writedata 结构体中？

```c
cifs_writev_requeue
  cifs_writedata_alloc
    pages = kcalloc(nr_pages, // 申请 page
    cifs_writedata_direct_alloc // 申请 cifs_writedata, 引用计数为1
  cifs_async_writev
    kref_get(&wdata->refcount)
  kref_put // 减小引用计数, 如果异步写正在执行，则不会释放

// 异步写完成，释放 cifs_writedata
cifs_writev_complete
  kref_put(&wdata->refcount,
```

# 30573a82fb17 CIFS: Gracefully handle QueryInfo errors during open

```c
cifs_nt_open
  cifs_open_file // server->ops->open
  cifs_get_inode_info_unix / cifs_get_inode_info // 出错时
  // 如果没有 close，会导致文件无法删除
  cifs_close_file // server->ops->close
```

# abe57073d08c CIFS: Fix retry mid list corruption on reconnects

从 pending_mid_q 链表中移到 dispose_list 链表前，先增加 mid_entry 的引用计数(注意同时还持有锁 GlobalMid_Lock)，避免在操作链表的过程中 struct mid_q_entry 被释放。
另外从 pending_mid_q 链表移除后，mid_entry->mid_flags 设上标记 MID_DELETED。
从 pending_mid_q 链表删除前，判断 MID_DELETED，然后调用 DeleteMidQEntry 释放。

补丁合入前 `DeleteMidQEntry` 释放 `mid_entry` 时没有 `GlobalMid_Lock` 保护，可能引起 UAF，补丁合入后的 `DeleteMidQEntry` 流程:
```c
DeleteMidQEntry
  cifs_mid_q_entry_release
    spin_lock(&GlobalMid_Lock)
    kref_put
      _cifs_mid_q_entry_release
        // 释放 mid_entry
    spin_unlock(&GlobalMid_Lock)
```
