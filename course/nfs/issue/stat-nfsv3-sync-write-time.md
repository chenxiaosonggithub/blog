# 问题描述

需要统计4.19内核上同步写操作各个阶段所花的时间，nfsv3挂载选项:
```sh
(rw,relatime,sync,vers=3,rsize=262144,wsize=262144,namlen=255,acregmin=0,acregmax=0,acdirmin=0,acdirmax=0,hard,noac,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=xx.xx.xx.xx,mountvers=3,mountport=2050,mountproto=tcp,local_lock=none,addr=xx.xx.xx.xx)
```

通过`man nfs`查看`sync`挂载选项的解释:
```
NFS 客户端对 sync 挂载选项的处理方式与某些其他文件系统不同（参见 mount(8) 中对通用 sync 与 async 挂载选项的描述）。如果既未指定 sync，也未指定 async（或显式指定了 async），NFS 客户端会将应用程序的写入操作延迟发送到服务器，直到发生以下任一情况：

系统内存压力迫使内核回收内存资源。

应用程序通过 sync(2)、msync(2) 或 fsync(3) 显式刷新文件数据。

应用程序通过 close(2) 关闭文件。

文件通过 fcntl(2) 加锁或解锁。

换言之，在正常情况下，应用程序写入的数据可能不会立即出现在托管该文件的服务器上。

如果在挂载点上指定了 sync 选项，则对该挂载点上的文件进行任何写操作的系统调用都会在返回用户空间之前，将数据刷新到服务器。这能在多个客户端之间提供更强的一致性保障，但会显著降低性能。

应用程序也可使用 O_SYNC 打开标志，在不使用 sync 挂载选项的情况下，对单个文件的写操作强制立即发送到服务器。
```

# 

