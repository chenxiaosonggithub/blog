本文章的内容绝大多取材于以下书籍：

>深入Linux内核-第3版 -- DANIEL P.BOVET & MARCO CESATI 著   陈莉君 张琼声  张宏伟 译
>
>Linux程序设计 第4版 -- [英] Neil Matthew & Richard Stones 著   陈健  宋健建 译

# 管道

管道只能在相关的程序之间传递数据：

```c
#include <stdio.h>
FILE *popen(const char *command, const char *open_mode);
int pclose(FILE *stream_to_close);
```

底层提供的`pipe`函数不需要启动一个shell来解释请求的命令，提供对读写数据的更多控制：

```c
#include <unistd.h>
// pipe函数的作用是创建一个管道
// 写到 file_descriptor[1]的所有数据都可以从 file_descriptor[0]读回来
// 如把1，2，3顺序写到 file_descriptor[1], 从 file_descriptor[0] 读取到的数据也是1，2，3的顺序
// 使用read和write读写file_descriptor[0]和file_descriptor[1];
int pipe(int file_descriptor[2]);
```

可以使用`dup`和`dup2`系统调用把管道用作标准输入和标准输出：

```c
#include <unistd.h>
// 返回值为新创建的文件描述符
// 创建的新文件描述符与 oldfd 指向同一个文件（或管道），新文件描述符取最小的可用值
// 如果 标准输入描述符0 已经关闭[close(0)]，则调用dup后新的文件描述符就是0
int dup(int oldfd);
// 返回值为新创建的文件描述符
// 新创建的文件描述符数值与newfd相同，或是第一个大于newfd的可用值
int dup2(int oldfd, int newfd);
```

看了以上两个函数的定义晕？不知道怎么用？那就对了，来个例子：

```c
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

int main()
{
    int data_processed;
    int file_pipes[2];
    const char some_data[] = "123";
    pid_t fork_result;
	// 创建管道，file_pipes[0]用于读，file_pipes[1]用于写
    if (pipe(file_pipes) == 0) {
        fork_result = fork();
        if (fork_result == (pid_t)-1) {
            fprintf(stderr, "Fork failure");
            exit(EXIT_FAILURE);
        }   
		// 子进程
        if (fork_result == (pid_t)0) {
            close(0);// 关闭标准输入
            // 执行完dup后，把file_pipes[0]（与管道读取端关联的文件描述符）复制为 文件描述符0（标准输入） 
            dup(file_pipes[0]);
            close(file_pipes[0]);
            close(file_pipes[1]);
            // 执行到这里，只有一个与管道关联的文件描述符，即文件描述符0（标准输入）
            
			// int execlp(const char *file, const char *arg0, ..., (char *)0);
            // execlp()会从PATH 环境变量所指的目录中查找符合参数file的文件名，找到后便执行该文件，然后将第二个(包括第二个)以后的参数当做该文件的argv[0]、argv[1]……，最后一个参数必须用空指针(0或NULL)作结束
            // "od -c"：参数-c相当于-tC（以字符格式输出），把标准输入的内容按16个字符一行，以八进制字码呈现出来（注意要满16个字符才会输出一次）
            execlp("od", "od", "-c", (char *)0);
            exit(EXIT_FAILURE);
        }
        // 父进程
        else {
            close(file_pipes[0]);
            // 向管道写数据
            data_processed = write(file_pipes[1], some_data,
                                   strlen(some_data));
            close(file_pipes[1]);
            printf("%d - wrote %d bytes\n", (int)getpid(), data_processed);
        }   
    }   
    exit(EXIT_SUCCESS);
}
```

编译执行后会有什么结果？自己尝试。

# 命名管道：FIFO

如果要在不相关的进程之间交换数据，需要使用命名管道。

可以在命令行下创建命名管道：

``` shell
$ mkfifo filename
```

在程序中，调用函数创建命名管道：

``` c
#include <sys/types.h>
#include <sys/stat.h>
int mkfifo(const char *filename, mode_t mode);
int mknode(const char *filename, mode_t mode | S_IFIFO, (dev_t)0);
```

有四种方式打开FIFO文件：

```c
// 阻塞，直到另一个进程以写方式打开同一个FIFO
open(const char *path, O_RDONLY);
// 不阻塞
open(const char *path, O_RDONLY | O_NONBLOCK);
// 阻塞，直到另一个进程以读方式打开同一个FIFO
open(const char *path, O_WRONLY);
// 不阻塞
open(const char *path, O_WRONLY | O_NONBLOCK);
```

