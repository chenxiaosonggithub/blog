最近调研了ksmbd，打算贡献社区补丁，发现所有的文件系统的函数中排名第二长度（901行, 2803~3705）的是`smb2_open()`（排名第一的是ntfs3的1470行的`log_replay()`，但不熟悉就暂时不瞎参与了），就想着先把这个函数给尝试重构了，也先通过这个函数入手深入了解ksmbd。

# 重构参考

重构技巧可以参考Jason Yan <yanaijie@huawei.com>的ext4重构补丁，`ext4_fill_super()`函数重构前有1093行。

- [[v3,00/16] some refactor of __ext4_fill_super()](https://patchwork.ozlabs.org/project/linux-ext4/cover/20220916141527.1012715-1-yanaijie@huawei.com/)
- [[0/8] some refactor of __ext4_fill_super(), part 2.](https://patchwork.ozlabs.org/project/linux-ext4/cover/20230323140517.1070239-1-yanaijie@huawei.com/)

# 客户端流程

先看一下客户端是怎么请求的，才能更好的知道服务端要处理哪些。

```c
// vfs的流程
openat
  do_sys_open
    do_sys_openat2
      do_filp_open
        path_openat
          open_last_lookups
            lookup_open
              atomic_open

// 请求流程
atomic_open
  cifs_atomic_open
    cifs_do_create
      smb2_open_file
        SMB2_open
          cifs_send_recv
            compound_send_recv
              smb2_setup_request // ses->server->ops->setup_request
                smb2_get_mid_entry
                  smb2_mid_entry_alloc
                  // 加到队列中
                  list_add_tail(&(*mid)->qhead, &server->pending_mid_q);
                // 状态设置成已提交
                midQ[i]->mid_state = MID_REQUEST_SUBMITTED
                smb_send_rqst
                  __smb_send_rqst
                    smb_send_kvec
                wait_for_response
                  // 状态要为已接收，在dequeue_mid()中设置
                  midQ->mid_state != MID_RESPONSE_RECEIVED
                // 回复的内容
                buf = (char *)midQ[i]->resp_buf

// 回复处理过程
kthread
  cifs_demultiplex_thread
    smb2_find_mid // server->ops->find_mid
      __smb2_find_mid
        // 从pending_mid_q链表中找
        list_for_each_entry
    standard_receive3
      cifs_handle_standard
        handle_mid
          dequeue_mid
            // 状态设置成已接收
            mid->mid_state = MID_RESPONSE_RECEIVED
            // 在锁的保护下从链表中删除（可能是pending_mid_q链表也可能是retry_list链表）
            list_del_init(&mid->qhead)
```

# ksmbd流程

```c
kthread
  worker_thread
    process_scheduled_works
      process_one_work
        handle_ksmbd_work
          __handle_ksmbd_work
            __process_request
              smb2_open
smb2_open
  WORK_BUFFERS
    // 获取smb2_create_req和smb2_create_rsp
    __wbuf
  smb2_get_name // 获取要打开的文件名
  parse_stream_name // stream name是什么鬼，后面再看TODO
  ksmbd_share_veto_filename // 检查是否禁止访问的文件，veto翻译为禁止或否决
  server_conf.flags & KSMBD_GLOBAL_FLAG_DURABLE_HANDLE // 处理durable
  dentry_open
    vfs_open
      do_dentry_open
        ext2_file_open // 执行到具体的后端文件系统
```