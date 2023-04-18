[toc]

# 反向ssh

https://cloud.tencent.com/developer/article/1722055

autossh:
```shell
# https://www.harding.motd.ca/autossh/ # centos9源码安装
sudo apt install autossh -y # ubuntu2204
```

内网电脑 A 通过公网 server 登录到另一个内网电脑 B

```shell
ssh -NfR 55555:localhost:22 root@chenxiaosong.com # 在内网电脑 B 上执行, chenxiaosong.com 为公网 server
ssh chenxiaosong.com # 在内网电脑 A 上执行, 登录到公网 server
ssh -p 12345 root@localhost # 在公网 server 上执行, 登录到内网电脑 B
```

在内网电脑 B 中设置开机启动 ssh-reverse, `/lib/systemd/system/ssh-reverse.service`:
```shell
[Unit]
Description=ssh reverse
StartLimitIntervalSec=0

[Service]
Type=forking
ExecStart=autossh -M 55556 -NfR 55555:localhost:22 root@chenxiaosong.com
Restart=always
RestartSec=1

[Install]
WantedBy=multi-user.target
```
```shell
sudo -i # 切换成 root, 因为开机运行 ssh-reverse 是 root 用户
ssh-keygen
ssh-copy-id root@chenxiaosong.com

sudo setenforce 0 # centos9
sudo vim /etc/selinux/config # centos9 改成 SELINUX=permissive
sudo systemctl enable ssh-reverse
sudo systemctl restart ssh-reverse
```

server:
```shell
vim /etc/ssh/sshd_config # GatewayPorts yes
systemctl restart sshd # 重启ssh
```

内网电脑 B, 在`/etc/bashrc`或`/etc/bash.bashrc`(通过`/etc/profile`查看到底是哪个文件)中添加：
```shell
AUTOSSH_POLL=60
```

# efi grub 选择系统

```shell
cd /boot/efi/EFI/centos # centos为启动盘
blkid # 打印 uuid
vim grub.cfg # 更改 uuid, set prefix=($dev)/　后接正确的路径
vim /etc/default/grub # GRUB_TIMEOUT=5

grub2-mkconfig -o /boot/grub2/grub.cfg # centos9
grub-mkconfig -o /boot/grub/grub.cfg # ubuntu2204
```

# ubuntu 20.04

```shell
sudo apt install openssh-server -y
sudo apt install build-essential -y
sudo apt-get install qemu qemu-kvm virt-manager bridge-utils qemu-system -y # 可能需要重启才能以非root用户启动virt-manager
sudo apt install ibus*wubi* -y
sudo apt install flex bison -y

sudo apt install samba -y
sudo systemctl restart smbd.service

# https://launchpad.net/~wireshark-dev/+archive/ubuntu/stable
sudo add-apt-repository ppa:wireshark-dev/stable
sudo apt update
sudo apt install wireshark -y
```

# ubuntu 22.04

```shell
sudo apt install openssh-server -y
sudo apt install build-essential -y
sudo apt-get install qemu qemu-kvm virt-manager bridge-utils qemu-system -y # 可能需要重启才能以非root用户启动virt-manager
sudo apt install ibus*wubi* -y # 要重启
sudo apt install flex bison -y
sudo apt-get install fuse -y # V2Ray-Desktop-v2.4.0-linux-x86_64.AppImage 无法运行
sudo apt install tmux -y
sudo apt-get install libelf-dev libssl-dev -y # 内核源码编译依赖的库
sudo apt install libncurses-dev -y # make menuconfig

sudo useradd -s /bin/bash -d /home/test -m test
# sudo userdel -r test # 删除用户

sudo apt install libc6-i386 libgl1:i386 -y # steam

sudo hostnamectl set-hostname Threadripper-Ubuntu2204

sudo apt install gcc-arm-linux-gnueabi gcc-arm-linux-gnueabihf -y

sudo apt install gcc-riscv64-linux-gnu -y

sudo apt install exfat-utils -y
```

# centos 9

