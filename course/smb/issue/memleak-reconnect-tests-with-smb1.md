# 问题描述

这个问题是Paulo Alcantara <pc@manguebit.org>发现的，maintainer Steve French <smfrench@gmail.com>转发给我让我帮忙看一下。

邮件描述如下:
```
Hi Steve,

While running DFS reconnect tests with v6.19-rc1 I found out that we end
up leaking various "small buffers" as reported my kmemleak:

    > $ cat /sys/kernel/debug/kmemleak
    > ...
    > unreferenced object 0xffff8881264356c0 (size 448):
    >   comm "cifsd", pid 1106, jiffies 4294824756
    >   hex dump (first 32 bytes):
    >     ff 53 4d 42 32 57 02 00 c0 80 01 c0 00 00 00 00  .SMB2W..........
    >     00 00 00 00 00 00 00 00 01 08 53 04 00 08 0b 00  ..........S.....
    >   backtrace (crc c85bbdc2):
    >     kmem_cache_alloc_noprof+0x565/0x740
    >     mempool_alloc_noprof+0xf3/0x1a0
    >     cifs_small_buf_get+0x27/0x70 [cifs]
    >     allocate_buffers+0x9c/0x190 [cifs]
    >     cifs_demultiplex_thread+0x1fc/0x1560 [cifs]
    >     kthread+0x201/0x380
    >     ret_from_fork+0x345/0x3d0
    >     ret_from_fork_asm+0x1a/0x30                                                                                                     

When reloading cifs.ko module, I also get the usual BUG():

    > $ dmesg
    > ...
    > BUG cifs_small_rq (Tainted: G    B   W          ): Objects remaining on __kmem_cache_shutdown()
    > -----------------------------------------------------------------------------
    >
    > Object 0xffff888119e8d6c0 @offset=5824
    > Allocated in mempool_alloc_noprof+0xf3/0x1a0 age=195779 cpu=5 pid=1809
    > [567.944454] kmem_cache_alloc_noprof+0x319/0x740
    >  mempool_alloc_noprof+0xf3/0x1a0
    >  cifs_small_buf_get+0x27/0x70 [cifs]
    >  allocate_buffers+0x9c/0x190 [cifs]
    >  cifs_demultiplex_thread+0x1fc/0x1560 [cifs]
    >  kthread+0x201/0x380
    >  ret_from_fork+0x345/0x3d0
    >  ret_from_fork_asm+0x1a/0x30
```

# 代码分析

```c
cifs_demultiplex_thread
  allocate_buffers
    cifs_small_buf_get
      mempool_alloc
        mempool_alloc_noprof
          
```
