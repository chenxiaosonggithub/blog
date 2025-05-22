smb3有一个多通道的特性，以前没用过，准备看一下这块内容，找点补丁贡献。

# 多个网卡环境

请查看[《内核开发环境》](https://chenxiaosong.com/course/kernel/dev-environment.html#qemu-multi-nic)

# 环境

`/etc/samba/smb.conf`:
```sh
[global]
# 多通道
server multi channel support = yes
```

挂载:
```sh
mount -o user=root,multichannel //192.168.53.37/TEST /mnt
```

