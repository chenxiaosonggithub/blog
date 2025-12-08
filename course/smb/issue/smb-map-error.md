# smb2maperror

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

状态码个数:
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

md4:
```c
SMB2_sess_auth_rawntlmssp_authenticate / sess_auth_rawntlmssp_authenticate
  build_ntlmssp_auth_blob
    setup_ntlmv2_rsp

CIFS_SessSetup
  select_sec
    sess_auth_ntlmv2
      setup_ntlmv2_rsp

setup_ntlmv2_rsp
  calc_ntlmv2_hash // ksmbd有个同名的函数
    E_md4hash
      mdfour
        cifs_md4_init
```

# nterr

脚本:
```sh
sed -i "s/ (0x/ 0x/g" fs/smb/server/nterr.h
sed -i "s/)$//g" fs/smb/server/nterr.h
git add fs/smb/server/nterr.h
cp fs/smb/client/nterr.h fs/smb/server/nterr.h
git diff fs/smb/server/nterr.h > nterr.diff
```

[`nterr.diff`差异内容](https://gitee.com/chenxiaosonggitee/tmp/tree/master/gnu-linux/smb/patch/diff-nterr)。

- nt_errs,              nt_err_num,          struct nt_err_code_struct, __u32 nt_errcode
- mapping_table_ERRDOS, errdos_num,          struct smb_to_posix_error, __u16 smb_err
- mapping_table_ERRSRV, errsrv_num,          struct smb_to_posix_error, __u16 smb_err
- ntstatus_to_dos_map,  ntstatus_to_dos_num, struct ntstatus_to_dos,    __u32 ntstatus

打印查看比较次数:
```sh
[  156.606314] nt_errs_check_search, nt_err_num:514, cmp_count:9
[  156.608775]     ok 5 nt_errs_check_search
[  156.608861] ntstatus_to_dos_map_check_search, ntstatus_to_dos_num:524, cmp_count:9
[  156.611840]     ok 6 ntstatus_to_dos_map_check_search
[  156.611917] mapping_table_ERRDOS_check_search, errdos_num:38, cmp_count:5
[  156.614627]     ok 7 mapping_table_ERRDOS_check_search
[  156.614726] mapping_table_ERRSRV_check_search, errsrv_num:36, cmp_count:5
[  156.617709]     ok 8 mapping_table_ERRSRV_check_search
```

# 社区交流

```sh
git send-email --to=sfrench@samba.org,smfrench@gmail.com,linkinjeon@kernel.org,linkinjeon@samba.org --cc=linux-cifs@vger.kernel.org,linux-kernel@vger.kernel.org,liuzhengyuan@kylinos.cn,huhai@kylinos.cn,liuyun01@kylinos.cn  00*
```

- [version 3](https://lore.kernel.org/linux-cifs/20251205132536.2703110-1-chenxiaosong.chenxiaosong@linux.dev/)

