[toc]

```shell
umount /mnt/bb
umount /mnt
systemctl stop nfs-server
umount /aa/bb

rm /aa -rf
mkdir -p /aa/bb
echo "/aa *(fsid=0,crossmnt,rw,no_root_squash)" > /etc/exports
# echo "/aa/bb *(fsid=1,crossmnt,rw,no_root_squash)" >> /etc/exports
mount tmpfs /aa/bb -t tmpfs -o size=1M
# mount -t ext4 /dev/sda /aa/bb
touch /aa/bb/file
systemctl restart nfs-server
mount -t nfs -o vers=4.1 localhost:/ /mnt
```

if revert this patch, tmpfs have no uuid, nfsd cannot export.
```shell
59cda49ecf6c shmem: allow reporting fanotify events with file handles on tmpfs
```

```c
// userspace process rpc.mountd
statfs
  user_statfs
    vfs_statfs
      statfs_by_dentry
        shmem_statfs
          buf->f_fsid // return range

// userspace process rpc.mountd
write
  write
    ksys_write
      vfs_write
        proc_reg_write
          pde_write
            cache_write_procfs
              cache_write
                cache_downcall
                  cache_do_downcall
                    svc_export_parse
                      check_export
```
