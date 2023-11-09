

# 启动时指定ip

```shell
[root@192 ~]# cat /lib/systemd/system/qemu-vm-setup.service
[Unit]
Description=QEMU VM Setup

[Service]
Type=oneshot
ExecStart=/root/qemu-vm-setup.sh

[Install]
WantedBy=default.target
```

```shell
[root@192 ~]# cat qemu-vm-setup.sh 
#!/bin/sh

dev=$(ip link show | awk '/^[0-9]+: en/ {sub(":", "", $2); print $2}')
ip=$(awk '/IP=/ { print gensub(".*IP=([0-9.]+).*", "\\1", 1) }' /proc/cmdline)

if test -n "$ip"
then
	gw=$(echo $ip | sed 's/[.][0-9]\+$/.1/g')
	ip addr add $ip/24 dev $dev
	ip link set dev $dev up
	ip route add default via $gw dev $dev
fi
```

# xfstests环境

```shell
yum install libtool -y
yum install libuuid-devel -y
yum install xfsprogs-devel -y
yum install libacl-devel -y
```

# debian rootfs

参考:
https://blog.csdn.net/chengbeng1745/article/details/81271024
https://www.twblogs.net/a/5e5f6067bd9eee211685777c

arm32 在 linux 仓库中执行　`make dtbs` 生成 dtb 文件

`/etc/ssh/sshd_config` 修改以下内容:
```
PermitRootLogin yes
PasswordAuthentication yes
PermitEmptyPasswords yes
```

物理机中创建网络：
```shell
sudo apt-get install uml-utilities -y # tunctl 命令，　centos９没有
qemu-system-arm -net nic,model=? -M vexpress-a15 # 查看支持的虚拟网络
sudo tunctl -b # 按顺序创建 tap0 tap1
sudo tunctl -t tap0 -u sonvhi
sudo tunctl -t tap1 -u sonvhi
sudo ip link set tap0 up # 激活
sudo ip link set tap1 up # 激活
sudo tunctl -d tap1 # 删除 tap1
sudo brctl show # 查看网桥
sudo brctl addif virbr0 tap0 # tap0 加入网桥
sudo brctl addif virbr0 tap1 # tap1 加入网桥
sudo brctl delif virbr0 tap0 # tap0 移出网桥

sudo brctl addbr br0 # 新建网桥 br0
sudo brctl delbr br0 # 删除网桥 br0
sudo brctl addif br0 enx381428b8c32c # 注意:无线网卡不行, 必须是以太网卡
sudo brctl addif br0 tap0 # tap0 加入网桥
```

centos9宿主机中没有 `tunctl`:
```shell
sudo ip tuntap add tap0 mode tap user sonvhi
sudo ip tuntap del tap0 mode tap
sudo ip tuntap list
```

bullseye aarch64 `/etc/network/interfaces` 需要把 `eth0` 改成 `enp0s1`(通过`dmesg | grep -i eth`找到`enp0s1`)

```shell
apt-get install qemu qemu-kvm bridge-utils qemu-system -y
```

# riscv ubuntu2204 rootfs

```shell
qemu-system-riscv64 -netdev ?
```

```shell
systemctl status systemd-modules-load.service
mv /lib/systemd/system/systemd-modules-load.service /lib/systemd/system/systemd-modules-load.service.bak

cp /etc/fstab /etc/fstab.bak
vim /etc/fstab # 删除　LABEL=UEFI 一行
```
