[toc]

# 环境

参考[ksmbd.rst](https://github.com/torvalds/linux/blob/master/Documentation/filesystems/cifs/ksmbd.rst)和[ksmbd-tools](https://github.com/cifsd-team/ksmbd-tools)

```shell
ksmbd.adduser --add-user=root
ksmbd.adduser --update-user=root --password=MyNewPassword
ksmbd.adduser --del-user=MyUser
```

`ksmbd-svr-setup.sh`:
```shell
mkfs.ext4 -b 4096 -F /dev/sda
mkfs.ext4 -b 4096 -F /dev/sdb

mkdir /tmp/s_test
mkdir /tmp/s_scratch

mount -t ext4 /dev/sda /tmp/s_test
mount -t ext4 /dev/sdb /tmp/s_scratch

systemctl stop firewalld
setenforce 0

systemctl stop smbd.service

chmod 777 /tmp/s_test
chmod 777 /tmp/s_scratch

mkdir /tmp/test
mkdir /tmp/scratch

ksmbd.control --shutdown
ksmbd.mountd
```

`/usr/local/ksmbd-tools/etc/ksmbd/ksmbd.conf`:
```
[global]
        writeable = yes               
        public = yes                  
                                      
[TEST]                                
        comment = xfstests test dir   
        path = /tmp/s_test            
                                      
[SCRATCH]                             
        comment = xfstests scratch dir
        path = /tmp/s_scratch         
```

```shell
mount -t cifs //localhost/TEST /mnt
```

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
