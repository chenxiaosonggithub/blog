本文章介绍Linux的静态库和动态库，以及两个版本动态库的处理。

文件`main.c`：

```c
#include <stdio.h>
#include <add.h>
#include <sub.h>

int main()
{
    int res = 0;
    int a = 3, b = 2;
    res = add(a, b);
    printf("\n\r%d + %d = %d\n\r", a, b, res);
    res = sub(a, b);
    printf("\n\r%d - %d = %d\n\r", a, b, res);
    return 0;
}
```

文件`add/add.c`：

```c
#include <stdio.h>

int add(int a, int b)
{
    return a + b;
}
```

文件`add/add.h`：

```c
int add(int a, int b);
```

文件`sub/sub.c`：

```c
#include <stdio.h>

int sub(int a, int b)
{
    return a - b;
}
```

文件`sub/sub.h`：

```c
int sub(int a, int b);
```

# 静态库

文件`makefile`：

```makefile
all:
	gcc -c add/add.c
	# -r 将文件插入备存文件中（向库中添加模块，若模块已存在则替换）
	# -c 建立备存文件（创建库文件）
	# -s 若备存文件中包含了对象模式，可利用此参数建立备存文件的符号表（生成一个目标文件索引）
	ar -rcs add.a add.o
	gcc -c sub/sub.c
	ar -rcs sub.a sub.o
	gcc -c main.c -Iadd -Isub
	gcc main.o add.a sub.a
```
查看静态库中的模块清单的命令为：
```shell
# -t 显示备存文件中所包含的文件（查看静态库中的模块清单）
$ ar -t add.a
```
# 动态库
文件`makefile`：
```makefile
all:
	# -fPIC 是编译选项，PIC是 Position Independent Code 的缩写，表示要生成位置无关的代码，这是动态库需要的特性
	# -shared 是链接选项，告诉gcc生成动态库而不是可执行文件
	# 等价于以下两条命令：
	# gcc -c -fPIC add/add.c
	# gcc -shared -o libadd.so add.o
	gcc -fPIC -shared -o libadd.so add/add.c
	gcc -fPIC -shared -o libsub.so sub/sub.c
	#gcc -c main.c -Iadd -Isub
	# 其中-ladd表示要链接libadd.so。
	# -L.表示搜索要链接的库文件时包含当前路径
	gcc main.c -L. -ladd -lsub -Iadd -Isub
```

执行`./a.out`会得到以下错误：

```shell
./a.out: error while loading shared libraries: libadd.so: cannot open shared object file: No such file or directory
```

Linux是通过 `/etc/ld.so.cache` 文件搜寻要链接的动态库的。
而 `/etc/ld.so.cache` 是 ldconfig 程序读取 `/etc/ld.so.conf` 文件生成的。
（注意， `/etc/ld.so.conf` 中并不必包含 `/lib` 和 `/usr/lib`，`ldconfig`程序会自动搜索这两个目录）

如果我们把 `libadd.so` 所在的路径添加到 `/etc/ld.so.conf` 中，再以root权限运行 `ldconfig` 程序，更新 `/etc/ld.so.cache` ，`./a.out`运行时，就可以找到 `libmax.so`。

这里我们使用更简单的方法，就是为`a.out`指定 `LD_LIBRARY_PATH`。

```shell
$ LD_LIBRARY_PATH=. ./a.out
```

# 两个版本动态库

文件add2.c：

```c
#include <stdio.h>

int var = 7;

int add(int a, int b)
{
    return a + b + 1;
}
```

文件`makefile`：

```makefile
all:
	# -fPIC是编译选项，PIC是 Position Independent Code 的缩写，表示要生成位置无关的代码，这是动态库需要的特性
	# -shared是链接选项，告诉gcc生成动态库而不是可执行文件
	# 等价于以下两条命令：
	# gcc -c -fPIC add/add.c
	# gcc -shared -o libadd.so add.o
	gcc -fPIC -shared -o libadd.so add/add.c
	gcc -fPIC -shared -o libadd2.so add/add2.c
	gcc -fPIC -shared -o libsub.so sub/sub.c
	#gcc -c main.c -Iadd -Isub
	# 其中-ladd表示要链接libadd.so。
	# -L.表示搜索要链接的库文件时包含当前路径
	gcc main.c -L. -ladd2 -ladd -lsub -Iadd -Isub
```

