[点击这里查看openEuler的nfs+的使用](https://chenxiaosong.com/course/nfs/openeuler-enfs.html)。

nfs+（Enhanced NFS，简称 eNFS），是华为提出的，麒麟软件等公司共同参与开发的特性，对 Linux 内核原生 NFS 进行增强，通过多链路等技术很好的解决原生 NFS 客户端在性能和可靠性方面存在的一些不足，极大提升业务的性能与稳定性。

# [openEuler/kernel: enfs: add new path state PM_STATE_UNSTABLE](https://gitee.com/openeuler/kernel/pulls/18249/commits)

- <span style="color:red">feature: </span>[nfs/enfs: introduce enum PM_STATE_UNSTABLE](https://gitee.com/openeuler/kernel/commit/9220b0cf32cfb5c0f0eb8777298a77875d896267)
- <span style="color:red">feature: </span>[nfs/enfs: set PM_STATE_UNSTABLE if path is unstable](https://gitee.com/openeuler/kernel/commit/e961e79037beaa80d7709dd8ae2bf682263ce537)
- <span style="color:red">feature: </span>[nfs/enfs: introduce reconnect time KUnit tests](https://gitee.com/openeuler/kernel/commit/1c9eb515727c21c6c7b8212f40c006d656473bb6)
- <span style="color:red">feature: </span>[nfs/enfs: prefer normal rpc transport over unstable one](https://gitee.com/openeuler/kernel/commit/456df8f077c45533e49990364a9594008f9df8e8)
- [nfs/enfs: cleanups in pm_set_path_state()](https://gitee.com/openeuler/kernel/commit/b46237072d129a16a1ad2d671fab93ada3ff04bc)

# [2025年09月25日 openEuler/kernel: enfs: recreate shard info when re-adding enfs module](https://gitee.com/openeuler/kernel/pulls/17973/commits)

12 个补丁，改动 440 行。
<!--
4 +7  +16 +9  +6 +12  = 54
15+355+537+314+61+440 = 1722
-->

- <span style="color:red">feature: </span>[nfs/enfs: recreate shard info when re-adding enfs module](https://gitee.com/openeuler/kernel/commit/01f8a9007306f71ce2f9d1642d0de754b976c353)
- <span style="color:red">bugfix: </span>[nfs/enfs: reload config when re-adding enfs module](https://gitee.com/openeuler/kernel/commit/c83bfa180d2e2a0b9f1a39cc641b4b4839f5d8b3)
- <span style="color:red">bugfix: </span>[nfs/enfs: fix possible memory leak in exten_call.c](https://gitee.com/openeuler/kernel/commit/b31506834cd780cb0574b0d48c85cffabf73e6ca)
- [nfs/enfs: free memory uniformly at the end of function in exten_call.c](https://gitee.com/openeuler/kernel/commit/b6300d7bb68a616ffa9ee278daead4cb3e9698c1)
- <span style="color:red">bugfix: </span>[nfs/enfs: fix possible null-ptr-deref in exten_call.c](https://gitee.com/openeuler/kernel/commit/ba6ad67f35cf88bfc9036cd7c30a23957a7b38b4)
- <span style="color:red">bugfix: </span>[nfs/enfs: handle error returned by NfsExtendProcInfoExtendEncode()](https://gitee.com/openeuler/kernel/commit/d2f0e013f9f87e5d60f65602517fa9837cde5e12)
- [nfs/enfs: return more nuanced error in NfsExtendProcInfoExtendEncode() and NfsExtendProcInfoExtendDecode()](https://gitee.com/openeuler/kernel/commit/965d05feb591c2675cdcc15d4f23f1d3ca8e8610)
- [nfs/enfs: remove redundant flush_workqueue() before destroy_workqueue()](https://gitee.com/openeuler/kernel/commit/6887a78ae29e55d6bb8d99177afd2e0dc0bbe424)
- [nfs/enfs: remove lookupcache_workq_lock](https://gitee.com/openeuler/kernel/commit/8f2393a3b9b05e718df2a9bee9aafc94546b61b0)
- [nfs/enfs: remove ping_execute_workq_lock](https://gitee.com/openeuler/kernel/commit/2ce743a252aa9f7b58e7d42ae65e936c440d67b9)
- [nfs/enfs: remove enfs_tp_common.h](https://gitee.com/openeuler/kernel/commit/5797e07079ce65c21872506f9fc8cda9cc413c55)
- [nfs/enfs: remove duplicate EOPNOTSUPP definition](https://gitee.com/openeuler/kernel/commit/9b3a7b07e0df58566869da185945346f43a358f9)

# [2025年09月12日 openEuler/kernel: enfs: fix some bugs and optimize performance](https://gitee.com/openeuler/kernel/pulls/17898/commits)

6 个补丁，改动 61 行。
<!--
4 +7  +16 +9  +6
15+355+537+314+61
-->

- <span style="color:red">performance: </span>[sunrpc: do not set enfs transport in rpc_task_set_client()](https://gitee.com/openeuler/kernel/commit/24f295baf843a8d506ea8ff7c14f9435b8f9a62b)
- <span style="color:red">performance: </span>[nfs/enfs: get rpc procedure number from rpc_procinfo in get_uuid_from_task()](https://gitee.com/openeuler/kernel/commit/0e7a7ac732578ca804d5d81b26ef88869669d5a6)
- <span style="color:red">bugfix: </span>[nfs/enfs: introduce is_enfs_debug()](https://gitee.com/openeuler/kernel/commit/0fbb6e383e6818e7f24f90388d061f020f9640b0)
- <span style="color:red">bugfix: </span>[nfs/enfs: fix finding root uuid issue](https://gitee.com/openeuler/kernel/commit/96155a2ffed0ef662cfb6f30c9eaf575d19c9cc0)
- [nfs/enfs: fix some cleanup issues](https://gitee.com/openeuler/kernel/commit/22519a440ab80af2f3c8530aec7a4a1b3c9892ea)
- [nfs/enfs: remove duplicate definitions](https://gitee.com/openeuler/kernel/commit/960de6c02b85577e9b2851bcf1ef42a8c4b5376f)

# [2025年08月15日 openEuler/kernel: fix some bugs of enfs](https://gitee.com/openeuler/kernel/pulls/17479/commits)

9 个补丁，改动 314 行。
<!--
4 +7  +16 +9
15+355+537+314
-->

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

16 个补丁，改动 537 行。
<!--
4 +7  +16
15+355+537
-->

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

7 个补丁，改动 355 行。
<!--
4 +7
15+355
-->

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

4 个补丁，改动 15 行。

- <span style="color:red">bugfix: </span>[nfs: fix enfs mount failure when CONFIG_ENFS=y](https://gitee.com/openeuler/kernel/commit/f4f81ee1ead7362e5bb0b6b2fdebb3049cbaa76e)
- <span style="color:red">bugfix: </span>[nfs: fix build errors when CONFIG_ENFS=m && CONFIG_NFS_FS=y](https://gitee.com/openeuler/kernel/commit/53806d18641c15b833cd6f4f7c540c3018099d7f)
- <span style="color:red">bugfix: </span>[sunrpc, nfs: fix build errors when CONFIG_SUNRPC_ENFS=m && CONFIG_ENFS=m && CONFIG_NFS=y](https://gitee.com/openeuler/kernel/commit/2b5eae5c990f2df1de43dbae22fd46ebab87a3af)
- <span style="color:red">bugfix: </span>[sunrpc, nfs: CONFIG_ENFS should select CONFIG_SUNRPC_ENFS](https://gitee.com/openeuler/kernel/commit/9ec2dde4a003ebdebab8bf6f54e2c96c229b85ce)

