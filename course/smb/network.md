挂载时建立连接网络连接:
```c
cifs_get_tcp_session
  ip_connect
    generic_ip_connect
      __sock_create // sock_create_kern
```

发送数据:
```c
cifs_send_recv
  compound_send_recv
    smb_send_rqst
      __smb_send_rqst
        smb_send_kvec
          sock_sendmsg // kernel_sendmsg()
```

接收数据
```c
kthread
  cifs_demultiplex_thread
    cifs_read_from_socket
      cifs_readv_from_socket
        sock_recvmsg // kernel_sendmsg()
    standard_receive3
      cifs_read_from_socket
        cifs_readv_from_socket
          sock_recvmsg

