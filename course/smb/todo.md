和Steve French <smfrench@gmail.com>经常私下（没发送到邮件列表）交流一些待开发的特性，邮件还没全部整理完，会持续更新。

# SMB3.1.1 Feature/TODO list

```
Some general thoughts about fun projects for cifs.ko but first the
general goals:

1) High quality - make sure as many functional tests as possible can
run in 'reasonable' configurations (e.g. to Samba and ksmbd with the
SMB3.1.1 POSIX extensions and a reasonable subset of those to Windows
and the many various other servers without the SMB3.1.1 Linux protocol
extensions).   So action item for this:
   a) debug, fix and then add more xfstests to the list that can run
(see the buildbot e.g. but I also have some test scripts I have
posted, and we should keep the 'FULL test lists' for cifs.ko on the
Samba wiki page.  e.g. why does generic/009 fail
   b) add more cifs.ko specific tests (to test fsctls that are unique
to cifs.ko but also to test various reconnect scenarios e.g.) to the
cifs test group of xfstests
   c) add more functional tests (e.g. I added 10+ from the 'git'
functional tests to what our buildbot runs
   d) work with Meetakshi and Piyush on improving the 'LISA' test
automation and the test repos they pull the functional tests from
(they have a github repo for this)

Basically if an xfstest fails or skips from cifs.ko to Samba or ksmbd
- then it is worth debugging.   I estimate that at least 10 cifs.ko
bugs can be fixed from this and approximately 20 cifs 'features' (e.g.
support for POSIX ACLs, support for O_TMPFILE, support for "xifs_io
stat -v" support for various missing IOCTLs etc)

2) High security - make sure peer to peer Kerberos and IAKERB work -
both Windows and Mac now have support for these - make sure we
recognize these OIDs (in SPNEGO negotiation) and that  we upcall
properly etc (Alexander Bokovoy etc. can explain more of what is
needed if something fails).   Also ensure that we support the
strongest signing

3) Fixes:
    a) High priority: With SMB3.1.1 POSIX Extensions: there are a few
easy to spot bugs in chmod/chown to Samba (we also may spot some
server bugs in ksmbd or Samba when doing detailed testing with
SMB3.1.1 POSIX Extensions)
    b) there is a security bug where writing to a file with the setuid
bit set (with "cifsacl" or "modefromsid" mount option) does not clear
the setuid bit
    c) as directory leases become more common we had noticed some
intermittent problems when running tests that create/delete many files
in cached directories. Need to verify if still reproducible
   d) there is at least one intermittent netfs bug:
http://smb311-linux-testing.southcentralus.cloudapp.azure.com/#/builders/8/builds/207/steps/79/logs/stdio
   e) a deferred close issue "directory not empty" falure (presumably
a race between deferred close and delete).   See e.g.
http://smb311-linux-testing.southcentralus.cloudapp.azure.com/#/builders/8/builds/212/steps/41/logs/stdio
   f) intermittent generic/074 failure: see e.g.
http://smb311-linux-testing.southcentralus.cloudapp.azure.com/#/builders/8/builds/212/steps/43/logs/stdio
   g) intermittent "no such file or directory" failure See
http://smb311-linux-testing.southcentralus.cloudapp.azure.com/#/builders/5/builds/255/steps/300/logs/stdio
   h) fix generic/316 (incorrect fallocate, presumably missing a flush
call) http://smb311-linux-testing.southcentralus.cloudapp.azure.com/#/builders/6/builds/66/steps/108/logs/stdio

4) Features (some could require minor protocol extensions or new FSCTLs)
    a) high priority: async add channel support (Henrique WIP progress
patch, and anything else needed to enable multichannel by default
(when server NIC supports RSS, or multiple NICs)
    b) high priority: add support for SMB3.1.1 mounts over QUIC
(Henrique and Metz can help)
    c) high priority: add support for faster (GCM) signing
    d) high priority: finish off support for SMB3.1.1 compression
    e) add SMB3.1.1 clustering support
    f) add support for T10 ("ODX") offload
    g) add support for O_TMPFILE
    h) add POSIX ACL support
    i) add support for "xfs_io stat -v" (inode operation getattr?)
    j) add support for the relatively new Linux ioctl for query fs unique id
    k) High priority: add support for mounting with MacOS SMB3.1.1
protocol extensions
    l) Add support for the 'peer to peer' file sharing model that
Windows allows. Shyam has a little more detail on this.  Very cool
part of the protocol
    m) renameat2 full support (see generic/023)
    n) add casefold support (or flags?). see generic/556
    o) add RENAME_EXCHANGE and RENAME_WHITEOUT and RENAME_NOREPLACE
see generic/024 and generic/025
    p) add support for "trusted namespace"
    q) add defragmentation support.  See test generic/018
    r) add support for "chattr -i" (see test generic/079) and also
support for 'chattr -a" (see test generic/277)
    s) add support for quotas (see test generic/082)
    t) add deduplication support (see test generic/122)
    u) add support for EXCHANGE_RANGE (see test generic/263)
    v) add support for 'unshare' (see test generic/264)
    w) add support for encryption see generic/395
    x) readd (fix the regression, and add any missing pieces) support
for swap over SMB3.1.1 mounts. See generic/356 and 357 e.g.)
    y) add richacl support (which was invented for smb in the first
place) - see xfstests generic/362 through 372
     z) case preserving xattrs see generic/377

   I will try to cleanup the list later but hope this list helps

Any thoughts on this list?
```

