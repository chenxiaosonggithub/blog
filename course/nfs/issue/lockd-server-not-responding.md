# 问题描述

4.19内核打印:
```sh
lockd: server xx.xx.xx.xx not responding, still trying
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

# 构造

构造内核打印`lockd: server xx.xx.xx.xx not responding, still trying`。

## 内核修改

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

## 用户态程序

`test.c`:
```c
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>

// 设置文件锁的函数
int set_lock(int fd, int type, off_t offset, off_t len) {
    struct flock lock;
    
    // 设置锁结构
    lock.l_type = type;       // 锁类型: F_RDLCK, F_WRLCK, F_UNLCK
    lock.l_whence = SEEK_SET; // 相对文件开始处
    lock.l_start = offset;    // 锁区偏移量
    lock.l_len = len;         // 锁区长度
    lock.l_pid = getpid();    // 进程ID
    
    // 尝试设置锁 (F_SETLKW 会阻塞等待)
    if (fcntl(fd, F_SETLKW, &lock) == -1) {
        perror("fcntl(F_SETLKW) failed");
        return -1;
    }
    printf("加锁: 区域 [%ld, %ld] 已被 PID=%d 的 %s 锁锁定\n",
            offset, offset + len - 1, lock.l_pid,
            (lock.l_type == F_WRLCK) ? "写锁" : "读锁");
    return 0;
}

// 测试锁状态的函数
void test_lock(int fd, int type, off_t offset, off_t len) {
    struct flock lock;
    
    lock.l_type = type;
    lock.l_whence = SEEK_SET; // 相对文件开始处
    lock.l_start = offset;
    lock.l_len = len;
    lock.l_pid = getpid();
    
    if (fcntl(fd, F_GETLK, &lock) == -1) {
        perror("fcntl(F_GETLK) failed");
        return;
    }
    
    if (lock.l_type == F_UNLCK) {
        printf("锁测试: 区域 [%ld, %ld] 可以加锁\n", offset, offset + len - 1);
    } else {
        printf("锁测试: 区域 [%ld, %ld] 已被 PID=%d 的 %s 锁锁定\n",
               offset, offset + len - 1, lock.l_pid,
               (lock.l_type == F_WRLCK) ? "写锁" : "读锁");
    }
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "用法: %s <文件名>\n", argv[0]);
        exit(EXIT_FAILURE);
    }
    
    const char *filename = argv[1];
    int fd;
    
    // 打开文件 (读写模式)
    if ((fd = open(filename, O_RDWR | O_CREAT, 0644)) == -1) {
        perror("打开文件失败");
        exit(EXIT_FAILURE);
    }
    
    printf("进程 PID=%d 操作文件: %s\n\n", getpid(), filename);
    
    // 测试初始锁状态
    printf("测试初始锁状态:\n");
    test_lock(fd, F_WRLCK, 0, 100);
    
    // 设置写锁 (锁定前100字节)
    printf("\n==> 设置写锁 (0-99字节)\n");
    if (set_lock(fd, F_WRLCK, 0, 100) == -1) {
        close(fd);
        exit(EXIT_FAILURE);
    }
    
    // 测试自己的锁
    printf("\n测试自己的锁:\n");
    test_lock(fd, F_RDLCK, 0, 50);  // 尝试读锁
    test_lock(fd, F_WRLCK, 50, 50); // 尝试写锁
    
    // 测试重叠区域
    printf("\n测试重叠区域:\n");
    test_lock(fd, F_WRLCK, 90, 20); // 重叠区域 (90-109)
    
    // 测试非重叠区域
    printf("\n测试非重叠区域:\n");
    test_lock(fd, F_WRLCK, 100, 50); // 非重叠区域 (100-149)
    
    // 持有锁一段时间
    printf("\n==> 持有锁 10 秒...\n");
    sleep(10);
    
    // 释放锁
    printf("\n==> 释放锁\n");
    set_lock(fd, F_UNLCK, 0, 100);
    
    // 设置读锁 (锁定50-149字节)
    printf("\n==> 设置读锁 (50-149字节)\n");
    if (set_lock(fd, F_RDLCK, 50, 100) == -1) {
        close(fd);
        exit(EXIT_FAILURE);
    }
    
    // 测试读锁
    printf("\n测试读锁:\n");
    test_lock(fd, F_RDLCK, 50, 50);  // 测试读锁区域
    test_lock(fd, F_WRLCK, 50, 50);  // 尝试写锁会失败
    
    printf("\n==> 持有读锁 5 秒...\n");
    sleep(5);
    
    // 释放所有锁
    set_lock(fd, F_UNLCK, 50, 100);
    
    close(fd);
    return 0;
}
```

## 测试步骤和结果

```sh
mount -t nfs -o rw,relatime,vers=3,rsize=262144,wsize=262144,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountvers=3,mountproto=tcp,local_lock=none,_netdev localhost:/tmp /mnt
echo something > /mnt/file # 创建文件
gcc -o test test.c
echo 0xFFFF > /proc/sys/sunrpc/nfs_debug # NFSDBG_ALL
echo 0x7fff > /proc/sys/sunrpc/rpc_debug # RPCDBG_ALL
./test /mnt/file
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

