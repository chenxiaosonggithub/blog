[点击这里跳转到陈孝松个人主页:chenxiaosong.com](http://chenxiaosong.com/)。

翻译自Red Hat Bugzilla – [Bug 2176575 - intermittent severe NFS client performance drop via nfs_server_reap_expired_delegations looping?](https://bugzilla.redhat.com/show_bug.cgi?id=2176575)，大部分借助于ChatGPT翻译，仅作为我个人的参考，如果你想了解具体内容，建议查看原网页，因为我不确定我记录的中文翻译是否完整和正确。

- Frank Ch. Eigler 2023-03-08 18:28:42 UTC：
```
我们有一个连接到 Synology 最新的 NFS 服务器的 f37 客户端（内核版本为 6.1.14-200.fc37.x86_64），通过 nfs4 连接。间歇性地，会出现一种情况，其中客户端的速度急剧下降。正常的 NFS 操作是瞬时的，但当出现这种情况时，普通的 ls 操作可能需要几秒钟，Firefox 的启动需要 30 秒。

mount 命令报告的激活选项如下：
(rw,relatime,vers=4.1,rsize=131072,wsize=131072,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=192.168.1.1,local_lock=none,addr=192.168.1.21)

同一服务器的其他客户端在同一时间没有受到影响。在受影响的客户端、其他客户端或服务器上没有同时发生的诊断信息。因此，很难确定这种情况开始的时间点。

在内核上运行 "perf top" 显示了这种异常：
Samples: 6M of event 'cycles', 4000 Hz, Event count (approx.): 38276948048 lost: 0/0 drop: 0/0
Overhead  Shared Object                                   Symbol
  49.85%  [kernel]                                        [k] nfs_server_reap_expired_delegations    
   4.47%  [kernel]                                        [k] nfs_mark_test_expired_all_delegations 
   1.79%  [kernel]                                        [k] add_interrupt_randomness              
   0.87%  [kernel]                                        [k] check_preemption_disabled     
   0.86%  [kernel]                                        [k] read_tsc                

即 nfs_server_reap_expired_delegations() 非常繁忙。

iptraf-ng 报告在相对安静状态下（因此没有活动的文件活动）向服务器发送 O(1000) 次每秒的数据包，其中大部分似乎是 getattr 查询/响应。如果正在尝试进行 NFS 活动，则有 O(3000)+ 这样的数据包。
13:21:56.343792 IP (tos 0x2,ECT(0), ttl 64, id 43049, offset 0, flags [DF], proto TCP (6), length 268)
    CLIENT > SERVER: Flags [P.], cksum 0x8465 (incorrect -> 0x0852), seq 74016:74232, ack 34429, win 24571, options [nop,nop,TS val 1821171799 ecr 1844073712], length 216: NFS request xid 2025763571 212 getattr fh 0,1/53
13:21:56.343997 IP (tos 0x2,ECT(0), ttl 64, id 6274, offset 0, flags [DF], proto TCP (6), length 152)
    SERVER > CLIENT: Flags [P.], cksum 0xe7ab (correct), seq 34429:34529, ack 74232, win 24576, options [nop,nop,TS val 1844073713 ecr 1821171799], length 100: NFS reply xid 2025763571 reply ok 96 getattr NON 2 ids 0/-777130909 sz 469762048

在机器保持开启的状态下执行 umount -l / 和重新挂载同一文件系统似乎并没有改善情况。一旦发生这种情况，似乎无法停止它，即使通过重新启动服务器也不行。重新启动客户端可以很自然地修复问题。 :-)
```

- Frank Ch. Eigler 2023-03-08 18:47:09 UTC：
```
Wireshark 表明存在 NFSv4 TEST_STATEID 数据包

Frame 8: 282 bytes on wire (2256 bits), 282 bytes captured (2256 bits) on interface br0, id 0
Ethernet II, Src: 86:59:3e:3f:64:1d (86:59:3e:3f:64:1d), Dst: Synology_b2:55:91 (00:11:32:b2:55:91)
Internet Protocol Version 4, Src: 192.168.1.1, Dst: 192.168.1.21
Transmission Control Protocol, Src Port: 678, Dst Port: 2049, Seq: 649, Ack: 401, Len: 216
Remote Procedure Call, Type:Call XID:0x542ce2f3
Network File System, Ops(2): SEQUENCE, TEST_STATEID

No. Time Source Destination Protocol Info Length
9 0.001713316 192.168.1.21 192.168.1.1 NFS V4 Reply (Call In 8) TEST_STATEID 166

Frame 9: 166 bytes on wire (1328 bits), 166 bytes captured (1328 bits) on interface br0, id 0
Ethernet II, Src: Synology_b2:55:91 (00:11:32:b2:55:91), Dst: 86:59:3e:3f:64:1d (86:59:3e:3f:64:1d)
Internet Protocol Version 4, Src: 192.168.1.21, Dst: 192.168.1.1
Transmission Control Protocol, Src Port: 2049, Dst Port: 678, Seq: 401, Ack: 865, Len: 100
Remote Procedure Call, Type:Reply XID:0x542ce2f3
Network File System, Ops(2): SEQUENCE TEST_STATEID

No. Time Source Destination Protocol Info Length
10 0.001966063 192.168.1.1 192.168.1.21 NFS V4 Call (Reply In 11) TEST_STATEID 282
```

- Frank Ch. Eigler 2023-03-17 03:52:31 UTC:
  存在一个 sysctl.d 设置来将 fs.leases-enable 设置为 0 并不能阻止这个问题的发生。

- Frank Ch. Eigler 2023-07-17 20:40:45 UTC：
  Fedora 38 内核版本 6.3.8-200 并不能解决这个问题。一旦问题发生（在大约 3 周的正常运行时间后，且在网络上没有其他已知的更改），nfsstat -c 指示每秒 2 到 30 千个 test_stateid 消息，而 [IP-manager] 内核线程占用了大部分 CPU 时间。

- Trond Myklebust 2023-07-17 21:04:57 UTC：
```
上述情况在以下情形下预期会发生：当 NFSv4.1 服务器指示状态标识已被管理撤销，或者租约已过期时，通过返回错误之一 NFS4ERR_DELEG_REVOKED、NFS4ERR_ADMIN_REVOKED 或 NFS4ERR_EXPIRED。

如果服务器设置了 SEQUENCEID 标志之一 SEQ4_STATUS_EXPIRED_SOME_STATE_REVOKED 或 SEQ4_STATUS_ADMIN_STATE_REVOKED，也会发生这种情况。

在所有这些情况下，根据规范，客户端需要遍历其已知状态标识的列表，并调用 TEST_STATEID 以确保状态标识仍然有效。
```

- Frank Ch. Eigler 2023-07-17 21:35:22 UTC
  目前没有迹象表明服务器发送了这样的消息：无论是在服务器自己的日志中，还是在客户端的日志中，或者在任何其他客户端中都没有异常。而且，一旦这种情况开始，对已知状态标识列表的迭代似乎是永久的且持续的，直到重新启动机器。它似乎不是一次性的查询。

- Trond Myklebust 2023-07-17 22:35:25 UTC
  您有日志可以发布吗？

- Frank Ch. Eigler 2023-07-17 23:58:37 UTC
```
我本来打算说没有，因为客户端没有记录任何东西。
然而！另一个同行的NFS客户端（不是192.168.1.1），继续正常运行，通过dmesg输出了有关NFS服务器的以下信息：

[379489.954753] NFS: server HOSTNAME error: fileid changed
fsid 0:60: expected fileid 0x9fbe8fe, got 0x9fbe903
[380399.949813] NFS: server HOSTNAME error: fileid changed
fsid 0:60: expected fileid 0x9fbede6, got 0x9fbede7
[380403.949741] NFS: server HOSTNAME error: fileid changed
fsid 0:60: expected fileid 0x9fbedeb, got 0x9fbeded
[380428.949556] NFS: server HOSTNAME error: fileid changed
fsid 0:60: expected fileid 0x9fbee06, got 0x9fbee0a
[380518.949379] NFS: server HOSTNAME error: fileid changed
fsid 0:60: expected fileid 0x9fbee52, got 0x9fbee53
[380548.949321] NFS: server HOSTNAME error: fileid changed
fsid 0:60: expected fileid 0x9fbee69, got 0x9fbee6a
[384159.931317] NFS: server HOSTNAME error: fileid changed
fsid 0:60: expected fileid 0x9fbfd6d, got 0x9fbfd6e

而NFS服务器的dmesg显示了以下信息：

[4259331.428885] nfsd4_validate_stateid: 443 callbacks suppressed
[4259331.434869] NFSD: client 192.168.1.1 testing state ID with incorrect client ID
[4259331.443101] NFSD: client 192.168.1.1 testing state ID with incorrect client ID
[4259331.451501] NFSD: client 192.168.1.1 testing state ID with incorrect client ID
[4259331.459626] NFSD: client 192.168.1.1 testing state ID with incorrect client ID
[4259331.467707] NFSD: client 192.168.1.1 testing state ID with incorrect client ID
[4259331.475864] NFSD: client 192.168.1.1 testing state ID with incorrect client ID
[4259331.483976] NFSD: client 192.168.1.1 testing state ID with incorrect client ID
[4259331.492077] NFSD: client 192.168.1.1 testing state ID with incorrect client ID
[4259331.500249] NFSD: client 192.168.1.1 testing state ID with incorrect client ID
[4259331.508330] NFSD: client 192.168.1.1 testing state ID with incorrect client ID

这些可能在大致相同的时间发生。除了这大约10条日志条目外，没有其他日志条目，但问题持续了数小时，直到重新启动。

如果问题再次发生，您建议从客户端或服务器收集哪些跟踪或调试数据？
```

- Trond Myklebust 2023-07-18 00:25:30 UTC
  这些客户端是否具有唯一的主机名和/或是否设置了NFSv4唯一标识符？