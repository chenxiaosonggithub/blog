`ksmbd.conf`配置`vfs objects = acl_xattr`。

```sh
smbcacls //192.168.53.210/test file \
  -U 'root%1' \
  -m SMB3 \
  --numeric \
  -a 'ACL:S-1-1-0:ALLOWED/0x0/READ'

smbcacls //192.168.53.210/test file \
  -U 'root%1' \
  -m SMB3 \
  --numeric \
  --query-security-info=4
```

