[点击这里跳转到陈孝松个人主页:chenxiaosong.com](http://chenxiaosong.com/)。

[点击这里查看陈孝松所有博客](http://chenxiaosong.com/blog)。

# NFS和SunRPC

先看一下维基百科对NFS的定义：

> 网络文件系统（英语：Network File System，缩写作 NFS）是一种分布式文件系统，力求客户端主机可以访问服务器端文件，并且其过程与访问本地存储时一样，它由昇阳电脑（已被甲骨文公司收购）开发，于1984年发布。
>
> 它基于开放网路运算远端程序呼叫（ONC RPC，又被称为Sun ONC 或 Sun RPC）系统：一个开放、标准的RFC系统，任何人或组织都可以依据标准实现它。

再看一下SunRPC的定义：

> 开放网路运算远端程序呼叫（英语：Open Network Computing Remote Procedure Call，缩写为ONC RPC），一种被广泛应用的远端程序呼叫（RPC）系统，是一种属于应用层的协议堆叠，底层为TCP/IP协议。开放网路运算（ONC）最早源自于昇阳电脑（Sun），是网路文件系统计划的一部份，因此它经常也被称为Sun ONC 或 Sun RPC。现今在多数类UNIX系统上都实作了这套系统，微软公司也以Windows Services for UNIX在他们产品上提供ONC RPC的支援。2009年，昇阳电脑以标准三条款的BSD许可证释出这套系统。2010年，收购了昇阳电脑的甲骨文公司确认了这套软体BSD许可证的有效性与适用范围。

我们再来看一下OSI七层模型和TCP/IP四层模型中SunRPC的位置：
```sh
      OSI                TCP/IP
  +------------+      +------------+
 7|application |      |            |
  |   layer    |      |            |
  +------------+      |            |
 6|presentation|     4|application | sunrpc
  |   layer    |      |    layer   |
  +------------+      |            |
 5|   session  |      |            |
  |   layer    |      |            |
  +------------+      +------------+
 4| transport  |     3| transport  | tcp
  |   layer    |      |   layer    |
  +------------+      +------------+
 3|  network   |     2| internet   | ip
  |   layer    |      |   layer    |
  +------------+      +------------+
 2|  data link |     1|  network   |
  |   layer    |      |  access    |
  +------------+      |   layer    |
 1|  physical  |      |(link layer)|
  |  layer     |      |            |
  +------------+      +------------+
```

sunrpc之下的tcp层和ip层已经大概率的保证了数据的可靠性，sunrpc不会对数据的可靠性进行校验。但在我曾经定位过的问题中，遇到过一个问题，tcp的校验通过了，但数据还是错误的，概率非常低，所以最终数据的可靠性还要在用户态对文件进行校验。

client端通过nfs操作存储设备经过的路径如下图所示：
```sh
     client                      server
 +------------+              +------------+
 |   client   |              |   storage  |
 |     app    |              |    device  |
 +------------+              +------------+
     1.| ^                     11.| ^ 
       | |                        | |
       v |20.                     v |10. 
 +------------+              +------------+
 |    nfs     |              |    nfsd    |
 |            |              |(nfs server)|
 +------------+              +------------+
     2.| ^                     12.| ^ 
       v |19.                     v |9.    
 +------------+              +------------+
 |   sunrpc   |              |   sunrpc   |
 +------------+              +------------+
     3.| ^                     13.| ^ 
       v |18.                     v |8. 
 +------------+              +------------+
 |    tcp     |              |    tcp     |
 +------------+              +------------+
     4.| ^                     14.| ^ 
       v |17.                     v |7.     
 +------------+              +------------+
 |     ip     |              |     ip     |
 +------------+              +------------+
     5.| ^                     15.| ^
       | |                        | |
       | |  16.+------------+     | |      
       | +-----|  network   |<----+ | 
       +------>|            |-------+
               +------------+ 6.            
```

SunRPC有以下几个版本，你们一定和我一样在心里骂制定标准的人，为什么会有3个version 2，就不能命名成version 3和4？我们查阅时只需要选择[最新版本rfc5531](https://www.rfc-editor.org/rfc/rfc5531)：

- [rfc1050, April 1988,  RPC: Remote Procedure Call Protocol Specification](https://www.rfc-editor.org/rfc/rfc1050)
- [rfc1057, June 1988,   RPC: Remote Procedure Call Protocol Specification Version 2](https://www.rfc-editor.org/rfc/rfc1057)
- [rfc1831, August 1995, RPC: Remote Procedure Call Protocol Specification Version 2](https://www.rfc-editor.org/rfc/rfc1831)
- [rfc5531, May 2009,    RPC: Remote Procedure Call Protocol Specification Version 2](https://www.rfc-editor.org/rfc/rfc5531)

# NFS各版本比较

<!--
| 版本 | RFC | 发布时间 | 页数 |
|:-----------:|:-----------:|:-----------:|:----------:|
| NFSv2 | [rfc1094](https://www.rfc-editor.org/rfc/rfc1094.html) | March 1989 | 27 |
| NFSv3 | [rfc1813](https://www.rfc-editor.org/rfc/rfc1813.html) | June 1995 | 126 |
| NFSv4 | [rfc3530](https://www.rfc-editor.org/rfc/rfc3530.html)<br>（被[rfc7530](https://www.rfc-editor.org/rfc/rfc7530.html)取代，March 2015） | April 2003 | 275 |
| NFSv4.1 | [rfc5661](https://www.rfc-editor.org/rfc/rfc5661.html) [翻译](http://chenxiaosong.com/translations/rfc5661-nfsv4.1.html) | January 2010 | 617 |
| NFSv4.2 | [rfc7862](https://www.rfc-editor.org/rfc/rfc7862.html) [翻译](http://chenxiaosong.com/translations/rfc7862-nfsv4.2.html) | November 2016 | 104 |
-->
nfs的rfc协议文档有以下几个版本：

- [rfc1094, March 1989,    NFS: Network File System Protocol Specification](https://www.rfc-editor.org/rfc/rfc1094)
- [rfc1813, June 1995,     NFS Version 3 Protocol Specification](https://www.rfc-editor.org/rfc/rfc1813)
- [rfc7530, March 2015,    Network File System (NFS) Version 4 Protocol](https://www.rfc-editor.org/rfc/rfc7530)
- [rfc8881, August 2020,   Network File System (NFS) Version 4 Minor Version 1 Protocol](https://www.rfc-editor.org/rfc/rfc8881)
- [rfc7862, November 2016, Network File System (NFS) Version 4 Minor Version 2 Protocol](https://www.rfc-editor.org/rfc/rfc7862)

nfs各个版本的区别：

- NFSv2: 实现基本的功能，有很多的限制，如：读写最大长度限制8192字节，文件句柄长度固定32字节，只支持同步写。
- NFSv3: 取消了一些限制，如：文件句柄长度最大64字节，支持服务器异步写。增加ACCESS请求检查用户的访问权限。
- NFSv4: 有状态协议（NFSv2和NFSv3都是无状态协议），实现文件锁功能。只有两种请求`NULL`和`COMPOUND`，支持delegation。文件句柄长度最大128字节。
- NFSv4.1: 支持并行存储。
- NFSv4.2: 引入复合写操作（COMPOUNDV4 Write Operations），支持服务器端复制（不经过客户端）。

NFSv2的操作定义在`include/uapi/linux/nfs2.h`中的`NFSPROC_NULL ~ NFSPROC_STATFS`，编码解码函数定义在`nfs_procedures`和`nfsd_procedures2`。

NFSv3的操作定义在`include/uapi/linux/nfs3.h`中的`NFS3PROC_NULL ~ NFS3PROC_COMMIT`，编码解码函数定义在`nfs3_procedures`和`nfsd_procedures3`。

NFSv4的操作定义在`include/linux/nfs4.h`中的`NFSPROC4_NULL`和`NFSPROC4_COMPOUND`，server编译解码函数定义在`nfsd_procedures4`。

NFSv4 server详细的操作定义在`include/linux/nfs4.h`中的`enum nfs_opnum4`，处理函数定义在`nfsd4_ops`，编码解码函数定义在`nfsd4_enc_ops`和`nfsd4_dec_ops`。

NFSv4 client详细的操作定义在`include/linux/nfs4.h`中的`NFSPROC4_CLNT_NULL ~ NFSPROC4_CLNT_READ_PLUS`，编码解码函数定义在`nfs4_procedures`。

NFSv4反向通道的操作定义在`fs/nfs/callback.h`中的`enum nfs4_callback_opnum`，我已经提了补丁移到头文件：[NFSv4, NFSD: move enum nfs_cb_opnum4 to include/linux/nfs4.h](https://lore.kernel.org/all/tencent_03EDD0CAFBF93A9667CFCA1B68EDB4C4A109@qq.com/)。server在`fs/nfsd/state.h`中还定义了`nfsd4_cb_op`，编码解码函数定义在`nfs4_cb_procedures`。client的编码解码函数定义在`callback_ops`。

# 怎么用？

你可以先跳过这一节，先查看后面的内容，等到你需要搭建NFS环境的时候再来查阅。

nfs server安装所需软件：
```sh
apt-get install nfs-kernel-server -y # debian
```

nfs server编辑exportfs的配置文件`/etc/exports`，配置选项的含义可以通过命令`man 5 exports`查看:
```sh
/tmp/ *(rw,no_root_squash,fsid=0)
/tmp/s_test/ *(rw,no_root_squash,fsid=1)
/tmp/s_scratch *(rw,no_root_squash,fsid=2)
```

执行脚本[start-nfs-server.sh](https://github.com/chenxiaosonggithub/blog/blob/master/src/nfs/start-nfs-server.sh)启动nfs server。

nfs client安装所需软件：
```sh
apt-get install nfs-common -y # debian
```

nfs client挂载（更多挂载选项可以通过命令`man 5 nfs`查看）：
```sh
# nfsv4的根路径是/tmp/，源路径填写相对路径 /s_test 或 s_test
mount -t nfs -o vers=4.0 ${server_ip}:/s_test /mnt
mount -t nfs -o vers=4.1 ${server_ip}:/s_test /mnt
mount -t nfs -o vers=4.2 ${server_ip}:/s_test /mnt
# nfsv3和nfsv2 源路径要写完整的源路径，没有根路径的概念，源路径必须是绝对路径/tmp/s_test
mount -t nfs -o vers=3 ${server_ip}:/tmp/s_test /mnt
# nfsv2, nfs server 需要修改 /etc/nfs.conf 中的 `[nfsd] vers2=y`
mount -t nfs -o vers=2 ${server_ip}:/tmp/s_test /mnt
```

如果nfs server的exportfs的配置文件`/etc/exports`如下，没有`fsid`选项：
```sh
/tmp/s_test/ *(rw,no_root_squash)
```

这时nfsv4的根路径就是`/`，nfs client挂载nfsv4的命令如下：
```sh
mount -t nfs -o vers=4.0 ${server_ip}:/tmp/s_test /mnt # 或 tmp/s_test
```

# 文件句柄

我们先来看一下client端如果只告诉server端一个inode号会发生什么。

nfs server端的`/etc/exports`文件如下：
```sh
/export/sda *(rw,no_root_squash,fsid=0)
/export/sda/sdb *(rw,no_root_squash,fsid=1)
```

nfs server端以下命令执行后，`/export/sda/file`和`/export/sda/sdb/file`的inode号相同都是12（通过命令`stat file`查看）：
```sh
mkfs.ext4 -b 4096 -F /dev/sda
mkfs.ext4 -b 4096 -F /dev/sdb

mkdir /export/sda
mount -t ext4 /dev/sda /export/sda
touch /export/sda/file

mkdir /export/sda/sdb
mount -t ext4 /dev/sdb /export/sda/sdb
touch /export/sda/sdb/file
```

nfs client挂载命令：
```sh
mount -t nfs -o vers=4.1 ${server_ip}:/ /mnt
```

以上命令执行后，`${server_ip}:/`挂载到`/mnt`，nfs client端执行`stat /mnt/file`查看到inode为12。

nfs client再执行`stat /mnt/sdb/file`查看到inode也为12，这时会自动将`${server_ip}:/sdb`挂载到`/mnt/sdb`。

所以，如果nfs client只告诉nfs server一个inode号，nfs server不能确定是哪个文件系统的inode，也就无法找到对应的文件。

没看懂？那就对了，是我没讲明白，咱们来看个图：
```sh
                    1.  +------------+ 6.
                   +----|   client   |>>>>>>>>>>+
                   |    +------------+          | 
           hey man,|          ^               你好像在逗我
    can you tell me|          |额，你猜？
 whose inode is 12?|        5.|                 |         
                   |    +------------+          |   
                   +--->|   server   |<<<<<<<<<<+  
                        +------------+
                         |  ^    ^  |
                     2.1.|  |    |  |2.2.
               +---------+  |    |  +---------+
               |            |    |            |
       hey boy |       i know   i know too    |hey girl
   do you know?|            |    |            |do you know?
               v            |    |            v      
          +----------+ 4.1. |    |4.2.   +----------+ 
          | /dev/sda |------+    +-------| /dev/sdb |
          +----------+                   +----------+
               ^                              ^      
        i am 12|                              |i am 12
               |3.1.                      3.2.|
          +----------+                   +----------+
          |   file   |                   |   file   |
          +----------+                   +----------+
```

文件句柄中不仅包含inode信息，还包含服务端具体文件系统的信息，总之就是肯定可以在服务端找到对应的文件。nfs server文件句柄的数据结构是:
```c
struct knfsd_fh {                                                             
        unsigned int    fh_size;        /*                                    
                                         * Points to the current size while   
                                         * building a new file handle.        
                                         */                                   
        union {                                                               
                char                    fh_raw[NFS4_FHSIZE];                  
                struct {                                                      
                        u8              fh_version;     /* == 1 */            
                        u8              fh_auth_type;   /* deprecated */      
                        u8              fh_fsid_type;                         
                        u8              fh_fileid_type;                       
                        u32             fh_fsid[]; /* flexible-array member */
                };                                                            
        };                                                                    
};                                                                            
```

server端生成文件句柄的流程是：
```c
// 将当前文件句柄设置为根文件系统
nfsd4_putrootfh
  exp_pseudoroot
    fh_compose
      mk_fsid

// 打开文件时，创新一个新的文件句柄
nfsd4_open
  do_open_lookup
    do_nfsd_create
      fh_compose
        mk_fsid
```

nfs client查看文件的`filehandle`，可以用`tcpdump`抓包，再使用`wireshark`查看 。

# clientid和delegation机制

前面说过NFSv4最大的变化是有状态的协议，每个客户端有一个独一无二的clientid，相关的两种请求是`SETCLIENTID`和`SETCLIENTID_CONFIRM`。

clientid相关的信息保存在`struct nfs_client`中，client初始化clientid的函数为`nfs4_init_clientid`和`nfs41_init_clientid`。

在nfs client发起`SETCLIENTID`请求时，会创建一个RPC反向通道，nfs client是反向通道的服务器端。

delegation机制： 当nfs client1打开一个文件时，如果RPC反向通道可用，nfs server就会颁发一个凭证，nfs client1读写文件就不用发起`GETATTR`请求。当另一个client2也访问这个文件时，server就先回收client1的凭证，再响应client2的请求。之后，就和nfsv2和nfsv3一样读写之前要发起`GETATTR`请求。

回收delegation的过程如下：
```sh
                                +---------+
                                |         |
                                | client2 |<--------+
                                |         |         |
                                +---------+         |
                                  |     ^           |
                            1.OPEN|     |           |
                                  |     |           |
                                  | 2.NFS4ERR_DELAY |
                                  v     |           |
+---------+                     +---------+         |
|         |<---3.CB_RECALL------|         |         |
| client1 |----4.ok------------>| server  |--7.ok---+
|         |----5.DELEGRETURN--->|         |
|         |<---6.ok-------------|         |
+---------+                     +---------+
```

如果client1的反向通道抽风了，不能用了，回收delegation就会超时，server删除delegation，响应client2，然后在client1主动向server请求时，再通知client1。

客户端delegation的数据结构为`struct nfs_delegation`，服务端的数据结构为`struct nfs4_delegation`。delegation类型`enum open_delegation_type4`。

server创建delegation的流程：
```c
nfsd4_open
  nfsd4_process_open2
    nfs4_open_delegation
      nfsd4_cb_channel_good // 判断反向通道
      nfs4_set_delegation
        alloc_init_deleg
        vfs_setlease // 采用租借锁实现delegation
```

server回收delegation的操作是`NFSPROC4_CLNT_CB_RECALL`（操作处理函数定义在`nfs4_cb_procedures`），处理client发过来的请求的函数是`nfsd4_delegreturn`。

client端相关的流程：
```c
// 由_nfs4_open_and_get_state -> _nfs4_proc_open发起
rpc_async_schedule
  __rpc_execute
    rpc_prepare_task
      nfs4_open_prepare
        can_open_delegated // 判断是否要发起open请求

// 打开一个有delegation的文件
do_dentry_open
  nfs4_file_open
    nfs4_atomic_open
      nfs4_do_open
        _nfs4_do_open
          _nfs4_open_and_get_state
            _nfs4_proc_open
              nfs4_run_open_task
                .callback_ops = &nfs4_open_ops, // 会异步调用到nfs4_open_prepare
            _nfs4_opendata_to_nfs4_state
              nfs4_try_open_cached
                can_open_delegated

// 回收delegation
nfs_end_delegation_return
  nfs_end_delegation_return
    nfs_delegation_claim_opens
      nfs4_open_delegation_recall
        nfs4_open_recover_helper
          _nfs4_recover_proc_open // 发起open请求
          nfs4_opendata_to_nfs4_state // 更新struct nfs4_state
    nfs_do_return_delegation
      nfs4_proc_delegreturn // 最终调用到nfs4_xdr_enc_delegreturn, 更多的操作查看nfs4_procedures
```

# pNFS（parallel NFS）

从NFSv4.1开始，引入了pNFS，目的是为了解决系统吞吐量问题，pNFS的网络结构图如下：
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

pNFS系统由三部分组成：

1. server：保存文件的布局结构（layout），layout是对文件在storage devices中存储方式的一种说明，也就是元数据。pNFS是clients和server的通信协议。
2. storage devices: 由数据服务器构成，保存文件数据，当clients从server获得layout后，就可以向storage devices发送数据。clients和storage devices的存储协议有：file layout([rfc5661](https://www.rfc-editor.org/rfc/rfc5661.html))、block layout([rfc5663](https://www.rfc-editor.org/rfc/rfc5663.html))、object layout([rfc5664](https://www.rfc-editor.org/rfc/rfc5664.html))。server和storage devices的控制协议（control procotol）不属于pNFS的范围。
3. clients：支持pNFS和存储协议。

# nfs文件锁

使用命令`man 5 nfs`查看`lock / nolock`挂载选项翻译如下：
```sh
选择是否使用NLM（Network Lock Manager）侧边协议在服务器上对文件进行加锁。如果未指定任何选项（或指定了lock选项），则在此挂载点上使用NLM锁定。当使用nolock选项时，应用程序可以锁定文件，但此类锁定仅对在同一客户端上运行的其他应用程序提供排除效果。远程应用程序不受这些锁的影响。

在使用NFS挂载/var时，必须使用nolock选项禁用NLM锁定，因为/var包含Linux上的NLM实现使用的文件。在挂载不支持NLM协议的NFS服务器上的导出时，也需要使用nolock选项。
```

<!-- 网上查到的，不确定是否正确
挂载选项`nolock`：这是默认选项，在客户端加锁，不能保证多个客户端之间的数据不发生冲突。和其他文件系统的加锁过程一样。
挂载选项`lock`：在服务端加锁，能够保证所有客户端访问同一文件不发生冲突。这里只介绍服务端锁。
-->

nfsv2和nfsv3使用NLM（Network Lock Manager）协议实现文件锁。`lock / nolock`挂载选项仅针对nfsv2和nfsv3，未指定时，默认`lock`选项。

nfsv4实现了文件锁，不需要NLM协议。`lock / nolock`挂载选项对nfsv4似乎不起作用。

锁定文件使用的命令是：
```sh
# -n, --nonblock: 如果无法获得锁，不会阻塞，而是立即返回非零退出状态。
# -e, --exclusive: 获取排他锁（写锁）。
# -s, --shared: 获取共享锁（读锁）。
flock -n /mnt/file -c 'echo "get file lock success"'
```

代码处理流程如下：
```c
// 加锁
SYSCALL_DEFINE2(flock, ...
  nfs_flock // f.file->f_op->flock
    do_setlk
      nfs4_proc_lock

// 关闭文件时释放锁
fput
  init_task_work(&file->f_rcuhead, ____fput);
    ____fput
      __fput
        locks_remove_file
          locks_remove_flock
            nfs_flock
              do_unlk
                nfs4_proc_lock
```

`nfs4_proc_lock`的第二个参数`int cmd`有3种选项：

- F_GETLK: 查询文件锁
- F_SETLK: 设置文件锁，如果冲突就退出
- F_SETLKW: 设置文件锁，如果冲突就等待，直到成功

文件锁相关的请求：

- NFSPROC4_CLNT_LOCK: 加锁
- NFSPROC4_CLNT_LOCKT: 查询
- NFSPROC4_CLNT_LOCKU: 解锁
- NFSPROC4_CLNT_RELEASE_LOCKOWNER: 释放文件锁所有者

判断锁类型的函数`nfs4_lock_type()`。
