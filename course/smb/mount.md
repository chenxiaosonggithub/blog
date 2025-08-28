下面我们通过调试日志和抓包数据入手学习一下挂载的过程。

# 环境

- server端: 192.168.53.209
- client端: 192.168.53.211

挂载命令:
```sh
mount -o user=root //192.168.53.209/TEST /mnt
```

挂载选项如下:
```sh
//192.168.53.209/TEST on /mnt type cifs (rw,relatime,vers=3.1.1,cache=strict,upcall_target=app,username=root,uid=0,noforceuid,gid=0,noforcegid,addr=192.168.53.209,file_mode=0755,dir_mode=0755,soft,nounix,serverino,mapposix,reparse=nfs,nativesocket,symlink=native,rsize=4194304,wsize=4194304,bsize=1048576,retrans=1,echo_interval=60,actimeo=1,closetimeo=1)
```

# 调试日志

调试日志开关的使用请查看[《smb调试方法》](https://chenxiaosong.com/course/smb/debug.html)。

- [ksmbd挂载日志](https://gitee.com/chenxiaosonggitee/tmp/blob/master/smb/mount/ksmbd-log.txt)
- [client挂载日志](https://gitee.com/chenxiaosonggitee/tmp/blob/master/smb/mount/client-log.txt)

# tcpdump抓包数据

[点击这里下载抓包数据文件](https://gitee.com/chenxiaosonggitee/tmp/blob/master/smb/mount/mount.cap)。

```sh
No.     Time            Source          Destination    Protocol Length  Info
6       10.392311       192.168.53.211  192.168.53.209  SMB2    310     Negotiate Protocol Request
8       10.465939       192.168.53.209  192.168.53.211  SMB2    382     Negotiate Protocol Response
10      10.502937       192.168.53.211  192.168.53.209  SMB2    202     Session Setup Request, NTLMSSP_NEGOTIATE
12      10.517031       192.168.53.209  192.168.53.211  SMB2    330     Session Setup Response, Error: STATUS_MORE_PROCESSING_REQUIRED, NTLMSSP_CHALLENGE
13      10.542547       192.168.53.211  192.168.53.209  SMB2    456     Session Setup Request, NTLMSSP_AUTH, User: \root
14      10.582773       192.168.53.209  192.168.53.211  SMB2    142     Session Setup Response
16      10.623750       192.168.53.211  192.168.53.209  SMB2    184     Tree Connect Request Tree: \\192.168.53.209\IPC$
17      10.641059       192.168.53.209  192.168.53.211  SMB2    150     Tree Connect Response
19      10.671082       192.168.53.211  192.168.53.209  SMB2    234     Ioctl Request FSCTL_DFS_GET_REFERRALS, File: \192.168.53.209\TEST
20      10.681385       192.168.53.209  192.168.53.211  SMB2    143     Ioctl Response, Error: STATUS_FS_DRIVER_REQUIRED
21      10.706904       192.168.53.211  192.168.53.209  SMB2    184     Tree Connect Request Tree: \\192.168.53.209\TEST
22      10.722053       192.168.53.209  192.168.53.211  SMB2    150     Tree Connect Response
23      10.742234       192.168.53.211  192.168.53.209  SMB2    222     Create Request File: 
24      10.760105       192.168.53.209  192.168.53.211  SMB2    278     Create Response File: 
25      10.777042       192.168.53.211  192.168.53.209  SMB2    191     Ioctl Request FSCTL_QUERY_NETWORK_INTERFACE_INFO
26      10.786745       192.168.53.209  192.168.53.211  SMB2    486     Ioctl Response FSCTL_QUERY_NETWORK_INTERFACE_INFO
27      10.825189       192.168.53.211  192.168.53.209  SMB2    175     GetInfo Request FS_INFO/FileFsAttributeInformation File: 
28      10.837632       192.168.53.209  192.168.53.211  SMB2    162     GetInfo Response
29      10.855012       192.168.53.211  192.168.53.209  SMB2    175     GetInfo Request FS_INFO/FileFsDeviceInformation File: 
30      10.867201       192.168.53.209  192.168.53.211  SMB2    150     GetInfo Response
31      10.884696       192.168.53.211  192.168.53.209  SMB2    175     GetInfo Request FS_INFO/FileFsVolumeInformation File: 
32      10.896836       192.168.53.209  192.168.53.211  SMB2    168     GetInfo Response
33      10.914241       192.168.53.211  192.168.53.209  SMB2    175     GetInfo Request FS_INFO/FileFsSectorSizeInformation File: 
34      10.926081       192.168.53.209  192.168.53.211  SMB2    170     GetInfo Response
35      10.942951       192.168.53.211  192.168.53.209  SMB2    158     Close Request File: 
36      10.952492       192.168.53.209  192.168.53.211  SMB2    194     Close Response
37      10.970102       192.168.53.211  192.168.53.209  SMB2    222     Create Request File: 
38      10.988302       192.168.53.209  192.168.53.211  SMB2    278     Create Response File: 
39      11.005163       192.168.53.211  192.168.53.209  SMB2    158     Close Request File: 
40      11.014629       192.168.53.209  192.168.53.211  SMB2    194     Close Response
41      11.029817       192.168.53.211  192.168.53.209  SMB2    222     Create Request File: 
42      11.048212       192.168.53.209  192.168.53.211  SMB2    278     Create Response File: 
43      11.065103       192.168.53.211  192.168.53.209  SMB2    158     Close Request File: 
44      11.074584       192.168.53.209  192.168.53.211  SMB2    194     Close Response
45      11.095371       192.168.53.211  192.168.53.209  SMB2    414     Create Request File: ;GetInfo Request FILE_INFO/SMB2_FILE_ALL_INFO;Close Request
47      11.141635       192.168.53.209  192.168.53.211  SMB2    582     Create Response File: ;GetInfo Response;Close Response
```

