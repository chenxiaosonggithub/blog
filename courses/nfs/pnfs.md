# 文档

- [PNFS Development - Linux NFS](https://linux-nfs.org/wiki/index.php/PNFS_Development)
- [pnfs.com](http://www.pnfs.com/)
- file layout: [August 2020 rfc8881 nfsv4.1](https://www.rfc-editor.org/rfc/rfc8881)
- block layout: [January 2010 rfc5663 Parallel NFS (pNFS) Block/Volume Layout](https://www.rfc-editor.org/rfc/rfc5663), [July 2012 rfc6688 Parallel NFS (pNFS) Block Disk Protection](https://www.rfc-editor.org/rfc/rfc6688)
- object layout: [January 2010 rfc5664 Object-Based Parallel NFS (pNFS) Operations](https://www.rfc-editor.org/rfc/rfc5664)
- flexible file layout: [August 2018 rfc8435 Parallel NFS (pNFS) Flexible File Layout](https://www.rfc-editor.org/rfc/rfc8435)

# 邮件咨询

[Question about pNFS documentation](https://lore.kernel.org/all/BA2DED4720A37AFC+88e58d9e-6117-476d-8e06-1d1a62037d6d@chenxiaosong.com/)

Chuck Lever 回复内容翻译如下：
```
我不知道除了你这里列出的文档以外，还有没有其他最新的文档。

请注意，Linux NFS客户端实现了文件、块和flexfile布局类型，但Linux NFS服务器仅实现了pNFS块布局类型。

我一直在构建测试，旨在每次发布NFSD时运行这些测试，以检验Linux NFS服务器和客户端对pNFS块布局的支持，因为pNFS块是我们的客户端和服务器之间的共同点。

请查看[1]顶部的9个提交。这些提交包含对kdevops的更改，增加了它设置iSCSI目标并在其本地NFS服务器上启用pNFS的能力。如果你能阅读Ansible脚本，这些可能会帮助你形成使用Linux NFS实现及其iSCSI目标和发起程序来设置你自己环境的配方。

管理员文档（除了kdevops之外）还在待办事项列表中，但尚未开始。
```

# 简介

pNFS的网络结构图如下：
```sh
+---------+                                          
| +---------+
| | +---------+                             +---------+
| | |         |            pNFS             |         |
+-| | clients |<--------------------------->| server  |
  +-|         |                             |         |
    +---------+                             +---------+
       ^ ^ ^                                     ^     
       | | |                                     | 
       | | |                                     | 
       | | |                                     | 
       | | |                                     | 
       | | | storage                             | 
       | | | protocol  +---------+               | 
       | | +---------->| +---------+             |     
       | +------------>| | +---------+  control  |
       +-------------->| | |         |  protocol |
                       | | | storage |<----------+
                       +-| | devices |      
                         +-|         |
                           +---------+
```