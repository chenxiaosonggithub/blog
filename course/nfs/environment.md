# nfs server环境

[请查看《nfs server(nfsd)》](https://chenxiaosong.com/course/nfs/nfsd.html)

# nfs client环境

nfs client安装所需软件:
```sh
apt-get install nfs-common -y # debian
dnf install nfs-utils -y # openeuler
```

nfs client挂载（更多挂载选项可以通过命令`man 5 nfs`查看）:
```sh
# nfsv4的根路径是/tmp/，源路径填写相对路径 /s_test 或 s_test
mount -t nfs -o vers=4.0 ${server_ip}:/s_test /mnt
mount -t nfs -o vers=4.1 ${server_ip}:/s_test /mnt
mount -t nfs -o vers=4.2 ${server_ip}:/s_test /mnt
# nfsv3和nfsv2 源路径要写完整的源路径，没有根路径的概念，源路径必须是绝对路径/tmp/s_test
mount -t nfs -o vers=3 ${server_ip}:/tmp/s_test /mnt
# nfsv2, nfs server 需要修改 /etc/nfs.conf 中的 `[nfsd] vers2=y`,但在Debian 11 (bullseye) 上安装的nfs-utils 1.3.3上找不到/etc/nfs.conf
mount -t nfs -o vers=2 ${server_ip}:/tmp/s_test /mnt
```

如果nfs server的exportfs的配置文件`/etc/exports`如下，没有`fsid`选项:
```sh
/tmp/s_test/ *(rw,no_root_squash)
```

这时nfsv4的根路径就是`/`，nfs client挂载nfsv4的命令如下:
```sh
mount -t nfs -o vers=4.0 ${server_ip}:/tmp/s_test /mnt # 或 tmp/s_test
```

要注意的是nfs不能在`/etc/fstab`文件中配置开机挂载，因为那时网络还没启动。