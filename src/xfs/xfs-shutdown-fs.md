# 问题描述

`dmesg`中报warning，请查看[`xfs-shutdown-fs-log.txt`](https://gitee.com/chenxiaosonggitee/tmp/blob/master/xfs-shutdown-fs-log.txt)。

```sh
cat sos_commands/scsi/lsscsi 
[0:0:15:0]   enclosu SGA      E17202           0002  -          -
[0:2:0:0]    disk    AVAGO    MR9361-8i        4.68  /dev/sda   3600605b00eb200802cf6f6d2bc2a72b7
[0:2:1:0]    disk    AVAGO    MR9361-8i        4.68  /dev/sdb   3600605b00eb200802cf6f6debce27afe

cat sos_commands/block/lsblk
NAME                               MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sdb                                  8:16   0   7.1T  0 disk 
`-sdb1                               8:17   0   7.1T  0 part 
  |-VG_tidb-LV_t0ucccis_k07_data   253:2    0   500G  0 lvm  /paic/t0ucccis/td5520

cat sos_commands/block/lsblk_-f_-a_-l 
NAME                           FSTYPE      FSVER    LABEL UUID                                   FSAVAIL FSUSE% MOUNTPOINT
VG_tidb-LV_t0ucccis_k07_data   xfs                        94a6da2a-a2bb-41a1-bdd7-285c0b58c40a     79.2G    84% /paic/t0ucccis/td5520

xfs_metadump -o /dev/mapper/VG_tidb-LV_t0ucccis_k06_data  故障日志20240308.metadump.metadump
xfs_mdrestore 故障日志20240308.metadump  dm.img
xfs_repair -n dm.img 2>&1 | tee xfs_repair-log.txt
```

# 分析镜像

日志[`xfs_repair-log.txt`](https://gitee.com/chenxiaosonggitee/tmp/blob/master/xfs_repair-log.txt)中:
```sh
agf_freeblks 3997090, counted 4111777 in ag 0
agf_longest 14556, counted 14846 in ag 0
```

代表AG0中空闲块数量不对。

再解析镜像：
```sh
xfs_db -r dm.img 
xfs_db> agf 0
xfs_db> p
freeblks = 3997090 # AG0中空闲块数量
longest = 14556 # AG0中可用的最长连续空闲块的数量
```

<!--
```sh
xfs_db> sb 0
xfs_db> p
fdblocks = 36891964 # 超级块中存放的所有AG的空闲块总和
```
-->

查看日志：
```sh
xfs_logprint -n dm.img > xfs_logprint-n-log.txt # 不尝试解释日志数据，只解释日志头信息。
xfs_logprint dm.img > xfs_logprint-log.txt # 解释日志数据和日志头信息
```

[xfs_logprint-log.txt](https://gitee.com/chenxiaosonggitee/tmp/blob/master/xfs_logprint-log.txt)中有如下日志：
```sh
cycle: 230651	version: 2		lsn: 230651,154624	tail_lsn: 230651,147968
length of Log Record: 258048	prev offset: 154112		num ops: 69
uuid: 561a8354-b4e6-4b60-a868-c7d633ec2d8b   format: little endian linux
h_size: 262144
----------------------------------------------------------------------------
Oper (20): tid: 60e70d0f  len: 128  clientid: TRANS  flags: none
AGF Buffer: XAGF  
ver: 1  seq#: 0  len: 8192000  
root BNO: 4065919  CNT: 6109247
level BNO: 2  CNT: 2
1st: 0  last: 5  cnt: 6  freeblks: 4111777  longest: 14846
```

[xfs_logprint-n-log.txt](https://gitee.com/chenxiaosonggitee/tmp/blob/master/xfs_logprint-n-log.txt)中有如下日志：
```sh
cycle: 230651	version: 2		lsn: 230651,154624	tail_lsn: 230651,147968
length of Log Record: 258048	prev offset: 154112		num ops: 69
uuid: 561a8354-b4e6-4b60-a868-c7d633ec2d8b   format: little endian linux
h_size: 262144
----------------------------------------------------------------------------
Oper (20): tid: 60e70d0f  len: 128  clientid: TRANS  flags: none
0x58 0x41 0x47 0x46 0x00 0x00 0x00 0x01 0x00 0x00 0x00 0x00 0x00 0x7d 0x00 0x00 
0x00 0x3e 0x0a 0x7f 0x00 0x5d 0x38 0x3f 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x02 
0x00 0x00 0x00 0x02 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x05 
0x00 0x00 0x00 0x06 0x00 0x3e 0xbd 0xa1 0x00 0x00 0x39 0xfe 0x00 0x00 0x00 0x04 
0x56 0x1a 0x83 0x54 0xb4 0xe6 0x4b 0x60 0xa8 0x68 0xc7 0xd6 0x33 0xec 0x2d 0x8b 
0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x01 0x00 0x0c 0xee 0xbf 0x00 0x00 0x00 0x01 
0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 
0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 
```

- `0x00~0x03`数据`0x58 0x41 0x47 0x46`是`XAGF`，代表agf数据结构。
- `0x08~0x0b`数据`0x00 0x00 0x00 0x00`代表第0号AG。
- `0x34~0x37`数据`0x00 0x3e 0xbd 0xa1`是十进制`4111777`，代表`agf_freeblks`。
- `0x38~0x3b`数据`0x00 0x00 0x39 0xfe`是十进制`14846`，代表`agf_longest`。

`tail_lsn: 230651,147968`代表包含未提交缓冲区的第一个日志记录的日志序列号，`lsn: 230651,154624`大于`tail_lsn`，暂时不能说明这条记录对应的io完成函数已经被调用。

再看之后的记录：
```sh
cycle: 230651	version: 2		lsn: 230651,253952	tail_lsn: 230651,239616
length of Log Record: 258048	prev offset: 253440		num ops: 71
uuid: 561a8354-b4e6-4b60-a868-c7d633ec2d8b   format: little endian linux
h_size: 262144
```

这条记录的`tail_lsn: 230651,239616`大于前面分析的`lsn: 230651,154624`，说明前面分析的记录对应的io已经完成返回。

再查看AG0最近一次写入的`lsn`：
```sh
xfs_db -r dm.img
xfs_db> agf 0
xfs_db> p
lsn = 0x383dc00078a00
```

`lsn = 0x383dc00078a00 = (0x383dc, 0x00078a00) = (230364, 494080)`