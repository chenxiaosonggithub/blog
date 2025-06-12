# 问题描述

4.19内核打印:
```sh
lockd: server xx.xx.xx.xx not responding, still trying
```

需要回答以下问题:

- 核外: ftp哪些请求加锁，哪些请求解锁，怎么加锁？
- 核外: 请求加锁是同步锁还是异步锁怎么判断？ 
- lockd有哪些请求？哪些请求超时会报lockd信息？
- 超时时间参数？
- 重传机制？

# 代码分析

```c

```

