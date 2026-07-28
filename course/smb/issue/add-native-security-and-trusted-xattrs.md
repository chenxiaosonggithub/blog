```sh
# 第一步：验证 security.xfstests 能否正确设置并传到服务端
# client
mount -t cifs -o username=root,password=1,posix //192.168.53.210/test /mnt
cd /mnt
rm -f testfile
touch testfile
setfattr -n security.xfstests -v attr testfile
getfattr -n security.xfstests testfile
# server
cd /tmp/s_test
getfattr -n security.xfstests testfile


# 第二步：验证写入文件后清除 security.capability
# client
cd /mnt
rm -f testfile
touch testfile
# cap_chown：允许程序绕过文件所有者和组的限制，执行 chown(2)。
# p：把该能力加入文件的 Permitted 集合。
# e：程序执行后立即启用该能力。
# +：添加能力，不清除已有能力。
setcap cap_chown+ep testfile
getcap testfile
echo something >> testfile
cat testfile
getcap testfile
# server
cd /tmp/s_test
cat testfile
getcap testfile

# 第三步：验证写入文件只清除 capability，不清除 trusted xattr
# client
cd /mnt
rm -f testfile
touch testfile
setcap cap_chown+ep testfile
setfattr -n trusted.name -v value testfile
getcap testfile
getfattr -n trusted.name testfile
echo something >> testfile
cat testfile
getcap testfile
getfattr -n trusted.name testfile
# server
cd /tmp/s_test
getcap testfile
getfattr -n trusted.name testfile
cat testfile
```

