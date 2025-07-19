# 问题描述

[openEuler的nfs+](https://chenxiaosong.com/course/nfs/openeuler-enfs.html)的挂载和`modprobe -r enfs`并行执行时，nfs+没挂载成功，nfs+的功能无法使用。

# 构造复现

内核修改如下:
```sh
--- a/fs/nfs/enfs_adapter.c
+++ b/fs/nfs/enfs_adapter.c
@@ -159,12 +159,17 @@ int nfs_create_multi_path_client(struct nfs_client *client,
        if (cl_init->enfs_option == NULL)
                return 0;
 
+       printk("delay begin\n");
+       mdelay(10 * 1000);
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
sleep 10
mount | grep nfs # 看不到nfs+相关的挂载选项
```

