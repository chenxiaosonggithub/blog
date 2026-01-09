[与社区交流的英文网页](https://chenxiaosong.com/en/smb2-change-notify.html)。

# 需求描述 {#requirements-description}

请看[github上的issue](https://github.com/namjaejeon/ksmbd/issues/495#issuecomment-3473472265)。

与maintainer Steve French的其他沟通内容:
```
I am also very interested in the work to improve the VFS to allow
filesystems, especially cifs.ko (client) to support change notify
(without having to use the ioctl or smb client specific tool, smbinfo
etc).  It will be very useful.
翻译:
我也对改进 VFS 的工作非常感兴趣，
这样文件系统（尤其是客户端的 cifs.ko）就能支持 change notify（更改通知） 功能，
而无需使用 ioctl 或特定于 SMB 客户端的工具（如 smbinfo 等）。
这将会非常有用。

There are MANY exciting features for both client
and server that would be broadly helpful, and of course as you spot
new ioctls or VFS syscall flags there is always the opportunity to
make small extensions to SMB3.1.1 Linux Extensions to make
Linux-->Linux exceptional over SMB3.1.1.
翻译:
对于客户端和服务器来说，都有许多令人兴奋的新功能，
这些功能将会带来广泛的帮助。
当然，当你发现新的 ioctl 或 VFS 系统调用标志时，
总是有机会对 SMB3.1.1 Linux 扩展 进行一些小的改进，
从而让 Linux --> Linux 通过 SMB3.1.1 的交互更加出色。

there are relatively simple things like improving the
compression support, adding support for SMB3.1.1 over QUIC, adding
support for some additional fsctls, adding support for faster GCM
signing, etc that are well documented
翻译:
有一些相对简单的改进方向，例如：
改进压缩支持、
为 SMB3.1.1 添加基于 QUIC 的支持、
增加对更多 FSCTL 的支持、
以及支持更快速的 GCM 签名 等等，
这些都有相当完善的文档说明。

And Metze could probably help with the minor changes needed to support
SMB3.1.1 over QUIC.
翻译: 而 Metze 可能可以协助完成支持 SMB3.1.1 over QUIC 所需的一些小改动。

Would be awesome to fix inotify in the vfs layer to work with network fs (since cifs.ko already supports change notify)
翻译: 如果能在 VFS 层修复 inotify，使其支持网络文件系统就太好了（因为 cifs.ko 已经支持 change notify）。

Have you seen this article from my presentation a few years ago at
LSF/MM summit? https://lwn.net/Articles/896055/
翻译: 你有没有看到我几年前在 LSF/MM 峰会上演讲时写的这篇文章？ https://lwn.net/Articles/896055/
```

# 复现步骤

详细的分析过程请查看英文网页[《SMB2 CHANGE_NOTIFY feature》](https://chenxiaosong.com/en/smb2-change-notify.html#win-env)。

环境搭建请查看[《smb环境》](https://chenxiaosong.com/course/smb/environment.html)。

smb server在虚拟机中，要让外部的windows系统能访问到，需要[内网穿透](https://chenxiaosong.com/course/gnu-linux/ssh-reverse.html):
```sh
# 其中10.42.20.210是windows能访问到的地址，且这个系统上的445端口不能被占用（就是没有启动smb server）
# 192.168.53.209是虚拟机的ip，注意换成localhost用默认走ipv6
ssh -R 10.42.20.210:445:192.168.53.209:445 root@10.42.20.210
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

用`NT_STATUS_V()`得到错误码的值，但好像打印出来是个很大的负数，可以用`get_nt_error_c_code()`转换成字符串。

详细的分析过程请查看英文网页[《SMB2 CHANGE_NOTIFY feature》](https://chenxiaosong.com/en/smb2-change-notify.html#samba-code)。

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

