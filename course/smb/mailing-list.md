我熟悉的内核模块，除了nfs就是smb了。nfs client是我相对比较熟悉的模块，但nfs client maintainer很不友好，nfs server maintainer友好但我对nfs server不是太熟悉。smb server近两年贡献的人数不是很多，又是近几年才进内核的模块，所以是相对比较适合我投入社区的。

- [SMB 邮件列表](https://lore.kernel.org/linux-cifs/)
- [SMB patchwork](https://patchwork.kernel.org/project/cifs-client/list/)

# 社区

- smb client maintainer: Steve French <sfrench@samba.org>，友好
  - 所在时区UTC-6，中国早上9点时他晚上7点
<!--
我早上20251209-0910发的补丁，他回复时显示的是20251208-7:11 PM
-->
- smb server maintainer: Namjae Jeon <linkinjeon@kernel.org>，友好
  - 在韩国，所在时区UTC+9，中国早上9点时他早上10点
<!--
我20251204-1258发的补丁（他收到时可能是1300），他回复时显示的是20251204-1400
-->
- [smb client maintainer的仓库](https://git.samba.org/sfrench/?p=sfrench/cifs-2.6.git;a=summary): `https://git.samba.org/sfrench/cifs-2.6.git`,
[for-next分支](https://git.samba.org/sfrench/?p=sfrench/cifs-2.6.git;a=log;h=refs/heads/for-next)
- [smb server maintainer的仓库](https://git.samba.org/?p=ksmbd.git;a=summary): `https://git.samba.org/ksmbd.git`,
[github仓库（现在好像不更新了）](https://github.com/namjaejeon/ksmbd),
[ksmbd-for-next-next分支](https://git.samba.org/?p=ksmbd.git;a=log;h=refs/heads/ksmbd-for-next-next),
[ksmbd-for-next分支](https://git.samba.org/?p=ksmbd.git;a=log;h=refs/heads/ksmbd-for-next)

邮件需要发送和抄送的人:
```sh
Steve French <smfrench@gmail.com> # 常用
Namjae Jeon <linkinjeon@kernel.org> # 常用
Steve French <sfrench@samba.org>
Namjae Jeon <linkinjeon@samba.org>
Paulo Alcantara <pc@manguebit.org> (DFS, global name space)
Ronnie Sahlberg <ronniesahlberg@gmail.com> (directory leases, sparse files)
Shyam Prasad N <sprasad@microsoft.com> (multichannel)
Bharath SM <bharathsm@microsoft.com> (deferred close, directory leases)
Tom Talpey <tom@talpey.com> (RDMA, smbdirect) # server reviewer
Sergey Senozhatsky <senozhatsky@chromium.org> # server reviewer
# 这哥们是以下8个模块的maintainer，简直是劳模
# AFS FILESYSTEM: fs/afs/
# ASYMMETRIC KEYS: crypto/asymmetric_keys/
# CACHEFILES: FS-CACHE BACKEND FOR CACHING ON MOUNTED FILESYSTEMS: fs/cachefiles/
# CERTIFICATE HANDLING: certs/
# FILESYSTEMS [NETFS LIBRARY]: fs/netfs/
# KEYS/KEYRINGS: security/keys/
# LINUX KERNEL MEMORY CONSISTENCY MODEL (LKMM): tools/memory-model/
# RXRPC SOCKETS (AF_RXRPC): net/rxrpc/
David Howells <dhowells@redhat.com> # 时区UTC0
linux-cifs@vger.kernel.org
```

发送补丁:
```sh
git send-email --to=\
smfrench@gmail.com,\
linkinjeon@kernel.org,\
pc@manguebit.org,ronniesahlberg@gmail.com,sprasad@microsoft.com,tom@talpey.com,bharathsm@microsoft.com,senozhatsky@chromium.org,\
dhowells@redhat.com \
--cc=\
linux-cifs@vger.kernel.org \
00* \
# --in-reply-to=xxx --no-thread --suppress-cc=all
```
<!--
git send-email --to=\
smfrench@gmail.com,\
linkinjeon@kernel.org,\
pc@manguebit.org,ronniesahlberg@gmail.com,sprasad@microsoft.com,tom@talpey.com,bharathsm@microsoft.com,senozhatsky@chromium.org,\
dhowells@redhat.com,chenxiaosong@kylinos.cn,chenxiaosong.chenxiaosong@linux.dev \
--cc=\
linux-cifs@vger.kernel.org \
00*
-->

# smb补丁统计

现在（2025.12.30）的目录`fs/smb/`统计:
```sh
# 还要显示邮件可以用 --format='%aN <%aE>'
# --follow 对目录其实没啥卵用，但还是习惯的写了
git log --follow --format='%aN <%aE>' fs/smb/ | sort | uniq -c | sort -nr | less
    244 Stefan Metzmacher <metze@samba.org>
    183 Namjae Jeon <linkinjeon@kernel.org>
    182 Paulo Alcantara <pc@manguebit.org>
    106 David Howells <dhowells@redhat.com>
    104 Steve French <stfrench@microsoft.com>
     90 Pali Rohár <pali@kernel.org>
     69 Shyam Prasad N <sprasad@microsoft.com>
     53 ChenXiaoSong <chenxiaosong@kylinos.cn>
     26 Bharath SM <bharathsm@microsoft.com>
     19 Henrique Carvalho <henrique.carvalho@suse.com>
     17 NeilBrown <neil@brown.name>
     16 Jeff Layton <jlayton@kernel.org>
     16 Enzo Matsumiya <ematsumiya@suse.de>
     15 Al Viro <viro@zeniv.linux.org.uk>
     13 ZhangGuoDong <zhangguodong@kylinos.cn>
     12 Thorsten Blum <thorsten.blum@linux.dev>
     12 Eric Biggers <ebiggers@kernel.org>
     11 Markus Elfring <elfring@users.sourceforge.net>
     10 Wang Zhaolong <wangzhaolong@huaweicloud.com>
```

`checkout`到`38c8a9a52082 smb: move client and server files to common directory fs/smb`（2023-05-24）之前的记录:
```sh
git checkout cb8b02fd6343228966324528adf920bfb8b8e681 # fs/ksmbd/
git log --date=short --format="%cd %h %s %an <%ae>" fs/ksmbd/
# 2021-06-28 1a93084b9a89 ksmbd: move fs/cifsd to fs/ksmbd Namjae Jeon <namjae.jeon@samsung.com>
```

再`checkout`到`1a93084b9a89 ksmbd: move fs/cifsd to fs/ksmbd`（2021-06-28）之前的记录:
```sh
git checkout 131bac1ece2e16201674b2f29b64d2044c826b56 # fs/cifsd/
git log --date=short --format="%cd %h %s %an <%ae>"  fs/cifsd/
# 2021-05-10 0626e6641f6b cifsd: add server handler for central processing and tranport layers Namjae Jeon <namjae.jeon@samsung.com>
```

