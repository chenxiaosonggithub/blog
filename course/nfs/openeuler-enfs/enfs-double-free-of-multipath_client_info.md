# 问题描述

挂载时报以下信息然后panic（后面panic的日志没啥卵用就省略了）:
```sh
list_add corruption. prev->next should be next (ffff88813bbf2ca8), but was ffff888102e348b0. (prev=ffff888102e348b0).
WARNING: CPU: 7 PID: 419 at lib/list_debug.c:32 __list_add_valid_or_report+0x95/0xc0
...
RIP: 0010:__list_add_valid_or_report+0x95/0xc0
...
Call Trace:
 <TASK>
 insert_work+0x42/0x80
 __queue_work.part.0+0x195/0x310
 __queue_work+0x37/0x80
 queue_work_on+0x30/0x40
 nfs_multipath_client_info_free+0x65/0xc0 [enfs]
 nfs_free_multi_path_client+0x57/0x90 [nfs]
 nfs_free_client+0x7e/0xb0 [nfs]
 nfs_put_client.part.0+0x101/0x120 [nfs]
 nfs_init_client+0x75/0xb0 [nfs]
 nfs_get_client+0x182/0x1c0 [nfs]
 nfs_init_server.isra.0+0xf0/0x470 [nfs]
 nfs_create_server+0x6f/0x230 [nfs]
 nfs3_create_server+0x14/0x40 [nfsv3]
 nfs_try_mount_request+0xee/0x2b0 [nfs]
 nfs_try_get_tree+0x51/0x60 [nfs]
 nfs_get_tree+0x3c/0x60 [nfs]
 vfs_get_tree+0x2e/0xf0
 do_new_mount+0x188/0x330
 path_mount+0x1de/0x530
 __se_sys_mount+0x16d/0x1e0
 __x64_sys_mount+0x29/0x30
 x64_sys_call+0x108/0x2020
 do_syscall_64+0x5b/0x110
 entry_SYSCALL_64_after_hwframe+0x78/0xe2
```

# 构造复现

内核修改如下:
```sh
--- a/fs/nfs/enfs/enfs_multipath_client.c
+++ b/fs/nfs/enfs/enfs_multipath_client.c
@@ -77,8 +77,8 @@ int nfs_multipath_client_mount_info_init(
                (struct multipath_mount_options *)(cl_init->enfs_option);
 
        if (opt->local_ip_list) {
-               client_info->local_ip_list =
-                       kzalloc(sizeof(struct nfs_ip_list), GFP_KERNEL);
+               client_info->local_ip_list = NULL; // 模拟内存分配失败
+                       // kzalloc(sizeof(struct nfs_ip_list), GFP_KERNEL);
                if (!client_info->local_ip_list)
                        return -ENOMEM;
```

然后挂载，必现的哦:
```sh
mount -t nfs -o vers=3,localaddrs=192.168.53.57~192.168.53.214,remoteaddrs=192.168.53.68~192.168.53.225 192.168.53.225:/tmp/s_test /mnt/
```

# 代码分析

在`nfs_multipath_client_mount_info_init()`中构造内存分配失败，由于`->cl_multipath_data`释放后指针未置空，重复释放导致panic。

```c
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
                    // 这里client->cl_multipath_data为NULL
                    nfs_multipath_client_info_init(&client->cl_multipath_data, ...) // ops->client_info_free
                      *enfs_info = kzalloc() // 这里 client->cl_multipath_data 不为NULL
                      info = *enfs_info
                      nfs_multipath_client_mount_info_init
                        client_info->local_ip_list = NULL // 直接赋值NULL，模拟kzalloc()内存分配失败
                      // 这里被inline了
                      nfs_multipath_client_info_free
                        nfs_multipath_client_info_free_work // INIT_WORK(&clp_info->work,
                          enfs_free_client_info
                      info != NULL // 注意这里 client->cl_multipath_data 不为 NULL
                    // 执行完nfs_multipath_client_info_init()后client->cl_multipath_data 当然也不为 NULL
                  nfs_put_client
                    nfs_free_client
                      nfs_free_multi_path_client
                        // 这里没被inline
                        nfs_multipath_client_info_free(clp->cl_multipath_data) // ops->client_info_free
                          // clp->cl_multipath_data 不为 NULL，就发生double free了
```

# 解决方案

[请查看pr](https://gitee.com/openeuler/kernel/pulls/17205/commits)。

