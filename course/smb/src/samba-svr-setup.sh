mkfs.ext4 -b 4096 -F /dev/sda
mkfs.ext4 -b 4096 -F /dev/sdb

mkdir /tmp/s_test
mkdir /tmp/s_test2
mkdir /tmp/s_test3

mount -t ext4 /dev/sda /tmp/s_test
mount -t ext4 /dev/sdb /tmp/s_test2

systemctl stop firewalld
setenforce 0

systemctl stop ksmbd
systemctl restart smbd.service # debian
systemctl restart smb.service # fedora

chmod 777 /tmp/s_test
chmod 777 /tmp/s_test2

mkdir /tmp/test
mkdir /tmp/test2
