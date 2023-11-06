[点击这里跳转到陈孝松个人主页:chenxiaosong.com](http://chenxiaosong.com/)。

# 1. 编译内核代码

内核开发环境的安装请参考[《Linux环境安装与配置》](http://chenxiaosong.com/linux/userspace-environment.html)其中内核相关的部分。

用git下载内核代码，仓库链接可以点击[内核网站](https://kernel.org/)上对应版本的`[browse] -> summary`查看：
```sh
git clone https://kernel.googlesource.com/pub/scm/linux/kernel/git/torvalds/linux.git # 国内使用googlesource仓库链接比较快
```

建议新建一个`build`目录，把所有的编译输出存放在这个目录下，注意[`.config`](https://github.com/chenxiaosonggithub/blog/blob/master/src/kernel-environment/x86_64/config)文件要放在`build`目录:
```sh
rm build -rf && mkdir build && cp /home/sonvhi/chenxiaosong/code/blog/src/kernel-environment/x86_64/config build/.config
```

编译命令：
```sh
make O=build menuconfig # 交互式地配置内核的编译选项
KNLMKFLGS="-j64" make O=build olddefconfig ${KNLMKFLGS} && make O=build bzImage ${KNLMKFLGS} && make O=build modules ${KNLMKFLGS} && make O=build modules_install INSTALL_MOD_PATH=mod ${KNLMKFLGS}
```

# 2. 一些额外的补丁

如果你要更方便的使用一些调试的功能，就要加一些额外的补丁。

## 2.1. `dump_stack()`输出的栈全是问号的解决办法

如果你使用`dump_stack()`输出的栈全是问号，可以 revert 补丁 `f1d9a2abff66 x86/unwind/orc: Don't skip the first frame for inactive tasks`。

主线已经有补丁做了 revert： `230db82413c0 x86/unwind/orc: Fix unreliable stack dump with gcov`。

## 2.2. 降低编译优化等级

默认的内核编译优化等级太高，用GDB调试时不太方便，有些函数语句被优化了，无法打断点，这时就要降低编译优化等级。

可以在[src/kernel-environment/x86_64](https://github.com/chenxiaosonggithub/blog/tree/master/src/kernel-environment/x86_64)目录下选择对应版本的补丁，更多详细的内容可以查看本文档中GDB调试的章节。

# 3. GDB调试内核代码

我刚开始是做用户态开发的，习惯了利用gdb调试来理解那些写得不好的用户态代码，尤其是公司内部一些不开源的用户态代码。

转方向做了Linux内核开发后，也尝试用qemu+gdb来调试内核代码。

要特别说明的是，内核的大部分代码是很优美的，并不需要太依赖qemu+gdb这一调试手段，更建议通过阅读代码来理解。但某些写得不好的内核模块如果利用qemu+gdb将能使我们更快的熟悉代码。

这里只介绍`x86_64`下的qemu+gdb调试，其他cpu架构以此类推，只需要做些小改动。

## 3.1. 编译选项和补丁

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

## 3.2. qemu命令选项

qemu启动虚拟机时，要添加以下几个选项：
```sh
-append "nokaslr ..." # 防止地址随机化，编译内核时关闭配置 CONFIG_RANDOMIZE_BASE
-S # 挂起 gdbserver
-gdb tcp::5555 # 端口5555, 使用 -s 选项表示用默认的端口1234
-s # 相当于 -gdb tcp::1234 默认端口1234，不建议用，最好指定端口
```

## 3.3. GDB命令

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

## 3.4. GDB辅助调试功能

使用内核提供的[GDB辅助调试功能](https://www.kernel.org/doc/Documentation/dev-tools/gdb-kernel-debugging.rst)可以更方便的调试内核：
```sh
echo "set auto-load safe-path /" > ~/.gdbinit # 设置自动加载共享库文件的安全路径
echo "source /home/sonvhi/.gdb-linux/vmlinux-gdb.py" >> ~/.gdbinit # /home/sonvhi 是我的家目录
# !!! 使用5.10版本执行make scripts_gdb
make scripts_gdb # 在 linux 仓库下执行，注意最新的版本可能有问题，5.10版本肯定可以
mkdir ${HOME}/.gdb-linux/
cp scripts/gdb/* ${HOME}/.gdb-linux/ -rf
vim ${HOME}/.gdb-linux/vmlinux-gdb.py # 改成 sys.path.insert(0, "/home/sonvhi/.gdb-linux")
```

重新启动GDB就可以使用GDB辅助调试功能：
```sh
(gdb) apropos lx # 帮助命令
(gdb) p $lx_current().pid # 打印断点所在进程的进程id
(gdb) p $lx_current().comm # 打印断点所在进程的进程名
```

## 3.5. GDB打印结构体偏移

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

## 3.6. ko模块

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

# 4. vmcore分析

首先你需要有个发生panic时的vmcore，有些发行版默认发生oops时不会panic，需要修改配置（注意这样修改重启后会还原）：
```sh
echo 1 > /proc/sys/kernel/panic_on_oops # 注意不能用 vim 编辑
cat /proc/sys/kernel/panic_on_oops # 确认是否生效
```

按`ctrl + a c`打开QEMU控制台，使用以下命令导出vmcore：
```sh
(qemu) dump-guest-memory /your_path/vmcore
```

以[4.19 nfs_updatepage空指针解引用问题](http://chenxiaosong.com/nfs/4.19-null-ptr-deref-in-nfs_updatepage.html)构造复现导出的vmcore为例，说明vmcore的分析过程。

启动crash，查看崩溃在哪一行：
```sh
# 启动crash
crash vmlinux vmcore

# 查看内核日志
crash> dmesg | less
...
BUG: unable to handle kernel NULL pointer dereference at 0000000000000080
...
RIP: 0010:_raw_spin_lock+0x1d/0x35
...
 nfs_inode_add_request+0x1cc/0x5b8

# 在内核仓库目录下执行的shell命令，在docker环境中打印不出具体行号，原因暂时母鸡
./scripts/faddr2line build/vmlinux nfs_inode_add_request+0x1cc/0x5b8 # 或者把vmlinux替换成ko文件
nfs_inode_add_request+0x1cc/0x5b8:
nfs_have_writebacks at include/linux/nfs_fs.h:548 (discriminator 3)
(inlined by) nfs_inode_add_request at fs/nfs/write.c:774 (discriminator 3)

# 查看崩溃的栈，输出的栈包含
# [exception RIP: _raw_spin_lock+29] RIP: ffffffff836c0e4a
# #8 [ffff8880b1ab7a78] nfs_inode_add_request at ffffffff81c0a939
# #9 [ffff8880b1ab7ab0] nfs_setup_write_request at ffffffff81c14312
crash> bt

# 反汇编指定地址的代码，以查看其汇编指令, -l 选项用于在反汇编时显示源代码行号（如果可用）
crash> dis -l ffffffff81c0a939
/home/sonvhi/chenxiaosong/code/4.19-stable/build/../include/linux/nfs_fs.h: 248
0xffffffff81c0a939 <nfs_inode_add_request+460>: lea    -0xe0(%rbp),%r14

# 查找指定地址的符号信息
crash> sym ffffffff836c0e4a
ffffffff836c0e4a (T) _raw_spin_lock+29 /home/sonvhi/chenxiaosong/code/4.19-stable/build/../arch/x86/include/asm/atomic.h: 194
crash> sym ffffffff81c0a939
ffffffff81c0a939 (t) nfs_inode_add_request+460 /home/sonvhi/chenxiaosong/code/4.19-stable/build/../include/linux/nfs_fs.h: 248
```

`faddr2line`脚本解析是的`nfs_inode_add_request`函数中的774行，也就是发生问题的`spin_lock(&mapping->private_lock)`之后的一行，看来解析还是有一点点的不准，不过不要紧，我们再看`dmesg`命令中的日志`RIP: 0010:_raw_spin_lock+0x1d/0x35`，就能确定确实是崩溃在773行`spin_lock(&mapping->private_lock)`。

另外，由crash的`dis -l`和`sym`命令定位到`include/linux/nfs_fs.h: 248`的`NFS_I()`函数，这就不知道为什么了，麻烦知道的朋友联系我。

如果crash要加载ko模块：
```sh
crash> help mod # 帮助命令
crash> mod -s <module name> <ko path> # 加载
crash> mod -d <module name> # 删除
```

查看`nfs_inode_add_request`函数中的堆栈：
```sh
# -F[F]：类似于 -f，不同之处在于当适用时以符号方式显示堆栈数据；如果堆栈数据引用了 slab cache 对象，将在方括号内显示 slab cache 的名称；在 ia64 架构上，将以符号方式替代参数寄存器的内容。如果输入 -F 两次，并且堆栈数据引用了 slab cache 对象，将同时显示地址和 slab cache 的名称在方括号中。
crash> bt -FF
#10 [ffff8880b1ab79c0] async_page_fault at ffffffff8380119e
    [exception RIP: _raw_spin_lock+29]
    ...
    RDX: 0000000000000001  RSI: ffff8880b5760000  RDI: 0000000000000002
    ...
#11 [ffff8880b1ab7a78] nfs_inode_add_request at ffffffff81c0a939
    ffff8880b1ab7a80: ffffea0002cd5900 [ffff8880b0cf0b00:nfs_page] 
    ...

crash> bt -F
#11 [ffff8880b1ab7a78] nfs_inode_add_request at ffffffff81c0a939
    ffff8880b1ab7a80: ffffea0002cd5900 [nfs_page]

# -f：显示堆栈帧中包含的所有数据；此选项可用于确定传递给每个函数的参数；在 ia64 架构上，将显示参数寄存器的内容。
crash> bt -f
#11 [ffff8880b1ab7a78] nfs_inode_add_request at ffffffff81c0a939
    ffff8880b1ab7a80: ffffea0002cd5900 ffff8880b0cf0b00
```

注意`[ffff8880b0cf0b00:nfs_page]`并不一定是`nfs_page`结构体的起始地址，有可能是中间某个变量的地址，要用`kmem`命令查看：
```sh
crash> kmem ffff8880b0cf0b00
...
  FREE / [ALLOCATED]
  [ffff8880b0cf0b00]
...
```

只是这里刚好是起始地址，使用地址`ffff8880b0cf0b00`来查看结构体`nfs_page`中的数据：
```sh
crash> struct nfs_page ffff8880b0cf0b00 -x
struct nfs_page {
  ...
  wb_page = 0xffffea0002cd5900,
  ...
}
```

再查看`wb_page = 0xffffea0002cd5900`中的数据：
```sh
struct page {
  ...
  {
    {
      ...
      mapping = 0x0,
      ...
    },
  }
}
```

再看发生崩溃的地方：
```c
nfs_inode_add_request
  spin_lock(&mapping->private_lock) // static __always_inline void spin_lock(spinlock_t *lock)
    #define raw_spin_lock(lock)     _raw_spin_lock(lock)
      void __lockfunc _raw_spin_lock(raw_spinlock_t *lock)
```

再解析结构体偏移：
```sh
# 首先已知 struct address_space *mapping = 0
crash> struct address_space -ox
struct address_space {
  ...
  # 这里正好和dmesg日志中对应上：BUG: unable to handle kernel NULL pointer dereference at 0000000000000080
  [0x80] spinlock_t private_lock;
  ...
}
SIZE: 0xa8

crash> struct spinlock_t -ox
typedef struct spinlock {
        union {
  [0x0]     struct raw_spinlock rlock;
        };
} spinlock_t;
SIZE: 0x4
```

再查看`_raw_spin_lock`的反汇编：
```sh
crash> dis _raw_spin_lock
0xffffffff836c0e2d <_raw_spin_lock>:    nopl   0x0(%rax,%rax,1) [FTRACE NOP]
0xffffffff836c0e32 <_raw_spin_lock+5>:  push   %rbx
0xffffffff836c0e33 <_raw_spin_lock+6>:  mov    %rdi,%rbx
0xffffffff836c0e36 <_raw_spin_lock+9>:  mov    $0x4,%esi
0xffffffff836c0e3b <_raw_spin_lock+14>: call   0xffffffff817f4d19 <kasan_check_write>
0xffffffff836c0e40 <_raw_spin_lock+19>: mov    $0x0,%eax
0xffffffff836c0e45 <_raw_spin_lock+24>: mov    $0x1,%edx
0xffffffff836c0e4a <_raw_spin_lock+29>: lock cmpxchg %edx,(%rbx)
0xffffffff836c0e4e <_raw_spin_lock+33>: test   %eax,%eax
0xffffffff836c0e50 <_raw_spin_lock+35>: jne    0xffffffff836c0e54 <_raw_spin_lock+39>
0xffffffff836c0e52 <_raw_spin_lock+37>: pop    %rbx
0xffffffff836c0e53 <_raw_spin_lock+38>: ret    
0xffffffff836c0e54 <_raw_spin_lock+39>: mov    %eax,%esi
0xffffffff836c0e56 <_raw_spin_lock+41>: mov    %rbx,%rdi
0xffffffff836c0e59 <_raw_spin_lock+44>: call   0xffffffff813a704d <__pv_queued_spin_lock_slowpath>
0xffffffff836c0e5e <_raw_spin_lock+49>: xchg   %ax,%ax
0xffffffff836c0e60 <_raw_spin_lock+51>: jmp    0xffffffff836c0e52 <_raw_spin_lock+37>
```

x86_64下整数参数使用的寄存器依次为：RDI，RSI，RDX，RCX，R8，R9，`_raw_spin_lock`只有一个参数，从栈中可以看到`RDI: 0000000000000002`，这个值是怎么来的呢？