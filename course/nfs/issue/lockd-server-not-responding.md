# 问题描述

4.19内核日志:
```sh
grep -r "not responding"
# 0619
Jun 19 02:22:38 xxxxxxxxxx kernel: [9697905.032077] lockd: server 215.2.21.62 not responding, still trying
Jun 19 03:50:47 xxxxxxxxxx kernel: [9703193.915722] lockd: server 215.2.21.62 not responding, timed out
Jun 19 06:22:05 xxxxxxxxxx kernel: [9712271.571929] lockd: server 215.2.21.62 not responding, still trying
# 另一个环境日志, 0622
Jun 22 22:55:38 xxxxxxxxxx kernel: [9263358.933594] lockd: server 11.73.24.85 not responding, still trying
Jun 22 22:56:18 xxxxxxxxxx kernel: [9263398.655377] lockd: server 11.73.24.85 0K
```

挂载参数:
```sh
rw,relatime,vers=3,rsize=262144,wsize=262144,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountvers=3,mountproto=tcp,local_lock=none,_netdev
```

需要回答以下问题:

<!--
- 核外: ftp哪些请求加锁，哪些请求解锁，怎么加锁？
- 核外: 请求加锁是同步锁还是异步锁怎么判断？
-->
- lockd有哪些请求？哪些请求超时会报lockd信息？
- 超时时间参数？
- 重传机制？

# 构造 {#reproduce}

## 构造server不处理请求 {#reproduce-server-not-reply-lock}

构造内核打印`lockd: server xx.xx.xx.xx not responding, still trying`。

内核修改:
```c
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -31,6 +31,7 @@
 #include <linux/lockd/nlm.h>
 #include <linux/lockd/lockd.h>
 #include <linux/kthread.h>
+#include <linux/delay.h>

 #define NLMDBG_FACILITY                NLMDBG_SVCLOCK

@@ -404,6 +405,11 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
        int                     error;
        __be32                  ret;

+       while (1) {
+               printk("%s:%d, sleep\n", __func__, __LINE__);
+               msleep(20 * 1000);
+       }
+
        dprintk("lockd: nlmsvc_lock(%s/%ld, ty=%d, pi=%d, %Ld-%Ld, bl=%d)\n",
                                locks_inode(file->f_file)->i_sb->s_id,
                                locks_inode(file->f_file)->i_ino,
```

