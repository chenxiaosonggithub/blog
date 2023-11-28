# openeuler nfs+

[NFS多路径用户指南](https://docs.openeuler.org/zh/docs/23.03/docs/NfsMultipath/NFS%E5%A4%9A%E8%B7%AF%E5%BE%84.html)（[文档源码](https://gitee.com/openeuler/docs/tree/stable2-23.03/docs/zh/docs/NfsMultipath)）。

pull request: [[openEuler-20.03-LTS-SP4]add enfs feature patch and change log info.](https://gitee.com/src-openeuler/kernel/pulls/1300/commits)。

编译前打开配置`CONFIG_ENFS=y`

挂载选项解析流程：
```c
nfs_parse_mount_options
  enfs_check_mount_parse_info
    nfs_multipath_parse_options
      nfs_multipath_parse_ip_list
        nfs_multipath_parse_ip_list_inter
```

