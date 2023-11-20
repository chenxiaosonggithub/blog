[点击这里跳转到陈孝松个人主页:chenxiaosong.com](http://chenxiaosong.com/)。

我刚开始是做用户态开发的，习惯了利用gdb调试来理解那些写得不好的用户态代码，尤其是公司内部一些不开源的用户态代码。

转方向做了Linux内核开发后，也尝试用qemu+gdb来调试内核代码。

要特别说明的是，内核的大部分代码是很优美的，并不需要太依赖qemu+gdb这一调试手段，更建议通过阅读代码来理解。但某些写得不好的内核模块如果利用qemu+gdb将能使我们更快的熟悉代码。

这里只介绍`x86_64`下的qemu+gdb调试，其他cpu架构以此类推，只需要做些小改动。

# 1. 编译选项和补丁

首先确保修改以下配置：
```sh
CONFIG_DEBUG_SECTION_MISMATCH=y # 防止内联
CONFIG_DEBUG_INFO=y # 调试信息
CONFIG_DEBUG_KERNEL=y # 调试信息
CONFIG_FRAME_POINTER=y # Makefile 中选择GCC编译选项
CONFIG_GDB_SCRIPTS=y # gdb python
CONFIG_RANDOMIZE_BASE = n # 关闭地址随机化
```

可以使用我常用的[x86_64的内核配置文件](https://github.com/chenxiaosonggithub/blog/blob/master/src/kernel-environment/x86_64/config)。

gcc的编译选项`O1`优化等级不需要修改就可以编译通过。`O0`优化等级无法编译（尝试`CONFIG_JUMP_LABEL=n`还是不行），要修改汇编代码，有兴趣的朋友可以和我一直尝试。`Og`优化等级经过修改可以编译通过，`x86_64`合入目录[`src/kernel-environment/x86_64`](https://github.com/chenxiaosonggithub/blog/tree/master/src/kernel-environment/x86_64)对应版本的补丁。

# 2. qemu命令选项

qemu启动虚拟机时，要添加以下几个选项：
```sh
-append "nokaslr ..." # 防止地址随机化，编译内核时关闭配置 CONFIG_RANDOMIZE_BASE
-S # 挂起 gdbserver
-gdb tcp::5555 # 端口5555, 使用 -s 选项表示用默认的端口1234
-s # 相当于 -gdb tcp::1234 默认端口1234，不建议用，最好指定端口
```

# 3. GDB命令

启动GDB：
```sh
gdb build/vmlinux
```

进入GDB界面后：
```sh
(gdb) target remote:5555 # 对应qemu命令中的-gdb tcp::5555
(gdb) b func_name # 普通断点
(gdb) hb func_name # 硬件断点，有些函数普通断点不会停下, 如: nfs4_atomic_open，降低优化等级后没这个问题
```

gdb命令的用法和用户态程序的调试大同小异。

# 4. GDB辅助调试功能

使用内核提供的[GDB辅助调试功能](https://www.kernel.org/doc/Documentation/dev-tools/gdb-kernel-debugging.rst)可以更方便的调试内核：
```sh
echo "set auto-load safe-path /" > ~/.gdbinit # 设置自动加载共享库文件的安全路径
echo "source ${HOME}/.gdb-linux/vmlinux-gdb.py" >> ~/.gdbinit
# 曾经碰到过最新的版本有问题，5.10版本可以，但5.10编译出来的可能无法调试最新版本的代码
make O=build scripts_gdb # 在内核仓库目录下执行
rm -rf ${HOME}/.gdb-linux/
mkdir ${HOME}/.gdb-linux/
cp build/scripts/gdb/* ${HOME}/.gdb-linux/ -rf # 在内核仓库目录下执行
cp scripts/gdb/vmlinux-gdb.py ${HOME}/.gdb-linux/ # 在内核仓库目录下执行
sed -i '/sys.path.insert/s/^/# /' ${HOME}/.gdb-linux/vmlinux-gdb.py # 将sys.path.insert所在的行注释掉
sed -i '/sys.path.insert/a\sys.path.insert(0, "'${HOME}'/.gdb-linux")' ${HOME}/.gdb-linux/vmlinux-gdb.py # 插入 sys.path.insert(0, "${HOME}/.gdb-linux")
```

重新启动GDB就可以使用GDB辅助调试功能：
```sh
(gdb) apropos lx # 查看有哪些命令
(gdb) p $lx_current().pid # 打印断点所在进程的进程id
(gdb) p $lx_current().comm # 打印断点所在进程的进程名
```

# 5. GDB打印结构体偏移

结构体定义有时候加了很多宏判断，再考虑到内存对齐之类的因素，通过看代码很难确定结构体中某一个成员的偏移大小，使用gdb来打印就很直观。

如结构体`struct cifsFileInfo`:
```c
struct cifsFileInfo {
    struct list_head tlist;
    ...
    struct tcon_link *tlink;
    ...
    char *symlink_target;
};
```

想要确定`tlink`的偏移，可以使用以下命令：
```sh
gdb ./cifs.ko # ko文件或vmlinux
(gdb) p &((struct cifsFileInfo *)0)->tlink
```

`(struct cifsFileInfo *)0`：这是将整数值 0 强制类型转换为指向 struct cifsFileInfo 类型的指针。这实际上是创建一个指向虚拟内存地址 0 的指针，该地址通常是无效的。这是一个计算偏移量的技巧，因为偏移量的计算不依赖于结构体的实际实例。

`(0)->tlink`: 指向虚拟内存地址 0 的指针的成员`tlink`。

`&(0)->tlink`: tlink的地址，也就是偏移量。

# 6. ko模块

使用`gdb vmlinux`启动gdb后，如果调用到ko模块里的代码，这时候就不能直接对ko模块的代码进行打断点之类的操作，因为找不到对应的符号。

这时就要把符号加入进来。首先，查看被调试的qemu虚拟机中的各个段地址：
```sh
cd /sys/module/ext4/sections/ # ext4 为模块名
cat .text .data .bss # 输出各个段地址
```

在gdb窗口中加载ko文件：
```sh
add-symbol-file <ko文件位置> <text段地址> -s .data <data段地址> -s .bss <bss段地址>
```

这时就能开心的对ko模块中的代码进行打断点之类的操作了。
