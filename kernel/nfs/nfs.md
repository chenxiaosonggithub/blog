[toc]

# 环境

```shell
apt-get install nfs-kernel-server -y # debian
```

`/etc/exports`:
```shell
/tmp/ *(rw,no_root_squash,fsid=0)
/tmp/s_test/ *(rw,no_root_squash,fsid=1)
/tmp/s_scratch *(rw,no_root_squash,fsid=2)
```

启动 nfs server:
```shell
mkfs.ext4 -b 4096 -F /dev/sda
mkfs.ext4 -b 4096 -F /dev/sdb

mkdir /tmp/s_test
mkdir /tmp/s_scratch

mount -t ext4 /dev/sda /tmp/s_test
mount -t ext4 /dev/sdb /tmp/s_scratch

ulimit -n 65535
# iptables -F
exportfs -r
systemctl stop firewalld
setenforce 0
systemctl restart nfs-server.service
systemctl restart rpcbind

chmod 777 /tmp/s_test
chmod 777 /tmp/s_scratch

mkdir /tmp/test
mkdir /tmp/scratch
```

挂载：
```shell
# nfsv4
mount -t nfs -o vers=4.1 192.168.122.87:/s_test /mnt
# nfsv3 要写完整的源路径
mount -t nfs -o vers=3 192.168.122.87:/tmp/s_test /mnt
# nfsv2, nfs server 需要修改 /etc/nfs.conf, [nfsd] vers2=y
mount -t nfs -o vers=2 192.168.122.87:/tmp/s_test /mnt
```

# mount

按顺序从上往下, nfsv4.1

