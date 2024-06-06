# 参考资料

- [KSMBD kernel doc](https://chenxiaosong.com/translations/ksmbd-kernel-doc.html)
- [ksmbd-tools](https://github.com/cifsd-team/ksmbd-tools)
- [cifsd-team/ksmbd](https://github.com/cifsd-team/ksmbd)

# 环境

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

执行脚本[ksmbd-svr-setup.sh](https://gitee.com/chenxiaosonggitee/blog/blob/master/courses/smb/ksmbd-svr-setup.sh)启动内核的ksmbd server。
