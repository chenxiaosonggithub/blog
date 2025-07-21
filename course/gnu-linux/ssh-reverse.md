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
systemctl restart sshd # fedora
systemctl restart ssh # ubuntu
```

在private-server上创建`/lib/systemd/system/ssh-reverse.service`。
```sh
[Unit]
Description=ssh reverse
StartLimitIntervalSec=0

[Service]
Type=simple
ExecStart=autossh -M 55556 -Nf -R 55555:localhost:22 root@chenxiaosong.com
Restart=always
RestartSec=1

[Install]
WantedBy=multi-user.target
```

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

`monitor-ssh.sh`脚本:
```sh
# 在 root 下执行 ssh-copy-id -p 55555 chenxiaosong.com
# 在 root 下执行本脚本 bash monitor-ssh.sh
log_path=/tmp
while true
do
        ssh -p 55555 -o ConnectTimeout=2 -q sonvhi@hz.chenxiaosong.com exit
        if [ $? != 0 ]
        then
                echo `date` > ${log_path}/ssh-monitor-fail.log
                systemctl restart ssh-reverse.service
        else
                echo `date` > ${log_path}/ssh-monitor-success.log
        fi

        sleep 30
done
```

执行以下命令:
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

# 内网穿透商业软件

当然我使用的是能白嫖的免费版。

## [花生壳](https://service.oray.com/question/15507.html)

[免费版限1GB/月](https://hsk.oray.com/price#personal)，域名和端口固定。

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

## [cpolar](https://www.cpolar.com/blog/cpolar-quick-start-tutorial-ubuntu-series)

曾经我遇到过花生壳免费版的出问题不能用，就临时用了cpolar，注意cpolar域名和端口不固定:
```sh
sudo apt-get update -y
sudo apt-get install curl -y
curl -L https://www.cpolar.com/static/downloads/install-release-cpolar.sh | sudo bash
cpolar version
cpolar authtoken xxxxxxx # token访问: https://dashboard.cpolar.com/auth
sudo systemctl enable cpolar
sudo systemctl start cpolar
```

访问[localhost:9200](http://localhost:9200/)并登录邮箱账号，[创建隧道localhost:9200/#/tunnels/create](http://localhost:9200/#/tunnels/create)，[在线隧道列表localhost:9200/#/status/online](http://localhost:9200/#/status/online)查看，或在[cpolar网官](https://dashboard.cpolar.com/status)查看。

cpolar的域名和端口不固定，可以使用以下脚本获取域名和端口然后ssh:

- 获取cpolar的status网页: [`cpolar-get-status-html.sh`](https://github.com/chenxiaosonggithub/blog/blob/master/course/gnu-linux/src/cpolar-get-status-html.sh)
- 获取ssh命令: [`cpolar-get-ssh-cmd.sh`](https://github.com/chenxiaosonggithub/blog/blob/master/course/gnu-linux/src/cpolar-get-ssh-cmd.sh)

## 其他

以下几个不建议用:

- [natapp](https://natapp.cn/article/natapp_newbie): 域名和端口不固定，两天自动删除，不建议用
- [网云穿](https://blog.xiaomy.net/archives/4.html): 域名和端口固定，但免费版只能用7天，如果要充钱可以考虑用

## 监控

注意因为网络故障或其他原因连接可能会断开，可以用以下脚本检查重启服务:
```sh
# 需要先执行 sudo -i
while true
do
	ssh -p xxxxx -o ConnectTimeout=3 -q xxx@xxxx.chenxiaosong.com exit
	if [ $? != 0 ]
	then
		echo `date` xxx fail
		phddns restart
	fi

	sleep 300
done
```

# 远程桌面

远程桌面软件:

- [向日葵](https://sunlogin.oray.com/download?categ=personal)，有[命令行版本](https://service.oray.com/question/11017.html)（要付费，还不如自己买个服务器，当然更推荐用花生壳）
- [ToDesk](https://www.todesk.com/download.html)

# 家里远程桌面到公司ubuntu24.04 {#remote-desktop}

ubuntu24.04没有vnc协议，只有rdp协议，位置是`设置 -> 系统 -> 桌面共享`，注意物理机上需要连接显示器才能远程桌面控制。
命令行控制rdp:
```sh
grdctl status
grdctl rdp enable
grdctl rdp disable
```

我是从家里的苹果笔记本连接到公司的ubuntu24.04，macOS通过向日葵连接到virt-manager中的Windows11，Windows11通过“远程桌面连接”连接到ubuntu24.04。
另外，通过[网络唤醒（Wake-on-LAN）](https://chenxiaosong.com/course/gnu-linux/install.html#wake-on-lan)另一台Linux。

ubuntu通过命令行操作wifi:
```sh
nmcli device wifi list          # 列出所有可用 Wi-Fi 网络
nmcli dev status                # 查看设备状态
nmcli connection show --active  # 查看所有活动连接
nmcli -f ALL dev wifi list      # 显示完整信息（包括BSSID）
sudo nmcli dev wifi show-password # 显示当前连接密码（需root）
sudo nmcli dev disconnect wlo2  # 断开指定网卡（替换 wlo2 为你的网卡名）
nmcli con down "HUAWEI-NET"     # 通过连接名称断开
nmcli radio wifi off           # 关闭 Wi-Fi 硬件
sudo nmcli dev connect wlo2.    # 连接
nmcli dev wifi connect "HUAWEI-NET" ifname wlo2 # 连接开放网络（无密码）
nmcli dev wifi connect "HUAWEI-NET" password "your_password" ifname wlo2 # 连接加密网络（WPA/WPA2）
```

如果Virt-manager中的Windows11出问题（比如卡死），可以用以下命令在远程操作virt-manager:
```sh
virsh list # 本地活动虚拟机
virsh list --all # 本地所有的虚拟机（活动的+不活动的）
virsh shutdown Win11_24H2_Chinese_Simplified_x64 # 正常关闭虚拟机
virsh destroy Win11_24H2_Chinese_Simplified_x64 # 强制关闭虚拟机
virsh start Win11_24H2_Chinese_Simplified_x64 # 启动非活动虚拟机
```

# JuiceSSH

安卓手机上远程登录可以使用[JuiceSSH](https://juicessh.com/changelog)。

