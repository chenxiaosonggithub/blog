- [补丁](https://lore.kernel.org/linux-cifs/2026040636-icy-constable-9e17@gregkh/)
- [AI review](https://sashiko.dev/#/patchset/2026040635-banking-unsoiled-3250%40gregkh)

```c
cifs_handle_standard
  smb2_check_message // server->ops->check_message

smb2_open_file
  SMB2_open
    SMB2_open_init
      smb2_plain_req_init(SMB2_CREATE, ...)
  smb2_parse_symlink_response

smb2_query_path_info
  open_cached_dir
    SMB2_open_init
      smb2_plain_req_init(SMB2_CREATE, ...)
  SMB2_query_info // query info 和 symlink无关
    query_info
      SMB2_query_info_init
        smb2_plain_req_init(SMB2_QUERY_INFO, ...)
  parse_create_response
    smb2_parse_symlink_response

  smb2_parse_symlink_response
    symlink_data

```

