`smb.conf`:
```sh
[test]
    vfs objects = btrfs
```


```sh
touch file # client
chattr +c file # client

lsattr file # client
# --------c------------- file

dd if=/dev/zero of=file bs=1M count=100 # client

compsize file # server
# Processed 1 file, 800 regular extents (800 refs), 0 inline.
# Type       Perc     Disk Usage   Uncompressed Referenced
# TOTAL        3%      3.1M         100M         100M
# zlib         3%      3.1M         100M         100M

lsattr file # client
# --------c------------- file

chattr -c file # client

lsattr file # client
# ---------------------- file

compsize file # server
# Processed 1 file, 1 regular extents (1 refs), 0 inline.
# Type       Perc     Disk Usage   Uncompressed Referenced  
# TOTAL      100%      100M         100M         100M       
# none       100%      100M         100M         100M
```

# code analysis

## samba

```c
smb2_ioctl_filesys
  fsctl_get_cmprn
```

## kernel

```c
cifs_ioctl
  cifs_ioctl_query_info
    smb2_ioctl_query_info // tcon->ses->server->ops->ioctl_query_info
      if (qi.flags & PASSTHRU_FSCTL) // 0x00000001
      else if (qi.flags == PASSTHRU_QUERY_INFO) // 0x00000000

smb2_query_info
  case SMB2_O_INFO_FILE
  smb2_get_info_file
    case FILE_COMPRESSION_INFORMATION
    get_file_compression_info
    case FILE_ALL_INFORMATION
    get_file_all_info
```

## cifs-utils

```c
cmd_getcompression
  QueryInfoStruct(info_type=0x9003c, flags=PASSTHRU_FSCTL, // FSCTL_GET_COMPRESSION

cmd_setcompression
  QueryInfoStruct(info_type=0x9c040, flags=PASSTHRU_FSCTL, // FSCTL_SET_COMPRESSION

cmd_fileallinfo
  qi = QueryInfoStruct(info_type=0x1, file_info_class=18, // FILE_ALL_INFORMATION
  buf = qi.ioctl
    fcntl.ioctl(fd, CIFS_QUERY_INFO,

cmd_filestandardinfo
  QueryInfoStruct(info_type=0x1, file_info_class=5, // FILE_STANDARD_INFORMATION
```

<!--
todo:
- smb2_file_standard_info, FILE_STANDARD_INFO
- smb2_file_all_info, FILE_ALL_INFO

-->

