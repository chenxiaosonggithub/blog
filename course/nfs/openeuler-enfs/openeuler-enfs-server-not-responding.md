# 问题描述

按以下步骤操作，报错`nfs: server 192.168.53.210 not responding, timed out`:
```sh
mount -t nfs -o vers=3,localaddrs=192.168.53.209~192.168.53.46,remoteaddrs=192.168.53.210~192.168.53.47 192.168.53.210:/tmp/s_test /mnt/
modprobe -r enfs
modprobe enfs # 报错 nfs: server 192.168.53.210 not responding, timed out
```

