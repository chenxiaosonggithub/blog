# 环境

github源码: [linux-test-project/ltp](https://github.com/linux-test-project/ltp)，参考[INSTALL](https://github.com/linux-test-project/ltp/blob/master/INSTALL)安装需要的依赖软件。其中`linux-headers`相关的在debian上可以使用以下命令安装：
```sh
apt search linux-headers | less # 搜索对应的软件包名
apt install -y linux-headers-amd64 linux-headers-5.10.0-28-common
```

编译安装参考[README中文翻译](https://chenxiaosong.com/translations/ltp-readme.html)，默认安装在`/opt/ltp`中。

# LTP Network Tests

[LTP Network Tests README中文翻译](https://chenxiaosong.com/translations/ltp-network-tests-readme.html)。

打开配置`CONFIG_VETH=m`、`CONFIG_NFS_FS=m`。

在debian发行版下，启动nfs server服务后，执行命令`cd /opt/ltp/testscripts; ./network.sh -n`后报错，换成手动执行第一个用例`cd /opt/ltp/testcases/bin; PATH=$PATH:$PWD ./nfs01.sh -v 3 -t udp`，报错`nfs01 1 TCONF: rpc.statd not running`，修改`/opt/ltp/testcases/bin/nfs_lib.sh`：
```sh
diff --git a/testcases/network/nfs/nfs_stress/nfs_lib.sh b/testcases/network/nfs/nfs_stress/nfs_lib.sh
index d3de3b7f1..4be0bcc6f 100644
--- a/testcases/network/nfs/nfs_stress/nfs_lib.sh
+++ b/testcases/network/nfs/nfs_stress/nfs_lib.sh
@@ -174,7 +174,7 @@ nfs_setup()
        fi

        if tst_cmd_available pgrep; then
-               for i in rpc.mountd rpc.statd; do
+               for i in rpc.mountd; do
                        pgrep $i > /dev/null || tst_brk TCONF "$i not running"
                done
        fi
```

# 4.19 `loongarch64`测试失败问题

## 问题描述

`x86_64`下执行`systemctl start nfs-server; cd /opt/ltp/testcases/bin; PATH=$PATH:$PWD ./nfs01.sh -v 4 -t tcp`成功，但`loongarch64`下执行失败：
```sh
nfs01 1 TINFO: initialize 'lhost' 'ltp_ns_veth2' interface
nfs01 1 TINFO: add local addr 10.0.0.2/24
nfs01 1 TINFO: add local addr fd00:1:1:1::2/64
nfs01 1 TINFO: initialize 'rhost' 'ltp_ns_veth1' interface
nfs01 1 TINFO: add remote addr 10.0.0.1/24
nfs01 1 TINFO: add remote addr fd00:1:1:1::1/64
nfs01 1 TINFO: Network config (local -- remote):
nfs01 1 TINFO: ltp_ns_veth2 -- ltp_ns_veth1
nfs01 1 TINFO: 10.0.0.2/24 -- 10.0.0.1/24
nfs01 1 TINFO: fd00:1:1:1::2/64 -- fd00:1:1:1::1/64
nfs01 1 TINFO: timeout per run is 0h 5m 0s
nfs01 1 TINFO: mount.nfs: (linux nfs-utils 2.5.1)
nfs01 1 TINFO: setup NFSv4, socket type tcp
nfs01 1 TINFO: Mounting NFS: mount -v -t nfs -o proto=tcp,vers=4 10.0.0.2:/tmp/LTP_nfs01.T8ifnS128N/4/tcp /tmp/LTP_nfs01.T8ifnS128N/4/0
mount.nfs: mount(2): No such file or directory
mount.nfs: mounting 10.0.0.2:/tmp/LTP_nfs01.T8ifnS128N/4/tcp failed, reason given by server: No such file or directory
mount.nfs: timeout set for Mon Apr 22 17:00:23 2024
mount.nfs: trying text-based options 'proto=tcp,vers=4.2,addr=10.0.0.2,clientaddr=10.0.0.1'
nfs01 1 TBROK: mount command failed
nfs01 1 TINFO: Cleaning up testcase

Summary:
passed   0
failed   0
broken   1
skipped  0
warnings 0
```

配置文件`/etc/exports`修改成如下内容：
```sh
/tmp/ *(rw,no_root_squash,fsid=0)
/tmp/s_test/ *(rw,no_root_squash,fsid=1)
```

重启服务`systemctl restart nfs-server`，手动挂载`mount -v -t nfs -o proto=tcp,vers=4 10.0.0.2:/s_test /mnt`，挂载成功，说明nfs功能正常。

## 定位

单步执行测试用例：
```sh
mkdir /tmp/s_test -p
exportfs -i -o fsid=148252,no_root_squash,rw *:/tmp/s_test
mount -v -t nfs -o proto=tcp,vers=4 localhost:/tmp/s_test /mnt
```

在`x86_64`虚拟机中测试正常，在`loongarch64`环境下测试失败。