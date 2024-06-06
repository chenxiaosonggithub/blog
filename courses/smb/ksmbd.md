# 参考资料

- [KSMBD kernel doc](https://chenxiaosong.com/translations/ksmbd-kernel-doc.html)
- [ksmbd-tools](https://github.com/cifsd-team/ksmbd-tools)
- [cifsd-team/ksmbd](https://github.com/cifsd-team/ksmbd)

# 环境

```sh
apt install -y git gcc pkgconf autoconf automake libtool make meson ninja-build gawk libnl-3-dev libnl-genl-3-dev libglib2.0-dev
git clone https://github.com/cifsd-team/ksmbd-tools.git
cd ksmbd-tools
./autogen.sh
./configure --with-rundir=/run # --prefix=/usr/local/sbin --sysconfdir=/usr/local/etc
make
sudo make install 
```

安装的二进制文件为`/usr/local/sbin/ksmbd.*`，配置文件例子`/usr/local/etc/ksmbd/ksmbd.conf.example`。

以上是使用`autotools`编译，如果要使用`meson`编译，查看[ksmbd-tools README](https://chenxiaosong.com/translations/ksmbd-tools-readme.html)。

用户操作：
```sh
# 以下3个命令是很早以前的命令
# ksmbd.adduser --add-user=MyUser
# ksmbd.adduser --update-user=MyUser --password=MyNewPassword
# ksmbd.adduser --del-user=MyUser

mkdir -vp /tmp/s_test
# 生成 ksmbd.conf
sudo ksmbd.addshare --add \
                    --option "path = /tmp/s_test" \
                    --option 'read only = no' \
                    TEST
sudo ksmbd.addshare --update TEST # 填写其他信息
sudo ksmbd.adduser --add root
sudo ksmbd.mountd # 启动
sudo ksmbd.control --shutdown # 关闭
```

编辑配置文件`/usr/local/etc/ksmbd/ksmbd.conf`:
```sh
[global]
        writeable = yes
        public = yes

[TEST]
        comment = xfstests test dir
        ; 注意路径后面不要有空格，被路径后的空格坑过
        path = /tmp/s_test

[SCRATCH]
        comment = xfstests scratch dir
        path = /tmp/s_scratch
```

执行脚本[ksmbd-svr-setup.sh](https://gitee.com/chenxiaosonggitee/blog/blob/master/courses/smb/ksmbd-svr-setup.sh)启动内核的ksmbd server。
