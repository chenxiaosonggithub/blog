[中文分析过程请点击这里查看](https://chenxiaosong.com/course/smb/issue/smb2-change-notify.html)。

# Requirements description

[Please see GitHub issue](https://github.com/namjaejeon/ksmbd/issues/495).

# KSMBD development environment {#ksmbd-dev-env}

Install ksmbd-tools from source:
```sh
apt install -y git gcc pkgconf autoconf automake libtool make meson ninja-build gawk libnl-3-dev libnl-genl-3-dev libglib2.0-dev # debian
dnf install -y git gcc pkgconf autoconf automake libtool make meson ninja-build gawk libnl3-devel glib2-devel # fedora
git clone https://github.com/cifsd-team/ksmbd-tools.git
cd ksmbd-tools
./autogen.sh
./configure --with-rundir=/run # --prefix=/usr/local/sbin --sysconfdir=/usr/local/etc
make -j`nproc`
make install -j`nproc`
```

create smb user:
```sh
# We are testing in a virtual machine, so we just use the root user.
sudo ksmbd.adduser --add root
```

Then create config file `/usr/local/etc/ksmbd/ksmbd.conf`:
```sh
[global]
        writeable = yes
        public = yes

[TEST]
        comment = test dir
        ; Note: there should not be a space after the path.
        path = /tmp/s_test
```

Start ksmbd:
```sh
mkdir /tmp/s_test
systemctl stop smbd.service # stop samba on debian
systemctl stop smb.service # stop samba on fedora
chmod 777 /tmp/s_test # just for test
systemctl restart ksmbd
```

# Samba development environment

Install samba from source:
```sh
git clone https://gitlab.com/samba-team/devel/samba.git 
cd samba/bootstrap/generated-dists/fedora41/ # You can replace fedora41 with your own distribution
./bootstrap.sh # It may take some time to install the dependencies
cd ../../../
./configure --with-systemd --with-libunwind
make -j`nproc`
make install -j`nproc`
export PATH=/usr/local/samba/bin/:/usr/local/samba/sbin/:$PATH
```

When you only want to build and install `smbd`:
```sh
make -j`nproc` bin/smbd && rm -rf /usr/local/samba/sbin/smbd; cp bin/smbd /usr/local/samba/sbin/smbd
```

Create or update `/usr/lib/systemd/system/smb.service`:
```sh
[Unit]
Description=Samba SMB Daemon
Documentation=man:smbd(8) man:samba(7) man:smb.conf(5)
Wants=network-online.target
After=network.target network-online.target nmb.service winbind.service

[Service]
Type=notify
PIDFile=/run/smbd.pid
LimitNOFILE=16384
EnvironmentFile=-/etc/sysconfig/samba
ExecStart=/usr/local/samba/sbin/smbd --foreground --no-process-group $SMBDOPTIONS
ExecReload=/bin/kill -HUP $MAINPID
LimitCORE=infinity
Environment=KRB5CCNAME=FILE:/run/samba/krb5cc_samba

[Install]
WantedBy=multi-user.target
```

Create config file `/usr/local/samba/etc/smb.conf`:
```sh
[TEST]
    comment = test dir
    path = /tmp/s_test
    public = yes
    read only = no
    writeable = yes
```

Create smb user:
```sh
# We are testing in a virtual machine, so we just use the root user.
pdbedit -a -u root
```

Start samba:
```sh
# stop the ksmbd service before starting samba
systemctl stop ksmbd.service

mkdir /tmp/s_test
chmod 777 /tmp/s_test # just for test

systemctl restart smbd.service # debian
systemctl restart smb.service # fedora
```

# Windows environment {#win-env}

`10.42.20.210` is the IP address of the SMB server.

Enter the following path in "File Explorer":
```sh
# Windows is case-insensitive, so you can use either "TEST" or "test"
\\10.42.20.210\test
```

When switching between samba and ksmbd, Windows may fail to mount.
In that case, open PowerShell on Windows and run the following commands:
```sh
# View existing connections
net use
# Delete a specific connection
net use \\10.42.20.210\IPC$ /delete
net use \\10.42.20.210\test /delete
# Delete all connections (not recommended)
net use * /delete
```

# Analysis of packets captured by tcpdump {#tcpdump}

## samba 20251110-2016

[The full capture file can be found on GitHub](https://github.com/chenxiaosonggithub/tmp/blob/master/gnu-linux/smb/change-notify/20251110-2016/samba.md)
([or on gitee](https://gitee.com/chenxiaosonggitee/tmp/blob/master/gnu-linux/smb/change-notify/20251110-2016/samba.md)).

Windows "File Explorer" enter root directory of smb server:

  - client request `20:17:17.201 Notify Request No.123 [Response in: 271]`

Windows "File Explorer" enter `dir/`:

  - client request `20:17:29.666 Create Request;Notify Request No.239`
  - server respond `20:17:29.668 Notify Response, Error: STATUS_PENDING No.244 [Response to: 239]`
  - client request `20:17:29.760 Cancel Request No.270 [Response in: 271]`
  - server respond `20:17:29.760 Notify Response, Error: STATUS_CANCELLED No.271 [Response to: 123 270]`, the samba server stops notifying Windows of changes to root directory of smb server

Samba server executes `touch dir/file1`:

  - server respond `20:17:54.095 Notify Response No.285 [Response to: 239]`


# samba code analysis {#samba-code}

Some code (e.g., the definition of `NT_STATUS_PENDING`) is generated during compilation. To see the full code, the project must be compiled first.

You can use macros like `DBG_ERR()`, ..., `DBG_DEBUG()`, etc., to print debug information.

Use `log_stack_trace()` to print the function stack. If you get a compilation error indicating that `log_stack_trace()` cannot be found,
you can refer to the changes in the patch [`0001-dump-stack-of-smbd_parent_loop.patch`](https://github.com/chenxiaosonggithub/blog/blob/master/course/smb/src/0001-dump-stack-of-smbd_parent_loop.patch).

The logs can be found in `/usr/local/samba/var/log.smbd`.

<!--
main
  smbd_parent_loop
    _tevent_loop_wait
      std_event_loop_wait
        tevent_common_loop_wait
          _tevent_loop_once
            std_event_loop_once
              epoll_event_loop_once
                epoll_event_loop
                  tevent_common_invoke_fd_handler
                    smbd_accept_connection
                      smbd_process
                        _tevent_loop_wait
                          std_event_loop_wait
                            tevent_common_loop_wait
                              _tevent_loop_once
                                std_event_loop_once
                                  epoll_event_loop_once
                                    epoll_event_loop
                                      tevent_common_invoke_fd_handler
                                        messaging_dgm_read_handler

tevent_common_invoke_fd_handler
  messaging_dgm_read_handler
    messaging_dgm_recv
      msg_dgm_ref_recv
        messaging_recv_cb
          messaging_dispatch_rec
            messaging_dispatch_classic


tevent_common_invoke_fd_handler
  smbd_smb2_connection_handler
    smbd_smb2_io_handler
      smbd_smb2_advance_incoming
        smbd_smb2_request_dispatch
-->

When samba receive `Create Request`:
```c
smbd_smb2_request_dispatch
  smbd_smb2_request_process_create
    smbd_smb2_create_send
      smbd_smb2_create_finish
        // save the fsp, and return immediately when file_fsp_smb2() is called later
        smb2req->compat_chain_fsp = smb1req->chain_fsp
```

When samba receive `Notify Request`:
```c
smbd_smb2_request_dispatch
  smbd_smb2_request_process_notify
    // both persistent_id and volatile_id are -1 when `Create Request` and `Notify Request` are in the same compound request
    file_fsp_smb2
      return smb2req->compat_chain_fsp
    smbd_smb2_notify_send
      change_notify_create
      if (change_notify_fsp_has_changes(fsp) // have change information
      change_notify_reply // notify immediately
        // reply NT_STATUS_OK
      change_notify_add_request // No changes for now, wait in the queue
    smbd_smb2_request_pending_queue // nothing to notify, start the timer
```

Start the timer:
```c
smbd_smb2_request_pending_timer
  // reply NT_STATUS_PENDING
  // SMB2_HDR_OPCODE defines the offset of the Command field in struct smb2_hdr
```

When Windows exits the directory, samba receive `Cancel Request`:
```c
smbd_smb2_request_dispatch
  smbd_smb2_request_process_cancel
    _tevent_req_cancel
      smbd_smb2_notify_cancel
        smbd_notify_cancel_by_smbreq
          smbd_notify_cancel_by_map
            change_notify_reply
              // reply NT_STATUS_CANCELLED
```

Samba send `Notify Response` when change information is available:
```c
messaging_dispatch_classic
  notify_handler
    notify_callback
      files_forall
        notify_fsp_cb
          notify_fsp
            change_notify_reply
              // reply NT_STATUS_OK
```

# fanotify {#fanotify}

[Click here to view userspace fanotify usage examples `fs-monitor.c`](https://github.com/chenxiaosonggithub/blog/blob/master/course/smb/src/fs-monitor.c):
```sh
gcc -o fs-monitor fs-monitor.c
./fs-monitor /path/to/file
```

When reading a file:
```c
read
  ksys_read
    vfs_read
      fanotify_read
        add_wait_queue // wait here
        copy_event_to_user

vfs_read / __kernel_read
  fsnotify_access
    fsnotify_file
      fsnotify_path
        fsnotify_parent
          __fsnotify_parent
            fsnotify
              send_to_group
                fanotify_handle_event
                  fsnotify_insert_event
                    // wake up the wait queue in fanotify_read()
                    wake_up(&group->notification_waitq)
```

