现在有3台电脑:
```
1. 局域网电脑 private-server
2. 有公网ip的服务器 public-server
3. 另一个局域网电脑 private-client
```

```sh
                           Wide Area Network                         
                              +--------+
                              | public |                             
             +--------------->| server |<-------------+              
             |                +--------+              |              
             |                public ip               |              
             |                                        |              
             |                                        |              
             |                                        |              
             v                                        v              
+-----------------------+                   +-----------------------+
| Local Area Network A  |                   | Local Area Network B  |
|                       |                   |                       |
|       +---------+     |                   |     +---------+       |
|       | private |     |                   |     | private |       |
|       | client  |     |                   |     | server  |       |
|       +---------+     |                   |     +---------+       |
|                       |                   |                       |
+-----------------------+                   +-----------------------+
```

由于private-client和private-server处于局域网（Local Area Network），private-client 无法直接访问 private-server，要通过 public-server（有公网ip） 做一个中转。

# 安装

首先在private-server上安装autossh:
```sh
# https://www.harding.motd.ca/autossh/ # centos9源码安装, 没法通过包管理器安装

sudo apt install autossh -y # ubuntu2204
```

private-server安装openssh-server:
```sh
sudo apt install openssh-server -y
```

# 配置

public-server上做如下更改:
```shell
vim /etc/ssh/sshd_config # GatewayPorts yes
systemctl restart sshd # 重启ssh
```

