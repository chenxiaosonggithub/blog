# 1. 源码安装 strace

下载[chenxiaosonggithub/strace](https://github.com/chenxiaosonggithub/strace)，这个仓库是在[strace/strace](https://github.com/strace/strace)的基础上修改而来，添加了一个补丁[fault-inject: inject memory allocate failed error](https://github.com/chenxiaosonggithub/strace/commit/b196eb9fd65f2801c7c72f2c5ef1230e5734769e)。

编译命令如下：
```sh
./bootstrap
mkdir build && cd build
../configure --enable-mpers=no
make
```

# 2. 内核修改

内核代码打上补丁[src/strace-fault-inject/0001-fault-inject-always-print-the-stack.patch](https://github.com/chenxiaosonggithub/blog/blob/master/src/strace-fault-inject/0001-fault-inject-always-print-the-stack.patch)，配置打开文件[src/strace-fault-inject/fault-inject-config.txt](https://github.com/chenxiaosonggithub/blog/blob/master/src/strace-fault-inject/fault-inject-config.txt)中的选项

# 3. 测试

执行以下脚本进行测试：
```sh
for i in `seq 1 100000`
do
    mount_options=<添加挂载选项>
    strace -f -o output.txt -e trace=mount -e inject=mount:when=1:fault=${i} mount -t nfs -o ${mount_options} localhost:s_test /mnt # ${i}表示第几次内存分配注入故障
    umount /mnt
    echo "i = ${i}"
    OUT=`grep -nr 'FAIL-NTH 0/' output.txt`
    if [ -z "${OUT}" ]; then
        bread; # 提前结束
    fi
done
```