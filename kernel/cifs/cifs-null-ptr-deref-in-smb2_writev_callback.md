[toc]

possible fix patch:
```shell
abe57073d08c CIFS: Fix retry mid list corruption on reconnects
```

4.19 代码：
```c
kthread
  cifs_demultiplex_thread
    cifs_read_from_socket
      cifs_readv_from_socket
        cifs_reconnect
          list_for_each_safe(tmp, tmp, &retry_list)
          list_del_init
          smb2_writev_callback // mid_entry->callback
            DeleteMidQEntry
              cifs_mid_q_entry_release // UAF
          smb2_writev_callback // another mid_entry ?
            tcon = tlink_tcon(wdata->cfile->tlink) // wdata->cfile == NULL

do_writepages
  cifs_writepages
    wdata_alloc_and_fillpages
      cifs_writedata_alloc((unsigned int)tofind, cifs_writev_complete)
    wdata_send_pages
      smb2_async_writev
        cifs_call_async(..., smb2_writev_callback, ...)
          smb2_setup_async_request // server->ops->setup_async_request
            smb2_mid_entry_alloc

kthread
  cifs_demultiplex_thread
    smb2_writev_callback

kthread
  cifs_demultiplex_thread
    standard_receive3
      cifs_handle_standard
        handle_mid
          dequeue_mid // how to get here when write ?
```

