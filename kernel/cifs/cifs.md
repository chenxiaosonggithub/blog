[toc]

# 协议

1996年，微软提出将SMB改称为Common Internet File System。
2006年，Microsoft 随着 Windows Vista 的发布 引入了新的SMB版本 (SMB 2.0 or SMB2)。
SMB 2.1, 随 Windows 7 和 Server 2008 R2 引入, 主要是通过引入新的机会锁机制来提升性能。
SMB 3.0 (前称 SMB 2.2)在Windows 8 和 Windows Server 2012 中引入。

[SMB](https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-smb/f210069c-7086-4dc2-885e-861d837df688), [SMB2](https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-smb2/5606ad47-5ee0-437a-817e-70c366052962)

NetBIOS [RFC1001](www.rfc-editor.org/rfc/rfc1001) [RFC1002](www.rfc-editor.org/rfc/rfc1002)

# 环境

```shell
# debian 发行版
apt-get install samba -y
apt install cifs-utils -y # 安装 cifs 客户端, 否则无法挂载
apt install smbclient -y # 查询服务器共享了哪些目录

pdbedit -L # 查看cifs用户
smbpasswd -a root # 添加用户
smbpasswd -x root # 删除用户
smbpasswd -s # 修改密码
```

`/etc/samba/smb.conf`配置文件：
```shell
[global]
# 通过 man smb.conf 查看
server min protocol = NT1

[TEST]
	comment = xfstests test dir
	path = /tmp/s_test
	public = yes
	read only = no
	writeable = yes
[SCRATCH]
	comment = xfstests scratch dir
	path = /tmp/s_scratch
	public = yes
	read only = no
	writeable = yes
```

启动　cifs server:
```shell
mkfs.ext4 -b 4096 -F /dev/sda
mkfs.ext4 -b 4096 -F /dev/sdb

mkdir /tmp/s_test
mkdir /tmp/s_scratch

mount -t ext4 /dev/sda /tmp/s_test
mount -t ext4 /dev/sdb /tmp/s_scratch

systemctl stop firewalld
setenforce 0

sudo systemctl restart smbd.service

chmod 777 /tmp/s_test
chmod 777 /tmp/s_scratch

mkdir /tmp/test
mkdir /tmp/scratch
```

挂载命令：
```shell
mount -t cifs -o username=root,vers=1.0,cifsacl //localhost/TEST /mnt
mount -t cifs -o username=root,mfsymlinks,vers=2.0,cifsacl,nocase //localhost/TEST /mnt
mount -t cifs -o username=root,mfsymlinks,vers=2.1 //localhost/TEST /mnt
mount -t cifs -o username=root,mfsymlinks,vers=3.0 //localhost/TEST /mnt
```

# mount 与 umount

```c
mount
  do_mount
    path_mount
      do_new_mount
        vfs_get_tree
          smb3_get_tree
            smb3_get_tree_common
              cifs_smb3_do_mount
                cifs_mount
                  is_dfs_mount
                    mount_get_conns
                      cifs_get_smb_ses
                        cifs_setup_session
                          CIFS_SessSetup
                            sess_auth_rawntlmssp_negotiate
                              sess_sendreceive
                                SendReceive2
                                  cifs_send_recv
                                    compound_send_recv
                              sess_data->func = sess_auth_rawntlmssp_authenticate
                            sess_auth_rawntlmssp_authenticate
                              sess_sendreceive
                                SendReceive2
                                  cifs_send_recv
                                    compound_send_recv

task_work_run
  __cleanup_mnt
    cleanup_mnt
      deactivate_super
        deactivate_locked_super
          cifs_kill_sb
            cifs_umount
              cifs_put_tlink
                cifs_put_tcon
                  // ses->server->ops->tree_disconnect
                  CIFSSMBTDis
                    SendReceiveNoRsp
                  cifs_put_smb_ses
                    CIFSSMBLogoff
                      SendReceiveNoRsp
```

# 创建、打开、关闭

```c
// TODO: 这个系统调用干啥的？
utimensat
  do_utimes
    do_utimes_fd
      vfs_utimes
        notify_change
          cifs_setattr
            cifs_setattr_unix
              CIFSSMBUnixSetFileInfo
                SendReceiveNoRsp
                  SendReceive2
                    cifs_send_recv
                      compound_send_recv

SYM_INNER_LABEL(entry_SYSCALL_64_after_hwframe, SYM_L_GLOBAL)
  do_syscall_64
    syscall_exit_to_user_mode
      __syscall_exit_to_user_mode_work
        exit_to_user_mode_prepare
          exit_to_user_mode_loop
            resume_user_mode_work
              task_work_run
                // work->func(work)
                ____fput
                  __fput
                    cifs_close
                      _cifsFileInfo_put
                        cifs_close_file
                          CIFSSMBClose
                            SendReceiveNoRsp
                              SendReceive2
                                cifs_send_recv
                                  compound_send_recv

open
  do_sys_open
    do_sys_openat2
      do_filp_open
        path_openat
          do_open
            handle_truncate
              do_truncate
                notify_change
                  cifs_setattr
                    cifs_setattr_unix
                      cifs_set_file_size
                        CIFSSMBSetFileSize
                          SendReceiveNoRsp
                      CIFSSMBUnixSetFileInfo
                        SendReceiveNoRsp

```

# read

```c
read
  ksys_read
    vfs_read
      new_sync_read
        call_read_iter
          cifs_strict_readv
            generic_file_read_iter
              filemap_read
                filemap_get_pages
                  page_cache_sync_readahead
                    page_cache_sync_ra
                      ondemand_readahead
                        page_cache_ra_order
                          do_page_cache_ra
                            page_cache_ra_unbounded
                              read_pages
                                cifs_readahead
                                  cifs_async_readv
                                    cifs_call_async(..., cifs_readv_receive, cifs_readv_callback, ...)
                                      smb_send_rqst

kthread
  cifs_demultiplex_thread
    // mids[0]->receive
    cifs_readv_receive
    // mids[i]->callback
    cifs_readv_callback

```

# write

```c
dup2
  ksys_dup3
    do_dup2
      filp_close
        cifs_flush
          filemap_write_and_wait
            filemap_write_and_wait_range
              __filemap_fdatawrite_range
                filemap_fdatawrite_wbc
                  do_writepages
                    cifs_writepages
                      wdata_alloc_and_fillpages
                        cifs_writedata_alloc((unsigned int)tofind, cifs_writev_complete)
                      wdata_send_pages
                        cifs_async_writev(..., NULL, cifs_writev_callback, ...)
                          cifs_call_async
                            smb_send_rqst

kthread
  worker_thread
    process_one_work
      cifs_writev_complete
```

# cifs_reconnect

重启 server 端的 samba 服务
```c
kthread
  cifs_demultiplex_thread
    cifs_read_from_socket
      cifs_reconnect
```

# echo

```c
kthread
  worker_thread
    process_one_work
      cifs_echo_request
        CIFSSMBEcho
          cifs_call_async
            smb_send_rqst
```
