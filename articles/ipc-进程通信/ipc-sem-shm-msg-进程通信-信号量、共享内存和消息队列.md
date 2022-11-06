信号量、共享内存和消息队列，最初由AT&T System V.2版本的Unix引入，所以被称为System V IPC（Inter-Process Communication）。

本文章的内容绝大多取材于以下书籍：

>深入Linux内核-第3版 -- DANIEL P.BOVET & MARCO CESATI 著   陈莉君 张琼声  张宏伟 译
>
>Linux程序设计 第4版 -- [英] Neil Matthew & Richard Stones 著   陈健  宋健建 译

# 信号量

检查系统中信号量的状态，可以使用：

```shell
$ ipcs -s
# key        semid      owner      perms      nsems
```

删除信号量：

```shell
$ ipcrm -s semid
```

信号量函数：

```c
#include <sys/sem.h>
// 创建一个新信号量或取得一个已有信号量的键，返回标识符
// key: 非0整数，用于不同进程访问同一个信号量。值为IPC_PRIVATE时只有创建者进程才能访问（但很少使用）
// num_sems: 信号量数目，一般取1
// sem_flags: 与open函数标志相似。IPC_CREAT(创建新的)、IPC_EXCL（唯一的，如果已存在返回错误）
int semget(key_t key, int num_sems, int sem_flags);
// 改变信号量的值
// sem_id: semget的返回值（信号量标识符）
// num_sem_ops: sem_ops数组大小
int semop(int sem_id, struct sembuf *sem_ops, size_t num_sem_ops);
struct sembuf
{
    short sem_num;// 信号量编号，一般取0（使用一组信号量时不为0）
    short sem_op;// 需要改变的值，-1为P操作（等待信号量变为可用），1为V操作（发送信号表示信号量可用）
    short sem_flg;// 通常为SEM_UNDO,表示进程终止时系统自动释放该进程持有的信号量
};
// 直接控制信号量信息
// sem_id: semget的返回值（信号量标识符）
// sem_num: 一般取0，表示第一个也唯一的一个信号量
// command: 将要采取的动作，SETVAL第一次使用时把信号量初始化为已知的值（通过union semun.val设置），IPC_RMID删除信号量标识符
// 第四个参数: union semun
int semctl(int sem_id, int sem_num, int command, ...);
union semun
{
    int val;
    struct semid_ds *buf;
    unsigned shor *array;
};
```

# 共享内存

查看共享内存状态：

```shell
$ ipcs -m
# key        shmid      owner      perms      bytes      nattch     status 
```

删除共享内存：

```shell
$ ipcrm -m shmid
```

共享内存函数：

```c
#include <sys/shm.h>
// 创建共享内存,返回标识符
// key: 非0整数，用于不同进程访问同一个共享内存标识符。值为IPC_PRIVATE时只有创建者进程才能访问（在某些Linux系统中并非私有）
// size: 共享的内存容量，单位：Byte
// shmflg: 与open函数标志相似。IPC_CREAT(创建新的)
int shmget(key_t key, size_t size, int shmflg);
// 把shm连接到进程的地址空间，返回第一个字节的指针
// shm_id: shmget的返回值（shm标识符）
// *shm_addr: 共享内存在当前进程中的地址，通常为空指针（表示系统选择共享内存出现的地址）
// shmflg: SHM_RND和shm_addr一起使用（shm_addr不为空指针），SHM_RDONLY使得连续的内存只读
void *shmat(int shm_id, const void *shm_addr, int shmflg);
// 将共享内存从当前进程中分享
int shmdt(const void *shm_addr);
// 共享内存控制
// shm_id: shmget的返回值（shm标识符）
// command: 要采取的动作，IPC_STAT把shmid_ds结构中的数据设置为共享内存的当前关联值，IPC_SET把共享内存的当前关联值设置为shmid_ds的值，IPC_RMID删除共享内存段
// *buf: 结构：共享内存模式、访问权限
int shmctl(int shm_id, int command, struct shmid_ds *buf);
struct shmid_ds
{
    uid_t shm_perm.uid;
    uid_t shm_perm.gid;
    mode_t shm_perm.mode;
};
```



# 消息队列

查看消息队列：

```shell
$ ipcs -q
# key        msqid      owner      perms      used-bytes   messages
```

删除消息队列：

```shell
$ ipcrm -q msqid
```

消息队列函数：

```c
#include <sys/msg.h>
// 创建和访问一个消息队列
// key: 非0整数，用于不同进程访问同一个消息队列标识符。值为IPC_PRIVATE时只有创建者进程才能访问（在某些Linux系统中并非私有）
// msgflg: 与open函数标志相似。IPC_CREAT(创建新的)
int msgget(key_t key, int msgflg);
// 把消息添加到msq中
// msqid: msgget的返回值（msq标识符）
// msg_ptr: 发送消息的指针， 格式为struct my_msg
// msg_sz: 不包括my_msg.msg_type的长度
// msg_flg: IPC_NOWAIT设置时，如果msq满或到达系统范围的限制值时将立刻返回（不发送消息，返回-1）；IPC_NOWAIT不设置时，发送进程挂起以等待msq不为满
struct my_msg
{
    long int msg_type;// 数据类型
    // 要发送的数据
};
int msgsnd(int msqid, const void *msg_ptr, size_t msg_sz, int msgflg);
// 从msq中获取消息
// msqid: msgget的返回值（msq标识符）
// msg_ptr: 发送消息的指针， 格式为struct my_msg
// msg_sz: 不包括my_msg.msg_type的长度
// msgtype: 为0时获取第一个，不为0时获取相同类型的第一个消息
// msg_flg: IPC_NOWAIT设置时，如果msq为空将立刻返回（不发送消息，返回-1）；IPC_NOWAIT不设置时，进程挂起以等待msq不为空
int msgrcv(int msqid, void *msg_ptr, size_t msg_sz, long int msgtype, int msgflg);
// msq控制
// msqid: msgget的返回值（msq标识符）
// command: 要采取的动作，IPC_STAT把msqid_ds结构中的数据设置为msq的当前关联值，IPC_SET把msq的当前关联值设置为msqid_ds的值，IPC_RMID删除msq
// *buf: 结构：共享内存模式、访问权限
struct msqid_ds
{
    uid_t msg_perm.uid;
    uid_t msg_perm.gid;
    mode_t msg_perm.mode;
};
int msgctl(int msqid, int command, struct msqid_ds *buf);
```

