# 问题描述

NFS客户端采用NFSv4.2(vers=4.2)挂载时，tcpdump抓包发现，NFS服务端经常SEQUENCE 返回 NFS4ERR_BADSESSION错误导致 客户端主动DESTROY_SESSION和CREATE_SESSION，
客户端创建会话时，服务端返回NFS4ERR_STATLE_CLIENTID错误，客户端需要重新EXCHANGE_ID后CREATE_SESSION才成功，因为反复出现这种现象，导致客户端读写文件会出现偶尔错误，系统errno 会返回5。
<!-- 客户端改成 NFSv4.0和NFSv4.1没有出现这种现象（暂不确定）。 -->
client日志中打印了`NFS: nfs4_reclaim_open_state: Lock reclaim failed!`，server日志中打印了`NFSD: client xx.xx.xx.xx testing state ID with incorrect client ID`。

挂载参数:
```sh
(ro,noexec,relatime,vers=4.1,rsize=1048576,wsize=1048576,namlen=255,soft,proto=tcp,timeo=10,retrans=2,sec=sys,clientaddr=xx.xx.xx.xx,local_lock=none,addr=xx.xx.xx.xx)
(ro,noexec,relatime,vers=4.2,rsize=1048576,wsize=1048576,namlen=255,soft,proto=tcp,timeo=10,retrans=2,sec=sys,clientaddr=xx.xx.xx.xx,local_lock=none,addr=xx.xx.xx.xx)
```

# 补丁分析

