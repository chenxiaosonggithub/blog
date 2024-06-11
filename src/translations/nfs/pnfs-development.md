本文档翻译自[linux-nfs.org中PNFS Development相关的内容](https://linux-nfs.org/wiki/index.php/PNFS_Development)，大部分借助于ChatGPT。仅作为我个人的参考，如果你想查阅，建议看英文文档，因为我不确定我记录的中文翻译是否完整和正确。

# PNFS Development

[原网页](https://linux-nfs.org/wiki/index.php/PNFS_Development)。

Linux pNFS具有可插拔的客户端和服务器架构，通过为文件、对象和块布局启用动态支持，充分发挥了pNFS作为通用和可扩展的元数据协议的潜力。

pNFS是第一个NFSv4小版本的一部分。这个空间用于跟踪和分享Linux pNFS实现的想法和问题。

## 客户端信息

- Fedora pNFS 客户端设置 - 如何设置 Fedora pNFS 客户端。
- Archlinux pNFS 客户端设置 - 如何设置 Archlinux pNFS 客户端。

## 服务器端信息

从4.0版本开始，上游服务器包含pNFS块支持。请参阅PNFS块服务器设置以获取说明。

以下说明适用于过时的原型：

- pNFS设置说明 - 基本的pNFS设置说明。
- GFS2设置注意事项 - cluster3，2.6.27内核

## 开发资源

- pNFS开发Git树
- pNFS Git树配方
- pNFS服务器文件系统API设计
- Wireshark补丁

## 提交错误

- linux-nfs.org Bugzilla - "NFSv4.1相关错误"组成员可读/写访问
  - 使用关键词："NFSv4.1"和"pNFS"。
  - "NFSv4.1相关错误"组用于跟踪我们的错误。您需要在bugzilla上拥有用户帐户，然后发送电子邮件给Trond将您添加到该组。

## 设计笔记

- pNFS开发路线图
- pNFS基于文件的状态标识分发

## 历史内容

pNFS原型设计

# Fedora pNFS Client Setup

[原网页](https://linux-nfs.org/wiki/index.php/Fedora_pNFS_Client_Setup)。

