[点击这里跳转到陈孝松个人主页:chenxiaosong.com](http://chenxiaosong.com/)。

# 1. 导出vmcore

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

启动crash：
```sh
# 启动crash
crash vmlinux vmcore

# 加载ko模块：
crash> help mod # 帮助命令
crash> mod -s <module name> <ko path> # 加载
crash> mod -d <module name> # 删除
```

# 2. 查看崩溃在哪一行

```sh
# 查看内核日志
crash> dmesg | less
...
BUG: unable to handle kernel NULL pointer dereference at 0000000000000080
...
RIP: 0010:_raw_spin_lock+0x1d/0x35
...
 nfs_inode_add_request+0x1cc/0x5b8

# 在内核仓库目录下执行的shell命令，在docker ubuntu2204环境中打印不出具体行号，原因暂时母鸡
./scripts/faddr2line build/vmlinux nfs_inode_add_request+0x1cc/0x5b8 # 或者把vmlinux替换成ko文件
nfs_inode_add_request+0x1cc/0x5b8:
nfs_have_writebacks at include/linux/nfs_fs.h:548 (discriminator 3)
(inlined by) nfs_inode_add_request at fs/nfs/write.c:774 (discriminator 3)

# 反汇编指定地址的代码，以查看其汇编指令, -l 选项用于在反汇编时显示源代码行号（如果可用）
crash> dis -l ffffffff81c0a939
/home/sonvhi/chenxiaosong/code/4.19-stable/build/../include/linux/nfs_fs.h: 248
0xffffffff81c0a939 <nfs_inode_add_request+460>: lea    -0xe0(%rbp),%r14

crash> bt # 查看崩溃的栈
[exception RIP: _raw_spin_lock+29] RIP: ffffffff836c0e4a
...
[ffff8880b1ab7a78] nfs_inode_add_request at ffffffff81c0a939
[ffff8880b1ab7ab0] nfs_setup_write_request at ffffffff81c14312

# 查找指定地址的符号信息
crash> sym ffffffff836c0e4a # [exception RIP: _raw_spin_lock+29] RIP: ffffffff836c0e4a
ffffffff836c0e4a (T) _raw_spin_lock+29 /home/sonvhi/chenxiaosong/code/4.19-stable/build/../arch/x86/include/asm/atomic.h: 194
crash> sym ffffffff81c0a939 # [ffff8880b1ab7a78] nfs_inode_add_request at ffffffff81c0a939
ffffffff81c0a939 (t) nfs_inode_add_request+460 /home/sonvhi/chenxiaosong/code/4.19-stable/build/../include/linux/nfs_fs.h: 248
```

`faddr2line`脚本解析是的`nfs_inode_add_request`函数中的774行，也就是发生问题的`spin_lock(&mapping->private_lock)`之后的一行，看来解析还是有一点点的不准，不过不要紧，我们再看`dmesg`命令中的日志`RIP: 0010:_raw_spin_lock+0x1d/0x35`，就能确定确实是崩溃在773行`spin_lock(&mapping->private_lock)`。

另外，由crash的`dis -l`和`sym`命令定位到`include/linux/nfs_fs.h: 248`的`NFS_I()`函数，这就不知道为什么了，麻烦知道的朋友联系我。

# 3. 分析栈帧数据

## 3.1. 确认`page->mapping`为`NULL`

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
  FREE / [ALLOCATED] # 中括号[ALLOCATED]代表已分配
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
  spin_lock(lock = &mapping->private_lock) // static __always_inline void spin_lock(spinlock_t *lock)
    raw_spin_lock(&lock->rlock)
      _raw_spin_lock(&lock->rlock) // void __lockfunc _raw_spin_lock(raw_spinlock_t *lock)
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

x86_64下整数参数使用的寄存器依次为：RDI，RSI，RDX，RCX，R8，R9，`_raw_spin_lock`只有一个参数，从栈中可以看到`RDI: 0000000000000002`，这个值是怎么来的呢？估计要看`nfs_inode_add_request`和`_raw_spin_lock`的反汇编。

## 3.2. `nfs_inode_add_request`的第一个参数`struct inode *inode`

我们再看一次跟`inode`有关的栈帧数据:
```sh
crash> bt -FF
#10 [ffff8880b1ab79c0] async_page_fault at ffffffff8380119e
    [exception RIP: _raw_spin_lock+29]
    ...
    ffff8880b1ab79c8: [ffff8880b6a43ec8:nfs_inode_cache(198:serial-getty@ttyS0.service)] ffffea0002cd5900 
    ...
    ffff8880b1ab79e8: [ffff8880b6a43ec8:nfs_inode_cache(198:serial-getty@ttyS0.service)] 0000000000000080 
    ...
#11 [ffff8880b1ab7a78] nfs_inode_add_request at ffffffff81c0a939
    ...
    ffff8880b1ab7aa0: [ffff888107060a80:kmalloc-128] [ffff8880b6a43ec8:nfs_inode_cache(198:serial-getty@ttyS0.service)] 
    ...
```

注意地址`[ffff8880b6a43ec8:nfs_inode_cache]`并不是`struct nfs_inode`的首地址，而是`struct inode`的首地址，使用`kmem`命令解析：
```sh
crash> kmem ffff8880b6a43ec8
...
  FREE / [ALLOCATED]
  [ffff8880b6a43cf0] # 这才是struct nfs_inode的首地址
...

crash> struct nfs_inode ffff8880b6a43cf0 -ox
struct nfs_inode {
  ...
  [ffff8880b6a43ec8] struct inode vfs_inode; # 这就是struct page的地址
}
SIZE: 0x430

crash> struct inode ffff8880b6a43ec8 -x
struct inode {
  ...
  i_mapping = 0xffff8880b6a44040,
  ...
```

`inode->i_mapping`的值和`nfs_setup_write_request`栈中的一个数据一样，以后再研究他们之间的关系吧：
```sh
#12 [ffff8880b1ab7ab0] nfs_setup_write_request at ffffffff81c14312
    ...
    ffff8880b1ab7ad8: [ffff8880b6a44040:nfs_inode_cache(198:serial-getty@ttyS0.service)] 000000000000000f 
```
