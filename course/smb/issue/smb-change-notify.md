# 需求描述

请看[github上的issue](https://github.com/namjaejeon/ksmbd/issues/495#issuecomment-3473472265)。

与maintainer的其他沟通内容:
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

smb server在虚拟机中，要让外部的windows系统能访问到，需要[内网穿透](https://chenxiaosong.com/course/gnu-linux/ssh-reverse.html):
```sh
# 其中10.42.20.210是windows能访问到的地址，且这个系统上的445端口不能被占用（就是没有启动smb server）
ssh -R 10.42.20.210:445:localhost:445 root@10.42.20.210
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

# samba代码分析

```c
change_notify_reply
```

