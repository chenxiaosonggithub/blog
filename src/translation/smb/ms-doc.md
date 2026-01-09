这里整理一下我在开发smb过程中参考的一些协议，主要是和代码联系起来。想看完整的翻译[可以点击这里从百度网盘下载pdf](https://chenxiaosong.com/baidunetdisk)。

# MS-SMB2

- [MS-SMB2](https://learn.microsoft.com/pdf?url=https%3A%2F%2Flearn.microsoft.com%2Fen-us%2Fopenspecs%2Fwindows_protocols%2Fms-smb2%2Ftoc.json)

## 2.2.1 SMB2 Packet Header

SMB2 数据包头（也称 SMB2 Header） 是所有 SMB2 协议请求和响应的头部。
该头部有两种变体：

- ASYNC
- SYNC

如果 Flags 中设置了 SMB2_FLAGS_ASYNC_COMMAND 位，则使用 SMB2 Packet Header - ASYNC（见 2.2.1.1 节）。这种头部格式用于服务器异步处理请求时的响应，如 3.3.4.2、3.3.4.3、3.3.4.4 和 3.2.5.1.5 节所述。
对于已经收到临时响应（interim response）的请求，SMB2 CANCEL 请求 必须 使用这种格式，如 3.2.4.24 和 3.3.5.16 节所述。

如果 Flags 中未设置 SMB2_FLAGS_ASYNC_COMMAND 位，则使用 SMB2 Packet Header - SYNC（见 2.2.1.2 节）。

## 2.2.13 SMB2 CREATE Request

SMB2 CREATE 请求数据包由客户端发送，用于请求创建文件或访问文件。
如果目标是命名管道或打印机，服务器 必须 创建一个新文件。

该请求由一个 SMB2 数据包头组成（如 2.2.1 节所述），后面跟随该请求结构体。

```c
struct smb2_create_req {
  struct smb2_hdr hdr;
  __le16 StructureSize;   /* Must be 57 */
  __u8   SecurityFlags;
  __u8   RequestedOplockLevel;
  __le32 ImpersonationLevel;
  __le64 SmbCreateFlags;
  __le64 Reserved;
  __le32 DesiredAccess;
  __le32 FileAttributes;
  __le32 ShareAccess;
  __le32 CreateDisposition;
  __le32 CreateOptions;
  __le16 NameOffset;
  __le16 NameLength;
  __le32 CreateContextsOffset;
  __le32 CreateContextsLength;
  __u8   Buffer[];
} __packed;
```

## 2.2.35 SMB2 CHANGE_NOTIFY Request

SMB2 CHANGE_NOTIFY 请求数据包由客户端发送，用于请求获取目录的变更通知。
该请求由一个 SMB2 头（参见 2.2.1 节）以及紧随其后的该请求结构组成。

```c
struct smb2_change_notify_req {
  struct smb2_hdr hdr;
  // 客户端 必须 将该字段设置为 32，表示请求结构体的大小（不包含 SMB2 头）
  __le16  StructureSize;
  // 指示该操作必须如何处理的标志。此字段必须为 0，或以下取值之一： SMB2_WATCH_TREE
  __le16  Flags;
  // 服务器在 SMB2 CHANGE_NOTIFY Response（见章节 2.2.36）中允许返回的最大字节数。
  __le32  OutputBufferLength;
  struct {
    __u64   PersistentFileId; /* 不透明字节序 */
    __u64   VolatileFileId; /* 不透明字节序 */
  } fid; // 用于监控变化的目录的 SMB2_FILEID 标识符
  // 指定要监控的变更类型。可以选择多个触发条件。
  // 在这种情况下，只要满足任意一个条件，客户端就会收到变更通知，并且 CHANGE_NOTIFY 操作会完成。
  // 该字段 必须（MUST） 使用以下值来构造：
  // FILE_NOTIFY_CHANGE_FILE_NAME ... FILE_NOTIFY_CHANGE_STREAM_WRITE
  __le32  CompletionFilter;
  // 此字段 不得使用（MUST NOT），并且 必须保留（MUST be reserved）。
  // 客户端 必须（MUST） 将该字段设置为 0，服务器在接收时 必须（MUST） 忽略该字段。
  __u32   Reserved;
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

## 2.2.14.1 SMB2_FILEID

SMB2 FILEID 用来表示对一个文件的打开（操作）。

```c
struct {
  // 当连接断开后重新连接时，该文件句柄依然保持持久存在，如 3.3.5.9.7 节所述。
  // 服务器 必须（MUST） 在 SMB2 CREATE Response（见 2.2.14 节）中返回该文件句柄。
  __u64   PersistentFileId;
  // 当连接断开后重新连接时，该文件句柄可能会发生变化，如 3.3.5.9.7 节所述。
  // 服务器 必须（MUST） 在 SMB2 CREATE Response（见 2.2.14 节）中返回该文件句柄。
  // 此值 不得（MUST NOT） 发生变化，除非执行了重新连接操作。此值在同一会话范围内必须唯一，用于区分所有易失性句柄。
  __u64   VolatileFileId;
} fid; // 用于监控变化的目录的 SMB2_FILEID 标识符
```

## 2.2.36 SMB2 CHANGE_NOTIFY Response

SMB2 CHANGE_NOTIFY 响应数据包由服务器发送，用于传输客户端 SMB2 CHANGE_NOTIFY 请求（见 2.2.35 节）的结果。
该响应由一个 SMB2 头（参见 2.2.1 节）以及紧随其后的响应结构组成。

```c
struct smb2_change_notify_rsp {
  struct smb2_hdr hdr;
  // 服务器 必须 将该字段设置为 9，以表示请求结构体的大小（不包括头部）。
  // 无论实际发送的请求中 Buffer[] 的长度是多少，服务器 都必须 将该字段设置为该值。
  __le16  StructureSize;
  // 从 SMB2 头部起始位置到返回的更改信息的偏移量（以字节为单位）
  __le16  OutputBufferOffset;
  // 返回的更改信息的长度（以字节为单位）
  __le32  OutputBufferLength;
  // 一个可变长度的缓冲区，包含响应中返回的更改信息，其内容由 OutputBufferOffset 和 OutputBufferLength 字段描述。
  // 该字段是一个 FILE_NOTIFY_INFORMATION 结构体数组，如 [MS-FSCC] 第 2.7.1 节所指定。
  __u8    Buffer[];
} __packed;
```
## 3.2.4.24 Application Requests Canceling an Operation {#smb2-3.2.4.24}

应用程序提供要取消的操作的 CancelId。

客户端 必须（MUST） 枚举 ConnectionTable 中的所有连接，并在
Connection.OutstandingRequests 中查找其 Request.CancelId 与应用程序提供的
CancelId 相匹配的请求。如果找到匹配项，客户端需要执行以下操作：

客户端按照 第 2.2.30 节 中定义的语法初始化一个 SMB2 CANCEL 请求。SMB2 头部按如下方式初始化：

- Command 字段 必须（MUST） 设置为 SMB2 CANCEL。
- MessageId 字段 应该（SHOULD）<179> 设置为此前用于被取消请求的标识符。由于复用了相同的 MessageId，取消请求不得（MUST NOT）消耗序列号。
- 如果 Request.AsyncId 非空，表示该命令此前已经返回过一个中间响应（interim response），则：
客户端将 AsyncId 设置为 Request.AsyncId；
并在 Flags 字段中将 SMB2_FLAGS_ASYNC_COMMAND 置为 TRUE。

SessionId 字段 必须（MUST） 设置为此前用于被取消请求的会话标识符。

如果由 SessionId 标识的会话中 Session.SigningRequired 等于 TRUE，
客户端必须在 Flags 字段中将 SMB2_FLAGS_SIGNED 置为 TRUE。

SMB2 CANCEL 请求其余字段 必须 按照 第 2.2.30 节 中规定的默认值进行初始化。

该请求 必须（MUST） 发送到服务器。

不会向调用方返回任何状态信息。

## 3.3.5.16 Receiving an SMB2 CANCEL Request {#smb2-3.3.5.16}

当服务器接收到一个 SMB2 头部的 Command 字段等于 SMB2 CANCEL 的请求时，消息处理流程如下：

SMB2 CANCEL 请求不包含必须检查的序列号。因此，服务器 不得 按照第 3.3.5.2.3 节中规定的方式处理该接收到的数据包。

如果取消请求的 SMB2 头部中的 Flags 字段设置了 SMB2_FLAGS_SIGNED 位，服务器 必须 按照第 3.3.5.2.9 节的规定验证该会话。

如果取消请求的 SMB2 头部中的 Flags 字段设置了 SMB2_FLAGS_ASYNC_COMMAND 位，服务器 应该<400> 在 Connection.AsyncCommandList 中查找一个请求，使得
Request.AsyncId 与传入的取消请求中的 AsyncId 相匹配。

如果 SMB2_FLAGS_ASYNC_COMMAND 未设置，则服务器 必须 在 Connection.RequestList 中查找一个请求，使得
Request.MessageId 与传入的取消请求中的 MessageId 相匹配。

如果未找到对应的请求，服务器 必须 停止对此取消请求的处理，且不发送任何响应。

如果找到了对应的请求，服务器 应该<401> 尝试取消该请求（以下简称为 目标请求）。

如果目标请求被成功取消，服务器 必须 通过发送一个 ERROR 响应包（如第 2.2.2 节所规定），使目标请求失败，并且将 SMB2 头部（第 2.2.1 节）的 Status 字段设置为 STATUS_CANCELLED。

如果目标请求未能成功取消，则 必须继续处理目标请求，并且 不对取消请求发送任何响应。

取消请求表明客户端 必须获得目标请求的响应，无论该请求最终是否成功。服务器 必须 按照上述步骤 加速处理 取消请求。

# MS-FSCC

- [MS-FSCC](https://learn.microsoft.com/pdf?url=https%3A%2F%2Flearn.microsoft.com%2Fen-us%2Fopenspecs%2Fwindows_protocols%2Fms-fscc%2Ftoc.json)

## 2.7.1 FILE_NOTIFY_INFORMATION

FILE_NOTIFY_INFORMATION 结构体包含客户端被通知的更改信息。该结构体由以下内容组成。

```c
/* response contains array of the following structures */
struct file_notify_information {
  // 该字段表示从本结构体起始位置到下一个 FILE_NOTIFY_INFORMATION 结构体的偏移量（以字节为单位）。
  // 如果不存在后续结构体，则 NextEntryOffset 字段 必须 为 0。
  // NextEntryOffset 必须 始终是 4 的整数倍。FileName 数组 必须 填充至从结构体起始位置算起的下一个 4 字节对齐边界。
  __le32 NextEntryOffset;
  // 文件上发生的更改。该字段 必须 包含以下值之一。FILE_ACTION_ADDED ... FILE_ACTION_TUNNELLED_ID_COLLISION
  // 如果两个或更多文件被重命名，则每个文件重命名对应的 FILE_NOTIFY_INFORMATION 条目 必须在此响应中连续出现，
  // 以便客户端能够正确对应旧名称和新名称。
  __le32 Action;
  // FileName 字段中文件名的长度（以字节为单位）。
  __le32 FileNameLength;
  // 一个包含已更改文件名称的 Unicode 字符串。
  __u8  FileName[];
} __packed;

// 文件被添加，FileName 包含新文件名。仅当重命名操作改变了文件所在目录时才会发送此通知。
// 客户端还将收到一个 FILE_ACTION_REMOVED 通知。如果文件在同一目录内被重命名，则不会收到此通知。
FILE_ACTION_ADDED
// 文件被删除，FileName 包含旧文件名。仅当重命名操作改变了文件所在目录时才会发送此通知。
// 客户端还将收到一个 FILE_ACTION_ADDED 通知。如果文件在同一目录内被重命名，则不会收到此通知。
FILE_ACTION_REMOVED
// 文件被修改。可以是文件数据或属性的更改。
FILE_ACTION_MODIFIED
// 文件被重命名，FileName 包含旧文件名。仅当重命名操作未改变文件所在目录时才会发送此通知。
// 客户端还将收到一个 FILE_ACTION_RENAMED_NEW_NAME 通知。如果文件被重命名到不同目录，则不会收到此通知。
FILE_ACTION_RENAMED_OLD_NAME
// 文件被重命名，FileName 包含新文件名。仅当重命名操作未改变文件所在目录时才会发送此通知。
// 客户端还将收到一个 FILE_ACTION_RENAMED_OLD_NAME 通知。如果文件被重命名到不同目录，则不会收到此通知。
FILE_ACTION_RENAMED_NEW_NAME
// 文件被添加到命名流中。
FILE_ACTION_ADDED_STREAM
// 文件从命名流中被移除。
FILE_ACTION_REMOVED_STREAM
// 文件被修改。可以是文件数据或属性的更改。
FILE_ACTION_MODIFIED_STREAM
// 由于所引用的文件被删除，对象 ID 被移除。
// 仅当被监控的目录是特殊目录 \$Extend\$ObjId:$O:$INDEX_ALLOCATION 时才会发送此通知。
FILE_ACTION_REMOVED_BY_DELETE
// 尝试将对象 ID 信息“隧道”到正在创建或重命名的文件失败，因为该对象 ID 已被同一卷上的其他文件使用。
// 仅当被监控的目录是特殊目录 \$Extend\$ObjId:$O:$INDEX_ALLOCATION 时才会发送此通知。
FILE_ACTION_ID_NOT_TUNNELLED
// 尝试将对象 ID 信息“隧道”到正在重命名的文件失败，因为该文件已存在对象 ID。
// 仅当被监控的目录是特殊目录 \$Extend\$ObjId:$O:$INDEX_ALLOCATION 时才会发送此通知。
FILE_ACTION_TUNNELLED_ID_COLLISION
```