```shell
sudo dnf groupinstall "development tools" -y
sudo dnf install qemu-kvm virt-manager libvirt -y
sudo systemctl restart libvirtd
sudo dnf install ncurses-devel -y

# https://wiki.linuxfoundation.org/networking/bridge
git clone -b main git://git.kernel.org/pub/scm/network/bridge/bridge-utils.git
cd bridge-utils
autoconf
./configure

sudo hostnamectl set-hostname Threadripper-CentOS9

sudo vim /etc/selinux/config # centos9 改成 SELINUX=disabled

# 最后２个参数的意义：dump, fsck
sudo vim /etc/fstab # UUID=b7aa1308-f57e-4f28-834c-c463237a8383 /home/sonvhi/sonvhi/   ext4    errors=remount-ro 0       0
```

# centos6

```shell
vi /etc/sysconfig/network-scripts/ifcfg-eth0 # 删除　UUID　和　HWADDR
rm /etc/udev/rules.d/70-persistent-net.rules 
```

ubuntu22.04无法ssh到centos6：
```shell
ssh -oHostKeyAlgorithms=+ssh-dss root@192.168.122.14
```

无法安装软件的解决办法：
```shell
vi /etc/yum.repos.d/CentOS-Base.repo # 取消注释 baseurl=, 替换　mirror.centos.org　为　vault.centos.org
yum clean all # 清除原有yum缓存
yum makecache # （刷新缓存），　yum repolist all　或者这条命令
yum repolist all # （查看所有配置可以使用的文件，会自动刷新缓存），yum makecache　或者这条命令

yum groupinstall "Development Tools" -y
yum install ncurses-devel -y
```

# virtualbox

```shell
vboxmanage internalcommands sethduuid Fedora-Workstation-Live-x86_64-34-1.2.vmdk # 多个磁盘的 uuid 一样时无法同时新建虚拟机, 需要更新 uuid
vboxmanage list vms
VBoxManage modifyvm "fedora34" --nested-hw-virt on # 注意：前面一定不能加sudo
```

# virt-manager

Edit -> Preferences -> Enable XML editing 开启 xml 编辑

修改 xml 配置：
```xml
<cpu mode="host-passthrough" check="partial"/>
```

# tmpfs

```shell
sudo mount -t tmpfs -o size=64G syzkaller tmpfs/
```

# 源码编译 emacs

https://github.com/emacs-mirror/emacs/blob/master/INSTALL

```shell
./autogen.sh
mkdir build && cd build
../configure --prefix=xxx --with-xxx=no
```

# 搭建 nginx http 服务器

```shell
apt install nginx -y
vim /etc/nginx/sites-enabled/default # 在 root /var/www/html 后添加 autoindex on;
systemctl restart nginx
```

# strace build from source

```shell
./bootstrap
mkdir build && cd build
../configure --enable-mpers=no
make
```

# docker

https://docs.docker.com/engine/install/ubuntu/
https://repo.huaweicloud.com/docker-ce/linux/ubuntu/gpg

```shell
sudo apt-get remove docker docker-engine docker.io containerd runc -y
sudo apt-get update -y
sudo apt-get install ca-certificates curl gnupg lsb-release -y
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://repo.huaweicloud.com/docker-ce/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://repo.huaweicloud.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
sudo cat /etc/group | grep docker # 如果没有则创建 sudo groupadd docker
sudo gpasswd -a sonvhi docker # 或者使用usermod ？添加完后要重启（可能有办法不用重启）

sudo docker pull ubuntu:18.04
sudo docker image ls # 查看镜像
sudo docker image rm ubuntu:18.04
sudo docker ps -a # 查看容器

sudo docker run -it ubuntu:18.04 bash # 根据镜像启动容器
# apt install build-essential -y
# apt-get install libelf-dev libssl-dev -y # 内核源码编译依赖的库
# apt install flex -y
# apt install bison -y
# strings /lib/x86_64-linux-gnu/libc.so.6 |grep GLIBC_
sudo docker export 25c2e986e912 > ubuntu-kernel:18.04.tar # 导出
cat ubuntu-kernel\:18.04.tar | sudo docker import - ubuntu-kernel:18.04 # 导入到镜像
sudo docker container prune # 删除容器

sudo docker run --rm -v "$PWD":/usr/src/myapp -w /usr/src/myapp ubuntu-kernel:18.04 gcc -v
sudo docker run --rm -it -v "$PWD":/usr/src/myapp -w /usr/src/myapp ubuntu-kernel:18.04 bash
```
