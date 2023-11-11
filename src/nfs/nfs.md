[点击这里跳转到陈孝松个人主页:chenxiaosong.com](http://chenxiaosong.com/)。

# NFS简介

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
  +------------+      |            |
 6|presentation|     4|application | sunrpc
  |   layer    |      |    layer   |
  +------------+      |            |
  +------------+      |            |
 5|   session  |      |            |
  |   layer    |      |            |
  +------------+      +------------+
  +------------+      +------------+
 4| transport  |     3| transport  | tcp
  |   layer    |      |   layer    |
  +------------+      +------------+
  +------------+      +------------+
 3|  network   |     2| internet   | ip
  |   layer    |      |   layer    |
  +------------+      +------------+
  +------------+      +------------+
 2|  data link |      |            |
  |   layer    |     1|  network   |
  +------------+      |  access    |
  +------------+      |   layer    |
 1|  physical  |      |(link layer)|
  |   layer    |      |            |
  +------------+      +------------+
```

sunrpc之下的tcp层和ip层已经保证了数据的可靠性，sunrpc不会对数据的可靠性进行校验。但在我曾经定位过的问题中，出现过一个问题，tcp的校验通过了，但数据还是错误的，概率非常低，所以最终数据的可靠性还要在用户态对文件进行校验。

client端通过nfs操作存储设备经过的路径如下图所示：
```sh
     client                      server
 +------------+              +------------+
 |   client   |              |   storage  |
 |     app    |              |    device  |
 +------------+              +------------+ 
     1.|^                       11.|^       
       ||                          ||
       v|20.                       v|10.   
 +------------+              +------------+
 |    nfs     |              |    nfsd    |
 |            |              |(nfs server)|
 +------------+              +------------+ 
     2.|^                       12.|^       
       v|19.                       v|9.    
 +------------+              +------------+
 |   sunrpc   |              |   sunrpc   |
 +------------+              +------------+
     3.|^                       13.|^       
       v|18.                       v|8.     
 +------------+              +------------+
 |    tcp     |              |    tcp     |
 +------------+              +------------+
     4.|^                       14.|^      
       v|17.                       v|7.     
 +------------+              +------------+ 
 |     ip     |              |     ip     |
 +------------+              +------------+
     5.|^                       15.|^
       ||                          ||
       ||   16.+------------+      ||      
       |+------|  network   |<-----+|      
       +------>|            |-------+       
               +------------+ 6.            
```

# 怎么用？

nfs server安装所需软件：
```sh
apt-get install nfs-kernel-server -y # debian
```

nfs server编辑exportfs的配置文件`/etc/exports`，配置选项的含义可以通过命令`man 5 exports`查看:
```shell
/tmp/ *(rw,no_root_squash,fsid=0)
/tmp/s_test/ *(rw,no_root_squash,fsid=1)
/tmp/s_scratch *(rw,no_root_squash,fsid=2)
```

执行脚本[start-nfs-server.sh](https://github.com/chenxiaosonggithub/blog/blob/master/src/nfs/start-nfs-server.sh)启动nfs server。

nfs client挂载：
```sh
# nfsv4填写相对路径 /s_test 或 s_test
mount -t nfs -o vers=4.1 192.168.122.87:/s_test /mnt # /s_test和s_test都可以
# nfsv3和nfsv2 要写完整的源路径
mount -t nfs -o vers=3 192.168.122.87:/tmp/s_test /mnt
# nfsv2, nfs server 需要修改 /etc/nfs.conf, [nfsd] vers2=y
mount -t nfs -o vers=2 192.168.122.87:/tmp/s_test /mnt
```

# NFS各版本比较

| 版本 | RFC | 发布时间 | 页数 |
|-----------|-----------|-----------|----------|
| NFSv2 | [rfc1094](https://www.rfc-editor.org/rfc/rfc1094.html) | March 1989 | 27 |
| NFSv3 | [rfc1813](https://www.rfc-editor.org/rfc/rfc1813.html) | June 1995 | 126 |
| NFSv4 | [rfc3530](https://www.rfc-editor.org/rfc/rfc3530.html) | April 2003 | 275 |
| NFSv4.1 | [rfc5661](https://www.rfc-editor.org/rfc/rfc5661.html)（被[rfc7530](https://www.rfc-editor.org/rfc/rfc7530.html)取代，March 2015） | January 2010 | 617 |
| NFSv4.2 | [rfc7862](https://www.rfc-editor.org/rfc/rfc7862.html) | November 2016 | 104 |

# 文件句柄

， fh_compose, knfsd_fh, 

# clientid

反向通道

# delegation机制

冲突处理图
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

# nfs文件锁

NLM

# pNFS

网络结构图

```sh
+---------+                                          
|+---------+                                         
||+---------+                             +---------+
|||         |            pNFS             |         |
+|| clients |<--------------------------->| server  |
 +|         |                             |         |
  +---------+                             +---------+
      ^^^                                      ^     
      |||                                      |     
      |||                                      |     
      |||                                      |     
      |||                                      |     
      ||| storage                              |     
      ||| protocol   +---------+               |     
      ||+----------->|+---------+              |     
      |+------------>||+---------+  control    |
      +------------->|||         |  protocol   |
                     ||| storage |<------------+
                     +|| devices |      
                      +|         |      
                       +---------+                   
```