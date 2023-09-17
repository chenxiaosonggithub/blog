[toc]

# 查看磁盘缓存的文件有哪些

```shell
crash> foreach files -c # 找到每个打开文件的pagecache数量，内核打开的看不到
crash> mount -f # 把所有inode dump出来
crash> files -p <16进制inode地址> # pagecache中page的数量
```

# 文件系统写放大


文件系统写放大（File System Write Amplification）是一种与固态硬盘（SSD）存储技术密切相关的概念。它指的是在写入数据到SSD时，实际写入存储介质的数据量要比应用程序要写入的数据量大，因为SSD内部的工作机制引起了额外的写入操作。文件系统写放大的存在可能会导致SSD的性能下降，缩短其寿命，并浪费存储空间。

文件系统写放大的主要原因包括以下几点：

块擦除操作：SSD内部的存储单元以块的形式进行擦除和写入。当需要更新某个块内的数据时，文件系统通常需要先将整个块擦除，然后重新写入已更新的数据，即使只有一小部分数据发生了变化。

写入日志（Write Logging）：一些文件系统会维护写入日志，以确保数据的一致性和可恢复性。写入日志会导致额外的写入操作，增加写放大效应。

TRIM操作：SSD需要进行TRIM操作以清除已删除数据的块。这也会引起额外的写入。

为了减小文件系统写放大，可以采取以下措施：

使用TRIM：确保SSD支持并启用TRIM功能，以便及时清除无用的块。

使用块对齐（Alignment）：确保文件系统和应用程序对齐写入操作，以最小化不必要的块擦除。

增加页面大小（Page Size）：某些SSD允许在块内增加页面大小，以减小写入时的擦除操作。

选择文件系统：不同的文件系统对写放大的影响不同，因此选择合适的文件系统可以降低写放大效应。

通过以上方法，可以最小化文件系统写放大，提高SSD的性能，延长其寿命，并减少存储空间的浪费。

# strace 故障注入

```shell
for i in `seq 1 100000`
do
    strace -f -o output.txt -e trace=mount -e inject=mount:when=1:fault=${i} mount -t nfs -o ... localhost:s_test /mnt # ${i}表示第几次内存分配注入故障
    umount /mnt
    echo "i = ${i}"
    OUT=`grep -nr 'FAIL-NTH 0/' output.txt`
    if [ -z "${OUT}" ]; then
        bread;
    fi
done
```