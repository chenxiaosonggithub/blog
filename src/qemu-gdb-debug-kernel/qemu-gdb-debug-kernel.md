[点击这里跳转到陈孝松个人主页:chenxiaosong.com](http://chenxiaosong.com/)。

我刚开始是做用户态开发的，习惯了利用gdb调试来理解那些写得不好的用户态代码，尤其是公司内部一些不开源的用户态代码。

转方向做了Linux内核开发后，也尝试用qemu+gdb来调试内核代码。

要特别说明的是，内核的大部分代码是很优美的，并不需要太依赖qemu+gdb这一调试手段，更建议通过阅读代码来理解。但某些写得不好的内核模块如果利用qemu+gdb将能使我们更快的熟悉代码。

这里只介绍x86_64下的qemu+gdb调试，其他cpu架构以此类推，只需要做些小改动。

# 内核编译

首先确保修改以下配置：
```shell
CONFIG_DEBUG_SECTION_MISMATCH=y # 防止内联
CONFIG_DEBUG_INFO=y
CONFIG_DEBUG_KERNEL=y
CONFIG_FRAME_POINTER=y # Makefile 中选择GCC编译选项
CONFIG_GDB_SCRIPTS=y # gdb python
CONFIG_RANDOMIZE_BASE = n
```

`O1`优化等级不需要修改就可以编译通过。

`O0`优化等级无法编译（尝试`CONFIG_JUMP_LABEL=n`还是不行），要修改汇编代码，有兴趣的朋友可以和我一直尝试。

`Og`优化等级经过修改可以编译通过，主线合入补丁[`src/qemu-gdb-debug-kernel/x86_64-gcc-build-Og.patch`](https://github.com/chenxiaosonggithub/blog/blob/master/src/qemu-gdb-debug-kernel/x86_64-gcc-build-Og.patch)，5.10合入补丁[`src/qemu-gdb-debug-kernel/x86_64-5.10-gcc-build-Og.patch`](https://github.com/chenxiaosonggithub/blog/blob/master/src/qemu-gdb-debug-kernel/x86_64-5.10-gcc-build-Og.patch)。


