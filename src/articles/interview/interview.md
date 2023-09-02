[toc]

# 查看磁盘缓存的文件有哪些

```shell
crash> foreach files -c # 找到每个打开文件的pagecache数量，内核打开的看不到
crash> mount -f # 把所有inode dump出来
crash> files -p <16进制inode地址> # pagecache中page的数量
```