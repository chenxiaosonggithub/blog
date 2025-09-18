<!--
# 疑问

- 在进行文件操作时 eNFS 将 IO 通过 RoundRobin 方式负载均衡到多条链路上以提升性能（当前版本负载均衡只支持 NFS V3）

# todo

```c
get_view_table和create_view_table不明确
enfs_recovery_nlm_lock // 嵌套太多层
enfs_choose_shard_xport // 嵌套太多层
enfs_update_fsshard // 内存泄露？
xprts_options_and_clnt 删除
enfs_query_lookup_cache 重复遍历nfs_server，要用nfs_sb_active()对nfs_server加锁

nfs_rename flag overlayfs

使用kprobe在原nfs代码插入enfs，参考 HAVE_DYNAMIC_FTRACE_WITH_DIRECT_CALLS
```
-->
# 我的贡献

[点击这里查看我的openEuler nfs+贡献](https://chenxiaosong.com/enfs-contribution.html)。

# 问题分析 {#issue}

- [openEuler的nfs+ xprt_switch_get()空指针解引用问题](https://chenxiaosong.com/course/nfs/openeuler-enfs/openeuler-enfs-null-ptr-deref-in-xprt_switch_get.html)
- [openEuler的nfs+ multipath_client_info double free的问题](https://chenxiaosong.com/course/nfs/openeuler-enfs/openeuler-enfs-double-free-of-multipath_client_info.html)
- [openEuler的nfs+初始化enfs client失败的问题](https://chenxiaosong.com/course/nfs/openeuler-enfs/openeuler-enfs-create-client-fail.html)
- [openEuler的nfs+报错not responding的问题](https://chenxiaosong.com/course/nfs/openeuler-enfs/openeuler-enfs-server-not-responding.html)
- [openEuler的nfs+代码重构](https://chenxiaosong.com/course/nfs/openeuler-enfs/openeuler-enfs-refactor.html)
- [openEuler的nfs+重新插入enfs模块时生成shard信息的功能](https://chenxiaosong.com/course/nfs/openeuler-enfs/openeuler-enfs-recreate-shard-info.html)

# 多个网卡环境

请查看[《内核开发环境》](https://chenxiaosong.com/course/kernel/environment.html#qemu-multi-nic)

# openeuler nfs+的使用

- [eNFS 使用指南](https://docs.openeuler.org/zh/docs/20.03_LTS_SP4/docs/eNFS/enfs%E4%BD%BF%E7%94%A8%E6%8C%87%E5%8D%97.html)
- [openeuler23.03 NFS多路径用户指南](https://docs.openeuler.org/zh/docs/23.03/docs/NfsMultipath/NFS%E5%A4%9A%E8%B7%AF%E5%BE%84.html)（[文档源码](https://gitee.com/openeuler/docs/tree/stable2-23.03/docs/zh/docs/NfsMultipath)），瞎搞的，这个版本根本没有多路径功能
- [src-openeuler仓库的pull request](https://gitee.com/src-openeuler/kernel/pulls?assignee_id=&author_id=&label_ids=&label_text=&milestone_id=&priority=&project_id=src-openeuler%2Fkernel&project_type=&scope=&search=enfs&single_label_id=&single_label_text=&sort=closed_at+desc&status=merged&target_project=&tester_id=)
- [openeuler仓库的pull request](https://gitee.com/openeuler/kernel/pulls?assignee_id=&author_id=&label_ids=&label_text=&milestone_id=&priority=&project_id=openeuler%2Fkernel&project_type=&scope=&search=enfs&single_label_id=&single_label_text=&sort=closed_at+desc&status=merged&target_project=&tester_id=)
- [补丁文件](https://gitee.com/src-openeuler/kernel/tree/openEuler-20.03-LTS-SP4)
- [support.huawei.com](https://support.huawei.com/supportindex/index)选择"企业技术支持"

6.6内核可直接切换到[`OLK-6.6`分支](https://gitee.com/openeuler/kernel/tree/OLK-6.6/)。

4.19内核切换到`openEuler-1.0-LTS`分支，可以使用脚本[`create-enfs-patchset.sh`](https://gitee.com/chenxiaosonggitee/blog/blob/master/course/nfs/src/create-enfs-patchset.sh)生成完整的补丁文件，
[再打上我修改的补丁](https://gitee.com/chenxiaosonggitee/tmp/tree/master/nfs/enfs-4.19-patch)，
也可以直接用[我的仓库kernel-enfs](https://gitee.com/chenxiaosonggitee/kernel-enfs/tree/openEuler-1.0-LTS/)。
编译前打开配置`CONFIG_ENFS`，可能还要关闭配置`CONFIG_NET_VENDOR_NETRONOME`。

挂载:
```sh
modprobe enfs
mount -t nfs -o localaddrs=192.168.53.40~192.168.53.53,remoteaddrs=192.168.53.215~192.168.53.216 192.168.53.216:/s_test /mnt/
```

如果没有创建`/etc/enfs/config.ini`，会报错`failed to open file:/etc/enfs/config.ini err:-2`，配置文件请参考[eNFS 使用指南](https://docs.openeuler.org/zh/docs/20.03_LTS_SP4/docs/eNFS/enfs%E4%BD%BF%E7%94%A8%E6%8C%87%E5%8D%97.html)。只需要在nfs client端支持enfs就可以，`/etc/enfs/config.ini`默认配置如下:
```sh
path_detect_interval=10 # 路径连通探测周期，单位 ： 秒
path_detect_timeout=10 # 路径连通探测消息越野时间，单位 ： 秒
multipath_timeout=0 # 选择其他路径达到的文件操作的超时阈值，0表示使用 mount 命令指定的 timeo 参数，不使用 eNFS 模块的配置，单位 ： 秒。
multipath_disable=0 # 启用 eNFS 特性
```

除了`mount`命令查看之外，还可以用以下方式:
```sh
cat /proc/enfs/192.168.53.216_0/path
cat /proc/enfs/192.168.53.216_0/stat
```

<!--
# 以前的代码分析（4.19）

[pull request](https://gitee.com/src-openeuler/kernel/pulls?assignee_id=&author_id=&label_ids=&label_text=&milestone_id=&priority=&project_id=src-openeuler%2Fkernel&project_type=&scope=&search=enfs&single_label_id=&single_label_text=&sort=closed_at+desc&status=merged&target_project=&tester_id=)和[补丁文件](https://gitee.com/src-openeuler/kernel/tree/openEuler-20.03-LTS-SP4)。

## [`1/6 nfs: add api to support enfs registe and handle mount option`](https://gitee.com/src-openeuler/kernel/blob/openEuler-20.03-LTS-SP4/0001-nfs_add_api_to_support_enfs_registe_and_handle_mount_option.patch)

```
At the NFS layer, the eNFS registration function is called back when
the mount command parses parameters. The eNFS parses and saves the IP
address list entered by users.
```

这个补丁实现了nfs层的enfs的接口，下面的代码流程是我看代码时的笔记:
```c
struct nfs_client_initdata
  void *enfs_option; /* struct multipath_mount_options * */

struct nfs_parsed_mount_data
  void *enfs_option; /* struct multipath_mount_options * */ 

struct nfs_client
  /* multi path private structure (struct multipath_client_info *) */
  void *cl_multipath_data;

struct enfs_adapter_ops

nfs4_create_server
  nfs4_init_server
    enfs_option = data->enfs_option
    nfs4_set_client
      .enfs_option = enfs_option,
      nfs_get_client
        nfs_match_client
          nfs_multipath_client_match
        nfs4_alloc_client
          nfs_create_multi_path_client
            nfs_multipath_router_get
              request_module("enfs")
              try_module_get(ops->owner) // 引用计数直到umount时才能释放
            nfs_multipath_client_info_init
          nfs_create_rpc_client
            .multipath_option = cl_init->enfs_option,

nfs4_free_client
  nfs_free_client
    nfs_free_multi_path_client
      nfs_multipath_router_put // 释放nfs_create_multi_path_client中一直持有的引用计数

nfs_parse_mount_options
  enfs_check_mount_parse_info
    enfs_parse_mount_options
      nfs_multipath_parse_options // parse_mount_options
        nfs_multipath_parse_ip_list
          nfs_multipath_parse_ip_list_inter
```

## [`2/6 sunrpc: add api to support enfs registe and create multipath then dispatch IO`](https://gitee.com/src-openeuler/kernel/blob/openEuler-20.03-LTS-SP4/0002-sunrpc_add_api_to_support_enfs_registe_and_create_multipath_then_dispatch_IO.patch)

```
At the sunrpc layer, the eNFS registration function is called back When
the NFS uses sunrpc to create rpc_clnt, the eNFS combines the IP address
list entered for mount to generate multiple xprts. When the I/O times
out, the callback function of the eNFS is called back so that the eNFS
switches to an available link for retry.
```

```c
// The high-level client handle
struct rpc_clnt
  bool cl_enfs

struct rpc_create_args
  // 这里使用了nfs层的结构体，耦合了
  void *multipath_option // struct multipath_mount_options

struct rpc_task
  unsigned long           tk_major_timeo

// RPC task flags
#define RPC_TASK_FIXED  0x0004          /* detect xprt status task */

struct rpc_multipath_ops

struct rpc_xprt
  atomic_long_t   queuelen;
  void *multipath_context;

struct rpc_xprt_switch
  unsigned int            xps_nactive;
  atomic_long_t           xps_queuelen;
  unsigned long           xps_tmp_time;

// 挂载
nfs4_alloc_client
  nfs_create_rpc_client
    rpc_create
      rpc_create_xprt
        rpc_multipath_ops_create_clnt

// 卸载
rpc_shutdown_client
  rpc_multipath_ops_releas_clnt

rpc_task_release_client / nfs4_async_handle_exception
  rpc_task_release_transport // 这里改成和主线一样
    rpc_task_release_xprt // 从主线搬运过来的

rpc_task_set_transport
  rpc_task_get_next_xprt // 从主线搬运过来的
    rpc_task_get_xprt // 从主线搬运过来的

call_reserveresult
  rpc_multipath_ops_task_need_call_start_again

call_transmit
  rpc_multipath_ops_prepare_transmit

call_timeout
  rpc_multipath_ops_failover_handle

rpc_clnt_add_xprt
  rpc_xprt_switch_set_roundrobin

rpc_init_task
  rpc_task_get_xprt // 和主线一样
```

## [`3/6 nfs: add enfs module for nfs mount option`](https://gitee.com/src-openeuler/kernel/blob/openEuler-20.03-LTS-SP4/0003-add_enfs_module_for_nfs_mount_option.patch)

```
The eNFS module registers the interface for parsing the mount command.
During the mount process, the NFS invokes the eNFS interface to enable
the eNFS to parse the mounting parameters of UltraPath. The eNFS module
saves the mounting parameters to the context of nfs_client.
```

## [`4/6 nfs: add enfs module for sunrpc multipatch`](https://gitee.com/src-openeuler/kernel/blob/openEuler-20.03-LTS-SP4/0004-add_enfs_module_for_sunrpc_multipatch.patch)

```
When the NFS invokes the SunRPC to create rpc_clnt, the eNFS interface
is called back. The eNFS creates multiple xprts based on the output IP
address list. When NFS V3 I/Os are delivered, eNFS distributes I/Os to
available links based on the link status, improving performance through
load balancing.
```

## [`5/6 nfs: add enfs module for sunrpc failover and configure`](https://gitee.com/src-openeuler/kernel/blob/openEuler-20.03-LTS-SP4/0005-add_enfs_module_for_sunrpc_failover_and_configure.patch)

```
When sending I/Os from the SunRPC module to the NFS server times out,
the SunRPC module calls back the eNFS module to reselect a link. The
eNFS module distributes I/Os to other available links, preventing
service interruption caused by a single link failure.
```

## [`6/6 nfs, sunrpc: add enfs compile option`](https://gitee.com/src-openeuler/kernel/blob/openEuler-20.03-LTS-SP4/0006-add_enfs_compile_option.patch)

```
The eNFS compilation option and makefile are added. By default, the eNFS
compilation is performed.
```
-->

