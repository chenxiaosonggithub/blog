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

[丁鹏龙](https://dingpenglong.com/)写的脚本:
```sh
#include <linux/fs.h>
#include <linux/types.h>
#include <linux/uio.h>
#include <linux/sunrpc/clnt.h>   // RPC 相关头文件
#include <linux/sunrpc/sched.h>  // struct rpc_task 定义

BEGIN {
    printf("Tracing nfs_file_write execution time... Hit Ctrl-C to end.\n");
}

////////////////////////////////////////////////////////////
//                 NFS File Write 跟踪                    //
////////////////////////////////////////////////////////////
kprobe:nfs_file_write
{
    $iocb  = (struct kiocb *)arg0;
    $file  = $iocb->ki_filp;
    $dentry = $file->f_path.dentry;
    $from  = (struct iov_iter *)arg1;

    @filename_ptr[tid]  = $dentry->d_name.name;  // 存储文件名指针
    @inode[tid]         = $file->f_inode->i_ino; // 存储 inode
    @write_offset       = $iocb->ki_pos;
    @write_length       = $from->count;
    @start_time[tid]    = nsecs;                 // 记录起始时间

    printf("%s, name:%-20s inode:%-8lu len:%-6d offset:%-8d time:%-20llu\n",
           probe, str($dentry->d_name.name), $file->f_inode->i_ino,
           @write_length, @write_offset, nsecs);
}

kretprobe:nfs_file_write
{
    $duration = nsecs - @start_time[tid];
    $name_ptr = @filename_ptr[tid];
    $ino      = @inode[tid];

    printf("nfs_file_write - File: %-20s ", str($name_ptr));
    printf("Inode: %-8lu ", $ino);
    printf("Duration: %ld s %ld ms %ld μs %ld ns\n",
           $duration / 1000000000,
           ($duration % 1000000000) / 1000000,
           ($duration % 1000000) / 1000,
           $duration % 1000);

    delete(@filename_ptr[tid]);
    delete(@inode[tid]);
    delete(@start_time[tid]);
}

////////////////////////////////////////////////////////////
//                  RPC Execute 阶段                      //
////////////////////////////////////////////////////////////
kprobe:rpc_execute
{
    $task = (struct rpc_task *)arg0;
    @rpc_task = $task;

    // 检查是否为 NFSv3 WRITE 操作
    if ($task->tk_msg.rpc_proc->p_proc != 7) {
        return;  // 非 WRITE 操作，直接返回
    }

    @rpc_xid[tid]        = $task->tk_rqstp->rq_xid;  // 存储 RPC XID
    @rpc_op[tid]         = $task->tk_msg.rpc_proc->p_name;  // RPC 操作名
    @rpc_start_time[tid] = nsecs;

    printf("rpc_execute START - XID:0x%08x OP:%-12s time:%-20llu\n",
           @rpc_xid[tid], str(@rpc_op[tid]), nsecs);
}

kretprobe:rpc_execute
{
    $task = @rpc_task;
    if ($task->tk_msg.rpc_proc->p_proc != 7) {
        return;  // 非 WRITE 操作，直接返回
    }

    $duration = nsecs - @rpc_start_time[tid];
    printf("rpc_execute END   - XID:0x%08x ", @rpc_xid[tid]);
 	printf("Duration: %ld s %ld ms %ld μs %ld ns\n",
           $duration / 1000000000,
           ($duration % 1000000000) / 1000000,
           ($duration % 1000000) / 1000,
           $duration % 1000);

    delete(@rpc_xid[tid]);
    delete(@rpc_op[tid]);
    delete(@rpc_start_time[tid]);
}

////////////////////////////////////////////////////////////
//                  RPC Call 阶段                         //
////////////////////////////////////////////////////////////
kprobe:call_start
{
    $task = (struct rpc_task *)arg0;
    @rpc_task = $task;

    // 检查是否为 NFSv3 WRITE 操作
    if ($task->tk_msg.rpc_proc->p_proc != 7) {
        return;  // 非 WRITE 操作，直接返回
    }

    @call_xid[tid]        = $task->tk_rqstp->rq_xid;
    @call_start_time[tid] = nsecs;
    $proc_num             = $task->tk_msg.rpc_proc->p_proc;

    printf("call_start    - XID:0x%08x Proc:%-4d time:%-20llu\n",
           @call_xid[tid], $proc_num, nsecs);
}

kretprobe:call_start
{
    $task = @rpc_task;
    if ($task->tk_msg.rpc_proc->p_proc != 7) {
        return;  // 非 WRITE 操作，直接返回
    }

    $duration = nsecs - @call_start_time[tid];
    printf("call_start    - XID:0x%08x ", @call_xid[tid]);
    printf("Duration: %ld s %ld ms %ld μs %ld ns\n",
           $duration / 1000000000,
          ($duration % 1000000000) / 1000000,
          ($duration % 1000000) / 1000,
           $duration % 1000);

    delete(@call_xid[tid]);
    delete(@call_start_time[tid]);
}

kprobe:call_transmit
{
    $task = (struct rpc_task *)arg0;
    @rpc_task = $task;

    // 检查是否为 NFSv3 WRITE 操作
    if ($task->tk_msg.rpc_proc->p_proc != 7) {
        return;  // 非 WRITE 操作，直接返回
    }

    @transmit_xid[tid]        = $task->tk_rqstp->rq_xid;
    @transmit_start_time[tid] = nsecs;

    printf("call_transmit - XID:0x%08x time:%-20llu\n",
           @transmit_xid[tid], nsecs);
}

kretprobe:call_transmit
{
    $task = @rpc_task;
    if ($task->tk_msg.rpc_proc->p_proc != 7) {
        return;  // 非 WRITE 操作，直接返回
    }

    $duration = nsecs - @transmit_start_time[tid];
    printf("call_transmit - XID:0x%08x ", @transmit_xid[tid]);
    printf("Duration: %ld s %ld ms %ld μs %ld ns\n",
           $duration / 1000000000,
          ($duration % 1000000000) / 1000000,
          ($duration % 1000000) / 1000,
           $duration % 1000);

    delete(@transmit_xid[tid]);
    delete(@transmit_start_time[tid]);
}

kprobe:call_decode
{
    $task = (struct rpc_task *)arg0;

    // 检查是否为 NFSv3 WRITE 操作
    if ($task->tk_msg.rpc_proc->p_proc != 7) {
        return;  // 非 WRITE 操作，直接返回
    }

    @decode_xid[tid]        = $task->tk_rqstp->rq_xid;
    @decode_start_time[tid] = nsecs;

    printf("call_decode   - XID:0x%08x time:%-20llu\n",
           @decode_xid[tid], nsecs);
}

kretprobe:call_decode
{
    $task = @rpc_task;
    if ($task->tk_msg.rpc_proc->p_proc != 7) {
        return;  // 非 WRITE 操作，直接返回
    }

    $duration = nsecs - @decode_start_time[tid];
    printf("call_decode   - XID:0x%08x ", @decode_xid[tid]);
    printf("Duration: %ld s %ld ms %ld μs %ld ns\n",
           $duration / 1000000000,
          ($duration % 1000000000) / 1000000,
          ($duration % 1000000) / 1000,
           $duration % 1000);

    delete(@decode_xid[tid]);
    delete(@decode_start_time[tid]);
}

END {
    clear(@filename_ptr);
    clear(@inode);
    clear(@start_time);
    clear(@rpc_xid);
    clear(@rpc_task);
    clear(@rpc_op);
    clear(@rpc_start_time);
    clear(@call_xid);
    clear(@call_start_time);
    clear(@transmit_xid);
    clear(@transmit_start_time);
    clear(@decode_xid);
    clear(@decode_start_time);
}
```

