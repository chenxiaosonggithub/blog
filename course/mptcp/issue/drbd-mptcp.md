<!--
v1: https://patchwork.kernel.org/project/mptcp/cover/cover.1747904572.git.tanggeliang@kylinos.cn/
v11: https://patchwork.kernel.org/project/mptcp/cover/cover.1757723270.git.tanggeliang@kylinos.cn/
-->

DRBD 类似磁盘阵列的RAID 1（镜像），只不过 RAID 1 是在同一台电脑内，而 DRBD 是透过网络。

准备试试让DRBD支持mptcp。

# drbd环境

- [官方网站](http://www.drbd.org)
- [ubuntu文档](https://documentation.ubuntu.com/server/how-to/high-availability/install-drbd/index.html)

安装软件:
```sh
dnf install drbd-utils -y
apt install drbd-utils -y
```

两台机器上分别设置hostname:
```sh
hostnamectl set-hostname drbd01.chenxiaosong.com # 192.168.53.209
hostnamectl set-hostname drbd02.chenxiaosong.com # 192.168.53.210
```

两台机器都在`/etc/hosts`中添加以下内容:
```sh
192.168.53.209     drbd01.chenxiaosong.com       drbd01
192.168.53.210     drbd02.chenxiaosong.com       drbd02
```

两台机器的`/etc/drbd.conf`配置文件如下（参考`/usr/share/doc/drbd-utils/drbd.conf.example`）:
```sh
global { usage-count no; }
common { syncer { rate 100M; } }
resource r0 {
        protocol C;
        startup {
                wfc-timeout  15;
                degr-wfc-timeout 60;
        }
        net {
                cram-hmac-alg sha1;
                shared-secret "secret";
        }
        # 要写完整的域名，只写 drbd01 有问题
        on drbd01.chenxiaosong.com {
                device /dev/drbd0;
                disk /dev/sda;
                address 192.168.53.209:7788;
                meta-disk internal;
        }
        on drbd02.chenxiaosong.com {
                device /dev/drbd0;
                disk /dev/sda;
                address 192.168.53.210:7788;
                meta-disk internal;
        }
}
```

两台机器上都执行以下命令:
```sh
wipefs -a /dev/sda
drbdadm create-md r0
systemctl start drbd.service
```

`drbd01`上:
```sh
drbdadm -- --overwrite-data-of-peer primary all # primary host, 与secondary host（也就是 drbd02）同步
drbdadm status
  # r0 role:Primary
  #   disk:UpToDate
  #   peer role:Secondary
  #     replication:Established peer-disk:UpToDate
```

`drbd02`上查看进度:
```sh
watch -n1 cat /proc/drbd # ctrl+c取消
drbdadm status
  # r0 role:Primary
  #   disk:UpToDate
  #   peer role:Secondary
  #     replication:Established peer-disk:UpToDate
```

`drbd01`上:
```sh
mkfs.ext2 /dev/drbd0
mount /dev/drbd0 /mnt
echo something > /mnt/file # 写点东西
umount /mnt
drbdadm secondary r0 # drbd01 设置成 secondary
```

`drbd02`提升为primary:
```sh
drbdadm primary r0
mount /dev/drbd0 /mnt
cat /mnt/file
```

我们看到在`drbd01`上写入的数据在`drbd02`上能看到，说明备份成功。

# 内核修改

```sh
--- a/drivers/block/drbd/drbd_receiver.c
+++ b/drivers/block/drbd/drbd_receiver.c
@@ -620,7 +620,7 @@ static struct socket *drbd_try_connect(struct drbd_connection *connection)

        what = "sock_create_kern";
        err = sock_create_kern(&init_net, ((struct sockaddr *)&src_in6)->sa_family,
-                              SOCK_STREAM, IPPROTO_TCP, &sock);
+                              SOCK_STREAM, IPPROTO_MPTCP, &sock);
        if (err < 0) {
                sock = NULL;
                goto out;
@@ -715,7 +715,7 @@ static int prepare_listen_socket(struct drbd_connection *connection, struct acce

        what = "sock_create_kern";
        err = sock_create_kern(&init_net, ((struct sockaddr *)&my_addr)->sa_family,
-                              SOCK_STREAM, IPPROTO_TCP, &s_listen);
+                              SOCK_STREAM, IPPROTO_MPTCP, &s_listen);
        if (err) {
                s_listen = NULL;
                goto out;
```

# 调试

启动drbd服务后，报错的日志[`drbd-mptcp-log.txt`](https://gitee.com/chenxiaosonggitee/tmp/blob/master/gnu-linux/mptcp/drbd-mptcp-log.txt)。

用`ss -ieMl`命令查看:
```sh
State   Recv-Q  Send-Q   Local Address:Port  Peer Address:Port
LISTEN  3       5       192.168.53.209:7788       0.0.0.0:*
```

再用`ss -iaM`命令查看:
```sh
State     Recv-Q   Send-Q    Local Address:Port      Peer Address:Port
FIN-WAIT  0        0        192.168.53.209:33097   192.168.53.210:7788
FIN-WAIT  0        0        192.168.53.209:54917   192.168.53.210:7788
ESTAB     960      0        192.168.53.209:7788     192.168.53.1:58511
FIN-WAIT  0        0        192.168.53.209:39051   192.168.53.210:7788
FIN-WAIT  0        0        192.168.53.209:38833   192.168.53.210:7788
ESTAB     0        0        192.168.53.209:51037   192.168.53.210:7788
LISTEN    1        5        192.168.53.209:7788           0.0.0.0:*
```

可以看到，mptcp连接已经建立，但是`sock_recvmsg()`返回错误:
```sh
[ 1003.627149] drbd r0: sock_recvmsg returned -11
```

`sock_recvmsg()`返回错误码`-EAGAIN`。

还需要进一步定位。

# 代码分析

```c
drbd_recv
  drbd_recv_short
  drbd_err(connection, "sock_recvmsg returned %d\n", rv)
```

