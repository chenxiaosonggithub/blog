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

三台机器，其中KDC全称Key Distribution Center:

- kerberos KDC：kdc.book.vbird：192.168.53.209
- NFS server：server.book.vbird：192.168.53.210
- NFS client：client.book.vbird：192.168.53.211

三台机器都在`/etc/hosts`中添加以下内容:
```sh
192.168.53.209     kdc.book.vbird          kdc
192.168.53.210     server.book.vbird       server
192.168.53.211     client.book.vbird       client
```

## kerberos KDC

### 设置KDC服务器

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

### 建立KDC数据库的主机规则(principal)

在kerberos KDC环境上:
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

如果三个系统上都有一个`test`用户，还可以执行以下命令，但一般我们测试如果只用到`root`用户就不用执行以下命令:
```sh
kadmin.local
kadmin.local:  addprinc test # 要输入两次密码
kadmin.local:  listprincs # 查看
kadmin.local:  exit
```

## nfs server

安装软件:
```sh
yum install -y krb5-workstation pam_krb5
```

设置hostname:
```sh
hostnamectl set-hostname server.book.vbird
```

从KDC复制配置文件:
```sh
scp kdc:/etc/krb5.conf /etc
```

登入 KDC 数据库，并建立本身的票据资料与 client 的票据资料:
```sh
kadmin # 要输入密码
kadmin:  listprincs # 查看
kadmin:  ktadd host/server.book.vbird@BOOK.VBIRD
kadmin:  ktadd nfs/server.book.vbird@BOOK.VBIRD
kadmin:  ktadd -k /root/client.keytab host/client.book.vbird@BOOK.VBIRD
kadmin:  ktadd -k /root/client.keytab nfs/client.book.vbird@BOOK.VBIRD
kadmin:  exit
```

这时，就多出了两个文件:
```sh
ll /etc/krb5.keytab /root/client.keytab
# -rw------- 1 root root 336 May  5 15:28 /etc/krb5.keytab # 权限要是600
# -rw------- 1 root root 336 May  5 15:28 /root/client.keytab
```

使用`klist`命令查看:
```sh
klist -k
  # Keytab name: FILE:/etc/krb5.keytab
  # KVNO Principal
  # ---- --------------------------------------------------------------------------
  #    2 host/server.book.vbird@BOOK.VBIRD
  #    2 host/server.book.vbird@BOOK.VBIRD
  #    2 nfs/server.book.vbird@BOOK.VBIRD
  #    2 nfs/server.book.vbird@BOOK.VBIRD
klist -t /root/client.keytab -k
  # Keytab name: FILE:/root/client.keytab
  # KVNO Timestamp           Principal
  # ---- ------------------- ------------------------------------------------------
  #    2 05/05/2025 15:28:08 host/client.book.vbird@BOOK.VBIRD
  #    2 05/05/2025 15:28:08 host/client.book.vbird@BOOK.VBIRD
  #    2 05/05/2025 15:28:14 nfs/client.book.vbird@BOOK.VBIRD
  #    2 05/05/2025 15:28:14 nfs/client.book.vbird@BOOK.VBIRD
```

在`/etc/exports`文件中添加`sec=krb5p`:
```sh
/tmp/ *(rw,sec=krb5p,no_root_squash,fsid=0)
/tmp/s_test/ *(rw,sec=krb5p,no_root_squash,fsid=1)
/tmp/s_scratch *(rw,sec=krb5p,no_root_squash,fsid=2)
```

启动服务:
```sh
systemctl restart nfs-server
systemctl status nfs-server 
systemctl status rpc-gssd
```

查看导出的目录:
```sh
showmount -e localhost
```

## nfs client

安装软件:
```sh
yum -y install krb5-workstation pam_krb5
```

设置hostname:
```sh
hostnamectl set-hostname client.book.vbird
```

从另外两个环境复制文件，注意一定要先操作nfs server环境，不然复制个卵:
```sh
scp kdc:/etc/krb5.conf /etc # 从kdc复制
scp server:/root/client.keytab /etc/krb5.keytab # 从nfs server复制
ll -Z /etc/krb5.keytab # print any security context of each file
```

查看:
```sh
klist -k
  # Keytab name: FILE:/etc/krb5.keytab
  # KVNO Principal
  # ---- --------------------------------------------------------------------------
  #    2 host/client.book.vbird@BOOK.VBIRD
  #    2 host/client.book.vbird@BOOK.VBIRD
  #    2 nfs/client.book.vbird@BOOK.VBIRD
  #    2 nfs/client.book.vbird@BOOK.VBIRD
```

启动服务（是否必需？）:
```sh
systemctl restart nfs-client.target
systemctl enable nfs-client.target
systemctl status rpc-gssd
```

查看nfs server的导出:
```sh
showmount -e server
```

挂载:
```sh
mount -t nfs -o sec=krb5p server.book.vbird:/ /mnt
mount -t nfs -o sec=krb5p server:/ /mnt # 也可以不写完整的域名
```

## Troubleshooting

按照上面的步骤，没法挂载成功，慢慢折腾吧。

```sh
echo 0xFFFF > /proc/sys/sunrpc/nfs_debug # 打开nfs日志
echo 0x7fff > /proc/sys/sunrpc/rpc_debug # 打开rpc日志
```



