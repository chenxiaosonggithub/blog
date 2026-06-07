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

<!--
samba:
```c
smb2_ioctl_filesys
  fsctl_get_cmprn
```

ksmbd:
```c

```
-->

