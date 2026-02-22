# 参考网站

- [鸟哥的Linux私房菜 简体 - "SAMBA服务器"章节](http://cn.linux.vbird.org/linux_server/#part3)
- [鸟哥的Linux私房菜 繁体 - "SAMBA伺服器"](https://linux.vbird.org/linux_server/centos6/0370samba.php)
- [鸟哥的Linux私房菜 繁体 - 伺服器架設篇目錄 - RockyLinux 9 (開發中)](https://linux.vbird.org/linux_server/rocky9/)
- [Samba - opening windows to a wider world](https://www.samba.org/)
- [kernel Documentation: `admin-guide/cifs`](https://github.com/torvalds/linux/tree/master/Documentation/admin-guide/cifs)
- [kernel Documentation: `filesystems/smb`](https://github.com/torvalds/linux/tree/master/Documentation/filesystems/smb)

# 内核态server搭建

请查看[smb server (ksmbd)](https://chenxiaosong.com/course/smb/ksmbd.html#environment)。

# 用户态server搭建

安装用户态工具:
```sh
apt-get install samba -y # debian
dnf install samba -y # fedora
```

用户操作（优先用`pdbedit`而不是`smbpasswd`）:
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

编辑[`/etc/samba/smb.conf`](https://gitee.com/chenxiaosonggitee/tmp/blob/master/gnu-linux/smb/smb.conf)配置文件（不区分大小写），具体参数用法查看`man 5 smb.conf`:
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
    # browseable = yes
    # 如果无法访问，create mask可以设置为0770或0777（但不建议）
    # create mask = 0700
    # 如果无法访问，directory mask设置为0770或0777（但不建议）
    # directory mask = 0700
    # valid users = sonvhi
    # available = yes
    # guest ok = no
    comment = xfstests test dir
    path = /tmp/s_test
    public = yes
    read only = no
    writeable = yes
```

执行脚本[samba-svr-setup.sh](https://gitee.com/chenxiaosonggitee/blog/blob/master/course/smb/src/samba-svr-setup.sh)启动用户态的samba server。

- `nmbd`用于管理工作组和NetBIOS name，通过UDP开启端口137和138解析名称。
- `smbd`权限管理, 用于管理SAMBA主机共享的目录、文件和打印机等，通过TCP来传输数据，端口为139和445，ksmbd监听的端口是445。
- `tdbdump,tdbtool`: TDB (Trivial DataBase)数据库, `tdb-tools`软件包。
- `smbstatus`: 联机状况。
- `smbpasswd,pdbedit`: 账号密码，早期`smbpasswd`，使用TDB后用`pdbedit`。
- `testparm`: 检查`/etc/samba/smb.conf`。
- `smbstatus`: 观察状态。

文档查看`/usr/share/doc/samba*`。

如果windows和macOS客户端无法访问Linux的文件夹，Linux可能需要再进行以下步骤:
```sh
sudo firewall-cmd --permanent --add-service=samba	#（允许samba服务）
sudo firewall-cmd --permanent --add-service=samba-dc	#（允许samba-dc服务，可能不需要操作）
sudo setsebool -P samba_enable_home_dirs on		#（把用户目录的samba功能使能，可读写）
sudo firewall-cmd --reload  	#（防火墙重新加载配置）
sudo systemctl stop firewalld.service	#（关闭防火墙）
sudo systemctl disable firewalld.service	#（开机不启动防火墙）
sudo firewall-cmd --get-services # 查看所有的service
sudo firewall-cmd --list-services # 查看已添加的service
sudo systemctl restart smb.service		#（重启samba服务）
```

## 源码安装samba（用户态smb server） {#build-samba-from-source}

[参考文档: Build Samba from Source](https://wiki.samba.org/index.php/Build_Samba_from_Source)。

```sh
git clone https://gitlab.com/samba-team/devel/samba.git 
cd samba/bootstrap/generated-dists/fedora41/ # fedora41可替换你使用的发行版
./bootstrap.sh # 安装依赖软件，时间可能比较久
cd ../../../
./configure --with-systemd --with-libunwind
make -j`nproc`
make install -j`nproc`
export PATH=/usr/local/samba/bin/:/usr/local/samba/sbin/:$PATH

# 只编译安装 smbd
make -j`nproc` bin/smbd && rm -rf /usr/local/samba/sbin/smbd; cp bin/smbd /usr/local/samba/sbin/smbd
```

注意`NT_STATUS_WAIT_0`等宏定义是在编译过程中用脚本`source4/scripting/bin/gen_ntstatus.py`自动生成的，生成的文件是`bin/default/include/public/core/ntstatus_gen.h`和`bin/default/libcli/util/ntstatus_gen.h`。

更新`/usr/lib/systemd/system/smb.service`，具体位置可以用`systemctl status smb`查看:
```sh
[Unit]
Description=Samba SMB Daemon
Documentation=man:smbd(8) man:samba(7) man:smb.conf(5)
Wants=network-online.target
After=network.target network-online.target nmb.service winbind.service

[Service]
Type=notify
PIDFile=/run/smbd.pid
LimitNOFILE=16384
EnvironmentFile=-/etc/sysconfig/samba
ExecStart=/usr/local/samba/sbin/smbd --foreground --no-process-group $SMBDOPTIONS
ExecReload=/bin/kill -HUP $MAINPID
LimitCORE=infinity
Environment=KRB5CCNAME=FILE:/run/samba/krb5cc_samba

[Install]
WantedBy=multi-user.target
```

不能直接复制`./packaging/systemd/smb.service.in`，现在要设置环境变量的值了。

创建配置文件:
```sh
ln -s /etc/samba/smb.conf /usr/local/samba/etc/smb.conf
```

需要特别注意的是要重新创建用户:
```sh
pdbedit -a -u root
```

启动服务:
```sh
systemctl daemon-reload
systemctl restart smb.service
```

# Windows导出目录

参考[how to mount from linux to windows 11](https://learn.microsoft.com/en-us/answers/questions/4376417/how-to-mount-from-linux-to-windows-11)。

`设置 -> 网络与Internet -> 高级网络设置`，打开公用网络的`网络发现`和`xxx共享`（也可以尝试把几个网络都打开）。

在文件夹上点击鼠标右键，`属性 -> 共享 -> 共享(S)...`，这时`所有者`权限已经默认添加，也可以尝试再添加`Everyone`。这时目录还没导出，还需要再点击`高级共享(D)...`，勾选`共享此文件夹(S)`。

注意如果Windows11是以微软账户邮箱登录，则用户名是邮箱或`C:\Users`目录下的用户名缩写，密码是微软账户邮箱的密码（不是PIN码）。

Linux挂载命令:
```sh
mount -t cifs -o username=chenx,password=微软账户邮箱密码,uid=$(id -u),gid=$(id -g) //192.168.122.106/win-test /mnt/
```

# smb客户端环境

## Linux客户端

安装所需工具:
```sh
apt install cifs-utils -y # 安装 cifs 客户端, 否则无法挂载
dnf install cifs-utils -y # fedora
apt install smbclient -y # 查询服务器共享了哪些目录
```

测试:
```sh
smbclient -L //127.0.0.1 -U root
smbclient //127.0.0.1/TEST -U root # 然后用help查看帮助，ftp的语法
nmblookup -U 192.168.53.209 netbios_name
nmblookup -S netbios_name
```

挂载命令:
```sh
getsebool -a | grep samba
setsebool -P samba_enable_home_dirs=1

# 挂载Windows导出的目录
mount -t cifs -o username=chenx,password=微软账户邮箱密码,uid=$(id -u),gid=$(id -g) //192.168.122.106/win-test /mnt/

# 选项: password=密码，iocharset=本机编码（如big5、utf8、cp950），codepage=远程主机编码
# 指定挂载后文件的所有者: uid=1000,gid=1000，当前用户的id用 id $USER 查看
# 建议用username而不是user
mount -t cifs -o username=root,vers=1.0 //localhost/TEST /mnt
mount -t cifs -o username=root,vers=2.0 //localhost/TEST /mnt
mount -t cifs -o username=root,vers=2.1 //localhost/TEST /mnt
mount -t cifs -o username=root,vers=3.0 //localhost/TEST /mnt
```

- `mount.cifs`: 挂载命令。
- `smbclient`: 查询服务器共享了哪些目录。
- `nmblookup`: 查NetBIOS name。
- `smbtree`: 查树状目录分布图。

错误日志请查看`/var/log/samba/log*`。

## Windows和macOS客户端

Windows系统下，在Windows资源管理器中输入 `\\192.168.122.1\TEST`就可访问Linux系统的文件。

macOS系统下，在Finder中按快捷键`cmd+k`，跳出Connect to Server窗口，输入`smb://192.168.122.1/TEST`就可访问Linux系统的文件。
