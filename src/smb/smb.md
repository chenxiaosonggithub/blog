
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
