# 编译内核代码

内核开发环境的安装请参考[《Linux环境安装与配置》](http://chenxiaosong.com/linux/userspace-environment.html)其中内核相关的部分。

用git下载内核代码，仓库链接可以点击[内核网站](https://kernel.org/)上对应版本的`[browse] -> summary`查看：
```sh
git clone https://kernel.googlesource.com/pub/scm/linux/kernel/git/torvalds/linux.git # 国内使用googlesource仓库链接比较快
```

建议新建一个`build`目录，把所有的编译输出存放在这个目录下，注意[`.config`](https://gitee.com/chenxiaosonggitee/blog/blob/master/src/kernel-environment/x86_64/config)文件要放在`build`目录:
```sh
rm build -rf && mkdir build && cp /home/sonvhi/chenxiaosong/code/blog/src/kernel-environment/x86_64/config build/.config
```

编译命令，其中`ARCH`的值为`arch/`目录下相应的架构：
```sh
make ARCH=x86 O=build menuconfig # 交互式地配置内核的编译选项
KNLMKFLGS="-j64" && make ARCH=x86 O=build olddefconfig ${KNLMKFLGS} && make ARCH=x86 O=build bzImage ${KNLMKFLGS} && make ARCH=x86 O=build modules ${KNLMKFLGS} && make ARCH=x86 O=build modules_install INSTALL_MOD_PATH=mod ${KNLMKFLGS}
```

如果报错`Warning: 'make modules_install' requires /sbin/depmod.`，安装所需软件：
```sh
sudo apt-get install kmod -y
```

如果是其他架构，编译命令是：
```sh
make ARCH=i386 O=build bzImage # x86 32bit
# armel, arm eabi(embeded abi) little endian, 传参数用普通寄存器
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi-  O=build zImage
# armhf, arm eabi(embeded abi) little endian hard float, 传参数用fpu的寄存器，浮点运算性能更高
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- O=build zImage
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- O=build Image
make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- O=build Image
```

# 一些额外的补丁

如果你要更方便的使用一些调试的功能，就要加一些额外的补丁。

## `dump_stack()`输出的栈全是问号的解决办法

如果你使用`dump_stack()`输出的栈全是问号，可以 revert 补丁 `f1d9a2abff66 x86/unwind/orc: Don't skip the first frame for inactive tasks`。

主线已经有补丁做了 revert： `230db82413c0 x86/unwind/orc: Fix unreliable stack dump with gcov`。

## 降低编译优化等级

默认的内核编译优化等级太高，用GDB调试时不太方便，有些函数语句被优化了，无法打断点，这时就要降低编译优化等级。

可以在[src/kernel-environment/x86_64](https://gitee.com/chenxiaosonggitee/blog/tree/master/src/kernel-environment/x86_64)目录下选择对应版本的补丁，更多详细的内容请查看[《GDB调试Linux内核》](http://chenxiaosong.com/kernel/kernel-gdb.html)。