用户态程序[`nfs-lock.c`](https://github.com/chenxiaosonggithub/blog/blob/master/course/nfs/src/nfs-lock.c)。

测试步骤:
```sh
mount -t nfs -o rw,relatime,vers=3,rsize=262144,wsize=262144,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountvers=3,mountproto=tcp,local_lock=none,_netdev localhost:/tmp /mnt
echo something > /mnt/file # 创建文件
gcc -o nfs-lock nfs-lock.c
echo 0xFFFF > /proc/sys/sunrpc/nfs_debug # NFSDBG_ALL
echo 0x7fff > /proc/sys/sunrpc/rpc_debug # RPCDBG_ALL
./nfs-lock /mnt/file &
```

日志如下:
```sh
[   49.386593] RPC:    49 __rpc_execute flags=0x80
[   49.631584] RPC:    49 call_transmit (status 0)
[   49.696061] RPC:    49 setting alarm for 20000 ms
[   69.745721] RPC:    49 call_status (status -110)
[   69.747284] RPC:    49 call_timeout (minor)
[   69.752302] RPC:    49 call_transmit (status 0)
[   69.771959] RPC:    49 setting alarm for 30000 ms
[   99.952647] RPC:    49 call_status (status -110)
[   99.954153] RPC:    49 call_timeout (minor)
[   99.959084] RPC:    49 call_transmit (status 0)
[   99.979495] RPC:    49 setting alarm for 40000 ms
[  140.400818] RPC:    49 call_status (status -110)
[  140.402356] RPC:    49 call_timeout (major)
[  140.403783] lockd: server localhost not responding, still trying
```

大约90+秒超时打印`lockd: server localhost not responding, still trying`。

nfs client会不断重发请求，直到用户态退出进程。

## 构造tcp连接断开 {#reproduce-tcp-disconnect}

[`nfs-lock.c`](https://github.com/chenxiaosonggithub/blog/blob/master/course/nfs/src/nfs-lock.c)修改如下:
```sh
--- a/course/nfs/src/nfs-lock.c
+++ b/course/nfs/src/nfs-lock.c
@@ -68,10 +68,10 @@ int main(int argc, char *argv[]) {
     
     printf("进程 PID=%d 操作文件: %s\n\n", getpid(), filename);
     
-    // 测试初始锁状态
-    printf("测试初始锁状态:\n");
-    test_lock(fd, F_WRLCK, 0, 100);
-    
+    printf("开始休眠，请在server端执行 ifconfig ens2 down\n");
+    sleep(5);
+    printf("休眠结束，将发送lock请求\n");
+
     // 设置写锁 (锁定前100字节)
     printf("\n==> 设置写锁 (0-99字节)\n");
     if (set_lock(fd, F_WRLCK, 0, 100) == -1) {
```

client端操作:
```sh
# client和server不在同一个环境
mount -t nfs -o rw,relatime,vers=3,rsize=262144,wsize=262144,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountvers=3,mountproto=tcp,local_lock=none,_netdev 192.168.53.40:/tmp /mnt
tcpdump --interface=any --buffer-size=20480 -w out.cap
gcc -o nfs-lock nfs-lock.c
date && ./nfs-lock /mnt/file & # Fri Jun 27 19:41:39 CST 2025
```

server端操作:
```sh
# 执行完 ./nfs-lock /mnt/file 后立刻输入
ifconfig ens2 down
# 当client端打印still trying后，再执行下面命令
ifconfig ens2 up
```

如果是要再次测试，可以手动断开tcp连接:
```sh
netstat -tunap | grep ESTABLISHED
apt install -y dsniff
tcpkill -i ens2 host 192.168.53.40 and port 40115 and port 40115 # server ip port
```

`dmesg -T`日志:
```sh
[Fri Jun 27 19:42:45 2025] lockd: server 192.168.53.40 not responding, still trying
[Fri Jun 27 19:43:59 2025] lockd: server 192.168.53.40 OK
```

执行`nfs-lock /mnt/file`命令的时间是`19:41:39`，5秒后`19:41:44` `LOCK Call`的sunrpc请求尝试发出（但未发出），`still trying`的打印大约在60+秒后`19:42:45`。

抓包数据如下，`19:41:44` `LOCK Call`的sunrpc请求尝试发出（但未发出），但这时和server端的`40115`端口的tcp连接还没建立，所以先发出tcp的`SYN`包，但server端的网络关闭，tcp连接一直无法建立，直到`19:42:59` server端网络重新打开，tcp连接才建立成功，紧接着`LOCK Call`的sunrpc请求成功发出，直到`19:43:59` `LOCK Reply`的回复收到才打印`server 192.168.53.40 OK`。

```sh
No.	Time	Source	Destination	Protocol	Length	Info	src port	dst port
11	2025-06-27 19:41:44.044159	192.168.53.214	192.168.53.40	TCP	80	740 → 40115 [SYN] Seq=0 Win=64240 Len=0 MSS=1460 SACK_PERM TSval=3154905536 TSecr=0 WS=128	740	40115
15	2025-06-27 19:41:45.107047	192.168.53.214	192.168.53.40	TCP	80	[TCP Retransmission] 740 → 40115 [SYN] Seq=0 Win=64240 Len=0 MSS=1460 SACK_PERM TSval=3154906599 TSecr=0 WS=128	740	40115
18	2025-06-27 19:41:47.155016	192.168.53.214	192.168.53.40	TCP	80	[TCP Retransmission] 740 → 40115 [SYN] Seq=0 Win=64240 Len=0 MSS=1460 SACK_PERM TSval=3154908647 TSecr=0 WS=128	740	40115
22	2025-06-27 19:41:54.258986	192.168.53.214	192.168.53.214	ICMP	108	Destination unreachable (Host unreachable)	740	40115
...
76	2025-06-27 19:42:46.163028	192.168.53.214	192.168.53.214	ICMP	108	Destination unreachable (Host unreachable)	740	40115
99	2025-06-27 19:42:59.796646	192.168.53.214	192.168.53.40	TCP	80	740 → 40115 [SYN] Seq=0 Win=64240 Len=0 MSS=1460 SACK_PERM TSval=3154981288 TSecr=0 WS=128	740	40115
102	2025-06-27 19:42:59.796807	192.168.53.40	192.168.53.214	TCP	80	40115 → 740 [SYN, ACK] Seq=0 Ack=1 Win=65160 Len=0 MSS=1460 SACK_PERM TSval=3137856369 TSecr=3154981288 WS=128	40115	740
103	2025-06-27 19:42:59.796819	192.168.53.214	192.168.53.40	TCP	72	740 → 40115 [ACK] Seq=1 Ack=1 Win=64256 Len=0 TSval=3154981289 TSecr=3137856369	740	40115
104	2025-06-27 19:42:59.796902	192.168.53.214	192.168.53.40	NLM	248	V4 LOCK Call (Reply In 171) FH:0x3c289931 svid:6 pos:0-100	740	40115
105	2025-06-27 19:42:59.797089	192.168.53.40	192.168.53.214	TCP	72	40115 → 740 [ACK] Seq=1 Ack=177 Win=65024 Len=0 TSval=3137856370 TSecr=3154981289	40115	740
166	2025-06-27 19:43:41.779024	192.168.53.214	192.168.53.40	NLM	248	[RPC retransmission of #104]V4 LOCK Call (Reply In 171) FH:0x3c289931 svid:6 pos:0-100	740	40115
168	2025-06-27 19:43:41.779729	192.168.53.40	192.168.53.214	TCP	72	40115 → 740 [ACK] Seq=1 Ack=353 Win=64896 Len=0 TSval=3137898352 TSecr=3155023271	40115	740
171	2025-06-27 19:43:59.990884	192.168.53.40	192.168.53.214	NLM	112	V4 LOCK Reply (Call In 104) NLM_DENIED_NOLOCKS	40115	740
172	2025-06-27 19:43:59.990927	192.168.53.214	192.168.53.40	TCP	72	740 → 40115 [ACK] Seq=353 Ack=41 Win=64256 Len=0 TSval=3155041483 TSecr=3137916563	740	40115
```

# 代码分析

## NLM操作

这里列出NLM (Network Lock Manager) 协议操作。

nfs client请求:
```c
#define NLMPROC_NULL            0   // 空操作。用于测试服务器是否存活和响应（Ping）
#define NLMPROC_TEST            1   // 测试锁。客户端询问服务器：如果我现在请求这个锁，能成功吗？(非阻塞，仅查询状态)
#define NLMPROC_LOCK            2   // 请求锁。客户端向服务器申请一个文件锁（可以是阻塞或非阻塞）
#define NLMPROC_CANCEL          3   // 取消锁请求。客户端取消之前发出的一个阻塞锁请求（在服务器响应 GRANTED 之前）
#define NLMPROC_UNLOCK          4   // 释放锁。客户端通知服务器释放它持有的一个锁
#define NLMPROC_TEST_RES        11  // 测试锁响应。客户端对服务器发来的 NLMPROC_TEST_MSG 询问做出响应（是否愿意释放/降级自己的锁）
#define NLMPROC_LOCK_RES        12  // 锁请求响应。客户端对服务器发来的 NLMPROC_LOCK_MSG 询问做出响应（是否愿意释放/降级自己的锁）
#define NLMPROC_CANCEL_RES      13  // 取消请求响应。客户端对服务器发来的 NLMPROC_CANCEL_MSG 通知做出响应（确认收到）
#define NLMPROC_UNLOCK_RES      14  // 解锁响应。客户端对服务器发来的 NLMPROC_UNLOCK_MSG 通知做出响应（确认收到）
#define NLMPROC_GRANTED_RES     15  // 锁已授予响应。客户端对服务器发来的 NLMPROC_GRANTED_MSG 通知做出响应（确认收到）。
#define NLMPROC_SHARE           20  // 创建共享保留 (SUN 特定扩展)。客户端在文件上建立一个共享保留（允许多个读者）
#define NLMPROC_UNSHARE         21  // 释放共享保留 (SUN 特定扩展)。客户端释放之前建立的共享保留
#define NLMPROC_NM_LOCK         22  // 非监控锁 (SUN 特定扩展)。请求一个锁，但不需要 statd 监控客户端状态（用于短暂或可安全中断的锁）
#define NLMPROC_FREE_ALL        23  // 释放所有锁。客户端通知服务器释放该客户端持有的所有锁（通常在客户端崩溃后重启或正常关闭时由恢复进程调用）
```

nfs server的请求:
```c
#define NLMPROC_GRANTED         5   // 锁已授予。服务器异步通知客户端：之前请求的一个阻塞锁 (NLMPROC_LOCK) 现在可用了（锁已被授予）
#define NLMPROC_TEST_MSG        6   // 测试锁请求消息。服务器收到 NLMPROC_TEST 请求时，如果需要询问其他持有冲突锁的客户端（通常涉及锁转换），会向该客户端发送此回调
#define NLMPROC_LOCK_MSG        7   // 锁请求消息。服务器收到 NLMPROC_LOCK 请求时，如果需要询问其他持有冲突锁的客户端（通常涉及锁转换），会向该客户端发送此回调
#define NLMPROC_CANCEL_MSG      8   // 取消请求消息。服务器收到 NLMPROC_CANCEL 请求时，如果需要通知之前被询问过 (LOCK_MSG) 的客户端这个取消操作，会发送此回调
#define NLMPROC_UNLOCK_MSG      9   // 解锁消息。服务器收到 NLMPROC_UNLOCK 请求时，如果需要通知之前被询问过 (LOCK_MSG) 的客户端这个解锁操作，会发送此回调
#define NLMPROC_GRANTED_MSG     10  // 锁已授予消息。服务器授予一个锁后（可能通过 GRANTED 或直接授予），如果需要通知之前被询问过 (LOCK_MSG) 的客户端这个锁已被授予他人，会发送此回调
#define NLMPROC_NSM_NOTIFY      16  /* statd callback */
                                    // 状态变更通知。这是 statd 守护进程使用的回调。当 lockd 监测到一个NFS客户端主机崩溃或重启时，
                                    // statd 会通过此RPC通知该主机上的 lockd，触发 lockd 释放该崩溃/重启客户端持有的所有锁 (NLMPROC_FREE_ALL)。
```

## 函数流程

```c
fcntl
  do_fcntl
    fcntl_setlk
      do_lock_file_wait
        vfs_lock_file
          nfs_lock // filp->f_op->lock
            do_setlk
              nfs3_proc_lock
                nlmclnt_proc
                  nlmclnt_lock
                    nlmclnt_call
                    nlmclnt_async_call // 用户态进程退出时执行到这里
```

# 抓包数据分析 {#tcpdump}

`tcp.completeness`字段的每一位:

- 0x01 (1): 看到 SYN (连接发起)
- 0x02 (2): 看到 SYN-ACK (连接响应)
- 0x04 (4): 看到最终的握手 ACK (连接建立完成)
- 0x08 (8): 看到正常的 FIN (连接开始关闭)
- 0x10 (16): 看到 RST (连接被重置)

## 6月19日 {#tcpdump-0619}

wireshark用以下条件过滤数据包:

- `tcp.srcport == 111 || tcp.dstport == 111`
- `tcp.completeness == 3`: 只看到了 SYN 和 SYN-ACK，没有看到建立连接的最终 ACK（连接可能建立失败，或 ACK 丢失未被捕获）
- `tcp.analysis.retransmission`: 重传

正常的三次握手流程如下:
```sh
[SYN] # synchronous，client端主动发
[SYN, ACK] # server端回复
[ACK] # client端确认
```

`02:21:34 ~ 02:22:38`一分钟左右的时间，tcp连接没有建立，nfs server回复了`[SYN, ACK]`且又重传了一次，nfs client没回复:
```sh
No.	Time	Source	Destination	Protocol	Length	Info
74132	2025-06-19 02:21:34.136390	215.1.39.124	215.2.21.62	TCP	74	33306 → 111 [SYN] Seq=0 Win=64240 Len=0 MSS=1460 SACK_PERM TSval=504648252 TSecr=0 WS=128
74133	2025-06-19 02:21:34.136660	215.2.21.62	215.1.39.124	TCP	74	111 → 33306 [SYN, ACK] Seq=0 Ack=1 Win=65160 Len=0 MSS=1460 SACK_PERM TSval=1196359912 TSecr=504648252 WS=128
74135	2025-06-19 02:21:35.154937	215.1.39.124	215.2.21.62	TCP	74	[TCP Retransmission] 33306 → 111 [SYN] Seq=0 Win=64240 Len=0 MSS=1460 SACK_PERM TSval=504649270 TSecr=0 WS=128
74136	2025-06-19 02:21:35.155190	215.2.21.62	215.1.39.124	TCP	74	[TCP Retransmission] 111 → 33306 [SYN, ACK] Seq=0 Ack=1 Win=65160 Len=0 MSS=1460 SACK_PERM TSval=1196360931 TSecr=504648252 WS=128
74153	2025-06-19 02:21:36.186955	215.2.21.62	215.1.39.124	TCP	74	[TCP Retransmission] 111 → 33306 [SYN, ACK] Seq=0 Ack=1 Win=65160 Len=0 MSS=1460 SACK_PERM TSval=1196361963 TSecr=504648252 WS=128
...
75214	2025-06-19 02:22:38.754950	215.1.39.124	215.2.21.62	TCP	74	[TCP Retransmission] 33306 → 111 [SYN] Seq=0 Win=64240 Len=0 MSS=1460 SACK_PERM TSval=504712870 TSecr=0 WS=128
75216	2025-06-19 02:22:38.755191	215.2.21.62	215.1.39.124	TCP	74	[TCP Retransmission] 111 → 33306 [SYN, ACK] Seq=0 Ack=1 Win=65160 Len=0 MSS=1460 SACK_PERM TSval=1196424531 TSecr=504648252 WS=128
```

## 6月22日 {#tcpdump-0622}

wireshark可用以下条件过滤数据包:

- `tcp.srcport == 871 || tcp.dstport == 871`
- `tcp.analysis.retransmission`: 重传

正常的四次挥手流程如下:
```sh
[FIN, ACK] # 这个 ACK 是对历史数据的确认，与挥手本身无关
[FIN, ACK] # 第 2 步（ACK） 和 第 3 步（FIN） 被合并为一个报文
[ACK] # 挥手完成
```

根据以下日志:
```sh
Jun 22 22:55:38 xxxxxxxxxx kernel:[9263358.933594]lockd: server 11.73.24.85 not responding, still trying
```

日志中在`22:55:38`超时，推测出在`22:54:38`左右发起sunrpc请求，但这时tcp连接正在断开。

再根据以下日志:
```sh
Jun 22 22:56:18 xxxxxxxxxx kernel:[9263398.655377]lockd: server 11.73.24.85 0K
```

nfs client收到`LOCK Reply`时打印上面的日志`lockd: server 11.73.24.85 0K`，分析抓包数据可以看出，直到`22:56:17`tcp连接重新建立，`LOCK Call`成功发出。

`22:53:13 ~ 22:56:17`期间，nfs client不断重传`[FIN, ACK]`数据包，nfs server没回复，所以问题出在nfs server端。
```sh
No.	Time	Source	Destination	Protocol	Length	Info
13388	2025-06-22 22:49:12.999433	11.8.68.71	11.73.24.85	TCP	66	[TCP Keep-Alive] 871 → 2052 [ACK] Seq=1296 Ack=241 Win=65280 Len=0 TSval=1220605896 TSecr=1453532233
13389	2025-06-22 22:49:12.999886	11.73.24.85	11.8.68.71	TCP	66	[TCP Keep-Alive ACK] 2052 → 871 [ACK] Seq=241 Ack=1297 Win=64384 Len=0 TSval=1453590835 TSecr=1220544507
...
15720	2025-06-22 22:53:13.639471	11.8.68.71	11.73.24.85	TCP	66	871 → 2052 [FIN, ACK] Seq=1297 Ack=241 Win=65280 Len=0 TSval=1220846533 TSecr=1453766614
15721	2025-06-22 22:53:13.859428	11.8.68.71	11.73.24.85	TCP	66	[TCP Retransmission] 871 → 2052 [FIN, ACK] Seq=1297 Ack=241 Win=65280 Len=0 TSval=1220846753 TSecr=1453766614
...
16310	2025-06-22 22:54:09.319444	11.8.68.71	11.73.24.85	TCP	66	[TCP Retransmission] 871 → 2052 [FIN, ACK] Seq=1297 Ack=241 Win=65280 Len=0 TSval=1220902212 TSecr=1453766614
16915	2025-06-22 22:55:06.279438	11.8.68.71	11.73.24.85	TCP	66	[TCP Retransmission] 871 → 2052 [FIN, ACK] Seq=1297 Ack=241 Win=65280 Len=0 TSval=1220959171 TSecr=1453766614
17561	2025-06-22 22:56:17.959499	11.8.68.71	11.73.24.85	TCP	74	[TCP Port numbers reused] 871 → 2052 [SYN] Seq=0 Win=64240 Len=0 MSS=1460 SACK_PERM TSval=1221030851 TSecr=0 WS=128
17562	2025-06-22 22:56:17.960011	11.73.24.85	11.8.68.71	TCP	74	2052 → 871 [SYN, ACK] Seq=0 Ack=1 Win=65160 Len=0 MSS=1460 SACK_PERM TSval=1454018687 TSecr=1221030851 WS=128
17563	2025-06-22 22:56:17.960038	11.8.68.71	11.73.24.85	TCP	66	871 → 2052 [ACK] Seq=1 Ack=1 Win=64256 Len=0 TSval=1221030851 TSecr=1454018687
17564	2025-06-22 22:56:17.960048	11.8.68.71	11.73.24.85	NLM	290	V4 LOCK Call (Reply In 17566) FH:0xe7823382 svid:224744 pos:0-0
17565	2025-06-22 22:56:17.960290	11.73.24.85	11.8.68.71	TCP	66	2052 → 871 [ACK] Seq=1 Ack=225 Win=65024 Len=0 TSval=1454018688 TSecr=1221030851
17566	2025-06-22 22:56:18.001690	11.73.24.85	11.8.68.71	NLM	106	V4 LOCK Reply (Call In 17564)
```

## 8月25日 {#tcpdump-0825}

wireshark可用以下条件过滤数据包:

- `tcp.srcport == 871 || tcp.dstport == 871`
- `tcp.analysis.retransmission`: 重传

正常的四次挥手流程如下:
```sh
[FIN, ACK] # 这个 ACK 是对历史数据的确认，与挥手本身无关
[FIN, ACK] # 第 2 步（ACK） 和 第 3 步（FIN） 被合并为一个报文
[ACK] # 挥手完成
```

根据以下日志:
```sh
messages:Aug 25 01:11:59 xxxx kernel: [14714673.140100] lockd: server 11.73.24.85 not responding, still trying
```

日志中在`01:11:59`超时，推测出在`01:10:59`左右发起sunrpc请求，但这时tcp连接正在断开。

再根据以下日志:
```sh
messages:Aug 25 01:13:36 xxxx kernel: [14714769.782512] lockd: server 11.73.24.85 OK
```

nfs client收到`LOCK Reply`时打印上面的日志`lockd: server 11.73.24.85 0K`，分析抓包数据可以看出，直到`01:13:36`tcp连接重新建立，`LOCK Call`成功发出。

`01:10:31 ~ 01:12:24`期间，nfs client不断重传`[FIN, ACK]`数据包，nfs server没回复，所以问题出在nfs server端。
```sh
No.	Time	Source	Destination	Protocol	Length	Info
6956	2025-08-25 01:09:35.399439	11.8.68.71	11.73.24.85	TCP	66	[TCP Keep-Alive] 871 → 2052 [ACK] Seq=864 Ack=161 Win=65280 Len=0 TSval=2377194083 TSecr=2610180812
6957	2025-08-25 01:09:35.399904	11.73.24.85	11.8.68.71	TCP	66	[TCP Keep-Alive ACK] 2052 → 871 [ACK] Seq=161 Ack=865 Win=64640 Len=0 TSval=2610239405 TSecr=2376946237
7574	2025-08-25 01:10:31.719473	11.8.68.71	11.73.24.85	TCP	66	871 → 2052 [FIN, ACK] Seq=865 Ack=161 Win=65280 Len=0 TSval=2377250403 TSecr=2610239405
7575	2025-08-25 01:10:31.939428	11.8.68.71	11.73.24.85	TCP	66	[TCP Retransmission] 871 → 2052 [FIN, ACK] Seq=865 Ack=161 Win=65280 Len=0 TSval=2377250623 TSecr=2610239405
7579	2025-08-25 01:10:32.159429	11.8.68.71	11.73.24.85	TCP	66	[TCP Retransmission] 871 → 2052 [FIN, ACK] Seq=865 Ack=161 Win=65280 Len=0 TSval=2377250843 TSecr=2610239405
7590	2025-08-25 01:10:32.589431	11.8.68.71	11.73.24.85	TCP	66	[TCP Retransmission] 871 → 2052 [FIN, ACK] Seq=865 Ack=161 Win=65280 Len=0 TSval=2377251273 TSecr=2610239405
7591	2025-08-25 01:10:33.479427	11.8.68.71	11.73.24.85	TCP	66	[TCP Retransmission] 871 → 2052 [FIN, ACK] Seq=865 Ack=161 Win=65280 Len=0 TSval=2377252163 TSecr=2610239405
7595	2025-08-25 01:10:35.239438	11.8.68.71	11.73.24.85	TCP	66	[TCP Retransmission] 871 → 2052 [FIN, ACK] Seq=865 Ack=161 Win=65280 Len=0 TSval=2377253923 TSecr=2610239405
7605	2025-08-25 01:10:38.679442	11.8.68.71	11.73.24.85	TCP	66	[TCP Retransmission] 871 → 2052 [FIN, ACK] Seq=865 Ack=161 Win=65280 Len=0 TSval=2377257363 TSecr=2610239405
7612	2025-08-25 01:10:45.809435	11.8.68.71	11.73.24.85	TCP	66	[TCP Retransmission] 871 → 2052 [FIN, ACK] Seq=865 Ack=161 Win=65280 Len=0 TSval=2377264493 TSecr=2610239405
7713	2025-08-25 01:10:59.879435	11.8.68.71	11.73.24.85	TCP	66	[TCP Retransmission] 871 → 2052 [FIN, ACK] Seq=865 Ack=161 Win=65280 Len=0 TSval=2377278562 TSecr=2610239405
8212	2025-08-25 01:11:27.399440	11.8.68.71	11.73.24.85	TCP	66	[TCP Retransmission] 871 → 2052 [FIN, ACK] Seq=865 Ack=161 Win=65280 Len=0 TSval=2377306082 TSecr=2610239405
8795	2025-08-25 01:12:24.359433	11.8.68.71	11.73.24.85	TCP	66	[TCP Retransmission] 871 → 2052 [FIN, ACK] Seq=865 Ack=161 Win=65280 Len=0 TSval=2377363041 TSecr=2610239405
9567	2025-08-25 01:13:36.039492	11.8.68.71	11.73.24.85	TCP	74	[TCP Port numbers reused] 871 → 2052 [SYN] Seq=0 Win=64240 Len=0 MSS=1460 SACK_PERM TSval=2377434720 TSecr=0 WS=128
9568	2025-08-25 01:13:36.040007	11.73.24.85	11.8.68.71	TCP	74	2052 → 871 [SYN, ACK] Seq=0 Ack=1 Win=65160 Len=0 MSS=1460 SACK_PERM TSval=2610491592 TSecr=2377434720 WS=128
9569	2025-08-25 01:13:36.040033	11.8.68.71	11.73.24.85	TCP	66	871 → 2052 [ACK] Seq=1 Ack=1 Win=64256 Len=0 TSval=2377434721 TSecr=2610491592
9570	2025-08-25 01:13:36.040042	11.8.68.71	11.73.24.85	NLM	290	V4 LOCK Call (Reply In 9572) FH:0xe9cbe99b svid:376683 pos:0-0
9571	2025-08-25 01:13:36.040292	11.73.24.85	11.8.68.71	TCP	66	2052 → 871 [ACK] Seq=1 Ack=225 Win=65024 Len=0 TSval=2610491592 TSecr=2377434721
9572	2025-08-25 01:13:36.043050	11.73.24.85	11.8.68.71	NLM	106	V4 LOCK Reply (Call In 9570)
```

