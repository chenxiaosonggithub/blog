[点击这里查看openEuler的nfs+的使用](https://chenxiaosong.com/course/nfs/openeuler-enfs.html)。

# [2025年08月15日 openEuler/kernel: fix some bugs of enfs](https://gitee.com/openeuler/kernel/pulls/17479/commits)

- <span style="color:red">bugfix: </span>[nfs/enfs: fix memory leak of shard_view_ctrl when removing nfs module](https://gitee.com/openeuler/kernel/commit/068e87b7ffc2d168cedd409e48e262b8dc0b9017)
- <span style="color:red">bugfix: </span>[nfs/enfs: set CONFIG_SUNRPC_ENFS=y by default](https://gitee.com/openeuler/kernel/commit/0b85eddf5ae7ab0cf1aec485e0e2fbd13b38ff1b)
- <span style="color:red">bugfix: </span>[nfs/enfs: fix alignment between struct rpc_clnt and rpc_clnt_reserve](https://gitee.com/openeuler/kernel/commit/59da5fcc7897637e47a2f7c63535379b01e26909)
- <span style="color:red">bugfix: </span>[nfs/enfs: fix error when showing dns list](https://gitee.com/openeuler/kernel/commit/ef21a71a781b6fb424d5aa0229b37be4788e3136)
- [nfs/enfs: support debugging ip and dns list](https://gitee.com/openeuler/kernel/commit/7d7c14ce5591646018ff176c1e232eef23c332fb)
- [nfs/enfs: unlock uniformly at the end of function in shard_route.c](https://gitee.com/openeuler/kernel/commit/c214f46042043f23f8b916a8f7275dc49c773999)
- [nfs/enfs: format get_ip_to_str() in shard_route.c](https://gitee.com/openeuler/kernel/commit/c591cbd938429333b46451adc60a30c967b50e33)
- [nfs/enfs: remove enfs_init() and enfs_fini()](https://gitee.com/openeuler/kernel/commit/5c582afec12819031e40ac56ad6f77adccfde048)
- [nfs/enfs: make some functions static in enfs_multipath_client.c](https://gitee.com/openeuler/kernel/commit/bc954e6ba5c80f2f7fafde7cd2eb818628421786)

# [2025年08月02日 openEuler/kernel: fix some panic bugs and memory leak bugs of enfs](https://gitee.com/openeuler/kernel/pulls/17205/commits)

- <span style="color:red">bugfix: </span>[nfs/enfs: fix null-ptr-deref in shard_update_work()](https://gitee.com/openeuler/kernel/commit/b29f941d7c6454ae39e85a23d8a004f47b274505)
- <span style="color:red">bugfix: </span>[nfs/enfs: fix double free of multipath_client_info](https://gitee.com/openeuler/kernel/commit/d6f01631a69cbca08be0157a09f30a93283c50d4)
- <span style="color:red">bugfix: </span>[nfs/enfs: fix memory leak in enfs_delete_fs_info()](https://gitee.com/openeuler/kernel/commit/f42fc08b94165563565d2c3cfda2bf208b2579cd)
- [nfs/enfs: introduce DEFINE_CLEAR_LIST_FUNC to define enfs_clear_fs_info()](https://gitee.com/openeuler/kernel/commit/2d5981287b67cc1a5d9231bff267f90001251ba3)
- [nfs/enfs: use DEFINE_CLEAR_LIST_FUNC to define enfs_clear_shard_view()](https://gitee.com/openeuler/kernel/commit/c91d7a809058cb3e7dfe883f7273d2f3e4dfea5a)
- <span style="color:red">bugfix: </span>[nfs/enfs: fix memory leak when free view_table](https://gitee.com/openeuler/kernel/commit/ca593c48d1e16a8143aa02ec6f8234d1a05af45e)
- [nfs/enfs: introduce DEFINE_PARSE_FH_FUNC to define parse_fh()](https://gitee.com/openeuler/kernel/commit/341daeb30f7a89cce5b355a537c49064ccd6a0cf)
- [nfs/enfs: make some functions static in shard_route.c](https://gitee.com/openeuler/kernel/commit/219d679b1436559ee1997f657294a29631f3dfbc)
- [nfs/enfs: remove unused functions in shard_route.c](https://gitee.com/openeuler/kernel/commit/a08dbac46462aacf6b2d34dd69b7b93c67383442)
- [nfs/enfs: fix typos in shard_route.c](https://gitee.com/openeuler/kernel/commit/fddc2e489dfbdc50e57d1716641fdaad54a6bf04)
- [nfs/enfs: remove nfs_multipath_client_info_free_work()](https://gitee.com/openeuler/kernel/commit/d11adecaa2cf72263a972a7348377c7c92e50ee4)
- [nfs/enfs: remove judgement about enfs_option in nfs_multipath_client_info_init()](https://gitee.com/openeuler/kernel/commit/1b175bd74767555c8d096ff44483834b78921ec9)
- [sunrpc: remove redundant rpc_task_release_xprt() of enfs](https://gitee.com/openeuler/kernel/commit/918127ac2167cf836ce2ebcb3b15665584bccb77)
- [nfs/enfs: remove usage of list_entry_is_head() in shard_route.c](https://gitee.com/openeuler/kernel/commit/23ee6e77f816d7527aa8a0eb7bf7bcce88d99db9)
- [nfs/enfs: remove enfs_uuid_debug in shard_route.c](https://gitee.com/openeuler/kernel/commit/11caad69b1bff61d4b809a8126e866cfab81e34e)
- [nfs/enfs: remove unnecessary shard_should_stop in shard_route.c](https://gitee.com/openeuler/kernel/commit/0f58edce86117b769f8e675a2265336676c780c1)

# [2025年07月26日 openEuler/kernel: unify log function usage of enfs](https://gitee.com/openeuler/kernel/pulls/17266/commits)

<!--
搜索日志函数:
  - git diff 搜索: dprintk|dfprintk|pr_info|pr_err|pr_debug
  - vim 搜索: dprintk\|dfprintk\|pr_info\|pr_err\|pr_debug
  - grep: grep -E dprintk\|dfprintk\|pr_info\|pr_err\|pr_debug
-->

- <span style="color:red">feature: </span>[nfs: use dfprintk() to debug enfs](https://gitee.com/openeuler/kernel/commit/e6faa11b29056bfdd959b913c1da731f3f8f5770)
- [nfs/enfs: use enfs_log_debug() instead of dfprintk() to debug enfs](https://gitee.com/openeuler/kernel/commit/74cbdf25fcf1cd15c2a2de1050f8b42bd93aa9d2)
- [nfs/enfs: remove unused code in enfs/dns_internal.h](https://gitee.com/openeuler/kernel/commit/28504d23f7771a50d8bbdd1882854861ea41feb6)
- [nfs/enfs: use enfs_log_debug() instead of pr_debug() to debug enfs](https://gitee.com/openeuler/kernel/commit/fac67ff637aa9d6301bb948bdb201416a7b2405f)
- [nfs/enfs: cleanups in enfs/shard_route.c](https://gitee.com/openeuler/kernel/commit/4fa937704cd76e82c6c91fe28e9a816aab3b690c)
- [nfs/enfs: use enfs_log_info() instead of pr_info() in enfs](https://gitee.com/openeuler/kernel/commit/de09a3d1076cccbce3970d3ee1008c6f6101e9b8)
- [nfs/enfs: use enfs_log_error() instead of pr_err() in enfs](https://gitee.com/openeuler/kernel/commit/69ccb9f7620d556dc3cd02572d34b145564d8591)

# [2025年07月04日 openEuler/kernel: fix some build errors of enfs](https://gitee.com/openeuler/kernel/pulls/16891/commits)

- <span style="color:red">bugfix: </span>[nfs: fix enfs mount failure when CONFIG_ENFS=y](https://gitee.com/openeuler/kernel/commit/f4f81ee1ead7362e5bb0b6b2fdebb3049cbaa76e)
- <span style="color:red">bugfix: </span>[nfs: fix build errors when CONFIG_ENFS=m && CONFIG_NFS_FS=y](https://gitee.com/openeuler/kernel/commit/53806d18641c15b833cd6f4f7c540c3018099d7f)
- <span style="color:red">bugfix: </span>[sunrpc, nfs: fix build errors when CONFIG_SUNRPC_ENFS=m && CONFIG_ENFS=m && CONFIG_NFS=y](https://gitee.com/openeuler/kernel/commit/2b5eae5c990f2df1de43dbae22fd46ebab87a3af)
- <span style="color:red">bugfix: </span>[sunrpc, nfs: CONFIG_ENFS should select CONFIG_SUNRPC_ENFS](https://gitee.com/openeuler/kernel/commit/9ec2dde4a003ebdebab8bf6f54e2c96c229b85ce)

