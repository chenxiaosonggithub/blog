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

# 调试

打开日志开头:
```sh
echo 0xFFFF > /proc/sys/sunrpc/nfs_debug # NFSDBG_ALL
echo 0x7fff > /proc/sys/sunrpc/rpc_debug # RPCDBG_ALL
```

得到以下rpc状态变化的日志:
```sh
[ 2654.631317] RPC:    45 call_start nfs3 proc WRITE (async)
[ 2654.632237] RPC:    45 call_reserve (status 0)
[ 2654.635102] RPC:    45 call_reserveresult (status 0)
[ 2654.635931] RPC:    45 call_refresh (status 0)
[ 2654.637647] RPC:    45 call_refreshresult (status 0)
[ 2654.638528] RPC:    45 call_allocate (status 0)
[ 2654.640483] RPC:    45 call_bind (status 0)
[ 2654.641244] RPC:    45 call_connect xprt 000000007e192939 is connected
[ 2654.642397] RPC:    45 call_transmit (status 0)
[ 2654.685691] RPC:    45 call_status (status 136)
[ 2654.685693] RPC:    45 call_decode (status 136)
[ 2654.695916] RPC:    45 call_decode result 13
```

# 代码分析

```c
write
  ksys_write
    vfs_write
      __vfs_write
        new_sync_write
          nfs_file_write
            generic_write_sync // 同步写执行到这里
              vfs_fsync_range
                nfs_file_fsync // file->f_op->fsync
                  filemap_write_and_wait_range
                    __filemap_fdatawrite_range
                      do_writepages
                        nfs_writepages
                          nfs_pageio_complete
                            nfs_pageio_doio
                              nfs_generic_pg_pgios
                                nfs_initiate_pgio
                                  .rpc_message = &msg,
                                  .flags = RPC_TASK_ASYNC // 异步rpc
                                  nfs_initiate_write // hdr->rw_ops->rw_initiate
                                    nfs3_proc_write_setup
                                      msg->rpc_proc = &nfs3_procedures[NFS3PROC_WRITE]
                                  rpc_run_task
                                    rpc_new_task
                                      rpc_init_task
                                    rpc_task_set_rpc_message // 设置tk_msg的值，NFS3PROC_WRITE和task关联上了
                                    rpc_call_start
                                      task->tk_action = call_start
                                    rpc_execute

call_transmit
  xprt_transmit
    xs_tcp_send_request
      xs_sendpages
        xs_send_kvec
          kernel_sendmsg

call_transmit -> call_decode : 104ms
nfs_file_write -> rpc_execute : 100ms
```

# 脚本

bpftrace的使用请查看[《BPF》](https://chenxiaosong.com/course/kernel/bpf.html#bpftrace)。

跟踪以下函数:
```c
nfs_file_write
rpc_execute
call_start
call_transmit
call_decode
```

[丁鹏龙](https://dingpenglong.com/)写的[bpftrace脚本](https://gitee.com/chenxiaosonggitee/tmp/tree/master/gnu-linux/nfs/dingpenglong-stat-nfsv3-sync-write-time)。

抓到以下日志:
```sh
kprobe:nfs_file_write, name:xxxx inode:1697123520 len:354    offset:132777   time:39290423881392412
call_transmit start - XID:0xedc0ad03 OP:GETATTR      time:39290423881405002
call_transmit start - XID:0xedc0ad03 OP:GETATTR      time:39290423982453372
call_transmit start - XID:0xeec0ad03 OP:WRITE        time:39290423982494112
call_transmit start - XID:0xeec0ad03 OP:WRITE        time:39290424084932650
nfs_file_write - File: xxxx Inode: 1697123520 Duration: 0 s 203 ms 592 μs 488 ns

kprobe:nfs_file_write, name:xxxx inode:1697123520 len:353    offset:140530   time:39290435940709314
call_transmit start - XID:0xfac1ad03 OP:GETATTR      time:39290435940720794
call_transmit start - XID:0xfac1ad03 OP:GETATTR      time:39290436041499632
call_transmit start - XID:0xfbc1ad03 OP:WRITE        time:39290436041541542
call_transmit start - XID:0xfbc1ad03 OP:WRITE        time:39290436149645344
nfs_file_write - File: xxxx Inode: 1697123520 Duration: 0 s 209 ms 7 μs 571 ns
```

抓包数据过滤xid: `rpc.xid==0xxxxxxxxx`:
```sh
30203	812.505210	175.20.2.166	172.21.3.10	NFS	228	V3 GETATTR Call (Reply In 30207), FH: 0x073dd918
30207	812.606206	172.21.3.10	175.20.2.166	NFS	184	V3 GETATTR Reply (Call In 30203)  Regular File mode: 0644 uid: 99999 gid: 88888
30211	812.606325	175.20.2.166	172.21.3.10	NFS	860	V3 WRITE Call (Reply In 30215), FH: 0x073dd918 Offset: 131072 Len: 2059 FILE_SYNC
30215	812.708700	172.21.3.10	175.20.2.166	NFS	232	V3 WRITE Reply (Call In 30211) Len: 2059 FILE_SYNC

31483	824.564522	175.20.2.166	172.21.3.10	NFS	228	V3 GETATTR Call (Reply In 31487), FH: 0x073dd918
31487	824.665249	172.21.3.10	175.20.2.166	NFS	184	V3 GETATTR Reply (Call In 31483)  Regular File mode: 0644 uid: 99999 gid: 88888
31495	824.665386	175.20.2.166	172.21.3.10	NFS	1372	V3 WRITE Call (Reply In 31501), FH: 0x073dd918 Offset: 131072 Len: 9811 FILE_SYNC
31501	824.773409	172.21.3.10	175.20.2.166	NFS	232	V3 WRITE Reply (Call In 31495) Len: 9811 FILE_SYNC
```

可以看到，`nfs_file_write()`函数中发送了write和getattr请求，write请求100+ms，getattr请求100+ms，耗时长是nfs server端导致的。

