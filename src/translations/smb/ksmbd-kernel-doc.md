本文档翻译自[Documentation/filesystems/smb/ksmbd.rst](https://github.com/torvalds/linux/blob/fdfd6dde4328635861db029f6fdb649e17350526/Documentation/filesystems/smb/ksmbd.rst)，翻译时文件的最新提交是`fdfd6dde4328635861db029f6fdb649e17350526 ksmbd: update feature status in documentation`，大部分借助于ChatGPT等工具翻译，仅作为我个人的参考，如果你想查阅，建议看英文文档，因为我不确定我记录的中文翻译是否完整和正确。

# KSMBD - SMB3 内核服务器

KSMBD 是一个 Linux 内核服务器，它在内核空间实现了 SMB3 协议，用于通过网络共享文件。

## KSMBD 架构

性能相关操作的子集位于内核空间，而与性能不直接相关的操作（如 DCE/RPC 管理，历史上导致了多起缓冲区溢出问题和严重的安全漏洞，以及用户账户管理）则实现在用户空间中，作为 ksmbd.mountd。与性能相关的文件操作（如打开/读取/写入/关闭等）在内核空间（ksmbd）中处理，这也有利于通过 VFS 接口轻松集成所有文件操作。

### ksmbd（内核守护进程）

当服务器守护进程启动时，它会在初始化时启动一个分叉线程（ksmbd/接口名），并打开端口 445 以监听 SMB 请求。每当新客户端发出请求时，分叉线程将接受客户端连接并为与客户端的专用通信通道分叉一个新的线程。这允许并行处理来自客户端的 SMB 请求（命令）以及允许新客户端建立新连接。每个实例被命名为 ksmbd/1~n（端口号）以指示已连接的客户端。根据 SMB 请求类型，每个新线程可以决定是否将命令传递给用户空间（ksmbd.mountd），目前识别到 DCE/RPC 命令应在用户空间中处理。为了进一步利用 Linux 内核，选择将命令作为工作项处理，并由 ksmbd-io kworker 线程的处理器执行。这允许复用处理器，因为内核会根据负载增加来初始化额外的工作线程，反之，如果负载减少则销毁多余的工作线程。因此，与客户端建立连接后，专用的 ksmbd/1..n（端口号）完全负责接收/解析 SMB 命令。接收到的每个命令都会并行处理，即，可以有多个客户端命令同时处理。接收到每个命令后，为每个命令准备一个独立的内核工作项，进一步排队等待由 ksmbd-io kworkers 处理。因此，每个 SMB 工作项都被排队到 kworkers 中，这样就允许由默认内核最优地管理负载共享，并通过并行处理客户端命令来优化客户端性能。

### ksmbd.mountd（用户空间守护进程）

ksmbd.mountd 是用户空间进程，用于传输使用 ksmbd.adduser（用户空间工具的一部分）注册的用户账户和密码。此外，它允许共享从 smb.conf 解析的信息参数到 KSMBD 内核。执行部分，它有一个持续运行的守护进程，通过 netlink 套接字连接到内核接口，等待请求（dcerpc 和共享/用户信息）。它处理 DCE/RPC 调用（至少几十个），这些调用对于文件服务器至关重要，例如 NetShareEnum 和 NetServerGetInfo。完整的 DCE/RPC 响应在用户空间中准备，并传递给关联的内核线程以供客户端使用。

## KSMBD Feature Status

请查看原网页。

## How to run

请查看原网页。

## Shutdown KSMBD

请查看原网页。

## How to turn debug print on

请查看原网页。
