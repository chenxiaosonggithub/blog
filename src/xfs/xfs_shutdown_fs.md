# 问题描述

`dmesg`中报warning，请查看[`xfs_shutdown_fs_log.txt`](https://gitee.com/chenxiaosonggitee/tmp/blob/master/xfs_shutdown_fs_log.txt)。

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
