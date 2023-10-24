[toc]

stable 5.10

```shell
mount -t ext4 -o nodev,nosuid,noexec /dev/sda /mnt
```

```c
statx
  do_statx
    vfs_statx
      filename_lookup
        path_lookupat
          walk_component
            __lookup_slow
              ext4_lookup
                ext4_iget
                  __ext4_iget
                    !ext4_inode_csum_verify // true
                    ext4_simulate_fail // false
                    !(EXT4_SB(sb)->s_mount_state & EXT4_FC_REPLAY) // true
```