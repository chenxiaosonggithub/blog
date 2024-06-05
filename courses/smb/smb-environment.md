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
- `smbd`用于管理SAMBA主机共享的目录、文件和打印机等，通过TCP来传输数据，端口为139和445(445不一定存在)。


