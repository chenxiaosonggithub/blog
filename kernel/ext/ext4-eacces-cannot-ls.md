[toc]

EXT4 构造返回 -EACCESS， 且 ls 没有列出。

```shell
touch file1
touch file2
touch file3

debugfs /dev/sda
imap /
inode_dump /
blocks /
stat /


dd if=/dev/sda of=output bs=1 skip=37892096 count=256
cp output input # 更改 file2 的 rec_len 字段为 0
dd if=input  of=/dev/sda bs=1 seek=37892096 count=256

echo 3 > /proc/sys/vm/drop_caches
```