```c
mount
  do_mount
    path_mount
      do_new_mount
        vfs_get_tree
          nfs_get_tree
            nfs4_try_get_tree
              nfs4_create_server
                nfs4_init_server // 初始化 super_block (nfs_server)
                  nfs4_set_client
                    nfs_get_client
                      nfs4_alloc_client
                        nfs_create_rpc_client
                          rpc_create
                            rpc_create_xprt
                              rpc_ping
                                rpc_call_null_helper
                                  rpc_run_task
                                    rpc_execute
                      nfs4_init_client
                        nfs4_discover_server_trunking
                          nfs41_discover_server_trunking // 返回的 nfs_client 未就绪
                            nfs4_proc_exchange_id
                              _nfs4_proc_exchange_id
                                nfs4_run_exchange_id
                                  rpc_run_task
                                    rpc_execute

kthread
  nfs4_run_state_manager
    nfs4_state_manager
      nfs4_reclaim_lease
        nfs4_establish_lease
          nfs41_init_clientid
            nfs4_proc_exchange_id
              _nfs4_proc_exchange_id
                nfs4_run_exchange_id
                  rpc_run_task
                    rpc_execute
            nfs4_proc_create_session
              _nfs4_proc_create_session
                rpc_call_sync
                  rpc_run_task
                    rpc_execute
            nfs_mark_client_ready(clp, NFS_CS_READY) // 设置成就绪状态
      nfs4_state_end_reclaim_reboot
        nfs4_reclaim_complete
          nfs41_proc_reclaim_complete
            nfs4_call_sync_custom
              rpc_run_task
                rpc_execute


do_mount
  path_mount
    do_new_mount
      vfs_get_tree
        nfs_get_tree
          nfs4_try_get_tree
            nfs4_create_server
              nfs4_init_server // 已执行完
              nfs4_server_common_setup
                nfs4_get_rootfh
                  nfs4_proc_get_rootfh
                    nfs41_find_root_sec
                      nfs41_proc_secinfo_no_name
                        _nfs41_proc_secinfo_no_name
                          nfs4_call_sync_custom
                            rpc_run_task
                              rpc_execute
                      nfs4_lookup_root_sec
                        nfs4_lookup_root
                          _nfs4_lookup_root
                            nfs4_call_sync
                              nfs4_call_sync_sequence
                                nfs4_do_call_sync
                                  nfs4_call_sync_custom
                                    rpc_run_task
                                      rpc_execute
                    nfs4_server_capabilities
                      _nfs4_server_capabilities
                        nfs4_call_sync
                          nfs4_call_sync_sequence
                            nfs4_do_call_sync
                              nfs4_call_sync_custom
                                rpc_run_task
                                  rpc_execute
                    nfs4_do_fsinfo
                      _nfs4_do_fsinfo
                        nfs4_call_sync
                          nfs4_call_sync_sequence
                            nfs4_do_call_sync
                              nfs4_call_sync_custom
                                rpc_run_task
                                  rpc_execute
                nfs_probe_server
                  nfs_probe_fsinfo
                    // clp->rpc_ops->set_capabilities
                    nfs4_server_capabilities
                      _nfs4_server_capabilities
                        nfs4_call_sync
                          nfs4_call_sync_sequence
                            nfs4_do_call_sync
                              nfs4_call_sync_custom
                                rpc_run_task
                                  rpc_execute
                    // clp->rpc_ops->fsinfo
                    nfs4_proc_fsinfo
                      nfs4_do_fsinfo
                        _nfs4_do_fsinfo
                          nfs4_call_sync
                            nfs4_call_sync_sequence
                              nfs4_do_call_sync
                                nfs4_call_sync_custom
                                  rpc_run_task
                                    rpc_execute
                    // clp->rpc_ops->pathconf
                    nfs4_proc_pathconf
                      _nfs4_proc_pathconf
                        nfs4_call_sync
                          nfs4_call_sync_sequence
                            nfs4_do_call_sync
                              nfs4_call_sync_custom
                                rpc_run_task
                                  rpc_execute
            do_nfs4_mount(nfs_create_server, ...) // nfs_create_server 已执行完
              fc_mount
                vfs_get_tree
                  nfs_get_tree
                    nfs_get_tree_common
                      nfs_get_root
                        nfs4_proc_get_root
                          nfs4_server_capabilities
                            _nfs4_server_capabilities
                              nfs4_call_sync
                                nfs4_call_sync_sequence
                                  nfs4_do_call_sync
                                    nfs4_call_sync_custom
                                      rpc_run_task
                                        rpc_execute
                          nfs4_proc_getattr
                            _nfs4_proc_getattr
                              nfs4_do_call_sync
                                nfs4_call_sync_custom
                                  rpc_run_task
                                    rpc_execute
              mount_subtree
                vfs_path_lookup
                  filename_lookup
                    path_lookupat
                      link_path_walk
                        inode_permission
                          nfs_permission
                            nfs_do_access
                              nfs4_proc_access
                                _nfs4_proc_access
                                  nfs4_call_sync
                                    nfs4_call_sync_sequence
                                      nfs4_do_call_sync
                                        nfs4_call_sync_custom
                                          rpc_run_task
                                            rpc_execute
                      lookup_last // 内联
                        walk_component
                          lookup_slow
                            __lookup_slow
                              nfs_lookup
                                nfs4_proc_lookup
                                  nfs4_proc_lookup_common
                                    _nfs4_proc_lookup
                                      nfs4_do_call_sync
                                        nfs4_call_sync_custom
                                          rpc_run_task
                                            rpc_execute
                          step_into
                            __traverse_mounts
                              follow_automount
                                nfs_d_automount
                                  nfs4_submount
                                    nfs4_proc_lookup_mountpoint
                                      nfs4_proc_lookup_common
                                        _nfs4_proc_lookup
                                          nfs4_do_call_sync
                                            nfs4_call_sync_custom
                                              rpc_run_task
                                                rpc_execute
                                    nfs_do_submount
                                      nfs_clone_server
                                        nfs_probe_server
                                          nfs_probe_fsinfo
                                            nfs4_server_capabilities
                                              _nfs4_server_capabilities
                                                nfs4_call_sync
                                                  nfs4_call_sync_sequence
                                                    nfs4_do_call_sync
                                                      nfs4_call_sync_custom
                                                        rpc_run_task
                                                          rpc_execute
                                            nfs4_proc_fsinfo
                                              nfs4_do_fsinfo
                                                _nfs4_do_fsinfo
                                                  nfs4_call_sync
                                                    nfs4_call_sync_sequence
                                                      nfs4_do_call_sync
                                                        nfs4_call_sync_custom
                                                          rpc_run_task
                                                            rpc_execute
                                            nfs4_proc_pathconf
                                              _nfs4_proc_pathconf
                                                nfs4_call_sync
                                                  nfs4_call_sync_sequence
                                                    nfs4_do_call_sync
                                                      nfs4_call_sync_custom
                                                        rpc_run_task
                                                          rpc_execute
                                      vfs_get_tree
                                        nfs_get_tree
                                          nfs_get_tree_common
                                            nfs_get_root
                                              nfs4_proc_get_root
                                                nfs4_server_capabilities
                                                  _nfs4_server_capabilities
                                                    nfs4_call_sync
                                                      nfs4_call_sync_sequence
                                                        nfs4_do_call_sync
                                                          nfs4_call_sync_custom
                                                            rpc_run_task
                                                              rpc_execute
                                                nfs4_proc_getattr
                                                  _nfs4_proc_getattr
                                                    nfs4_do_call_sync
                                                      nfs4_call_sync_custom
                                                        rpc_run_task
                                                          rpc_execute
```

