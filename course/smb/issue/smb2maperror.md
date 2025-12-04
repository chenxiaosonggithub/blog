# 开发过程笔记

查看数组是否只读:
```sh
objdump -t x86_64-build/fs/smb/common/smb_common.ko | grep smb2_error_map_table
```

```c
// 比较函数参考
symbols_cmp

// 单元测试用例
STATUS_SERIAL_COUNTER_TIMEOUT, -ETIMEDOUT, 110
STATUS_IO_REPARSE_TAG_NOT_HANDLED, -EOPNOTSUPP, 95
```

状态码个数
```c
 30 #define STATUS_SUCCESS cpu_to_le32(0x00000000)
 31 #define STATUS_WAIT_0 cpu_to_le32(0x00000000)
 32 #define STATUS_WAIT_1 cpu_to_le32(0x00000001)
...
 904 /*
 905  * 'OCCURED' is typo in MS-ERREF, it should be 'OCCURRED',
 906  * but we'll keep it consistent with MS-ERREF.
 907  */
...
 1777 #define STATUS_INVALID_LOCK_RANGE cpu_to_le32(0xC00001a1)

err_map_num:1740
(1777-32+1)-4 = 1742

// 少的两个是合并头文件时server新增的两个
```