# change notify {#change-notify}

```
I am also very interested in the work to improve the VFS to allow
filesystems, especially cifs.ko (client) to support change notify
(without having to use the ioctl or smb client specific tool, smbinfo
etc).  It will be very useful.
翻译:
我也对改进 VFS 的工作非常感兴趣，
这样文件系统（尤其是客户端的 cifs.ko）就能支持 change notify（更改通知） 功能，
而无需使用 ioctl 或特定于 SMB 客户端的工具（如 smbinfo 等）。
这将会非常有用。

There are MANY exciting features for both client
and server that would be broadly helpful, and of course as you spot
new ioctls or VFS syscall flags there is always the opportunity to
make small extensions to SMB3.1.1 Linux Extensions to make
Linux-->Linux exceptional over SMB3.1.1.
翻译:
对于客户端和服务器来说，都有许多令人兴奋的新功能，
这些功能将会带来广泛的帮助。
当然，当你发现新的 ioctl 或 VFS 系统调用标志时，
总是有机会对 SMB3.1.1 Linux 扩展 进行一些小的改进，
从而让 Linux --> Linux 通过 SMB3.1.1 的交互更加出色。

there are relatively simple things like improving the
compression support, adding support for SMB3.1.1 over QUIC, adding
support for some additional fsctls, adding support for faster GCM
signing, etc that are well documented
翻译:
有一些相对简单的改进方向，例如：
改进压缩支持、
为 SMB3.1.1 添加基于 QUIC 的支持、
增加对更多 FSCTL 的支持、
以及支持更快速的 GCM 签名 等等，
这些都有相当完善的文档说明。

And Metze could probably help with the minor changes needed to support
SMB3.1.1 over QUIC.
翻译: 而 Metze 可能可以协助完成支持 SMB3.1.1 over QUIC 所需的一些小改动。

Would be awesome to fix inotify in the vfs layer to work with network fs (since cifs.ko already supports change notify)
翻译: 如果能在 VFS 层修复 inotify，使其支持网络文件系统就太好了（因为 cifs.ko 已经支持 change notify）。

Have you seen this article from my presentation a few years ago at
LSF/MM summit? https://lwn.net/Articles/896055/
翻译: 你有没有看到我几年前在 LSF/MM 峰会上演讲时写的这篇文章？ https://lwn.net/Articles/896055/

Inotify API doesn't pass through to the underlying fs, so userspace apps that look for dir changes only get notified of local changes. Ironically the api was originally developed for samba server to use
翻译: Inotify API 不会将通知传递到底层文件系统，因此依赖目录变更通知的用户态应用只能收到本地发生的变更，而无法感知远程或底层文件系统产生的变更。具有讽刺意味的是，这个 API 最初正是为了供 Samba 服务器使用而开发的。

May not be too hard. Adding a call out to inotify to register with the underlying fs the need to watch for certain notify events should be fairly easy 
翻译: 应该不会太难。只需要让 inotify 调用底层文件系统，注册需要监听哪些通知事件，这件事应该比较容易实现。

Are any additional debug features for notify eg tracepoints and/or debug pseudo files that would help?
翻译: 对于 notify，还有没有什么额外的调试功能会有帮助？例如增加 tracepoint，或者提供一些用于调试的伪文件（debugfs 等）？
```

# Sashiko review的遗留问题

- [[PATCH v5 0/4] smb/client: fix incorrect nlink returned by fstat()](https://sashiko.dev/#/patchset/20260709025703.3715326-1-chenxiaosong%40chenxiaosong.com)