## mount 参数

```c
nfs_fs_context_parse_param
```

不指定版本号挂载时，默认用哪个版本由 `mount.nfs` 程序决定。

# umount

```c
do_syscall_64
  syscall_exit_to_user_mode
    exit_to_user_mode_prepare
      exit_to_user_mode_loop
        task_work_run
          __cleanup_mnt
            cleanup_mnt
              deactivate_super
                deactivate_locked_super
                  nfs_kill_super
                    nfs_free_server
                      nfs_put_client
                        nfs4_free_client
                          nfs4_shutdown_client
                            nfs41_shutdown_client
                              nfs4_destroy_session
                                nfs4_proc_destroy_session
                                  rpc_call_sync
                                    rpc_run_task
                                      rpc_execute
                              nfs4_destroy_clientid
                                nfs4_proc_destroy_clientid
                                  _nfs4_proc_destroy_clientid
                                    rpc_call_sync
                                      rpc_run_task
                                        rpc_execute
```

# read

```c
read
  ksys_read
    vfs_read
      new_sync_read
        nfs_file_read
          generic_file_read_iter
            filemap_read
              filemap_get_pages
                page_cache_sync_ra
                  ondemand_readahead
                    page_cache_ra_order
                      do_page_cache_ra
                        page_cache_ra_unbounded
                          read_pages
                            nfs_readahead // 低版本是　nfs_readpages
                              nfs_pageio_complete_read
                                nfs_pageio_complete
                                  nfs_pageio_complete_mirror
                                    nfs_pageio_doio
                                      nfs_generic_pg_pgios
                                        nfs_initiate_pgio
                                          rpc_run_task
                                            rpc_execute
```

# write

```c
dup2
  ksys_dup3
    do_dup2
      filp_close
        nfs4_file_flush
          nfs_wb_all
            filemap_write_and_wait_range
              __filemap_fdatawrite_range
                filemap_fdatawrite_wbc
                  do_writepages
                    nfs_writepages
                      write_cache_pages
                        nfs_writepages_callback// (*writepage)()
                          nfs_do_writepage
                            nfs_page_async_flush
                              nfs_set_page_writeback
                                test_set_page_writeback
                      nfs_pageio_complete
                        nfs_pageio_complete_mirror
                          nfs_pageio_doio
                            nfs_generic_pg_pgios
                              nfs_initiate_pgio
                                rpc_run_task
                                  rpc_execute
              __filemap_fdatawait_range
                wait_on_page_writeback
                  folio_wait_writeback
                    folio_wait_bit(PG_writeback)

kthread
  worker_thread
    process_one_work
      rpc_async_release
        rpc_free_task
          rpc_release_calldata
            nfs_pgio_release
              nfs_write_completion
                nfs_end_page_writeback
```