关于打印日志`NFS: nfs4_reclaim_open_state: Lock reclaim failed!`，请查看[`3e2910c7e23b NFS: Improve warning message when locks are lost.`](https://chenxiaosong.com/course/nfs/patch/NFS-Improve-warning-message-when-locks-are-lost.html)，注意nfs4.0、4.1和4.2都会有这个打印。

关于打印`NFSD: client xx.xx.xx.xx testing state ID with incorrect client ID`已经被补丁`663e36f07666 nfsd4: kill warnings on testing stateids with mismatched clientids`移除。

# 调试

## 测试步骤

```sh
echo something > /tmp/s_test/file # server
echo 3 > /proc/sys/vm/drop_caches # server
tcpdump --interface=ens2 --buffer-size=20480 -w client1.cap & # client1
tcpdump --interface=ens2 --buffer-size=20480 -w client2.cap & # client2
mount -t nfs -o ro,noexec,relatime,vers=4.2,rsize=1048576,wsize=1048576,namlen=255,soft,proto=tcp,timeo=10,retrans=2,sec=sys,local_lock=none 192.168.53.209:s_test /mnt # client1, client2
cat /mnt/file # client1, client2
```

## 日志收集

打开server端的打印开关:
```sh
echo 0x7FFF > /proc/sys/sunrpc/nfsd_debug # NFSDDBG_ALL
```

有以下打印:
```sh
__find_in_sessionid_hashtbl: session not found
```

## kprobe

kprobe跟踪函数:
```sh
cd /sys/kernel/debug/tracing/
cat available_filter_functions | grep __find_in_sessionid_hashtbl # 找不到
cat available_filter_functions | grep find_in_sessionid_hashtbl
cat available_filter_functions | grep init_session
cat available_filter_functions | grep unhash_session # 找不到
cat available_filter_functions | grep nfsd4_destroy_session
cat available_filter_functions | grep unhash_client_locked
echo 1 > tracing_on

echo 'p:p_find_in_sessionid_hashtbl find_in_sessionid_hashtbl' >> kprobe_events
echo 1 > events/kprobes/p_find_in_sessionid_hashtbl/enable
echo stacktrace > events/kprobes/p_find_in_sessionid_hashtbl/trigger
echo '!stacktrace' > events/kprobes/p_find_in_sessionid_hashtbl/trigger
echo 0 > events/kprobes/p_find_in_sessionid_hashtbl/enable
echo '-:p_find_in_sessionid_hashtbl' >> kprobe_events

echo 'p:p_init_session init_session' >> kprobe_events
echo 1 > events/kprobes/p_init_session/enable
echo stacktrace > events/kprobes/p_init_session/trigger
echo '!stacktrace' > events/kprobes/p_init_session/trigger
echo 0 > events/kprobes/p_init_session/enable
echo '-:p_init_session' >> kprobe_events

echo 'p:p_nfsd4_destroy_session nfsd4_destroy_session' >> kprobe_events
echo 1 > events/kprobes/p_nfsd4_destroy_session/enable
echo stacktrace > events/kprobes/p_nfsd4_destroy_session/trigger
echo '!stacktrace' > events/kprobes/p_nfsd4_destroy_session/trigger
echo 0 > events/kprobes/p_nfsd4_destroy_session/enable
echo '-:p_nfsd4_destroy_session' >> kprobe_events

echo 'p:p_unhash_client_locked unhash_client_locked' >> kprobe_events
echo 1 > events/kprobes/p_unhash_client_locked/enable
echo stacktrace > events/kprobes/p_unhash_client_locked/trigger
echo '!stacktrace' > events/kprobes/p_unhash_client_locked/trigger
echo 0 > events/kprobes/p_unhash_client_locked/enable
echo '-:p_unhash_client_locked' >> kprobe_events

echo 0 > trace # 清除trace信息
cat trace_pipe
```

# 抓包数据分析

第一个执行`cat`命令的client端的抓包数据显示一切顺利:
```sh
No.     Time            Source          Destination   Protocol  Length  Info
44      8.519424        192.168.53.211  192.168.53.209  NFS     242     V4 Call (Reply In 45) ACCESS FH: 0xda686b37, [Check: RD LU MD XT DL XAR XAW XAL]
45      8.520129        192.168.53.209  192.168.53.211  NFS     238     V4 Reply (Call In 44) ACCESS, [Allowed: RD LU MD XT DL XAR XAW XAL]
47      8.520438        192.168.53.211  192.168.53.209  NFS     318     V4 Call (Reply In 48) OPEN DH: 0xda686b37/file
48      8.521172        192.168.53.209  192.168.53.211  NFS     450     V4 Reply (Call In 47) OPEN StateID: 0xafa9
49      8.521476        192.168.53.211  192.168.53.209  NFS     258     V4 Call (Reply In 50) READ_PLUS StateID: 0x07c6 Offset: 0 Len: 4096
50      8.522020        192.168.53.209  192.168.53.211  NFS     202     V4 Reply (Call In 49) READ_PLUS
```

后执行`cat`命令的client端的抓包数据就有点问题:
```sh
No.     Time            Source          Destination   Protocol  Length  Info
58      40.222102       192.168.53.210  192.168.53.209  NFS     242     V4 Call (Reply In 59) ACCESS FH: 0xda686b37, [Check: RD LU MD XT DL XAR XAW XAL]
59      40.222821       192.168.53.209  192.168.53.210  NFS     114     V4 Reply (Call In 58) SEQUENCE Status: NFS4ERR_BADSESSION
61      40.223325       192.168.53.210  192.168.53.209  NFS     186     V4 Call (Reply In 62) DESTROY_SESSION
62      40.223764       192.168.53.209  192.168.53.210  NFS     114     V4 Reply (Call In 61) DESTROY_SESSION Status: NFS4ERR_BADSESSION
63      40.223910       192.168.53.210  192.168.53.209  NFS     298     V4 Call (Reply In 64) CREATE_SESSION
64      40.224568       192.168.53.209  192.168.53.210  NFS     114     V4 Reply (Call In 63) CREATE_SESSION Status: NFS4ERR_STALE_CLIENTID
65      40.224749       192.168.53.210  192.168.53.209  NFS     342     V4 Call (Reply In 66) EXCHANGE_ID
66      40.225228       192.168.53.209  192.168.53.210  NFS     314     V4 Reply (Call In 65) EXCHANGE_ID
67      40.225378       192.168.53.210  192.168.53.209  NFS     298     V4 Call (Reply In 68) CREATE_SESSION
68      40.245588       192.168.53.209  192.168.53.210  NFS     194     V4 Reply (Call In 67) CREATE_SESSION
69      40.245793       192.168.53.210  192.168.53.209  NFS     218     V4 Call (Reply In 70) PUTROOTFH | GETATTR
70      40.246160       192.168.53.209  192.168.53.210  NFS     182     V4 Reply (Call In 69) PUTROOTFH | GETATTR
71      40.246314       192.168.53.210  192.168.53.209  NFS     210     V4 Call (Reply In 72) RECLAIM_COMPLETE
72      40.255843       192.168.53.209  192.168.53.210  NFS     158     V4 Reply (Call In 71) RECLAIM_COMPLETE
73      40.256049       192.168.53.210  192.168.53.209  NFS     242     V4 Call (Reply In 74) ACCESS FH: 0xda686b37, [Check: RD LU MD XT DL XAR XAW XAL]
74      40.256467       192.168.53.209  192.168.53.210  NFS     238     V4 Reply (Call In 73) ACCESS, [Allowed: RD LU MD XT DL XAR XAW XAL]
75      40.256710       192.168.53.210  192.168.53.209  NFS     318     V4 Call (Reply In 76) OPEN DH: 0xda686b37/file
76      40.257300       192.168.53.209  192.168.53.210  NFS     450     V4 Reply (Call In 75) OPEN StateID: 0xafa9
77      40.257721       192.168.53.210  192.168.53.209  NFS     258     V4 Call (Reply In 78) READ_PLUS StateID: 0x9bc8 Offset: 0 Len: 4096
78      40.258192       192.168.53.209  192.168.53.210  NFS     202     V4 Reply (Call In 77) READ_PLUS
```

后执行`cat`命令的client端，OPEN前先执行ACCESS，但却返回NFS4ERR_BADSESSION错误，接着重新建立连接，然后再执行和第一个client端一样的过程。

# 代码分析

client端的clientid里含有hostname，如果加载nfs模块时没有指定模块参数`nfs4_unique_id`，也没有设置`/sys/fs/nfs/net/nfs_client/identifier`的值，那么clientid的值就只取决于hostname，如果多个client的hostname一样，那么这些client的clientid也都一样。

如果多个client的clientid一样，那么在第二个client执行挂载时，server端代码执行到`nfsd4_create_session()`时，就会因为与前一个client的clientid一样，而执行`unhash_client_locked()`销毁所有的sessionid，然后再生成新的sessionid。

接着，第一个client再执行任何请求时，server端代码`find_in_sessionid_hashtbl()`找不到sessionid，就会重新建立连接。

client组装clientid的过程:
```c
nfs4_proc_setclientid
  nfs4_init_uniform_client_string / nfs4_init_nonuniform_client_string
    nfs4_get_uniquifier
      // 先查看是否有设置 /sys/fs/nfs/net/nfs_client/identifier
      rcu_dereference(nn_clp->identifier);
      // 再查看是否有设置模块参数nfs4_unique_id
      strscpy(buf, nfs4_client_id_uniquifier, buflen);
    // 和hostname组成唯一字符串
    scnprintf(str, len, "Linux NFSv%u.%u %s/%s", ..., clp->cl_rpcclient->cl_nodename

// hostname的设置
rpc_create_xprt
  rpc_new_client
    rpc_clnt_set_nodename // nodename 就是 hostname

// /sys/fs/nfs/net/nfs_client/identifier 的设置
// fs/nfs/sysfs.c
struct kobj_attribute nfs_netns_client_id = __ATTR(identifier,
```

server端查找和生成sessionid的过程:
```c
// 查找sessionid
nfsd
  svc_process
    svc_process_common
      nfsd_dispatch
        nfsd4_proc_compound // proc->pc_func
          nfsd4_sequence // op->opdesc->op_func
            find_in_sessionid_hashtbl
              __find_in_sessionid_hashtbl
                idx = hash_sessionid

// 生成sessionid
nfsd4_proc_compound
  nfsd4_create_session
    find_unconfirmed_client / find_confirmed_client
      find_client_in_id_table
    find_confirmed_client_by_name // name->data的值是clientid
    mark_client_expired_locked
      unhash_client_locked
        list_del_init(&ses->se_hash)
    init_session
      gen_sessionid
        sid->clientid = clp->cl_clientid
      idx = hash_sessionid
      list_add(&new->se_hash, &nn->sessionid_hashtbl[idx])
```

server端销毁sessionid的过程:
```c
// 销毁sessionid
nfsd4_proc_compound
  // 执行umount命令时，先执行到这里，再执行到unhash_client_locked
  nfsd4_destroy_session
    unhash_session
      list_del(&ses->se_hash)

nfsd4_proc_compound
  nfsd4_destroy_clientid
    unhash_client
      unhash_client_locked
        list_del_init(&ses->se_hash)
```

# 结论

当多个 NFS 客户端使用相同的主机名时，默认的统一客户端字符串可能不够唯一，导致 NFS 服务器无法区分不同的客户端。NFS 服务器会将第二个客户端视为第一个客户端重启后的结果，从而使第一个客户端的 clientid 失效/过期，阻止第一个客户端进行通信。具体查看[NFSv4 clientid was expired suddenly due to use same hostname on several NFS clients](https://access.redhat.com/solutions/6395261)。