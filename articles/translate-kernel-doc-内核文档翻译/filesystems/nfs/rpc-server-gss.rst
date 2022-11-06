=========================================
rpcsec_gss support for kernel RPC servers
=========================================

本文是基于Documentation/filesystems/nfs/rpc-server-gss.rst以下提交记录:

.. code-block:: shell

        commit ade3dbad1459e0a9a8ee8812925e0d968a2a5252
        Author: J. Bruce Fields <bfields@redhat.com>
        Date:   Thu Aug 27 12:06:06 2020 -0400

        Documentation: update RPCSEC_GSSv3 RFC link

本文档参考了用于在内核 RPC 服务器（例如 NFS 服务器和 NFS 客户端的 NFSv4.0 回调服务器）中实现 RPCGSS 身份验证的标准和协议。 （但请注意，NFSv4.1 及更高版本不要求客户端充当服务器以进行身份验证。）

RPCGSS 在一些 IETF 文件中被指定：

 - RFC2203 v1: https://tools.ietf.org/rfc/rfc2203.txt
 - RFC5403 v2: https://tools.ietf.org/rfc/rfc5403.txt

我们目前还没有实现第三个版本：

 - RFC7861 v3: https://tools.ietf.org/rfc/rfc7861.txt

Background(背景)
==========

RPCGSS 身份验证方法描述了一种为 NFS 执行 GSSAPI 身份验证的方法。 尽管 GSSAPI 本身完全与机制无关，但在许多情况下，NFS 实现仅支持 KRB5 机制。

目前，Linux 内核仅支持 KRB5 机制，并依赖于特定于 KRB5 的 GSSAPI 扩展。

GSSAPI 是一个复杂的库，完全在内核中实现它是没有根据的。 然而，GSSAPI 操作基本上可以分为两部分：

- 初始上下文建立
- 完整性/隐私保护（单个数据包的签名和加密）

前者更复杂且与策略无关，但对性能不太敏感。 后者更简单，需要非常快。

因此，我们在内核中执行每个数据包的完整性和隐私保护，但将初始上下文建立留给用户空间。 我们需要调用来请求用户空间来执行上下文建立。

NFS Server Legacy Upcall Mechanism(NFS 服务器传统上行调用机制)
==================================

经典的上行调用机制使用基于自定义文本的上行调用机制与 nfs-utils 包提供的名为 rpc.svcgssd 的自定义守护进程对话。

这种向上调用机制有两个限制：

A) 它可以处理不超过 2KiB 的令牌
   在一些 Kerberos 部署中，由于攻击 Kerberos 票证的各种授权扩展，GSSAPI 令牌可能非常大，大小超过 64KiB，需要通过 GSS 层发送以执行上下文建立。

B) 由于可以发送回内核的缓冲区大小的限制，它无法正确处理用户属于数千个组（内核中当前的硬限制为 65K 组）的凭据（4KB）。

NFS Server New RPC Upcall Mechanism(NFS 服务器新的 RPC 上行调用机制)
===================================

较新的上行调用机制使用 RPC 通过 unix 套接字连接到名为 gss-proxy 的守护进程，该守护进程由名为 Gssproxy 的用户空间程序实现。

gss_proxy RPC 协议目前记录在 `此处 <https://fedorahosted.org/gss-proxy/wiki/ProtocolDocumentation>`_ 。

这种上行调用机制使用内核 rpc 客户端并通过常规 unix 套接字连接到 gssproxy 用户空间程序。 gssproxy 协议不受传统协议大小限制的影响。

Negotiating Upcall Mechanisms(协商上调机制)
=============================

为了提供向后兼容性，内核默认使用旧机制。 要切换到新机制，gss-proxy 必须绑定到 /var/run/gssproxy.sock，然后将“1”写入 /proc/net/rpc/use-gss-proxy。 如果 gss-proxy 失效，它必须重复这两个步骤。

一旦选择了上行调用机制，就无法更改。 为了防止锁定到遗留机制，必须在启动 nfsd 之前执行上述步骤。 任何启动 nfsd 的人都可以通过从 /proc/net/rpc/use-gss-proxy 读取并检查它是否包含“1”来保证这一点 -- 读取将阻塞，直到 gss-proxy 完成对文件的写入。
