[toc]

# 环境

作为本地文件系统使用：

```shell
apt install gfs2-utils -y

mkfs -t gfs2 -p lock_nolock -j 1 /dev/sda
mount -t gfs2 /dev/sda /mnt
```

# umount

```c
task_work_run
  __cleanup_mnt
    cleanup_mnt
      deactivate_super
        deactivate_locked_super
          kill_block_super
            generic_shutdown_super
              sync_filesystem
                gfs2_sync_fs
                  gfs2_log_flush
                    lops_before_commit
                      revoke_lo_before_commit
                        gfs2_flush_revokes
                          gfs2_ail1_empty
```
