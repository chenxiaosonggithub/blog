# 内核server搭建

请查看[KSMBD - SMB3 Kernel Server](https://chenxiaosong.com/courses/ksmbd.html)。

# 用户态server搭建

安装用户态工具：
```sh
apt-get install samba -y # debian
dnf install samba -y # fedora
```

用户操作（优先用`pdbedit`而不是`smbpasswd`）：
```sh
pdbedit -L # 查看cifs用户
pdbedit -Lw # -w: 使用旧版的 smbpasswd 格式显示
pdbedit -a -u root # -a: 新增，这里的用户名必须是系统用户名（在/etc/passwd中有）
smbpasswd -a root # 添加用户，这里的用户名必须是系统用户名（在/etc/passwd中有）
# 如果 smbpasswd -a 添加用户test失败，就要先创建系统用户test
useradd -s /bin/bash -d /home/test -m test
pdbedit -x -u root # 删除用户
smbpasswd -x root # 删除用户
smbpasswd -s root # 修改密码，显示密码
smbpasswd root # 修改密码，不显示密码
smbpasswd -n root # 设置成没密码, 但挂载时好像还是需要密码，以后再看为什么吧
```

编辑[`/etc/samba/smb.conf`](https://gitee.com/chenxiaosonggitee/tmp/blob/master/smb.conf)配置文件（不区分大小写），具体参数用法查看`man 5 smb.conf`：
```sh
[global]
# 注意注释要单独一行，不能加在配置内容后面
# 通过 man smb.conf 查看
server min protocol = NT1
# 以下3行表示用smbpasswd修改密码时也会修改/etc/shadow密码
unix password sync  = yes
passwd program      = /usr/bin/passwd %u
pam password change = yes

[TEST]
	comment = xfstests test dir
	path = /tmp/s_test
	public = yes
	read only = no
	writeable = yes
[SCRATCH]
	comment = xfstests scratch dir
	path = /tmp/s_scratch
	public = yes
	read only = no
	writeable = yes
```

执行脚本[samba-svr-setup.sh](https://gitee.com/chenxiaosonggitee/blog/blob/master/courses/smb/samba-svr-setup.sh)启动用户态的samba server。

- `nmbd`用于管理工作组和NetBIOS name，通过UDP开启端口137和138解析名称。
- `smbd`权限管理, 用于管理SAMBA主机共享的目录、文件和打印机等，通过TCP来传输数据，端口为139和445(445不一定存在)。
- `tdbdump,tdbtool`: TDB (Trivial DataBase)数据库, `tdb-tools`软件包。
- `smbstatus`: 联机状况。
- `smbpasswd,pdbedit`: 账号密码，早期`smbpasswd`，使用TDB后用`pdbedit`。
- `testparm`: 检查`/etc/samba/smb.conf`。
- `smbstatus`: 观察状态。

文档查看`/usr/share/doc/samba*`。

# smb客户端环境

安装所需工具：
```sh
apt install cifs-utils -y # 安装 cifs 客户端, 否则无法挂载
apt install smbclient -y # 查询服务器共享了哪些目录
```

测试：
```sh
smbclient -L //127.0.0.1 -U root
smbclient //127.0.0.1/TEST -U root # 然后用help查看帮助，ftp的语法
nmblookup -U 192.168.53.209 netbios_name
nmblookup -S netbios_name
```

挂载命令：
```shell
getsebool -a | grep samba
setsebool -P samba_enable_home_dirs=1
# 选项： password=密码，iocharset=本机编码（如big5、utf8、cp950），codepage=远程主机编码
mount -t cifs -o username=root,vers=1.0,cifsacl //localhost/TEST /mnt
mount -t cifs -o username=root,mfsymlinks,vers=2.0,cifsacl,nocase //localhost/TEST /mnt
mount -t cifs -o username=root,mfsymlinks,vers=2.1 //localhost/TEST /mnt
mount -t cifs -o username=root,mfsymlinks,vers=3.0 //localhost/TEST /mnt
```

- `mount.cifs`: 挂载命令。
- `smbclient`: 查询服务器共享了哪些目录。
- `nmblookup`: 查NetBIOS name。
- `smbtree`: 查树状目录分布图。

错误日志请查看`/var/log/samba/log*`。