# open

```c
open
  do_sys_open
    do_sys_openat2
      do_filp_open
        path_openat
          link_path_walk
            inode_permission
              nfs_permission
                nfs_do_access
                  nfs4_proc_access // 第一次打开时执行到这里
                    _nfs4_proc_access
                      nfs4_call_sync
                        nfs4_call_sync_sequence
                          nfs4_do_call_sync
                            nfs4_call_sync_custom
                              rpc_run_task
                                rpc_execute
                  nfs_access_get_cached // 第二次打开执行到这里
                    nfs_access_get_cached_locked
                      __nfs_revalidate_inode
                        nfs4_proc_getattr
                          _nfs4_proc_getattr
                            nfs4_do_call_sync
                              nfs4_call_sync_custom
                                rpc_run_task
                                  rpc_execute
          open_last_lookups // 第一次打开执行到这里
            lookup_open
              atomic_open
                nfs_atomic_open
                  nfs4_atomic_open
                    nfs4_do_open
                      _nfs4_do_open
                        _nfs4_open_and_get_state
                          _nfs4_proc_open
                            nfs4_run_open_task
                              rpc_run_task
                                rpc_execute
          do_open // 第二次打开执行到这里
            vfs_open
              do_dentry_open
                nfs4_file_open
                  nfs4_atomic_open
                    nfs4_do_open
                      _nfs4_do_open
                        _nfs4_open_and_get_state
                          _nfs4_proc_open
                            nfs4_run_open_task
                              rpc_run_task
                                rpc_execute
            handle_truncate // 第二次运行echo命令时，打开时执行到这里
              do_truncate
                notify_change
                  nfs_setattr
                    nfs4_proc_setattr
                      nfs4_do_setattr
                        _nfs4_do_setattr
                          nfs4_call_sync
                            nfs4_call_sync_sequence
                              nfs4_do_call_sync
                                nfs4_call_sync_custom
                                  rpc_run_task
                                    rpc_execute
```

# close

```c
task_work_run
  ____fput
    __fput
      nfs_file_release
        nfs_file_clear_open_context
          put_nfs_open_context_sync
            __put_nfs_open_context
              nfs4_close_context
                nfs4_close_sync
                  __nfs4_close
                    nfs4_do_close
                      rpc_run_task
                        rpc_execute
```

# df

```c
statfs
  user_statfs
    vfs_statfs
      statfs_by_dentry
        nfs_statfs
          nfs4_proc_statfs
            _nfs4_proc_statfs
              nfs4_call_sync
                nfs4_call_sync_sequence
                  nfs4_do_call_sync
                    nfs4_call_sync_custom
                      rpc_run_task
                        rpc_execute
```

# sequence

```c
kthread
  worker_thread
    process_one_work
      nfs4_renew_state
        nfs41_proc_async_sequence
          _nfs41_proc_sequence
            rpc_run_task
              rpc_execute

kthread
  nfs4_run_state_manager
    nfs4_state_manager
      nfs4_reset_session
        nfs4_proc_destroy_session
          rpc_call_sync
            rpc_run_task
              rpc_execute
        nfs4_proc_create_session
          _nfs4_proc_create_session
            rpc_call_sync
              rpc_run_task
                rpc_execute
      nfs4_reclaim_lease
        nfs4_establish_lease
          nfs41_init_clientid
            nfs4_proc_exchange_id
              _nfs4_proc_exchange_id
                nfs4_run_exchange_id
                  rpc_run_task
                    rpc_execute
            nfs4_proc_create_session
              _nfs4_proc_create_session
                rpc_call_sync
                  rpc_run_task
                    rpc_execute
            nfs41_finish_session_reset
              nfs4_setup_state_renewal
                nfs4_proc_get_lease_time
                  nfs4_call_sync_custom
                    rpc_run_task
                      rpc_execute
      nfs4_do_reclaim
      nfs4_state_end_reclaim_reboot
        nfs4_reclaim_complete
          nfs41_proc_reclaim_complete
            nfs4_call_sync_custom
              rpc_run_task
                rpc_execute
```

