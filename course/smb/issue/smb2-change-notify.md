[与社区交流的英文网页](https://chenxiaosong.com/en/smb2-change-notify.html)。

# 需求描述

请看[github上的issue](https://github.com/namjaejeon/ksmbd/issues/495#issuecomment-3473472265)。

与maintainer Steve French的其他沟通内容:
```
I am also very interested in the work to improve the VFS to allow
filesystems, especially cifs.ko (client) to support change notify
(without having to use the ioctl or smb client specific tool, smbinfo
etc).  It will be very useful.
翻译:
我也对改进 VFS 的工作非常感兴趣，
这样文件系统——尤其是 cifs.ko（客户端）——就能支持 change notify（更改通知） 功能，
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
```

# 复现步骤

环境搭建请查看[《smb环境》](https://chenxiaosong.com/course/smb/environment.html)。

smb server在虚拟机中，要让外部的windows系统能访问到，需要[内网穿透](https://chenxiaosong.com/course/gnu-linux/ssh-reverse.html):
```sh
# 其中10.42.20.210是windows能访问到的地址，且这个系统上的445端口不能被占用（就是没有启动smb server）
# 192.168.53.209是虚拟机的ip，注意换成localhost用默认走ipv6
ssh -R 10.42.20.210:445:192.168.53.209:445 root@10.42.20.210
```

windows挂载:
```sh
# windows不区分大小写，TEST和test都可以
\\10.42.20.210\test
```

用户态和内核态的smb server切换时，windows可能会挂载不上，这时需要在windows上打开PowerShell执行以下命令:
```sh
# 查看现有连接
net use
# 删除特定连接
net use \\10.42.20.210\IPC$ /delete
net use \\10.42.20.210\test /delete
# 删除所有连接，不建议用
net use * /delete
```

测试步骤如下:
```sh
# /tmp/s_test是smb server导出的目录
echo something > /tmp/s_test/file # 在server端执行
```

当server使用samba时，创建的新文件在windows上能立刻显示；当server使用ksmbd时，创建的新文件在windows上不会显示，需要按f5刷新。

# smb协议分析

[MS-SMB2](https://learn.microsoft.com/pdf?url=https%3A%2F%2Flearn.microsoft.com%2Fen-us%2Fopenspecs%2Fwindows_protocols%2Fms-smb2%2Ftoc.json)。

## MS-SMB2 2.2.35 SMB2 CHANGE_NOTIFY Request

SMB2 CHANGE_NOTIFY 请求数据包由客户端发送，用于请求获取目录的变更通知。
该请求由一个 SMB2 头（参见 2.2.1 节）以及紧随其后的该请求结构组成。

```c
struct smb2_change_notify_req {
  struct smb2_hdr hdr;
  __le16  StructureSize; // 客户端 必须 将该字段设置为 32，表示请求结构体的大小（不包含 SMB2 头）
  __le16  Flags; // 指示该操作必须如何处理的标志。此字段必须为 0，或以下取值之一： SMB2_WATCH_TREE
  __le32  OutputBufferLength; // 服务器在 SMB2 CHANGE_NOTIFY Response（见章节 2.2.36）中允许返回的最大字节数。
  struct {
    __u64   PersistentFileId; /* 不透明字节序 */
    __u64   VolatileFileId; /* 不透明字节序 */
  } fid; // 用于监控变化的目录的 SMB2_FILEID 标识符
  __le32  CompletionFilter; // 指定要监控的变更类型。可以选择多个触发条件。在这种情况下，只要满足任意一个条件，客户端就会收到变更通知，并且 CHANGE_NOTIFY 操作会完成。该字段 必须（MUST） 使用以下值来构造： FILE_NOTIFY_CHANGE_FILE_NAME ... FILE_NOTIFY_CHANGE_STREAM_WRITE
  __u32   Reserved; // 此字段 不得使用（MUST NOT），并且 必须保留（MUST be reserved）。客户端 必须（MUST） 将该字段设置为 0，服务器在接收时 必须（MUST） 忽略该字段。
} __packed;

// Flags
SMB2_WATCH_TREE // 该请求必须监控由 FileId 指定的目录下的任何文件或子目录的变更。

// CompletionFilter
FILE_NOTIFY_CHANGE_FILE_NAME    // 如果文件名发生变化，客户端会收到通知
FILE_NOTIFY_CHANGE_DIR_NAME     // 如果目录名发生变化，客户端会收到通知
FILE_NOTIFY_CHANGE_ATTRIBUTES   // 如果文件的属性发生变化，客户端会收到通知。可能的文件属性值在 [MS-FSCC] 第 2.6 节中进行了说明。
FILE_NOTIFY_CHANGE_SIZE         // 如果文件的大小发生变化，客户端会收到通知。
FILE_NOTIFY_CHANGE_LAST_WRITE   // 如果文件的最后写入时间发生变化，客户端会收到通知。
FILE_NOTIFY_CHANGE_LAST_ACCESS  // 如果文件的最后访问时间发生变化，客户端会收到通知。
FILE_NOTIFY_CHANGE_CREATION     // 如果文件的创建时间发生变化，客户端会收到通知。
FILE_NOTIFY_CHANGE_EA           // 如果文件的扩展属性（EA）发生变化，客户端会收到通知。
FILE_NOTIFY_CHANGE_SECURITY     // 如果文件的访问控制列表（ACL）设置发生变化，客户端会收到通知。
FILE_NOTIFY_CHANGE_STREAM_NAME  // 如果向文件中添加了命名数据流，客户端会收到通知。
FILE_NOTIFY_CHANGE_STREAM_SIZE  // 如果命名数据流的大小发生变化，客户端会收到通知。
FILE_NOTIFY_CHANGE_STREAM_WRITE // 如果命名数据流被修改，客户端会收到通知。
```

## MS-SMB2 2.2.14.1 SMB2_FILEID

SMB2 FILEID 用来表示对一个文件的打开（操作）。

```c
struct {
  __u64   PersistentFileId; // 当连接断开后重新连接时，该文件句柄依然保持持久存在，如 3.3.5.9.7 节所述。服务器 必须（MUST） 在 SMB2 CREATE Response（见 2.2.14 节）中返回该文件句柄。
  __u64   VolatileFileId; // 当连接断开后重新连接时，该文件句柄可能会发生变化，如 3.3.5.9.7 节所述。服务器 必须（MUST） 在 SMB2 CREATE Response（见 2.2.14 节）中返回该文件句柄。此值 不得（MUST NOT） 发生变化，除非执行了重新连接操作。此值在同一会话范围内必须唯一，用于区分所有易失性句柄。
} fid; // 用于监控变化的目录的 SMB2_FILEID 标识符
```

## MS-SMB2 2.2.36 SMB2 CHANGE_NOTIFY Response

SMB2 CHANGE_NOTIFY 响应数据包由服务器发送，用于传输客户端 SMB2 CHANGE_NOTIFY 请求（见 2.2.35 节）的结果。
该响应由一个 SMB2 头（参见 2.2.1 节）以及紧随其后的响应结构组成。

```c
struct smb2_change_notify_rsp {
        struct smb2_hdr hdr;
        __le16  StructureSize; // 服务器 必须 将该字段设置为 9，以表示请求结构体的大小（不包括头部）。无论实际发送的请求中 Buffer[] 的长度是多少，服务器 都必须 将该字段设置为该值。
        __le16  OutputBufferOffset; // 从 SMB2 头部起始位置到返回的更改信息的偏移量（以字节为单位）
        __le32  OutputBufferLength; // 返回的更改信息的长度（以字节为单位）
        __u8    Buffer[]; // 一个可变长度的缓冲区，包含响应中返回的更改信息，其内容由 OutputBufferOffset 和 OutputBufferLength 字段描述。该字段是一个 FILE_NOTIFY_INFORMATION 结构体数组，如 [MS-FSCC] 第 2.7.1 节所指定。
} __packed;
```

# tcpdump抓包分析



# samba代码分析

samba的调试方法请查看[《smb调试方法》](https://chenxiaosong.com/course/smb/debug.html#samba-print)

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
                                        smbd_smb2_connection_handler
                                          smbd_smb2_io_handler
                                            smbd_smb2_advance_incoming
                                              smbd_smb2_request_dispatch
                                                smbd_smb2_request_process_notify
                                                  smbd_smb2_notify_send
                                                    change_notify_reply
```

