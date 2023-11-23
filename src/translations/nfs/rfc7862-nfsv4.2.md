[点击这里跳转到陈孝松个人主页:chenxiaosong.com](http://chenxiaosong.com/)。

虽说接触NFS也有两年多了，但对RFC协议也只是偶尔查阅，没有系统的看过。最近公司鼓励我多做一些社区特性开发，就想着借助ChatGPT边翻译边学习，顺便记录下来，方便后继查阅。

持续更新中。。。

本文章翻译自文档[Network File System (NFS) Version 4 Minor Version 2 Protocol](https://www.rfc-editor.org/rfc/rfc7862.html)。

# 摘要

本文描述了NFS版本4次版本2；它说明了从NFS版本4次版本1引入的协议扩展。在NFS版本4的次版本2中引入的主要扩展包括以下内容：服务器端复制、应用程序输入/输出（I/O）建议、空间保留、稀疏文件、应用程序数据块和标记的NFS。

# 文档状态

本文档是一份Internet标准跟踪文件。

本文件是由互联网工程任务组（IETF）的产品。它代表了IETF社区的共识。它已经接受了公众审查，并已获得了互联网工程指导组（IESG）的出版批准。有关Internet标准的更多信息，请参阅RFC 7841的第2节。

有关本文档当前状态、任何勘误以及如何提供反馈的信息，请访问http://www.rfc-editor.org/info/rfc7862。

版权声明

版权所有（c）2016 IETF信托和被识别为文档作者的人员。保留所有权利。

本文件受到BCP 78和IETF Trust有关IETF文档的法律规定（http://trustee.ietf.org/license-info）的约束，这些规定于本文件发布日期生效。请仔细阅读这些文件，因为它们描述了您对本文件的权利和限制。从本文件中提取的代码组件必须包括第4.e节中所述的简化BSD许可证文本，并且按照简化BSD许可证中描述的那样提供，不带有任何保证。

# 1. 介绍

NFS版本4的次版本2（NFSv4.2）协议是NFS版本4（NFSv4）协议的第三个次版本。第一个次版本是NFSv4.0，详见[RFC7530]，第二个次版本是NFSv4.1，详见[RFC5661]。

作为一个次版本，NFSv4.2与NFSv4的整体目标保持一致，但NFSv4.2通过基于对NFSv4.1的经验，扩展了协议以更好地实现这些目标。此外，NFSv4.2还采纳了一些额外的目标，这些目标激发了NFSv4.2中的一些主要扩展。

## 1.1. 要求语言

本文档中的关键词"MUST"，"MUST NOT"，"REQUIRED"，"SHALL"，"SHALL NOT"，"SHOULD"，"SHOULD NOT"，"RECOMMENDED"，"MAY"和"OPTIONAL"的解释应按照RFC 2119 [RFC2119]中的描述进行。

## 1.2. 本文档范围

本文档将NFSv4.2协议描述为对NFSv4.1规范的一组扩展。该规范仍然保持最新，并为此处定义的新增内容提供基础。NFSv4.0的规范也仍然保持最新。

在将NFSv4.2特性添加到实现之前，有必要实现NFSv4.1的所有REQUIRED特性。关于NFSv4.0和NFSv4.1，本文档不会：

o 描述NFSv4.0或NFSv4.1协议，除非需要与NFSv4.2进行对比

o 修改NFSv4.0或NFSv4.1协议的规范

o 澄清NFSv4.0或NFSv4.1协议 - 也就是说，这里做出的任何澄清仅适用于NFSv4.2，而不适用于NFSv4.0或NFSv4.1

NFSv4.2是NFSv4.1的超集，所有新特性都是可选的。因此，NFSv4.2保持了与NFSv4.0相同的兼容性。任何新功能与NFSv4.1语义的交互在相关文本中都有描述。

NFSv4.2的完整外部数据表示（XDR）[RFC4506]在[RFC7863]中提供。

## 1.3. NFSv4.2目标

NFSv4.2提供的增强功能的一个主要目标是将先前版本的NFS中无法使用的常见本地文件系统功能提供到远程。这些功能可能

o 在服务器上已经可用，例如，稀疏文件

o 作为新标准正在开发，例如，SEEK引入了SEEK_HOLE和SEEK_DATA

o 通过某些专有手段由客户端与服务器一起使用，例如，标记的NFS

NFSv4.2提供了客户端在以前在NFS协议的范围内无法实现这些功能的情况下在服务器上利用这些功能的手段。

todo: 1.4.  Overview of NFSv4.2 Features