执行`LD_LIBRARY_PATH=. ./a.out`后可以发现，`add`函数是`libadd2.so`库的函数，也就是先加载的库。

如果要同时使用两个版本的动态库，可以使用以下办法，`main.c`文件修改成：

```c
#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>

typedef int (*func)(int, int);

/*
mode是打开方式，其值有多个，不同操作系统上实现的功能有所不同，在linux下，按功能可分为三类：
1、解析方式
    RTLD_LAZY：在dlopen返回前，对于动态库中的未定义的符号不执行解析（只对函数引用有效，对于变量引用总是立即解析）。
    RTLD_NOW： 需要在dlopen返回前，解析出所有未定义符号，如果解析不出来，在dlopen会返回NULL，错误为：: undefined symbol: xxxx.......
2、作用范围，可与解析方式通过“|”组合使用。
    RTLD_GLOBAL：动态库中定义的符号可被其后打开的其它库解析。
    RTLD_LOCAL： 与RTLD_GLOBAL作用相反，动态库中定义的符号不能被其后打开的其它库重定位。如果没有指明是RTLD_GLOBAL还是RTLD_LOCAL，则缺省为RTLD_LOCAL。
3、作用方式
    RTLD_NODELETE： 在dlclose()期间不卸载库，并且在以后使用dlopen()重新加载库时不初始化库中的静态变量。这个flag不是POSIX-2001标准。
    RTLD_NOLOAD： 不加载库。可用于测试库是否已加载(dlopen()返回NULL说明未加载，否则说明已加载），也可用于改变已加载库的flag，如：先前加载库的flag为RTLD_LOCAL，用dlopen(RTLD_NOLOAD|RTLD_GLOBAL)后flag将变成RTLD_GLOBAL。这个flag不是POSIX-2001标准。
    RTLD_DEEPBIND：在搜索全局符号前先搜索库内的符号，避免同名符号的冲突。这个flag不是POSIX-2001标准。
*/
// void *dlopen(const char *pathname, int mode);
// void *dlsym(void *handler, const char *symbol);
// int dlclose(void *handler);

int main()
{
    int res = 0;
    int a = 3, b = 2;
    void *dlhandler_add;
    void *dlhandler_add2;
    func add = NULL;
    func add2 = NULL;
    int *var_ptr = NULL;

    // 打开libadd.so库
    // RTLD_LAZY: 在dlopen返回前，对于动态库中的未定义的符号不执行解析（只对函数引用有效，对于变量引用总是立即解析）
    // RTLD_NOW： 需要在dlopen返回前，解析出所有未定义符号，如果解析不出来，在dlopen会返回NULL，错误为：: undefined symbol: xxxx.......
    dlhandler_add = dlopen("./libadd.so", RTLD_LAZY);
    if(dlhandler_add == NULL)
    {
        fprintf(stderr,"%s\n", dlerror());
        exit(-1);
    }
    //dlerror();

    // 打开libadd2.so库
    dlhandler_add2 = dlopen("./libadd2.so", RTLD_LAZY);
    if(dlhandler_add2 == NULL)
    {
        fprintf(stderr,"%s\n", dlerror());
        exit(-1);
    }
    //dlerror();

    // libadd.so库的add函数
    add = dlsym(dlhandler_add, "add");
    res = add(a, b);
    printf("\n\rlibadd, %d + %d = %d\n\r", a, b, res);

    // libadd2.so库的add函数
    add2 = dlsym(dlhandler_add2, "add");
    res = add2(a, b);
    printf("\n\rlibadd2, %d + %d = %d\n\r", a, b, res);

    // libadd2.so库的var变量地址
    var_ptr = (int *)dlsym(dlhandler_add2, "var");
    printf("\n\rlibadd2, var = %d\n\r", *var_ptr);

    // 关闭库
    dlclose(dlhandler_add);
    dlclose(dlhandler_add2);

    return 0;
}
```

文件`makefile`：

```makefile
all:
	# -fPIC是编译选项，PIC是 Position Independent Code 的缩写，表示要生成位置无关的代码，这是动态库需要的特性
	# -shared是链接选项，告诉gcc生成动态库而不是可执行文件
	# 等价于以下两条命令：
	# gcc -c -fPIC add/add.c
	# gcc -shared -o libadd.so add.o
	gcc -fPIC -shared -o libadd.so add/add.c
	gcc -fPIC -shared -o libadd2.so add/add2.c
	gcc main.c -ldl
```



