# nfs server环境

## 内核态server搭建 {#kernel-server-environment}

### 步骤

nfs server安装所需软件:
```sh
apt-get install nfs-kernel-server -y # debian
dnf install nfs-utils -y # openeuler
```

nfs server编辑`exportfs`的配置文件`/etc/exports`，配置选项的含义可以通过命令`man 5 exports`查看:
```sh
/tmp/ *(rw,no_root_squash,fsid=0)
/tmp/s_test/ *(rw,no_root_squash,fsid=1)
/tmp/s_scratch *(rw,no_root_squash,fsid=2)
```

或者使用以下命令，具体用法查看`man 8 exportfs`:
```sh
exportfs -i -o fsid=148252,no_root_squash,rw *:/tmp/s_test # 添加
exportfs -u *:/tmp/s_test # 删除
```

执行脚本[nfs-svr-setup.sh](https://gitee.com/chenxiaosonggitee/blog/blob/master/course/nfs/src/nfs-svr-setup.sh)启动nfs server，其中，`rpcbind`（在服务文件`/lib/systemd/system/rpcbind.service`中）负责端口的对应工作（以前叫`portmap`），其他程序请查看`/lib/systemd/system/nfs-server.service`服务文件。

查看支持的nfs版本:
```sh
cat /proc/fs/nfsd/versions
# -2 +3 +4 +4.1 +4.2 # 加号表示支持，减号表示不支持
```

### 软件和配置文件

`/etc/exports`的配置格式如下:
```sh
# 注意不能使用 192.168.122.* 而要使用 192.168.122.0/24
# [分享出去的目录]   [ip/(权限)]             [主机名]         [通配符]
tmp              192.168.122.0/24(ro)   localhost(rw)   *.chenxiaosong.com(ro,sync)
```
详细的配置查看`man 5 exports`，下面介绍几个常用的:

- `rw`可读可写，`ro`只读。
- `sync`写入磁盘，`async`先存放在内存中。
- client账号为root时，默认`root_squash`压缩成`nobody(nfsnobody) `，`no_root_squash`不压缩。
- `all_squash`把所有的用户都压缩成`nobody(nfsnobody)`。
- `anonuid,anongid`设置`nobody(nfsnobody)`对应的uid和gid。
- `nohide`和`crossmnt`: 仅针对v2和v3.
- `fsid=num|root|uuid`: 文件系统标识。

用以下命令查看开了哪些端口:
```sh
netstat -tulnp| grep -E '(rpc|nfs)'
```

以下命令查看rpc状态:
```sh
# -p: 针对ip
rpcinfo -p localhost
# -t: tcp, -u: udp
rpcinfo -t localhost nfs # nfs程序检查软件版本信息（tcp）
```

以下命令查看或操作分享的目录:
```sh
showmount -e localhost # 查看
exportfs # 查看
# -a: 全部，-r: 重新, -u: 取消，-v: 打印
exportfs -arv # 重新分享
exportfs -auv # 全部删除
```

还有两个文件:

- `/var/lib/nfs/etab`: 记录`/etc/exports`配置文件或`exportfs`命令分享出来的目录权限配置值。
- `/var/lib/nfs/xtab`和`/var/lib/nfs/rmtab`: 记录客户端数据。

## 用户态server搭建 {#userspace-server-environment}

[nfs-ganesha的github仓库](https://github.com/nfs-ganesha/nfs-ganesha)。

以fedora为例，安装编译所需依赖软件:
```sh
dnf install -y librgw-devel userspace-rcu-devel libnsl2-devel
```

下载代码编译安装:
```sh
git clone --recursive https://github.com/nfs-ganesha/nfs-ganesha.git
cd nfs-ganesha/
git submodule update --init
rm -rf build_dir; mkdir build_dir
cd build_dir
cmake -DUSE_FSAL_VFS=ON ../src
make -j`nproc`
make install # 日志查看https://gitee.com/chenxiaosonggitee/tmp/blob/master/gnu-linux/nfs/ganesha-install-log.txt
cp ../src/scripts/systemd/nfs-ganesha-lock.service.el8 /usr/lib/systemd/system/nfs-ganesha-lock.service
cp ../src/scripts/systemd/nfs-ganesha.service.el7 /usr/lib/systemd/system/nfs-ganesha.service
```

配置文件的位置在`/etc/ganesha/ganesha.conf`，可以参考[`config_samples`](https://github.com/nfs-ganesha/nfs-ganesha/tree/next/src/config_samples)，
下面示例的配置文件`/etc/ganesha/ganesha.conf`中`/tmp/s_test`挂载的是xfs文件系统:
```sh
EXPORT
{
        Export_Id = 12345;
        Path = /tmp/s_test;
        Pseudo = /;
        Protocols = 3,4;
        Access_Type = RW;
        FSAL {
                # ext4和xfs都可以写VFS
                # todo: 怎么导出其他文件系统，比如tmpfs
                Name = XFS;
        }
}

NFSV4 {
        # 作为设置 idmapper 程序的替代方法
        Allow_Numeric_Owners = true;
        Only_Numeric_Owners = true;
}
```

如果要调试，可以在`/etc/ganesha/ganesha.conf`加上以下配置:
```sh
LOG {
        # Default log level for all components
        Default_Log_Level = DEBUG;
}
```

启动服务:
```sh
systemctl daemon-reload
systemctl start nfs-ganesha
```

查看调试日志:
```sh
journalctl -u nfs-ganesha -b
journalctl -u nfs-ganesha -b --no-pager > log.txt # 重定向到文件
# rm -rf /var/log/journal/* # 日志太多可以清空
```

查看导出的目录:
```sh
showmount -e localhost
```

然后就能正常挂载了。

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



