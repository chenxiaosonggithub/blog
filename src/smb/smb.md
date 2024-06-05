
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