在private-server上执行[`link.sh`](https://github.com/chenxiaosonggithub/blog/blob/master/course/gnu-linux/src/link.sh)脚本
将[`ssh-reverse.service`](https://github.com/chenxiaosonggithub/blog/blob/master/course/gnu-linux/src/ssh-reverse.service)
链接到`/lib/systemd/system/ssh-reverse.service`。

private-server 在`/etc/bashrc`或`/etc/bash.bashrc`(通过`/etc/profile`查看到底是哪个文件)中添加:
```shell
AUTOSSH_POLL=60
```

然后在private-server上执行以下操作:
```sh
sudo -i # 切换成 root, 因为开机运行 ssh-reverse 是 root 用户
ssh-keygen # 生成ssh key
ssh-copy-id root@chenxiaosong.com # 执行后可以免密登录到 public-server

sudo setenforce 0 # centos9 关闭 selinux
sudo vim /etc/selinux/config # centos9 改成 SELINUX=permissive, 开机就关闭selinux
sudo systemctl enable ssh-reverse # 开机启动
sudo systemctl restart ssh-reverse # 重启服务
```

在public-server上查看是否在监听某些端口:
```sh
# -t: 显示 TCP 端口信息。
# -u: 显示 UDP 端口信息。
# -l: 仅显示正在监听的端口。
# -n: 显示数值格式的端口号，而不是尝试解析服务名称。
# -p: 显示PID/Program
netstat -tunpl | grep 5555
```

这时private-client就可以直接访问private-server了:
```sh
ssh -p 55555 sonvhi@chenxiaosong.com
```

# 监听

有时会因为网络波动出现无法远程连接，可以在private-server上使用脚本监测，当监测到无法连接时，重启服务。

执行以下命令，运行[`monitor-ssh.sh`](https://github.com/chenxiaosonggithub/blog/blob/master/course/gnu-linux/src/monitor-ssh.sh)脚本:
```sh
mkdir -p /home/sonvhi/chenxiaosong/monitor-ssh
# 因为要不断写日志，所以挂载一个tmpfs，避免写入磁盘，否则会降低磁盘寿命
sudo mount -t tmpfs -o size=64G monitor-ssh /home/sonvhi/chenxiaosong/monitor-ssh
sudo -i # 因为要重启service
cd /home/sonvhi/chenxiaosong/code/blog/src/ssh-reverse
bash monitor-ssh.sh &
```

# 内网穿透

ssh反向隧道还可以用于内网穿透，比如把内网linux的mysql端口暴露到公网上:
```shell
# ssh -R <公网服务器IP>:<公网端口>:localhost:<MySQL端口> <公网服务器用户名>@<公网服务器IP>
ssh -R chenxiaosong.com:22222:localhost:3306 root@chenxiaosong.com
ssh -N -R 22222:localhost:3306 root@chenxiaosong.com # -M: 启用控制台功能, -N: 不执行远程命令
# ssh -N -R 远程端口1:目标主机1:目标端口1 -R 远程端口2:目标主机2:目标端口2 用户名@远程主机
ssh -N -R 3306:localhost:3306 -R 6379:localhost:6379 -R 5001:localhost:5001 -R 5002:localhost:5002 root@chenxiaosong.com # 多个映射
```

通过访问`chenxiaosong.com`的`22222`端口就能访问到内网mysql的`3306`端口。

# 花生壳

如果不想自己搭建服务器，可以使用[花生壳](https://hsk.oray.com/)，[查看帮忙文档](https://service.oray.com/question/15507.html)。

注意不能用`wget`命令下载（下载的文件错误），直接访问[centos](https://dl.oray.com/hsk/linux/phddns_5.3.0_amd64.rpm)和[ubuntu](https://dl.oray.com/hsk/linux/phddns_5.3.0_amd64.deb)
下载链接（[版本号查看官网](https://hsk.oray.com/download)）在网页下载。

Linux安装请[点击这里查看文档](https://service.oray.com/question/11630.html):
```sh
# 安装成功后会打印`SN: orayxxxx   Default password: admin`
rpm -ivh phddns_5.3.0_amd64.rpm
sudo dpkg -i phddns_5.3.0_amd64.deb
```

启动服务:
```sh
sudo phddns enable # 开机启动
sudo phddns start # 启动
sudo phddns status # 查看状态
```

在[贝锐花生壳管理 - 设备列表](https://console.hsk.oray.com/zh/device)添加设备。

注意可能会断开，可以用以下脚本检查重启服务:
```sh
# 需要先执行 sudo -i
while true
do
	ssh -p xxxxx -o ConnectTimeout=3 -q xxx@xxxx.chenxiaosong.com exit
	if [ $? != 0 ]
	then
		echo `date` fail
		phddns restart
	fi

	sleep 120
done
```

# 向日葵和ToDesk

还可以使用[向日葵](https://sunlogin.oray.com/download?categ=personal)和[ToDesk](https://www.todesk.com/download.html)。

向日葵有[命令行版本](https://service.oray.com/question/11017.html)，但是要付费的，还不如自己买个服务器，下面以centos7为例说明安装过程:
```sh
yum install ./sunloginclientshell-10.1.1.28779.x86_64.rpm -y
sudo /usr/local/sunlogin/bin/sunloginclient
按F12 -> Bind, 登录向日葵账号密码
```

# 家里远程桌面到公司ubuntu24.04 {#remote-desktopl}

ubuntu24.04没有vnc协议，只有rdp协议，位置是`设置 -> 系统 -> 桌面共享`，注意物理机上需要连接显示器才能远程桌面控制。

我是从家里的苹果笑柄连接到公司的ubuntu24.04，macOS通过向日葵连接到virt-manager中的Windows11，Windows11通过“远程桌面连接”连接到ubuntu24.04。
另外，通过[网络唤醒（Wake-on-LAN）](https://chenxiaosong.com/course/gnu-linux/install.html#wake-on-lan)另一台Linux。

如果Virt-manager中的Windows11出问题（比如卡死），可以用以下命令在远程操作virt-manager:
```sh
virsh list # 本地活动虚拟机
virsh list –all # 本地所有的虚拟机（活动的+不活动的）
virsh shutdown Win11_24H2_Chinese_Simplified_x64 # 正常关闭虚拟机
virsh destroy Win11_24H2_Chinese_Simplified_x64 # 强制关闭虚拟机
virsh start Win11_24H2_Chinese_Simplified_x64 # 启动非活动虚拟机
```

# JuiceSSH

安卓手机上远程登录可以使用[JuiceSSH](https://juicessh.com/changelog)。