# nfs统计信息

```shell
nfsstat # 读取 /proc/net/rpc/nfs 和 /proc/net/rpc/nfsd 中的信息
```

`cat /proc/net/rpc/nfs`。
`net`一行 client 端没用到
```c
read
  ksys_read
    vfs_read
      proc_reg_read
        pde_read
          seq_read
            seq_read_iter
              rpc_proc_show

__rpc_execute
  call_start
    idx = task->tk_msg.rpc_proc->p_statidx
    clnt->cl_program->version[clnt->cl_vers]->counts[idx]++

NFSPROC4_CLNT_NULL ＝ 0 // 后面的枚举是每个方法
```

`cat /proc/net/rpc/nfsd`:
```c
read
  ksys_read
    vfs_read
      proc_reg_read
        pde_read
          seq_read
            seq_read_iter
              nfsd_proc_show
                svc_seq_show

svc_version nfsd_version4 = {
  .vs_nproc = 2,
  .vs_proc = nfsd_procedures4, // NULL COMPOUND  
}

#define LAST_NFS4_OP LAST_NFS42_OP
#define LAST_NFS42_OP OP_REMOVEXATTR // enum nfs_opnum4

kthread
  nfsd
    svc_process
      svc_process_common
        nfsd_dispatch
          nfsd4_proc_compound
            nfsd4_increment_op_stats
```

# delegation

```shell
mount -t nfs -o vers=4.0 192.168.122.247:/s_test /mnt
```

```c
#include <stdio.h>
#include <errno.h>
#include <unistd.h>
#include <linux/fs.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#define LEN 4096

int main()
{
	int fd = open("/mnt/file", O_RDONLY); // O_RDONLY O_WRONLY O_RDWR
	if (fd < 0) {
		printf("open fail, errno:%d\n", errno);
		return 1;
	}
	while (1)
		;
	return 0;
}
```

