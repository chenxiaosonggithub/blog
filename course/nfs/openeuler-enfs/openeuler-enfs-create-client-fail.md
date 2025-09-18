# 问题描述

[openEuler的nfs+](https://chenxiaosong.com/course/nfs/openeuler-enfs.html)的挂载和`modprobe -r enfs`并行执行时，nfs+ client未初始化，nfs+的功能无法使用。

# 构造复现

内核修改如下:
```sh
--- a/fs/nfs/enfs_adapter.c
+++ b/fs/nfs/enfs_adapter.c
@@ -159,12 +159,17 @@ int nfs_create_multi_path_client(struct nfs_client *client,
        if (cl_init->enfs_option == NULL)
                return 0;
 
+       printk("delay begin\n");
+       mdelay(5 * 1000);
+       printk("delay end\n");
+
        ops = nfs_multipath_router_get();
        if (ops != NULL && ops->client_info_init != NULL)
                ret = ops->client_info_init((void *)&client->cl_multipath_data,
```

测试步骤如下:
```sh
mount -t nfs -o vers=3,localaddrs=192.168.53.57~192.168.53.214,remoteaddrs=192.168.53.68~192.168.53.225 192.168.53.225:/tmp/s_test /mnt/ &
sleep 1
modprobe -r enfs
sleep 5
mount | grep nfs # 看不到nfs+相关的挂载选项
```

# 代码分析

只有在`enfs_parse_mount_options()`中会自动加载`enfs`模块，如果在初始化客户端（`nfs_create_multi_path_client()`函数）之前
执行了`modprobe -r enfs`移除了模块，就无法初始化多路径客户端，因为这时找不到`enfs`模块，也不会自动加载`enfs`模块。

```c
mount
  path_mount
    do_new_mount
      parse_monolithic_mount_data
        nfs_fs_context_parse_monolithic
          nfs23_parse_monolithic
            generic_parse_monolithic
              vfs_parse_monolithic_sep
                vfs_parse_fs_string
                  vfs_parse_fs_param
                    nfs_fs_context_parse_param
                      enfs_parse_mount_options
                        nfs_multipath_router_get // 这里加载enfs模块成功
                        nfs_multipath_parse_options // 解析enfs挂载参数成功
      vfs_get_tree
        nfs_get_tree
          nfs_try_get_tree
            nfs_try_mount_request
              nfs3_create_server
                nfs_create_server
                  nfs_init_server
                    nfs_get_client
                      nfs_init_client
                        nfs_create_multi_path_client
                          /*
                           * 如果在这之前执行了 modprobe -r enfs
                           * 在这里就会因为找不到模块而初始化cient失败
                           */
                          nfs_multipath_router_get // 持有模块引用计数
```

# 解决方案

暂时不解决这个问题。

