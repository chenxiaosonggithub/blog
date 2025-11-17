# Patches to be tested

todo

# Test results

After applying the debug patch
[`0001-debug-FILE_SYSTEM_ATTRIBUTE_INFO.patch`](https://github.com/chenxiaosonggithub/blog/blob/master/course/smb/src/0001-debug-FILE_SYSTEM_ATTRIBUTE_INFO.patch)
to the kernel code, debug it using the following steps.

Both `FileSystemNameLen` and `FileSystemName` in `FILE_SYSTEM_ATTRIBUTE_INFO` are correct.

## Samba environment

The contents of the `/etc/samba/smb.conf` configuration file are as follows:
```sh
[global]
# support SMB1
server min protocol = NT1

[TEST]
    path = /tmp/s_test
    public = yes
    read only = no
    writeable = yes
```

## SMB1 test results

Mount with SMB1:
```sh
mount -t cifs -o vers=1.0 //localhost/TEST /mnt
```

Kernel logs:
```sh
[   23.000819] CIFS: VFS: Use of the less secure dialect vers=1.0 is not recommended unless required for access to very old servers
[   23.004073] CIFS: Attempting to mount //localhost/TEST
[   23.015250] CIFSSMBQFSAttributeInfo:4870, struct size:12, FileSystemNameLen:8, FileSystemName:NTFS
```

## SMB2 and SMB3 test results

Mount with SMB3:
```sh
mount -t cifs -o vers=3.1.1 //localhost/TEST /mnt
```

Kernel logs:
```sh
[  167.211012] CIFS: Attempting to mount //localhost/TEST
...
[  167.243126] SMB2_QFS_attr:6034, copy_len: 12, FileSystemNameLen:8, FileSystemName:NTFS
```

# Code Analysis

When `FileSystemName` uses flexible array member, `fsAttrInfo` in `struct cifs_tcon` does not include `FileSystemName`.

The following part in the `CIFSSMBQFSAttributeInfo()` function is correct, we cannot add `MAX_FS_NAME_LEN` to `sizeof(FILE_SYSTEM_ATTRIBUTE_INFO)`.

```c
CIFSSMBQFSAttributeInfo()
{
...
    memcpy(&tcon->fsAttrInfo, response_data,
        sizeof(FILE_SYSTEM_ATTRIBUTE_INFO)); // it's correct here
...
}
```

And in the following part of the `SMB2_QFS_attr()` function, we should change it to `memcpy(..., min_t(..., min_len))`.

```c
SMB2_QFS_attr()
{
...
    if (level == FS_ATTRIBUTE_INFORMATION)
            memcpy(&tcon->fsAttrInfo, offset
                    + (char *)rsp, min_t(unsigned int,
                    rsp_len, max_len)); // should use `min_len` here
...
}
``` 

