# 文档

- [PNFS Development - Linux NFS](https://linux-nfs.org/wiki/index.php/PNFS_Development)
- [pnfs.com](http://www.pnfs.com/)
- file layout: [August 2020 rfc8881 nfsv4.1](https://www.rfc-editor.org/rfc/rfc8881)
- block layout: [January 2010 rfc5663 Parallel NFS (pNFS) Block/Volume Layout](https://www.rfc-editor.org/rfc/rfc5663), [July 2012 rfc6688 Parallel NFS (pNFS) Block Disk Protection](https://www.rfc-editor.org/rfc/rfc6688)
- object layout: [January 2010 rfc5664 Object-Based Parallel NFS (pNFS) Operations](https://www.rfc-editor.org/rfc/rfc5664)
- flexible file layout: [August 2018 rfc8435 Parallel NFS (pNFS) Flexible File Layout](https://www.rfc-editor.org/rfc/rfc8435)

# 社区邮件交流

[Question about pNFS documentation](https://lore.kernel.org/all/BA2DED4720A37AFC+88e58d9e-6117-476d-8e06-1d1a62037d6d@chenxiaosong.com/)

我问有没有详细的pNFS环境搭建文档，Chuck Lever 回复内容翻译如下：
```
我不知道除了你这里列出的文档以外，还有没有其他最新的文档。

请注意，Linux NFS客户端实现了文件、块和flexfile布局类型，但Linux NFS服务器仅实现了pNFS块布局类型。

我一直在构建测试，旨在每次发布NFSD时运行这些测试，以检验Linux NFS服务器和客户端对pNFS块布局的支持，因为pNFS块是我们的客户端和服务器之间的共同点。

请查看[1]顶部的9个提交。这些提交包含对kdevops的更改，增加了它设置iSCSI目标并在其本地NFS服务器上启用pNFS的能力。如果你能阅读Ansible脚本，这些可能会帮助你形成使用Linux NFS实现及其iSCSI目标和发起程序来设置你自己环境的配方。

管理员文档（除了kdevops之外）还在待办事项列表中，但尚未开始。

[1] https://github.com/chucklever/kdevops/tree/pnfs-block-testing
```

我再问除了block layout外，nfs server有没计划实现其他的layout布局，Chuck Lever 回复内容翻译如下：
```
对象布局类型已经被弃用。如果我没记错的话，Linux NFS 客户端几年前就移除了对该类型的支持。服务器端也不计划支持它。

文件布局类型通常需要一个集群文件系统作为后端。你可以在 Ceph 或 gfs2 上构建一些东西，但这将是一个重大努力，并且需要用户需求。目前没有任何需求。

NFS 服务器有一个玩具级的 flexfile 布局实现，仅仅是一个概念验证。我们确实有一个未规划的待办事项，即研究如何将其扩展以提供测试客户端 flexfile 支持的平台。但这个工作不是优先任务。
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