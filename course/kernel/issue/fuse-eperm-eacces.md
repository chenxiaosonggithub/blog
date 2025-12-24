# 问题描述

编译[`fuse_test/`](https://gitee.com/chenxiaosonggitee/tmp/tree/master/gnu-linux/kernel/fuse_test)下的文件并测试:
```sh
g++ fuse.cpp fuse_test.cpp -o fuse_test -lpthread
mkdir -p /tmp/source
mkdir -p /tmp/dest
./fuse_test /tmp/source /tmp/dest &
touch /tmp/dest/testfile
```

麒麟v11上报错`-EPERM`或`-EACCES`（不确定是哪个）。

