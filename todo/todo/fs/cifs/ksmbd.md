[toc]


# common

```c
ret_from_fork
  kthread
    worker_thread
      process_one_work
        handle_ksmbd_work
          __handle_ksmbd_work
            __process_ksmbd_work
              __process_request
                cmds->proc(work)
              ksmbd_conn_write(work)
```

# open

```c
__process_request
  smb2_open
    smb2_creat // 文件不存在时
      smbd_vfs_create
        vfs_create
    dentry_open
      vfs_open
```

# getinfo

```c
__process_request
  smb2_query_info
    smb2_get_info_file
      get_file_all_info // 打开一个已经存在的文件前，要先打开文件获取信息，再关闭, 然后再打开
```
