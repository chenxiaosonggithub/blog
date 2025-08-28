正在更新的内容都放到这篇文章中，等到有些知识点达到一定量时，会把这些知识点整理成专门的一章。

# `df`命令

client会发送两个`GETATTR`请求，第一个`GETATTR`请求以下内容:

- `Attr mask[0]: 0x0010011a (Type, Change, Size, FSID, FileId)`
- `Attr mask[1]: 0x00b0a23a (Mode, NumLinks, Owner, Owner_Group, RawDev, Space_Used, Time_Access, Time_Metadata, Time_Modify, Mounted_on_FileId)`

第二个`GETATTR`请求以下内容:

- `Attr mask[0]: 0x00e00000 (Files_Avail, Files_Free, Files_Total)`
- `Attr mask[1]: 0x00001c00 (Space_Avail, Space_Free, Space_Total)`

执行`df`命令后，再执行`echo 3 > /proc/sys/vm/drop_caches`后立刻执行`df`命令，不会执行到`__nfs_revalidate_inode()`。

# 网络超时

```sh
systemctl stop nfs-server
stat /mnt/file

[100196.619028] nfs: server localhost not responding, still trying
[100216.521372] nfs: server localhost not responding, timed out
```

# delegation

`echo something > /mnt/file; echo 3 > /proc/sys/vm/drop_caches; cat > /mnt/file`:
```c
nfsd4_open
  nfsd4_process_open2
    nfs4_open_delegation
      nfs4_set_delegation
        alloc_init_deleg
          nfs4_alloc_stid
      nfs4_put_stid(&dp->dl_stid)
```

`echo 3 > /proc/sys/vm/drop_caches`:
```c
nfsd4_delegreturn
  destroy_delegation
    destroy_unhashed_deleg
      nfs4_put_stid
  nfs4_put_stid
```

# Procedures和Operations

## NFSv2 Procedures

NFSv2的Procedures定义在`include/uapi/linux/nfs2.h`中的`NFSPROC_NULL ~ NFSPROC_STATFS`，编码解码函数定义在`nfs_procedures`和`nfsd_procedures2`。

## NFSv3 Procedures

NFSv3的Procedures定义在`include/uapi/linux/nfs3.h`中的`NFS3PROC_NULL ~ NFS3PROC_COMMIT`，编码解码函数定义在`nfs3_procedures`和`nfsd_procedures3`。

## NFSv4 Procedures和Operations

NFSv4的Procedures定义在`include/linux/nfs4.h`中的`NFSPROC4_NULL`和`NFSPROC4_COMPOUND`，server编码解码函数定义在`nfsd_procedures4`。

NFSv4 server详细的Operations定义在`include/linux/nfs4.h`中的`enum nfs_opnum4`，处理函数定义在`nfsd4_ops`，编码解码函数定义在`nfsd4_enc_ops`和`nfsd4_dec_ops`。

NFSv4 client详细的Operations定义在`include/linux/nfs4.h`中的`NFSPROC4_CLNT_NULL ~ NFSPROC4_CLNT_READ_PLUS`，编码解码函数定义在`nfs4_procedures`。

## 反向通道Operations

