- [补丁](https://lore.kernel.org/linux-cifs/2026040636-unsigned-jackal-e239@gregkh/)
- [AI review](https://sashiko.dev/#/patchset/2026040635-banking-unsoiled-3250%40gregkh)

```c
smb2_compound_op
  compound_send_recv
    buf = (char *)mid[i]->resp_buf
    resp_iov[i].iov_base = buf
    resp_iov[i].iov_len = mid[i]->resp_buf_size
  check_wsl_eas
    // struct smb2_query_info_rsp MS-SMB2 2.2.38

cifs_demultiplex_thread
  allocate_buffers
  smb3_receive_transform // server->ops->receive_transform
    receive_encrypted_standard
      if (pdu_length > MAX_CIFS_SMALL_BUFFER_SIZE)
      cifs_handle_standard
  standard_receive3
    if (pdu_length > MAX_CIFS_SMALL_BUFFER_SIZE)
    cifs_handle_standard
      handle_mid
        mid->resp_buf = buf
  mids[i]->resp_buf_size = server->pdu_size
  allocate_buffers
    cifs_buf_get / cifs_small_buf_get
```

```c
check_wsl_eas

wsl_to_fattr
  // struct smb2_file_full_ea_info MS-FSCC 2.4.16
  v = (void *)((u8 *)ea->ea_data + ea->ea_name_length + 1) // ea->ea_name_length == 6
  wsl_make_kuid(cifs_sb, void *ptr = v)
    u32 uid = le32_to_cpu(*(__le32 *)ptr);
```

