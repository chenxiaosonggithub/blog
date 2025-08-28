# pdf翻译

我用了网页插件[沉浸式翻译](https://immersivetranslate.com/zh-Hans/)，如果你有更好的工具，请分享给我。

pdf文件太大可能有些工具不支持，可以使用Linux下的`pdftk`（PDF Toolkit）工具分割和合并pdf文件:
```sh
sudo apt-get install pdftk -y # 安装
pdftk file.pdf burst # 把每一页都拆分
pdftk file.pdf cat 1-10 output part1.pdf # 拆分1-10页
pdftk part1.pdf part2.pdf cat output merged.pdf # 合并
```

拆分pdf文件可以使用脚本[`split-pdf.sh`](https://github.com/chenxiaosonggithub/blog/blob/master/script/split-pdf.sh)。

# kernel

[CFS Scheduler](https://chenxiaosong.com/src/translation/kernel/sched-design-CFS.html)

[EEVDF Scheduler](https://chenxiaosong.com/src/translation/kernel/sched-eevdf.html)

[Extensible Scheduler Class](https://chenxiaosong.com/src/translation/kernel/sched-ext.html)

[An EEVDF CPU scheduler for Linux](https://chenxiaosong.com/src/translation/kernel/An-EEVDF-CPU-scheduler-for-Linux.html)

[Completing the EEVDF scheduler](https://chenxiaosong.com/src/translation/kernel/Completing-the-EEVDF-scheduler.html)

[Ceph Distributed File System](https://chenxiaosong.com/src/translation/kernel/ceph.html)

[doc-guide/kernel-doc.rst](https://chenxiaosong.com/src/translation/kernel/kernel-doc.html)

[dev-tools/gdb-kernel-debugging.rst](https://chenxiaosong.com/src/translation/kernel/gdb-kernel-debugging.html)

[dev-tools/kgdb.rst](https://chenxiaosong.com/src/translation/kernel/kgdb.html)

# nfs

[NFSv4 client identifier](https://chenxiaosong.com/src/translation/nfs/kernel-doc-client-identifier)

[Connectathon NFS tests README](https://chenxiaosong.com/src/translation/nfs/cthon-nfs-tests-readme.html)

[Red Hat Bugzilla - Bug 2176575 - intermittent severe NFS client performance drop via nfs_server_reap_expired_delegations looping?](https://chenxiaosong.com/src/translation/nfs/bugzilla-redhat-bug-2176575.html)

[pnfs.com](https://chenxiaosong.com/src/translation/nfs/pnfs.com.html)

[kernel doc: Reference counting in pnfs](https://chenxiaosong.com/src/translation/nfs/kernel-doc-pnfs.html)

[linux-nfs.org PNFS Development](https://chenxiaosong.com/src/translation/nfs/pnfs-development.html)

[kernel doc: NFSv4.1 Server Implementation](https://chenxiaosong.com/src/translation/nfs/kernel-doc-nfs41-server.html)

[kernel doc: pNFS block layout server user guide](https://chenxiaosong.com/src/translation/nfs/kernel-doc-pnfs-block-server.html)

[kernel doc: pNFS SCSI layout server user guide](https://chenxiaosong.com/src/translation/nfs/kernel-doc-pnfs-scsi-server.html)

[kernel doc: NFS ID Mapper](https://chenxiaosong.com/src/translation/nfs/kernel-doc-nfs-idmapper.html)

[nfs idmap相关man手册](https://chenxiaosong.com/src/translation/nfs/man-nfsidmap.html)

[libsmb2 README](https://chenxiaosong.com/src/translation/smb/libsmb2-readme.html)

# smb

[[MS-SMB]: Server Message Block (SMB) Protocol](https://chenxiaosong.com/src/translation/smb/ms-smb.html)

[[MS-SMB2]: Server Message Block (SMB) Protocol Versions 2 and 3](https://chenxiaosong.com/src/translation/smb/ms-smb2.html)

[KSMBD kernel doc](https://chenxiaosong.com/src/translation/smb/ksmbd-kernel-doc.html)

[ksmbd-tools README](https://chenxiaosong.com/src/translation/smb/ksmbd-tools-readme.html)

[kernel doc: admin-guide/cifs/introduction.rst](https://chenxiaosong.com/src/translation/smb/kernel-doc-cifs-introduction.html)

[kernel doc: admin-guide/cifs/todo.rst](https://chenxiaosong.com/src/translation/smb/kernel-doc-cifs-todo.html)

# btrfs

[BTRFS documentation](https://chenxiaosong.com/src/translation/btrfs/btrfs-doc.html)

# wine

[Building Wine - WineHQ Wiki](https://chenxiaosong.com/src/translation/wine/building-wine-winehq-wiki.html)

[box64 Installing Wine64](https://chenxiaosong.com/src/translation/wine/box64-docs-X64WINE.html)

[box86 Installing Wine (and winetricks)](https://chenxiaosong.com/src/translation/wine/box86-docs-X86WINE.html)

# tests

[Linux Test Project README](https://chenxiaosong.com/src/translation/tests/ltp-readme.html)

[LTP Network Tests README](https://chenxiaosong.com/src/translation/tests/ltp-network-tests-readme.html)

[xfstests README](https://chenxiaosong.com/src/translation/tests/xfstests-readme.html)

[xfstests README.config-sections](https://chenxiaosong.com/src/translation/tests/xfstests-readme.config-sections.html)

[syzkaller - kernel fuzzer](https://chenxiaosong.com/src/translation/tests/syzkaller.html)

[kdevops README](https://chenxiaosong.com/src/translation/tests/kdevops-readme.html)

[kdevops docs/nfs.md](https://chenxiaosong.com/src/translation/tests/kdevops-nfs.html)

# qemu

[QEMU Documentation/Networking/NAT](https://chenxiaosong.com/src/translation/qemu/qemu-networking-nat.html)

# systemtap

[systemtap README](https://chenxiaosong.com/src/translation/systemtap/systemtap-readme.html)