客户端:
```c
// nfs4.1 bc_svc_process 相关
mount
  do_mount
    path_mount
      do_new_mount
        vfs_get_tree
          nfs_get_tree
            nfs4_try_get_tree
              nfs4_create_server
                nfs4_init_server
                  nfs4_set_client
                    nfs_get_client
                      nfs4_init_client
                        nfs4_init_client_minor_version
                          nfs4_init_callback
                            nfs_callback_up
                              nfs_callback_create_svc
                                // nfs4.1
                                threadfn = nfs41_callback_svc // bc_svc_process // 没执行到
                                svc_create
                                  __svc_create

// nfs4.0 没有 sequence
kthread
  worker_thread
    process_one_work
      nfs4_renew_state
        nfs4_proc_async_renew
          rpc_call_async
            rpc_run_task
              rpc_execute

// nfs4.0 权限没有冲突时,设置 delegation
open
  do_sys_open
    do_sys_openat2
      do_filp_open
        path_openat
          do_open
            vfs_open
              do_dentry_open
                nfs4_file_open
                  nfs4_atomic_open
                    nfs4_do_open
                      _nfs4_do_open
                        _nfs4_proc_open
                          nfs4_run_open_task
                            rpc_run_task
                              rpc_execute
                        _nfs4_open_and_get_state
                          _nfs4_opendata_to_nfs4_state
                            nfs4_opendata_check_deleg
                              nfs_inode_set_delegation

// umount 时回收 delegation
task_work_run
  __cleanup_mnt
    cleanup_mnt
      deactivate_super
        deactivate_locked_super
          nfs_kill_super
            generic_shutdown_super
              evict_inodes
                dispose_list
                  evict
                    nfs4_evict_inode
                      nfs_inode_evict_delegation
                        nfs_do_return_delegation
                          nfs4_proc_delegreturn

// client 接收到 CB_RECALL 请求后的处理
kthread
  nfs4_callback_svc
    svc_process
      svc_process_common
        nfs_callback_dispatch
          nfs4_callback_compound
            process_op
              nfs4_callback_recall
                nfs_async_inode_return_delegation
                  nfs_mark_return_delegation
                    set_bit(NFS_DELEGATION_RETURN, &delegation->flags)

// 设置 deleg return 标记后,发送 deleg return 请求
kthread
  nfs4_run_state_manager
    nfs4_state_manager
      nfs_client_return_marked_delegations
        nfs_client_for_each_server
          __nfs_list_for_each_server
            nfs_server_return_marked_delegations
              nfs_end_delegation_return
                nfs_do_return_delegation
                  nfs4_proc_delegreturn
                    _nfs4_proc_delegreturn
                      rpc_run_task
                        rpc_execute
                          __rpc_execute
```

服务端:
```c
// nfs4.0挂载时创建反向通道
kthread
  nfsd
    svc_process
      svc_process_common
        nfsd_dispatch
          nfsd4_proc_compound
            nfsd4_setclientid
              gen_callback

// nfs4.0 权限没有冲突时打开文件, 分发 delegation
kthread
  nfsd
    svc_process
      svc_process_common
        nfsd_dispatch
          nfsd4_proc_compound
            nfsd4_open
              nfsd4_process_open2
                nfs4_open_delegation
                  nfsd4_cb_channel_good
                  nfs4_set_delegation
                    alloc_init_deleg
                    vfs_setlease

// 权限冲突时,回收 delegation
kthread
  worker_thread
    process_one_work
      rpc_async_schedule
        __rpc_execute
          call_encode
            rpc_xdr_encode
              rpcauth_wrap_req
                rpcauth_wrap_req_encode
                  nfs4_xdr_enc_cb_recall
```

# sunrpc

```c
// 0.  Initial state
nfs4_setup_sequence
  rpc_call_start
    // task->tk_action = call_start
    call_start
// 1.   Reserve an RPC call slot
call_reserve
// 1b.  Grok([计算机用语]理解) the result of xprt_reserve()
call_reserveresult
// 1c.  Retry reserving an RPC call slot
call_retry_reserve
// 2.   Bind and/or refresh the credentials
call_refresh
// 2a.  Process the results of a credential refresh
call_refreshresult
// 2b.  Allocate the buffer. For details, see sched.c:rpc_malloc. (Note: buffer memory is freed in xprt_release).
call_allocate
// 3.   Encode arguments of an RPC call
call_encode
// 4.   Get the server port number if not yet set
call_bind
// 4a.  Sort out bind result
call_bind_status
// 4b.  Connect to the RPC server
call_connect
// 4c.  Sort out connect result
call_connect_status
// 5.   Transmit the RPC request, and wait for reply
call_transmit
// 5a.  Handle cleanup after a transmission
call_transmit_status
// 5b.  Send the backchannel RPC reply.  On error, drop the reply.  In addition, disconnect on connectivity errors.
call_bc_transmit
// 6.   Sort out the RPC call status
call_status
// 7.   Decode the RPC reply
call_decode
```

# pnfs

TODO

# nfs4_setfacl / nfs4_getfacl

