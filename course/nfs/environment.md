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

# krb5

参考[鸟哥《利用 kerberos 提供票據加密》](https://linux.vbird.org/events/kerberos.php)。

三台机器:

- kerberos KDC：kdc.book.vbird：192.168.53.37
- NFS server：server.book.vbird：192.168.53.38
- NFS client：client.book.vbird：192.168.53.211

三台机器都在`/etc/hosts`中添加以下内容:
```sh
192.168.53.37      kdc.book.vbird          kdc
192.168.53.38      server.book.vbird       server
192.168.53.211     client.book.vbird       client
```

## 设置KDC服务器

安装软件:
```sh
yum install -y krb5-server krb5-workstation krb5-libs
```

设置hostname:
```sh
hostnamectl set-hostname kdc.book.vbird
```

修改`/etc/krb5.conf`:
```sh
[libdefaults]
    ...
    default_realm = BOOK.VBIRD
    ...
    dns_lookup_kdc = false

[realms]
BOOK.VBIRD = {
    kdc = kdc.book.vbird
    admin_server = kdc.book.vbird
}

[domain_realm]
    .book.vbird = BOOK.VBIRD
    book.vbird = BOOK.VBIRD
```

初始化 KDC 数据库:
```sh
ll /var/kerberos/krb5kdc/
  # -rw------- 1 root root   22 Feb 11 08:00 kadm5.acl
  # -rw------- 1 root root  743 Feb 11 08:00 kdc.conf

kdb5_util create -s # 要输入两次密码

ll /var/kerberos/krb5kdc/
  # -rw------- 1 root root   22 Feb 11 08:00 kadm5.acl
  # -rw------- 1 root root  743 Feb 11 08:00 kdc.conf
  # -rw------- 1 root root 8192 May  5 14:25 principal
  # -rw------- 1 root root 8192 May  5 14:25 principal.kadm5
  # -rw------- 1 root root    0 May  5 14:25 principal.kadm5.lock
  # -rw------- 1 root root    0 May  5 14:25 principal.ok
```

修改`/var/kerberos/krb5kdc/kadm5.acl`，放行全部的管理员名单:
```sh
*/admin@BOOK.VBIRD      *
```

KDC创建 `root/admin`:
```sh
kadmin.local
kadmin.local:  ?  # 查看所有命令
kadmin.local:  addprinc root/admin # 输入两次密码
kadmin.local:  listprincs # 查看
kadmin.local:  exit # 退出
```

启动服务:
```sh
systemctl start kadmin krb5kdc
systemctl enable kadmin krb5kdc
systemctl status kadmin krb5kdc
netstat -tlunp | grep -E "kadmin|krb5kdc"
  # tcp        0      0 0.0.0.0:749             0.0.0.0:*               LISTEN      1751/kadmind
  # tcp        0      0 0.0.0.0:88              0.0.0.0:*               LISTEN      1753/krb5kdc
  # tcp        0      0 0.0.0.0:464             0.0.0.0:*               LISTEN      1751/kadmind
  # tcp6       0      0 :::749                  :::*                    LISTEN      1751/kadmind # 让 KDC client 可以登入
  # tcp6       0      0 :::88                   :::*                    LISTEN      1753/krb5kdc # 主要端口
  # tcp6       0      0 :::464                  :::*                    LISTEN      1751/kadmind
  # udp        0      0 0.0.0.0:88              0.0.0.0:*                           1753/krb5kdc
  # udp        0      0 0.0.0.0:464             0.0.0.0:*                           1751/kadmind
  # udp6       0      0 :::88                   :::*                                1753/krb5kdc
  # udp6       0      0 :::464                  :::*                                1751/kadmind
```

测试:
```sh
kadmin # 要输入刚刚设置的密码
kadmin:  listprincs # 执行有输出就是成功了
kadmin:  exit
```

## 建立 KDC 资料库的主机规则(principal)

```sh
kadmin.local
# -randkey host/: 增加 KDC 用户端主机
kadmin.local:  addprinc -randkey host/kdc.book.vbird
kadmin.local:  addprinc -randkey host/server.book.vbird
kadmin.local:  addprinc -randkey host/client.book.vbird
kadmin.local:  listprincs # 可以看到刚刚添加的三个规则
# -randkey nfs/: 增加可用 NFS 服务，只有server和client要用到nfs
kadmin.local:  addprinc -randkey nfs/server.book.vbird
kadmin.local:  addprinc -randkey nfs/client.book.vbird
kadmin.local:  listprincs # 查看刚刚添加的两个
kadmin.local:  exit
```

如果三个系统上都有一个`test`用户，还可以执行以下命令，但一般我们用不到:
```sh
kadmin.local
kadmin.local:  addprinc test # 要输入两次密码
kadmin.local:  listprincs # 查看
kadmin.local:  exit
```

## nfs server

```sh
hostnamectl set-hostname server.book.vbird
```

## nfs server

```sh
hostnamectl set-hostname client.book.vbird
```

