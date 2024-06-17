# 参考资料

- [KSMBD kernel doc](https://chenxiaosong.com/translations/ksmbd-kernel-doc.html)
- [ksmbd-tools](https://chenxiaosong.com/translations/ksmbd-tools-readme.html)
- [cifsd-team/ksmbd](https://github.com/cifsd-team/ksmbd)

# 现状

- [开发进度](https://github.com/torvalds/linux/blob/master/Documentation/filesystems/smb/ksmbd.rst)。
- maintainer: Namjae Jeon <linkinjeon@kernel.org>，友好。
- 使用指导文档较全。
- cve漏洞暂时较多：
  - 9.8分[CVE-2022-47939](https://nvd.nist.gov/vuln/detail/cve-2022-47939)
  - 9.8分[CVE-2023-32254](https://nvd.nist.gov/vuln/detail/CVE-2023-32254)
  - 9.0分[CVE-2023-32250](https://nvd.nist.gov/vuln/detail/CVE-2023-32250)
  - 8.8分[CVE-2022-47942](https://nvd.nist.gov/vuln/detail/CVE-2022-47942)
  - 8.1分[CVE-2022-47940](https://nvd.nist.gov/vuln/detail/CVE-2022-47940)
  - 8.1分[CVE-2023-32258](https://nvd.nist.gov/vuln/detail/CVE-2023-32258)
  - 8.1分[CVE-2023-32257](https://nvd.nist.gov/vuln/detail/CVE-2023-32257)
  - 7.8分[CVE-2023-32356](https://nvd.nist.gov/vuln/detail/CVE-2023-32356)
  - 7.5分[CVE-2023-32252](https://nvd.nist.gov/vuln/detail/CVE-2023-32252)
  - 7.5分[CVE-2023-32248](https://nvd.nist.gov/vuln/detail/CVE-2023-32248)
  - 7.5分[CVE-2023-32247](https://nvd.nist.gov/vuln/detail/CVE-2023-32247)

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
<!--
```sh
# 以下3个命令是很早以前的命令
# ksmbd.adduser --add-user=MyUser
# ksmbd.adduser --update-user=MyUser --password=MyNewPassword
# ksmbd.adduser --del-user=MyUser
```
-->
```sh
mkdir -vp /tmp/s_test
# 生成 ksmbd.conf
sudo ksmbd.addshare --add \
                    --option "path = /tmp/s_test" \
                    --option 'read only = no' \
                    TEST
sudo ksmbd.addshare --update TEST # 填写其他信息
sudo ksmbd.adduser --add root
sudo ksmbd.adduser --delete root # 删除用户
```

配置文件`/usr/local/etc/ksmbd/ksmbd.conf`的一个例子如下:
```sh
[global]
        writeable = yes
        public = yes

[TEST]
        comment = xfstests test dir
        ; 注意路径后面不要有空格，我被路径后的空格坑过
        path = /tmp/s_test
```

执行脚本[ksmbd-svr-setup.sh](https://gitee.com/chenxiaosonggitee/blog/blob/master/courses/smb/ksmbd-svr-setup.sh)启动内核的ksmbd server。

```sh
sudo ksmbd.control --shutdown # 关闭
sudo ksmbd.mountd # 启动
sudo mount -o user=root //127.0.0.1/TEST /mnt
```