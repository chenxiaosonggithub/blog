[与社区交流的英文网页](https://chenxiaosong.com/en/smb2-change-notify.html)。

# 需求描述 {#requirements-description}

请看[github上的issue](https://github.com/namjaejeon/ksmbd/issues/495#issuecomment-3473472265)。

[与maintainer Steve French的其他沟通内容](https://chenxiaosong.com/course/smb/todo.html#change-notify)

# 复现步骤

详细的分析过程请查看英文网页[《SMB2 CHANGE_NOTIFY feature》](https://chenxiaosong.com/en/smb2-change-notify.html#win-env)。

环境搭建请查看[《smb环境》](https://chenxiaosong.com/course/smb/environment.html)。

smb server在虚拟机中，要让外部的windows系统能访问到，需要[内网穿透](https://chenxiaosong.com/course/gnu-linux/ssh-reverse.html):
```sh
# 172.21.20.210是windows能访问到的地址，且这个系统上的445端口不能被占用（就是没有启动smb server），执行以下命令
sudo sed -i "s/#GatewayPorts no/GatewayPorts yes/" /etc/ssh/sshd_config
sudo systemctl restart sshd
# 192.168.53.210是虚拟机的ip，注意换成localhost用默认走ipv6，执行以下命令
ssh -R 172.21.20.210:445:192.168.53.210:445 root@172.21.20.210 # 注意这里登录root用户，因为445端口需要root权限
```

使用内网穿透，Windows好像要先连接samba所在的服务器，然后再切为ksmbd所在的服务器，这时才能挂载上ksmbd，但不确定，需要针对性再调试一下。

可能还需要删除凭据，打开"控制面板"（Win+R然后输入control），"用户账户" -> "凭据管理器" -> "管理Windows凭据"，点击条目展开，然后点击 "删除" 。

测试步骤如下:
```sh
# /tmp/s_test是smb server导出的目录
echo something > /tmp/s_test/file # 在server端执行
```

当server使用samba时，创建的新文件在windows上能立刻显示；当server使用ksmbd时，创建的新文件在windows上不会显示，需要按f5刷新。

# smb协议分析

请查看[《SMB MS文档翻译》](https://chenxiaosong.com/src/translation/smb/ms-doc.html)。

- MS-SMB2 2.2.1 SMB2 Packet Header
- MS-SMB2 2.2.1.1 SMB2 Packet Header - ASYNC
- MS-SMB2 2.2.1.2 SMB2 Packet Header - SYNC
- MS-SMB2 3.3.4.2 Sending an Interim Response for an Asynchronous Operation
- MS-SMB2 3.3.4.3 Sending a Success Response
- MS-SMB2 3.3.4.4 Sending an Error Response
- MS-SMB2 3.2.5.1.5 Handling Asynchronous Responses
- MS-SMB2 3.2.4.24 Application Requests Canceling an Operation
- MS-SMB2 3.3.5.16 Receiving an SMB2 CANCEL Request

# tcpdump抓包分析

在虚拟机中使用以下命令抓包:
```sh
tcpdump --interface=any -w smb-server.pcap
```

在wireshark中打开，用`smb2.cmd == 15`过滤。

详细的分析过程请查看英文网页[《SMB2 CHANGE_NOTIFY feature》](https://chenxiaosong.com/en/smb2-change-notify.html#tcpdump)。

# samba代码分析

samba的调试方法请查看[《smb调试方法》](https://chenxiaosong.com/course/smb/debug.html#samba-print)。

详细的分析过程请查看英文网页[《SMB2 CHANGE_NOTIFY feature》](https://chenxiaosong.com/en/smb2-change-notify.html#samba-code)。

入口:
```c
main
  smbd_parent_loop
    _tevent_loop_wait
      std_event_loop_wait
        tevent_common_loop_wait
          _tevent_loop_once
            std_event_loop_once
              epoll_event_loop_once
                epoll_event_loop
                  tevent_common_invoke_fd_handler
                    smbd_accept_connection
                      smbd_process
                        _tevent_loop_wait
                          std_event_loop_wait
                            tevent_common_loop_wait
                              _tevent_loop_once
                                std_event_loop_once
                                  epoll_event_loop_once
                                    epoll_event_loop
                                      tevent_common_invoke_fd_handler
                                        messaging_dgm_read_handler

tevent_common_invoke_fd_handler
  messaging_dgm_read_handler
    messaging_dgm_recv
      msg_dgm_ref_recv
        messaging_recv_cb
          messaging_dispatch_rec
            messaging_dispatch_classic


tevent_common_invoke_fd_handler
  smbd_smb2_connection_handler
    smbd_smb2_io_handler
      smbd_smb2_advance_incoming
        smbd_smb2_request_dispatch

```

```c
NT_TRANSACT_NOTIFY_CHANGE // SMB1

messaging_dispatch_classic
  notifyd_rec_change
    notifyd_apply_rec_change
      inotify_watch
        inotify_map
          inotify_mapping
        mask |= (IN_MASK_ADD | IN_ONLYDIR); // todo
        talloc_set_destructor(w, watch_destructor);

tevent_common_invoke_fd_handler
  inotify_handler
    inotify_dispatch
      // 过滤无关事件
      if ((e->mask & (IN_ATTRIB|IN_MODIFY|IN_CREATE|IN_DELETE|IN_MOVED_FROM|IN_MOVED_TO)) == 0)
      // rename from
      if (e->mask & IN_MOVED_FROM)
      save_moved_from // 只缓存，不触发回调
        tevent_add_timer // 100ms
      // rename to
      if (e->mask & IN_MOVED_TO)
      handle_local_rename(w, e);  // 生成 OLD_NAME + NEW_NAME
      // 只有to
      else if (e->mask & IN_MOVED_TO) {
      ne.action = NOTIFY_ACTION_ADDED;
      inotify_map_mask_to_filter
      if (filter_match(w, e))
      notifyd_sys_callback // w->callback

smbd_smb2_request_process_close
  smbd_smb2_close_send
    smbd_smb2_close
      close_file_smb
        fsp_unbind_smb
          notify_remove
            messaging_send_iov // 通知notifyd注销

// 从 notify_remove 通知过来
messaging_dispatch_classic
  notifyd_rec_change
    notifyd_apply_rec_change
      TALLOC_FREE
        talloc_free
          _talloc_free
            _talloc_free_internal
              _tc_free_internal
                watch_destructor

change_notify_reply
  notify_marshall_changes
    data_blob_append
      data_blob_realloc
        blob->length = length
  smbd_smb2_notify_reply(..., blob.length) // reply_fn
    if (len == 0)
    state->status = NT_STATUS_NOTIFY_ENUM_DIR

notifyd_rec_change
  if (log->num_recs >= 100) // 大于100条就立刻广播

notifyd_broadcast_reclog_send
  // 1秒定时器
  tevent_wakeup_send(..., timeval_current_ofs_msec(1000))

smbd_smb2_request_pending_timer
  async_id = message_id; /* keep it simple for now... */

smbd_smb2_request_pending_queue
  if (req->current_idx > 1) // compound 前面已经有完成的响应
  smb2_send_async_interim_response // 发出前缀
    nreq->out.vector_count -= SMBD_SMB2_NUM_IOV_PER_REQ; // 丢掉最后一个 async 请求的响应槽
    SIVAL(outhdr, SMB2_HDR_NEXT_COMMAND, 0); // 把前一个 response 的 NextCommand 改成 0
  req->current_idx = 1; memmove // 把原请求的 in/out vectors 前缀移除
  smbd_smb2_request_pending_timer
```

# samba code analysis {#samba-code}

Some code (e.g., the definition of `NT_STATUS_PENDING`) is generated during compilation. To see the full code, the project must be compiled first.

You can use macros like `DBG_ERR()`, ..., `DBG_DEBUG()`, etc., to print debug information.

Use `log_stack_trace()` to print the function stack. If you get a compilation error indicating that `log_stack_trace()` cannot be found,
you can refer to the changes in the patch [`0001-dump-stack-of-smbd_parent_loop.patch`](https://github.com/chenxiaosonggithub/blog/blob/master/course/smb/src/0001-dump-stack-of-smbd_parent_loop.patch).

The logs can be found in `/usr/local/samba/var/log.smbd`.

When samba receive `Create Request`:
```c
smbd_smb2_request_dispatch
  smbd_smb2_request_process_create
    smbd_smb2_create_send
      smbd_smb2_create_finish
        // save the fsp, and return immediately when file_fsp_smb2() is called later
        smb2req->compat_chain_fsp = smb1req->chain_fsp
```

When samba receive `Notify Request`:
```c
smbd_smb2_request_dispatch
  smbd_smb2_request_process_notify
    // both persistent_id and volatile_id are -1 when `Create Request` and `Notify Request` are in the same compound request
    file_fsp_smb2
      return smb2req->compat_chain_fsp
    smbd_smb2_notify_send
      change_notify_create
      if (change_notify_fsp_has_changes(fsp) // have change information
      change_notify_reply // notify immediately
        // reply NT_STATUS_OK
      change_notify_add_request // No changes for now, wait in the queue
    smbd_smb2_request_pending_queue // nothing to notify, start the timer
```

Start the timer:
```c
smbd_smb2_request_pending_timer
  // reply NT_STATUS_PENDING
  // SMB2_HDR_OPCODE defines the offset of the Command field in struct smb2_hdr
```

When Windows exits the directory, samba receive `Cancel Request`:
```c
smbd_smb2_request_dispatch
  smbd_smb2_request_process_cancel
    _tevent_req_cancel
      smbd_smb2_notify_cancel
        smbd_notify_cancel_by_smbreq
          smbd_notify_cancel_by_map
            change_notify_reply
              // reply NT_STATUS_CANCELLED
```

Samba send `Notify Response` when change information is available:
```c
messaging_dispatch_classic
  notify_handler
    notify_callback
      files_forall
        notify_fsp_cb
          notify_fsp
            change_notify_reply
              // reply NT_STATUS_OK
```

# fanotify {#fanotify}

[Click here to view userspace fanotify usage examples `fs-monitor.c`](https://github.com/chenxiaosonggithub/blog/blob/master/course/smb/src/fs-monitor.c):
```sh
gcc -o fs-monitor fs-monitor.c
./fs-monitor /path/to/file
```

When reading a file:
```c
read
  ksys_read
    vfs_read
      fanotify_read
        add_wait_queue // wait here
        copy_event_to_user

vfs_read / __kernel_read
  fsnotify_access
    fsnotify_file
      fsnotify_path
        fsnotify_parent
          __fsnotify_parent
            fsnotify
              send_to_group
                fanotify_handle_event
                  fsnotify_insert_event
                    // wake up the wait queue in fanotify_read()
                    wake_up(&group->notification_waitq)
```

# smb server内核代码分析

异步等待和唤醒:
```c
smb2_lock
  setup_async_work(..., smb2_remove_blocked_lock, ...)
    work->cancel_fn = fn
  smb2_send_interim_resp(work, STATUS_PENDING);
  ksmbd_vfs_posix_lock_wait

smb2_cancel
  iter->state = KSMBD_WORK_CANCELLED
  smb2_remove_blocked_lock // iter->cancel_fn
    locks_delete_block
      __locks_delete_block
        __locks_wake_up_blocks
          locks_wake_up_waiter
            wake_up(&flc->flc_wait)

ksmbd_conn_handler_loop // default_conn_ops.process_fn
  ksmbd_server_process_request
    queue_ksmbd_work
      ksmbd_alloc_work_struct
        ksmbd_queue_work
          handle_ksmbd_work // queue_work(ksmbd_wq,
            __handle_ksmbd_work
              __process_request
              ksmbd_conn_try_dequeue_request
                list_del_init(&work->request_entry) // 从async_requests链表中删除
                release_async_work
```

文件名处理:
```c
smb2_query_info
  smb2_get_info_filesystem
    struct smb2_query_info_rsp // MS-SMB2 2.2.38
    info = (FILE_SYSTEM_ATTRIBUTE_INFO *)rsp->Buffer;
  smb2_get_info_file
    smb2_get_ea
      ptr = (char *)rsp->Buffer
      eainfo = (struct smb2_ea_info *)ptr;

__handle_ksmbd_work
  smb2_allocate_rsp_buf // conn->ops->allocate_rsp_buf
    .max_trans_size = SMB3_DEFAULT_TRANS_SIZE,
```

# smb client内核代码分析

```c
ioctl
  cifs_ioctl
    smb3_notify
      SMB2_open(xid, &oparms, ...)
        SMB2_open_init
          smb2_plain_req_init(SMB2_CREATE,
      SMB2_change_notify
        SMB2_notify_init
          smb2_plain_req_init(SMB2_CHANGE_NOTIFY,
        cifs_send_recv
          compound_send_recv
            smb2_setup_request // .setup_request
              smb2_seq_num_into_buf
                smb2_seq_num_into_buf(server, shdr);
      SMB2_cancel
        cifs_send_recv
          compound_send_recv
            smb_send_rqst
              __smb_send_rqst
                rc = -ERESTARTSYS
                if (fatal_signal_pending(current)) { // 进程将要退出
                goto out
                return -ERESTARTSYS
      SMB2_close
        __SMB2_close
          rc = cifs_send_recv // -ERESTARTSYS
          smb2_handle_cancelled_close
            __smb2_handle_cancelled_cmd
              smb2_cancelled_close_fid // INIT_WORK(&cancelled->work,
                SMB2_close(0, tcon, // 在工作队列中再次尝试

kthread
  cifs_demultiplex_thread
    cifs_handle_standard
      smb2_is_status_pending

revert_current_mid
revert_current_mid_from_hdr
```

# fanotify

详细的分析过程请查看英文网页[《SMB2 CHANGE_NOTIFY feature》](https://chenxiaosong.com/en/smb2-change-notify.html#fanotify)。

