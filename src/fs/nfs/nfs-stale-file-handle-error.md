[toc]

nfs server `/etc/exports` 文件：
```
/tmp/s_test *(rw,no_subtree_check,no_root_squash)
```

nfs client 挂载命令：
```shell
# rw,relatime,vers=3,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=10.38.163.121,mountvers=3,mountport=20048,mountproto=udp,local_lock=none,addr=10.38.163.121
mount -t nfs -o vers=3 localhost:/tmp/s_test /mnt
```

```c
// mount -t nfs -o vers=3 localhost:/tmp/s_test /mnt
// dentry->d_name.name == "/"
write
  ksys_write
    vfs_write
      nfsctl_transaction_write
        write_filehandle
          exp_rootfh
            fh_compose

// ls /mnt
// dentry->d_name.name == "lost+found"
// dentry->d_name.name == "/"
ret_from_fork
  kthread
    nfsd
      svc_process
        svc_process_common
          nfsd_dispatch
            nfsd3_proc_readdirplus
              nfsd_readdir
                nfsd_buffered_readdir
                  nfs3svc_encode_entryplus3
                    svcxdr_encode_entry3_plus
                      compose_entry_fh
                        fh_compose
                          _fh_update
                            exportfs_encode_fh
                              exportfs_encode_inode_fh
                                export_encode_fh

nfsd
  svc_process
    svc_process_common
      nfsd_dispatch
        nfsd3_proc_getattr
          fh_verify
            nfsd_set_fh_dentry
              rqst_exp_find
                exp = exp_find
                  ek = exp_find_key = -ENOENT
                    err = cache_check = -ENOENT
                  return ERR_CAST(ek)
                if (PTR_ERR(exp) == -ENOENT) // 条件满足
                if (rqstp->rq_gssclient == NULL) // 条件满足
                return ERR_PTR(-ENOENT)
              if (PTR_ERR(exp) == -ENOENT) // 条件满足
              return nfserr_stale
```