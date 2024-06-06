# 用户态server搭建

安装用户态工具：
```sh
apt-get install samba -y
```

用户操作：
```sh
pdbedit -L # 查看cifs用户
smbpasswd -a root # 添加用户，这里的用户名必须是系统用户名
# 如果 smbpasswd -a 添加用户test失败，就要先创建系统用户test
useradd -s /bin/bash -d /home/test -m test
smbpasswd -x root # 删除用户
smbpasswd -s root # 修改密码
smbpasswd -n root # 设置成没密码, 但挂载时好像还是需要密码，以后再看为什么吧
```

编辑`/etc/samba/smb.conf`配置文件：
```sh
[global]
# 通过 man smb.conf 查看
server min protocol = NT1

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

文档查看`/usr/share/doc/samba*`。

# smb客户端环境

安装所需工具：
```sh
apt install cifs-utils -y # 安装 cifs 客户端, 否则无法挂载
apt install smbclient -y # 查询服务器共享了哪些目录
```

挂载命令：
```shell
mount -t cifs -o username=root,vers=1.0,cifsacl //localhost/TEST /mnt
mount -t cifs -o username=root,mfsymlinks,vers=2.0,cifsacl,nocase //localhost/TEST /mnt
mount -t cifs -o username=root,mfsymlinks,vers=2.1 //localhost/TEST /mnt
mount -t cifs -o username=root,mfsymlinks,vers=3.0 //localhost/TEST /mnt
```

- `mount.cifs`: 挂载命令。
- `smbclient`: 查询服务器共享了哪些目录。
- `nmblookup`: 查NetBIOS name。
- `smbtree`: 查树状目录分布图。



