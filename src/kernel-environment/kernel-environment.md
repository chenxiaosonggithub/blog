# 

# 编译

```shell
rm build -rf && mkdir build && cp /home/sonvhi/chenxiaosong/code/blog/src/kernel-environment/x86_64/config build/.config
make O=build olddefconfig -j64 && make O=build bzImage -j64 && make O=build modules -j64 && make O=build modules_install INSTALL_MOD_PATH=mod -j64
```

# dump_stack()输出全是问号的解决办法

revert 补丁 `f1d9a2abff66 x86/unwind/orc: Don't skip the first frame for inactive tasks`。

主线已经做了 revert： `230db82413c0 x86/unwind/orc: Fix unreliable stack dump with gcov`。