本文章的内容绝大多取材于以下书籍：

>Linux程序设计 第4版 -- [英] Neil Matthew & Richard Stones 著   陈健  宋健建 译

信号是Unix和Linux系统响应某些条件而产生的一个事件。

查看信号列表使用以下命令：

```shell
$ kill -l
```

在我Fedora系统上的输出为：

```shell
 1) SIGHUP       2) SIGINT       3) SIGQUIT      4) SIGILL       5) SIGTRAP
 6) SIGABRT      7) SIGBUS       8) SIGFPE       9) SIGKILL     10) SIGUSR1
11) SIGSEGV     12) SIGUSR2     13) SIGPIPE     14) SIGALRM     15) SIGTERM
16) SIGSTKFLT   17) SIGCHLD     18) SIGCONT     19) SIGSTOP     20) SIGTSTP
21) SIGTTIN     22) SIGTTOU     23) SIGURG      24) SIGXCPU     25) SIGXFSZ
26) SIGVTALRM   27) SIGPROF     28) SIGWINCH    29) SIGIO       30) SIGPWR
31) SIGSYS      34) SIGRTMIN    35) SIGRTMIN+1  36) SIGRTMIN+2  37) SIGRTMIN+3
38) SIGRTMIN+4  39) SIGRTMIN+5  40) SIGRTMIN+6  41) SIGRTMIN+7  42) SIGRTMIN+8
43) SIGRTMIN+9  44) SIGRTMIN+10 45) SIGRTMIN+11 46) SIGRTMIN+12 47) SIGRTMIN+13
48) SIGRTMIN+14 49) SIGRTMIN+15 50) SIGRTMAX-14 51) SIGRTMAX-13 52) SIGRTMAX-12
53) SIGRTMAX-11 54) SIGRTMAX-10 55) SIGRTMAX-9  56) SIGRTMAX-8  57) SIGRTMAX-7
58) SIGRTMAX-6  59) SIGRTMAX-5  60) SIGRTMAX-4  61) SIGRTMAX-3  62) SIGRTMAX-2
63) SIGRTMAX-1  64) SIGRTMAX
```

# 处理信号

可以使用`signal`库函数来处理信号：

```c
#include <signal.h>
// 第二个参数也可以是SIG_IGN(忽略信号)、SIG_DFL(恢复默认行为)
void (*signal(int sig, void (*func)(int)))(int);
```

说实话，我看到上面这个函数的定义也晕，不怕，来个例子就简单了：

```c
#include <signal.h>
#include <stdio.h>
#include <unistd.h>

// 信号处理函数
void ouch(int sig)
{
    printf("我靠！我捕获到一个信号：%d\n\r", sig);
    // 以下语句表示恢复默认行为，也就是下次再按ctr+c就会终止程序
    // 如果要忽略信号，可以使用(void)signal(SIGINT, SIG_IGN);
    (void)signal(SIGINT, SIG_DFL);
}

int main()
{
   	(void)signal(SIGINT, ouch);
    while(1)
    {
        printf("我爱Linux内核，快按ctr+c\n\r");
        sleep(1);
    }
    return 0;
}
```

# 发送信号

如果要向其他进程（当然也可以是自己）发送一个信号，可以使用以下函数：

```c
#include <sys/types.h>
#include <signal.h>
// 发送成功返回0
int kill(pid_t pid, int sig);
```

用户态的闹钟功能就用到了信号：

```c
#include <unistd.h>
unsigned int alarm(unsigned int seconds);
```

pause函数会把进程挂起直到有一个信号出现：

```c
#include <unistd.h>
int pause(void);
```

X/Open和Unix规范推荐了一个更健壮的接口：

```c
#include <signal.h>
int sigaction(int sig, const struct sigaction *act, struct sigaction *oact);

struct sigaction
{
    union
    {   
    	__sighandler_t sa_handler;
    	void (*sa_sigaction) (int, siginfo_t *, void *); 
    }   
    __sigaction_handler;
    __sighandler_t sa_handler;
    __sigset_t sa_mask;
    int sa_flags;
    void (*sa_restorer) (void);
};  

```

# 信号集

信号集操作就不详细讲了，仅列出函数：

```c
#include <signal.h>

int sigaddset(sigset_t *set, int signo);
int sigemptyset(sigset_t *set);
int sigaddset(sigset_t *set);
int sigfillset(sigset_t *set);
int sigdelset(sigset_t *set, int signo);

int sigismember(sigset_t *set, int signo);
int sigprocmask(int how, const sigset_t *set, sigset_t *oset);
int sigpending(sigset_t *set);
int sigsuspend(sigset_t *sigmask);
```

