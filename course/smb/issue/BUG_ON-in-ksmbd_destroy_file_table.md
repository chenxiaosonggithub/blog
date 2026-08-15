# 问题描述

[ksmbd: BUG_ON in locks_release_private() - file_lock destroyed while VFS blocked requests are still attached](https://lore.kernel.org/linux-cifs/CALT=-85WRdchL0vkA3mkTmFAiS-Ykjku+T-m+0My3_AcP=TJ3w@mail.gmail.com/)。

# 复现步骤

`ksmbd.conf`:
```sh
[global]
max ip connections = 0
server min protocol = SMB2_10
server signing = disabled
map to guest = never

[test]
path = /tmp/s_test
read only = no
guest ok = no
```

[复现脚本查看这里](https://gitee.com/chenxiaosonggitee/tmp/tree/master/gnu-linux/smb/debug-info/BUG_ON-in-ksmbd_destroy_file_table)。

```sh
LF_SECONDS=150 python3 -u main.py
```