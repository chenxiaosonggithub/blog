# SMB和NetBIOS

SMB全称Server Message Block，中文翻译：服务器信息块。

- 1996年，微软提出将SMB改称为Common Internet File System。
- 2006年，Microsoft 随着 Windows Vista 的发布 引入了新的SMB版本 (SMB 2.0 or SMB2)。
- SMB 2.1, 随 Windows 7 和 Server 2008 R2 引入, 主要是通过引入新的机会锁机制来提升性能。
- SMB 3.0 (前称 SMB 2.2)在Windows 8 和 Windows Server 2012 中引入。

NetBIOS协议：

- [RFC1001, CONCEPTS AND METHODS](https://www.rfc-editor.org/rfc/rfc1001)
- [RFC1002, DETAILED SPECIFICATIONS](https://www.rfc-editor.org/rfc/rfc1002)

# SMB各版本比较

smb的协议文档有以下几个版本：

- [10/1/2020, [MS-CIFS]: Common Internet File System (CIFS) Protocol](https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-cifs)
- [6/25/2021, [MS-SMB]: Server Message Block (SMB) Protocol](https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-smb)
- [9/20/2023, [MS-SMB2]: Server Message Block (SMB) Protocol Versions 2 and 3](https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-smb2)

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

执行脚本[samba-svr-setup.sh](https://gitee.com/chenxiaosonggitee/blog/blob/master/src/smb/samba-svr-setup.sh)启动用户态的samba server。

# 内核server搭建

参考[ksmbd.rst](https://github.com/torvalds/linux/blob/master/Documentation/filesystems/smb/ksmbd.rst)和[ksmbd-tools](https://github.com/cifsd-team/ksmbd-tools)

用户操作：
```sh
ksmbd.adduser --add-user=MyUser
ksmbd.adduser --update-user=MyUser --password=MyNewPassword
ksmbd.adduser --del-user=MyUser
```

编辑配置文件`/usr/local/ksmbd-tools/etc/ksmbd/ksmbd.conf`:
```sh
[global]
        writeable = yes               
        public = yes                  
                                      
[TEST]                                
        comment = xfstests test dir   
        path = /tmp/s_test            
                                      
[SCRATCH]                             
        comment = xfstests scratch dir
        path = /tmp/s_scratch         
```

执行脚本[ksmbd-svr-setup.sh](https://gitee.com/chenxiaosonggitee/blog/blob/master/src/smb/ksmbd-svr-setup.sh)启动内核的ksmbd server。

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