```c
setxattr
  path_setxattr
    setxattr
      vfs_setxattr
        __vfs_setxattr_locked
          __vfs_setxattr_noperm
            __vfs_setxattr
              nfs4_xattr_set_nfs4_acl
                nfs4_proc_set_acl
                  __nfs4_proc_set_acl

nfs4_xattr_get_nfs4_acl
```

4.19流程：
```c
newstat
  vfs_stat
    vfs_statx
      user_path_at
        user_path_at_empty
          filename_lookup
            path_lookupat
              link_path_walk
                may_lookup
                  inode_permission
                    do_inode_permission
                      nfs_permission
                        nfs_do_access
                          nfs4_proc_access
                            _nfs4_proc_access
                              nfs4_call_sync
                                nfs4_call_sync_sequence
                                  rpc_run_task
                                    rpc_execute
              lookup_last
                walk_component
                  lookup_slow
                    __lookup_slow
                      nfs_lookup
                        nfs4_proc_lookup
                          nfs4_proc_lookup_common
                            _nfs4_proc_lookup
                              nfs4_call_sync
                                nfs4_call_sync_sequence
                                  rpc_run_task
                                    rpc_execute

getxattr
  path_getxattr
    getxattr
      vfs_getxattr
        __vfs_getxattr
          nfs4_xattr_get_nfs4_acl
            nfs4_proc_get_acl
              __nfs4_get_acl_uncached
                nfs4_call_sync
                  nfs4_call_sync_sequence
                    .callback_ops = clp->cl_mvops->call_sync_ops
                    rpc_run_task
                      rpc_execute
                        __rpc_execute
                          rpc_wait_bit_killable
              while (exception.retry)
```

# server重启，client状态恢复

```c
// 异步rpc请求（如写请求）进入睡眠
ret_from_fork
  kthread
    worker_thread
      process_one_work
        rpc_async_schedule
          __rpc_execute
            rpc_exit_task
              nfs_pgio_result
                nfs_writeback_done
                  nfs_write_done
                    nfs4_write_done_cb
                      nfs4_async_handle_exception
                        rpc_sleep_on

ret_from_fork
  kthread
    nfs4_run_state_manager
      nfs4_state_manager
        test_and_clear_bit(NFS4CLNT_SESSION_RESET)
        nfs4_reset_session // 这里可能进入睡眠
        // 如果在这里加mdelay，则所有的rpc请求都将处于排队中
        nfs4_clear_state_manager_bit
          rpc_wake_up // 唤醒队列
```

# create file

```c
openat
  do_sys_open
    do_sys_openat2
      do_filp_open
        path_openat
          open_last_lookups
            lookup_open
              atomic_open
                nfs_atomic_open
                  nfs4_atomic_open
                    nfs4_do_open
                      _nfs4_do_open
                        _nfs4_open_and_get_state
                          _nfs4_opendata_to_nfs4_state
                            nfs4_opendata_find_nfs4_state
                              nfs4_opendata_get_inode
                                nfs_fhget
                                  set_nlink // NFS_ATTR_FATTR_NLINK
```

# create hard link

```c
linkat
  do_linkat
    vfs_link
      nfs_link
        nfs4_proc_link
          _nfs4_proc_link
            nfs4_inc_nlink
              nfs4_inc_nlink_locked
```

# delete file

```c
unlinkat
  do_unlinkat
    vfs_unlink
      nfs_unlink
        nfs_safe_remove
          nfs_drop_nlink
    iput
      iput_final
        nfs_drop_inode // op->drop_inode
          generic_drop_inode
            // 硬链接数为0，才从链表摘除
            if (!inode->i_nlink) // !inode->i_nlink ||
            inode_unhashed
        evict
          nfs4_evict_inode
          destroy_inode
            call_rcu(..., i_callback)

sysvec_apic_timer_interrupt
  irq_exit_rcu
    __irq_exit_rcu
      invoke_softirq
        __do_softirq
          rcu_core_si
            rcu_core
              rcu_do_batch
                i_callback
                  nfs_free_inode
```
