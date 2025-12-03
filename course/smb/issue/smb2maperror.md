```sh
objdump -t x86_64-build/fs/smb/common/smb_common.ko | grep smb2_error_map_table
```

```c
symbols_cmp

STATUS_SERIAL_COUNTER_TIMEOUT, -ETIMEDOUT, 110
STATUS_IO_REPARSE_TAG_NOT_HANDLED, -EOPNOTSUPP, 95
```

