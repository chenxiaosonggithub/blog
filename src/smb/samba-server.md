我是自由软件的狂热者，使用的操作系统是Linux，虽然爽但还是有部分商业软件未提供Linux版本，所以难免要使用其他的操作系统。比如我会在Linux的QEMU/KVM虚拟机下安装macOS（安装方法查看[《QEMU/KVM安装macOS系统》](http://chenxiaosong.com/linux/qemu-kvm-install-macos.html)），macOS访问Fedora的文件就需要安装samba服务（没错，我就是不用windows系统）。

# 安装

安装samba软件：

`sudo dnf install samba -y`

添加samba账号：

`sudo smbpasswd -a sonvhi`	 (**sonvhi必须是linux用户名**)

# 配置

编辑配置文件`sudo vim /etc/samba/smb.conf`，在文件末尾添加以下内容：
```
[forVM]
    comment = forVM
    browseable = yes
    #path填写要分享的路径
    path = /home/sonvhi/chenxiaosong/forVM
    #如果无法访问，create mask设置为0777
    create mask = 0700
    #如果无法访问，directory mask设置为0777
    directory mask = 0700
    #users为smbpasswd命令创建的samba账号
    valid users = sonvhi
    available = yes
    writable = yes
```

> 注意：
>
> 1. 如果无法访问，create mask和directory mask设置为0777
> 2. 配置文件中一般会有默认`[homes]`选项，表示访问账号的家目录，删除`[homes]`选项将无法访问家目录
> 3. 修改完配置后，要重启samba服务：**`sudo systemctl restart smb.service`**

如果windows和macOS还是无法访问Linux的文件夹，再进行以下步骤：

```shell
sudo firewall-cmd --permanent --add-service=samba	#（允许samba服务）
sudo firewall-cmd --permanent --add-service=samba-dc	#（允许samba-dc服务，可能不需要操作）
sudo setsebool -P samba_enable_home_dirs on		#（把用户目录的samba功能使能，可读写）
sudo firewall-cmd --reload  	#（防火墙重新加载配置）
sudo systemctl stop firewalld.service	#（关闭防火墙）
sudo systemctl disable firewalld.service	#（开机不启动防火墙）
sudo systemctl restart smb.service		#（重启samba服务）
```

> Fedora系统中:
>
> 查看所有的service：`sudo firewall-cmd --get-services`
>
> 查看已添加的service：`sudo firewall-cmd --list-services`

# 搞定

Windows系统下，在Windows资源管理器中输入 `\\192.168.122.1\forVM` （192.168.122.1为Linux系统的ip，forVM是配置文件里的选项名称）就可访问Linux系统的文件。

macOS系统下，在Finder中按快捷键cmd+k，跳出Connect to Server窗口，输入`smb://192.168.122.1/forVM` （192.168.122.1为Linux系统的ip，forVM是配置文件里的选项名称）就可访问Linux系统的文件。

Linux系统下，安装 `sudo apt install cifs-utils -y`，挂载: `sudo mount -t cifs -o username=sonvhi //192.168.122.1/forVM forVM`
