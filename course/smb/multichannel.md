smb3有一个多通道的特性，以前没用过，准备看一下这块内容，找点补丁贡献。

# 多个网卡环境

请查看[《内核开发环境》](https://chenxiaosong.com/course/kernel/environment.html#qemu-multi-nic)

这里我们用三个网卡:
```sh
-net nic,model=virtio,macaddr=00:11:22:33:44:01 \
-net nic,model=virtio,macaddr=00:11:22:33:44:62 \
-net nic,model=virtio,macaddr=00:11:22:33:44:72 \
```

# 环境

用户态server配置文件`/etc/samba/smb.conf`:
```sh
[global]
# 多通道，默认开启状态yes，如果要关闭改成no
server multi channel support = yes
```

客户端挂载:
```sh
mount -o user=root,multichannel,max_channels=3 //192.168.53.209/TEST /mnt
```

# 代码分析

```c
mount
  do_mount
    path_mount
      do_new_mount
        vfs_get_tree
          smb3_get_tree
            smb3_get_tree_common
              cifs_smb3_do_mount
                cifs_mount // 打开配置CONFIG_CIFS_DFS_UPCALL
                  dfs_mount_share
                    cifs_mount_get_tcon
                      smb3_qfs_tcon
                        SMB3_request_interfaces
                          SMB2_ioctl(..., FSCTL_QUERY_NETWORK_INTERFACE_INFO, ...)
                          parse_server_interfaces
                  cifs_try_adding_channels
                    iface = list_first_entry(&ses->iface_list,
```

