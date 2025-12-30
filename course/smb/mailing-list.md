我熟悉的内核模块，除了nfs就是smb了。nfs client是我相对比较熟悉的模块，但nfs client maintainer很不友好，nfs server maintainer友好但我对nfs server不是太熟悉。smb server近两年贡献的人数不是很多，又是近几年才进内核的模块，所以是相对比较适合我投入社区的。

- [邮件列表](https://lore.kernel.org/linux-cifs/)
- [patchwork](https://patchwork.kernel.org/project/cifs-client/list/)

# 社区

- smb client maintainer: Steve French <sfrench@samba.org>，友好
  - 所在时区比中国时间晚10小时，中国早上9点时他晚上7点
<!--
我早上20251209-0910发的补丁，他回复时显示的是20251208-7:11 PM，比中国时间晚10小时
-->
- smb server maintainer: Namjae Jeon <linkinjeon@kernel.org>，友好
  - 在韩国，所在时区比中国时间早1小时，中国早上9点时他早上10点
<!--
我20251204-1258发的补丁（他收到时可能是1300），他回复时显示的是20251204-1400，比中国时间早1小时
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
David Howells <dhowells@redhat.com>
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
00*
```

# smb server补丁统计

smb client很早进入内核，就不统计了。这里统计一下2021.03.16进入内核的smb server的补丁贡献者，列出贡献超过一个补丁的贡献者。

现在（2025.11.03）的目录`fs/smb/server`统计:
```sh
# 还要显示邮件可以用 --format='%aN <%aE>'
# --follow 对目录其实没啥卵用，但还是习惯的写了
git log --follow --format='%aN <%aE>' fs/smb/server/ | sort | uniq -c | sort -nr
    173 Namjae Jeon <linkinjeon@kernel.org>
     90 Stefan Metzmacher <metze@samba.org>
     10 NeilBrown <neil@brown.name>
      9 Thorsten Blum <thorsten.blum@linux.dev>
      8 Marios Makassikis <mmakassikis@freebox.fr>
      7 ChenXiaoSong <chenxiaosong@kylinos.cn>   # 这是我
      7 Al Viro <viro@zeniv.linux.org.uk>  
      6 Jeff Layton <jlayton@kernel.org>
      5 Norbert Szetei <norbert@doyensec.com>
      5 Christian Brauner <brauner@kernel.org>
      4 Steve French <stfrench@microsoft.com>
      4 Sean Heelan <seanheelan@gmail.com>     
      3 ZhangGuoDong <zhangguodong@kylinos.cn>
      3 Yang Li <yang.lee@linux.alibaba.com>   
      3 Hobin Woo <hobin.woo@samsung.com>      
      3 Gustavo A. R. Silva <gustavoars@kernel.org>
      3 Dr. David Alan Gilbert <linux@treblig.org>
      2 Randy Dunlap <rdunlap@infradead.org>
      2 Lu Hongfei <luhongfei@vivo.com>
      2 Kuan-Ting Chen <h3xrabbit@gmail.com>
      2 Jordy Zomer <jordyzomer@google.com>
      2 Fedor Pchelkin <pchelkin@ispras.ru>
      2 Eric Biggers <ebiggers@google.com>
      2 Dan Carpenter <dan.carpenter@linaro.org>
      2 Christophe JAILLET <christophe.jaillet@wanadoo.fr>
```

`checkout`到`38c8a9a52082 smb: move client and server files to common directory fs/smb`（2023.05.21）之前的记录:
```sh
git checkout cb8b02fd6343228966324528adf920bfb8b8e681
git log --follow --format='%aN <%aE>' fs/ksmbd/ | sort | uniq -c | sort -nr
    107 Namjae Jeon <linkinjeon@kernel.org>
     46 Hyunchul Lee <hyc.lee@gmail.com>
     42 Namjae Jeon <namjae.jeon@samsung.com>
     24 Christian Brauner <brauner@kernel.org>
     13 Marios Makassikis <mmakassikis@freebox.fr>
     10 Steve French <stfrench@microsoft.com>
      6 Dan Carpenter <error27@gmail.com>
      5 Yang Li <yang.lee@linux.alibaba.com>
      5 Ronnie Sahlberg <lsahlber@redhat.com>
      4 Ralph Boehme <slow@samba.org>
      4 Dawei Li <set_pte_at@outlook.com>
      4 David Disseldorp <ddiss@suse.de>
      4 Christophe JAILLET <christophe.jaillet@wanadoo.fr>
      4 Atte Heikkilä <atteh.mailbox@gmail.com>
      4 Al Viro <viro@zeniv.linux.org.uk>
      3 Jeff Layton <jlayton@kernel.org>
      3 Gustavo A. R. Silva <gustavoars@kernel.org>
      3 Colin Ian King <colin.i.king@gmail.com>
      3 Chih-Yen Chang <cc85nod@gmail.com>
      2 Tom Talpey <tom@talpey.com>
      2 Kees Cook <keescook@chromium.org>
      2 Greg Kroah-Hartman <gregkh@linuxfoundation.org>
      2 Amir Goldstein <amir73il@gmail.com>
      1 ChenXiaoSong <chenxiaosong2@huawei.com> # 这是我
```

再`checkout`到`1a93084b9a89 ksmbd: move fs/cifsd to fs/ksmbd`（2021.06.24）之前的记录:
```sh
git checkout 131bac1ece2e16201674b2f29b64d2044c826b56
git log --follow --format='%aN <%aE>' fs/cifsd/ | sort | uniq -c | sort -nr
     91 Namjae Jeon <namjae.jeon@samsung.com>
     13 Hyunchul Lee <hyc.lee@gmail.com>
      9 Marios Makassikis <mmakassikis@freebox.fr>
      5 Dan Carpenter <dan.carpenter@oracle.com>
      3 Yang Yingliang <yangyingliang@huawei.com>
      3 Colin Ian King <colin.king@canonical.com>
      2 Muhammad Usama Anjum <musamaanjum@gmail.com>
      2 kernel test robot <lkp@intel.com>
```