NFSv4反向通道的Operations定义在`include/linux/nfs4.h`中的`enum nfs_cb_opnum4`(老版本内核还重复定义在`fs/nfs/callback.h`中的`enum nfs4_callback_opnum`，我已经提补丁移到公共头文件: [NFSv4, NFSD: move enum nfs_cb_opnum4 to include/linux/nfs4.h](https://lore.kernel.org/all/tencent_03EDD0CAFBF93A9667CFCA1B68EDB4C4A109@qq.com/))，server在`fs/nfsd/state.h`中还定义了`nfsd4_cb_op`，编码解码函数定义在`nfs4_cb_procedures`。client的编码解码函数定义在`callback_ops`。

# exportfs

`struct export_operations`

#  文件句柄

```sh
                    1.  +------------+ 6.
                   +----|   client   |>>>>>>>>>>+
                   |    +------------+          | 
           hey man,|          ^               你好像在逗我
    can you tell me|          |额，你猜？
 whose inode is 12?|        5.|                 |         
                   |    +------------+          |   
                   +--->|   server   |<<<<<<<<<<+  
                        +------------+
                         |  ^    ^  |
                     2.1.|  |    |  |2.2.
               +---------+  |    |  +---------+
               |            |    |            |
       hey boy |       i know   i know too    |hey girl
   do you know?|            |    |            |do you know?
               v            |    |            v      
          +----------+ 4.1. |    |4.2.   +----------+ 
          | /dev/sda |------+    +-------| /dev/sdb |
          +----------+                   +----------+
               ^                              ^      
        i am 12|                              |i am 12
               |3.1.                      3.2.|
          +----------+                   +----------+
          |   file   |                   |   file   |
          +----------+                   +----------+
```

# idmap

启用idmap:
```sh
echo N > /sys/module/nfsd/parameters/nfs4_disable_idmapping # server，默认为Y
echo N > /sys/module/nfs/parameters/nfs4_disable_idmapping # client，默认为Y
```

server端`/etc/idmapd.conf`文件配置:
```sh
[General]

Verbosity = 0
Pipefs-Directory = /run/rpc_pipefs
# set your own domain here, if it differs from FQDN minus hostname
# 修改成其他值，客户端nfs_map_name_to_uid和nfs_map_group_to_gid函数中的id不为0
Domain = localdomain

[Mapping]

Nobody-User = nobody
Nobody-Group = nogroup
```

# 函数流程

## rpc

```c
// 挂载时
nfs4_alloc_client
  nfs_create_rpc_client
    rpc_create
      rpc_create_xprt // 只会在挂载时执行到
        rpc_ping
          rpc_call_null_helper
            rpc_call_null_helper
              rpc_run_task

rpc_run_task / rpc_run_bc_task
  rpc_new_task
    rpc_init_task
      rpc_task_get_xprt
  rpc_execute
    rpc_make_runnable
      INIT_WORK(&task->u.tk_work, rpc_async_schedule) // 异步执行
    __rpc_execute // 同步执行，异步在内核线程执行到这个函数

rpc_task_release_client / nfs4_async_handle_exception
  rpc_task_release_transport

rpc_task_set_client / call_start
  rpc_task_set_transport
```

## mount

```c
vfs_parse_fs_param
  // 不指定版本号挂载时，默认用哪个版本由 `mount.nfs` 程序决定
  nfs_fs_context_parse_param

// v3
vfs_get_tree
  nfs_get_tree
    nfs_try_get_tree
      nfs_try_mount_request
        nfs3_create_server
          nfs_create_server
            nfs_init_server
              nfs_get_client
                nfs_match_client
                nfs_alloc_client
                nfs_init_client

// v4
vfs_get_tree
  nfs_get_tree
    nfs4_try_get_tree
      nfs4_create_server
        nfs4_init_server
          nfs4_set_client
            nfs_get_client
              nfs_match_client
              nfs4_alloc_client
                nfs_create_rpc_client
                  rpc_create
              nfs4_init_client
                nfs4_discover_server_trunking
                  nfs41_discover_server_trunking // 返回的 nfs_client 未就绪
                    nfs4_proc_exchange_id
              nfs4_add_trunk // 主线的多路径？
                rpc_clnt_add_xprt

kthread
  nfs4_run_state_manager
    nfs4_state_manager
      nfs4_reclaim_lease
        nfs4_establish_lease
          nfs41_init_clientid
            nfs4_proc_exchange_id
            nfs4_proc_create_session
            nfs_mark_client_ready(clp, NFS_CS_READY) // 设置成就绪状态
      nfs4_state_end_reclaim_reboot
        nfs4_reclaim_complete
          nfs41_proc_reclaim_complete
```

## umount

```c
// v4
task_work_run
  __cleanup_mnt
    cleanup_mnt
      deactivate_super
        deactivate_locked_super
          nfs_kill_super
            nfs_free_server
              rpc_shutdown_client
              nfs_put_client
                nfs4_free_client
                  nfs4_shutdown_client
                    nfs41_shutdown_client
                      nfs4_destroy_session
                        nfs4_proc_destroy_session
                      nfs4_destroy_clientid
                        nfs4_proc_destroy_clientid
                          _nfs4_proc_destroy_clientid
                  nfs_free_client
                    rpc_shutdown_client
```

## read

```c
read
  ksys_read
    vfs_read
      new_sync_read
        nfs_file_read
          generic_file_read_iter
            filemap_read
              filemap_get_pages
                page_cache_sync_readahead
                  page_cache_sync_ra
                    page_cache_ra_order
                      read_pages
                        nfs_readahead // 低版本是 nfs_readpages
                          nfs_pageio_complete_read
                            nfs_pageio_complete
                              nfs_pageio_complete_mirror
                                nfs_pageio_doio
                                  nfs_generic_pg_pgios
                                    nfs_initiate_pgio
                                      atomic_set(&task->tk_count, 1) // 引用计数
                                      .flags = RPC_TASK_ASYNC | flags, // 异步
                                      nfs_initiate_read
                                        nfs3_proc_read_setup
                                          &nfs3_procedures[NFS3PROC_READ]
                                      rpc_run_task
                                        rpc_new_task
                                          rpc_init_task
                                            task->tk_flags  = task_setup_data->flags // flag在这里赋值
                                        atomic_inc(&task->tk_count) // 引用计数加1
                                        rpc_execute
                                          rpc_make_runnable
                                            INIT_WORK(&task->u.tk_work, rpc_async_schedule)
                filemap_update_page
                  folio_put_wait_locked // folio_unlock()唤醒？
                    folio_wait_bit_common
```

