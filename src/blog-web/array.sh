# 每一行代表:
#	是否生成目录
#	是否添加签名
#	源文件，markdown或rst文件相对路径
#	目的文件，html文件相对路径，如果是~，就代表只和源文件的后缀名不同
#	网页标题
comm_array=(
	# 自我介绍
	1 1 src/blog-web/index.md index.html '陈孝松个人主页'
	1 1 src/blog-web/blog.md blog.html "陈孝松博客"
	1 1 src/blog-web/contribution.md contribution.html "陈孝松自由软件贡献"
	1 1 src/blog-web/course.md course.html "课程和视频"
	1 1 src/blog-web/q.md q.html "QQ交流群"
	1 1 src/blog-web/patent-paper.md patent-paper.html "陈孝松专利和论文"
	1 1 src/blog-web/video.md video.html "博客配套视频"
	# 课程
	1 1 course/myfs/myfs.md ~ '"我的"文件系统'
	0 1 course/kernel/kernel.md ~ "Linux内核课程"
		1 1 course/kernel/video.md ~ "Linux内核课程配套视频"
		1 1 course/kernel/introduction.md ~ "内核简介"
		1 1 course/kernel/environment.md ~ "内核开发环境"
		1 1 course/kernel/book.md ~ "内核书籍推荐"
		1 1 course/kernel/community.md ~ "内核社区"
		1 1 course/kernel/test.md ~ "内核测试工具"
		1 1 course/kernel/fs.md ~ "文件系统"
		1 1 course/kernel/debug.md ~ "内核调试方法"
		1 1 course/kernel/mm.md ~ "内存管理"
		1 1 course/kernel/process.md ~ "进程管理和调度"
		1 1 course/kernel/interrupt.md ~ "中断"
		1 1 course/kernel/syscall.md ~ "系统调用"
		1 1 course/kernel/block.md ~ "块I/O层"
		1 1 course/kernel/page-cache-writeback.md ~ "页缓存和页回写"
		1 1 course/kernel/timer.md ~ "定时器"
		1 1 course/kernel/bpf.md ~ "BPF"
		1 1 course/kernel/sync.md ~ "内核同步"
		1 1 course/kernel/network.md ~ "网络"
		1 1 course/kernel/contribution.md ~ "陈孝松Linux内核贡献"
			1 1 course/kernel/my-patch/configfs-fix-a-race-in-configfs_-un-register_subsyst.md ~
				"84ec758fb2da configfs: fix a race in configfs_{,un}register_subsystem()"
			1 1 course/kernel/my-patch/xfs-fix-NULL-pointer-dereference-in-xfs_getbmap.md ~
				"001c179c4e26d xfs: fix NULL pointer dereference in xfs_getbmap()"
			1 1 course/kernel/my-patch/CVE-2022-24448.md ~ "CVE-2022-24448"
			1 1 course/kernel/my-patch/nfs-handle-writeback-errors-incorrectly.md ~ "NFS回写错误处理不正确的问题"
			1 1 course/kernel/my-patch/CVE-2024-46742.md ~ "CVE-2024-46742"
		1 1 course/kernel/patch.md ~ "内核补丁分析"
			# 调度
			1 1 course/kernel/patch/sched-EEVDF-and-latency-nice-and-or-slice-attr.md ~
				"sched: EEVDF and latency-nice and/or slice-attr"
			# vfs
			1 1 course/kernel/patch/iomap-Set-all-uptodate-bits-for-an-Uptodate-page.md ~
				"4595a298d556 iomap: Set all uptodate bits for an Uptodate page"
			# ext
			1 1 course/kernel/patch/jbd2-fix-a-potential-race-while-discarding-reserved-.md ~
				"23e3d7f7061f jbd2: fix a potential race while discarding reserved buffers after an abort"
			1 1 course/kernel/patch/ext4-fix-bug_on-in-ext4_writepages.md ~
				"ef09ed5d37b8 ext4: fix bug_on in ext4_writepages"
			1 1 course/kernel/patch/ext4-fix-bug_on-in-start_this_handle-during-umount-f.md ~
				"b98535d09179 ext4: fix bug_on in start_this_handle during umount filesystem"
			1 1 course/kernel/patch/ext4-fix-symlink-file-size-not-match-to-file-content.md ~
				"a2b0b205d125 ext4: fix symlink file size not match to file content"
			1 1 course/kernel/patch/ext4-fix-use-after-free-in-ext4_search_dir.md ~
				"c186f0887fe7 ext4: fix use-after-free in ext4_search_dir"
			1 1 course/kernel/patch/refactor-of-__ext4_fill_super.md ~
				"some refactor of __ext4_fill_super()"
	0 1 course/mptcp/mptcp.md ~ "MPTCP"
		# issue
			1 1 course/mptcp/issue/drbd-mptcp.md ~ "drbd支持mptcp"
	0 1 course/nfs/nfs.md ~ "nfs文件系统"
		1 1 course/nfs/video.md ~ "nfs课程配套视频"
		1 1 course/nfs/introduction.md ~ "nfs简介"
		1 1 course/nfs/environment.md ~ "nfs环境"
		1 1 course/nfs/client-data-structure.md ~ "nfs client数据结构"
		1 1 course/nfs/pnfs.md ~ "Parallel NFS (pNFS)"
		1 1 course/nfs/debug.md ~ "nfs调试方法"
		1 1 course/nfs/multipath.md ~ "nfs多路径"
		1 1 course/nfs/other.md ~ "nfs未分类的内容"
		1 1 course/nfs/mailing-list.md ~ "nfs社区贡献"
		1 1 course/nfs/patch.md ~ "nfs补丁分析"
			# 其他人的补丁
			1 1 course/nfs/patch/xprtrdma-kmalloc-rpcrdma_ep-separate-from-rpcrdma_xp.md ~
				"e28ce90083f0 xprtrdma: kmalloc rpcrdma_ep separate from rpcrdma_xprt"
			1 1 course/nfs/patch/nfsd-minor-4.1-callback-cleanup.md ~
				"12357f1b2c8e nfsd: minor 4.1 callback cleanup"
			1 1 course/nfs/patch/nfsd-Fix-races-between-nfsd4_cb_release-and-nfsd4_sh.md ~
				"2bbfed98a4d8 nfsd: Fix races between nfsd4_cb_release() and nfsd4_shutdown_callback()"
			1 1 course/nfs/patch/nfsd-Don-t-release-the-callback-slot-unless-it-was-a.md ~
				"e6abc8caa6de nfsd: Don't release the callback slot unless it was actually held"
			1 1 course/nfs/patch/nfsd4-use-reference-count-to-free-client.md ~
				"59f8e91b75ec nfsd4: use reference count to free client"
			1 1 course/nfs/patch/NFSD-Reschedule-CB-operations-when-backchannel-rpc_c.md ~
				"c1ccfcf1a9bf NFSD: Reschedule CB operations when backchannel rpc_clnt is shut down"
			1 1 course/nfs/patch/NFS-Improve-warning-message-when-locks-are-lost.md ~
				"3e2910c7e23b NFS: Improve warning message when locks are lost."
			1 1 course/nfs/patch/nfsd-Remove-incorrect-check-in-nfsd4_validate_statei.md ~
				"600df3856f0b nfsd: Remove incorrect check in nfsd4_validate_stateid"
			1 1 course/nfs/patch/patchset-nfs_instantiate-might-succeed-leaving-dentry-negative-unhashed.md ~
				"patchset: nfs_instantiate() might succeed leaving dentry negative unhashed"
			1 1 course/nfs/patch/patchset-Fix-nfsv4.1-deadlock-between-nfs4_evict_inode-and-nfs4_opendata_get_inode.md ~
				"patchset: Fix nfsv4.1 deadlock between nfs4_evict_inode() and nfs4_opendata_get_inode()"
			1 1 course/nfs/patch/patchset-nfsd-dont-allow-concurrent-queueing-of-workqueue-jobs.md ~
				"patchset: nfsd: don't allow concurrent queueing of workqueue jobs"
			1 1 course/nfs/patch/NFSD-Make-it-possible-to-use-svc_set_num_threads_syn.md ~ 
				"[PATCH 00/20 v3] SUNRPC: clean up server thread management"
		1 1 course/nfs/issue.md ~ "nfs问题分析"
			1 1 course/nfs/issue/nfs-clients-same-hostname-clientid-expire.md ~ "多个NFS客户端使用相同的hostname导致clientid过期"
			1 1 course/nfs/issue/4.19-nfs-no-iterate_shared.md ~ "nfs没实现iterate_shared()导致的遍历目录无法并发问题"
			1 1 course/nfs/issue/4.19-null-ptr-deref-in-nfs_updatepage.md ~ '4.19 nfs_updatepage()空指针解引用问题'
			1 1 course/nfs/issue/4.19-aarch64-null-ptr-deref-in-nfs_readpage_async.md ~ "aarch64架构 4.19 nfs_readpage_async()空指针解引用问题"
			1 1 course/nfs/issue/4.19-null-ptr-deref-in-nfs_readpage_async.md ~ '4.19 nfs_readpage_async()空指针解引用问题'
			1 1 course/nfs/issue/4.19-warning-in-nfs4_put_stid-and-panic.md ~ "4.19 nfs4_put_stid()报warning紧接着panic的问题"
			1 1 course/nfs/issue/4.19-null-ptr-deref-in-__nfs3_proc_setacls.md ~ "4.19 __nfs3_proc_setacls()空指针解引用问题"
			1 1 course/nfs/issue/nfs-df-long-time.md ~ "nfs df命令执行时间长的问题"
			1 1 course/nfs/issue/4.19-nfs-soft-lockup-in-nfs_wb_page.md ~ "4.19 nfs_wb_page() soft lockup的问题"
			1 1 course/nfs/issue/nfsiostat-queue-long-time.md ~ "nfsiostat命令queue时间长的问题"
			1 1 course/nfs/issue/null-ptr-deref-in-nfs_ctx_key_to_expire.md ~ "nfs_ctx_key_to_expire()引用计数泄露和空指针解引用的问题"
			1 1 course/nfs/issue/cthon-nfs-tests.md ~ "Connectathon NFS tests测试问题"
			1 1 course/nfs/issue/4.19-nfs-soft-lockup-in-__rpc_execute.md ~ "4.19 __rpc_execute() soft lockup的问题"
			1 1 course/nfs/issue/nfs-hung-task.md ~ "nfs hung task问题"
			1 1 course/nfs/issue/4.19-ll-time-longer-than-suse-4.12.md ~ "4.19内核执行ll时间比4.12内核(suse)长的问题"
			1 1 course/nfs/issue/4.19-bug-in-nfs_unlock_request.md ~ "4.19内核nfs_unlock_request()报BUG()的问题"
			1 1 course/nfs/issue/4.19-__rpc_execute-ERESTARTSYS.md ~ "sunrpc __rpc_execute()出现ERESTARTSYS的问题"
			1 1 course/nfs/issue/4.19-rdma-not-supported.md ~ "4.19 nfs rdma协议不支持的问题"
			1 1 course/nfs/issue/ganesha-not-support-tmpfs.md ~ "nfs-ganesha不支持导出tmpfs的问题"
			1 1 course/nfs/issue/nfs-umount-device-is-busy.md ~ "umount nfs报错device is busy的问题"
			1 1 course/nfs/issue/stat-nfsv3-sync-write-time.md ~ "统计nfsv3同步写的时间"
			1 1 course/nfs/issue/null-ptr-deref-in-nfsd4_probe_callback.md ~ "nfsd4_probe_callback()空指针解引用问题"
			1 2 tmp/nfs/en-null-ptr-deref-in-nfsd4_probe_callback.md
				en/nfs/en-null-ptr-deref-in-nfsd4_probe_callback.html
				"null-ptr-deref in nfsd4_probe_callback()"
			1 1 course/nfs/issue/lockd-server-not-responding.md ~ "nfsv3 NLM请求超时的问题"
			1 1 course/nfs/issue/nfs-mount-hung-in-nlmclnt_init.md ~ "nfsv3挂载卡在nlmclnt_init()的问题"
			1 1 course/nfs/issue/nfsv3-mount-hung-with-same-option.md ~ "nfsv3选项一样时挂载hung住的问题"
		1 1 course/nfs/openeuler-enfs.md ~ "openEuler的nfs+"
			1 1 course/nfs/openeuler-enfs/contribution.md enfs-contribution.html "陈孝松openEuler nfs+贡献"
			1 1 course/nfs/openeuler-enfs/openeuler-enfs-null-ptr-deref-in-xprt_switch_get.md ~ "openEuler的nfs+ xprt_switch_get()空指针解引用问题"
			1 1 course/nfs/openeuler-enfs/openeuler-enfs-double-free-of-multipath_client_info.md ~ "openEuler的nfs+ multipath_client_info double free的问题"
			1 1 course/nfs/openeuler-enfs/openeuler-enfs-create-client-fail.md ~ "openEuler的nfs+初始化enfs client失败的问题"
			1 1 course/nfs/openeuler-enfs/openeuler-enfs-refactor.md ~ "openEuler的nfs+代码重构"
			1 1 course/nfs/openeuler-enfs/openeuler-enfs-server-not-responding.md ~ "openEuler的nfs+报错not responding的问题"
			1 1 course/nfs/openeuler-enfs/openeuler-enfs-recreate-shard-info.md ~ "openEuler的nfs+重新插入enfs模块时生成shard信息的功能"
	0 1 course/smb/smb.md ~ "smb文件系统"
		1 1 course/smb/video.md ~ "smb课程配套视频"
		1 1 course/smb/introduction.md ~ "smb简介"
		1 1 course/smb/environment.md ~ "smb环境"
		1 1 course/smb/ksmbd.md ~ "smb server (ksmbd)"
		1 1 course/smb/client-struct.md ~ "smb client数据结构"
		1 1 course/smb/debug.md ~ "smb调试方法"
		1 1 course/smb/refactor.md ~ "smb代码重构"
		1 1 course/smb/other.md ~ "smb未分类的内容"
		1 1 course/smb/mailing-list.md ~ "smb社区贡献"
			1 1 course/smb/patch/other-patch.md ~ "社区补丁"
		# 1 1 course/smb/patch.md ~ "smb补丁分析"
			# 其他人的补丁
			1 1 course/smb/patch/cifs-Fix-in-error-types-returned-for-out-of-credit-s.md ~
				"7de0394801da cifs: Fix in error types returned for out-of-credit situations."
		1 1 course/smb/issue.md ~ "smb问题分析"
			1 1 course/smb/issue/4.19-null-ptr-deref-in-cifs_reconnect.md ~ "4.19 cifs_reconnect()空指针解引用问题"
			1 1 course/smb/issue/cifs-newfstatat-ENOTSUPP.md ~ "cifs newfstatat()系统调用报错ENOTSUPP"
			1 1 course/smb/issue/samba-systemd-start-timeout.md ~ "源码编译的samba通过systemd启动超时的问题"
	0 1 course/algorithm/algorithm.md ~ "算法"
		1 1 course/algorithm/video.md ~ "算法课程配套视频"
		1 1 course/algorithm/book.md ~ "算法书籍推荐"
		1 1 course/algorithm/dynamic-programming.md ~ "动态规划"
		1 1 course/algorithm/sort.md ~ "排序算法"
		1 1 course/algorithm/heap-priority-queue.md ~ "堆（优先队列）"
		1 1 course/algorithm/prefix-sum.md ~ "前缀和、差分"
		1 1 course/algorithm/hash-table.md ~ "哈希表"
		1 1 course/algorithm/monotonic-stack.md ~ "单调栈"
		1 1 course/algorithm/greedy.md ~ "贪心"
		1 1 course/algorithm/backtracking.md ~ "回溯"
		1 1 course/algorithm/binary-search.md ~ "二分查找"
		1 1 course/algorithm/union-find.md ~ "并查集"
		1 1 course/algorithm/trie.md ~ "前缀树（字典树）"
		1 1 course/algorithm/recursion.md ~ "递归"
		1 1 course/algorithm/sliding-window.md ~ "滑动窗口"
		1 1 course/algorithm/breadth-first-search.md ~ "广度优先搜索"
		1 1 course/algorithm/depth-first-search.md ~ "深度优先搜索"
		1 1 course/algorithm/string.md ~ "字符串"
		1 1 course/algorithm/other.md ~ "未分类的内容"
	0 1 course/godot/godot.md ~ "Godot游戏开发课程"
		1 1 course/godot/introduction.md ~ "Godot简介"
		1 1 course/godot/demo.md ~ "Godot官方demo"
	0 1 course/gnu-linux/gnu-linux.md ~ "GNU/Linux课程"
		1 1 course/gnu-linux/book.md ~ "GNU/Linux书籍推荐"
		1 1 course/gnu-linux/install.md ~ "安装GNU/Linux发行版"
		1 1 course/gnu-linux/editor.md ~ "编辑器"
		1 1 course/gnu-linux/ssh-reverse.md ~ "反向ssh和内网穿透"
		1 1 course/gnu-linux/blog-web.md ~ "如何拥有个人域名的网站和邮箱"
		1 1 course/gnu-linux/docker.md ~ "Docker安装与使用"
		1 1 course/gnu-linux/git.md ~ "git分布式版本控制系统"
		1 1 course/gnu-linux/shell.md ~ "shell和shell脚本"
		1 1 course/gnu-linux/config.md ~ "GNU/Linux配置文件"
	0 1 course/harmony/harmony.md ~ "鸿蒙课程"
		1 1 course/harmony/contribution.md ~ "陈孝松OpenHarmony贡献"
		1 1 course/harmony/openharmony.md ~ "OpenHarmony开发"
		1 1 course/harmony/harmonyos-next.md ~ "HarmonyOS NEXT系统"
	# Linux内核
	1 1 src/kernel-environment/kernel-qemu-kvm.md ~ "QEMU/KVM环境搭建与使用"
	1 1 src/strace-fault-inject/strace-fault-inject.md ~ "strace内存分配失败故障注入"
	1 1 src/kernel/openeuler-sysmonitor.md ~ "openEuler的sysmonitor"
	1 1 src/kernel/kprobe-scsi-data.md ~ "使用kprobe监控scsi的读写数据"
	1 1 src/kernel/gio-to-mount.md ~ "gio执行慢的临时解决办法"
	# nfs
	1 1 src/nfs/4.19-nfs-mount-hung.md ~ "4.19 nfs lazy umount 后无法挂载的问题"
	1 1 src/nfs/unable-to-initialize-client-recovery-tracking.md ~ "重启nfs server后client打开文件卡顿很长时间的问题"
	1 1 src/nfs/4.19-ltp-nfs-fail.md ~ "4.19 ltp nfs测试失败问题"
	1 1 src/nfs/nfs-no-net-oom.md ~ "nfs断网导致oom的问题"
	# smb(cifs)
	# ext
	# xfs
	1 1 src/xfs/xfs-shutdown-fs.md ~ "xfs agf没落盘的问题"
	# 文件系统
	1 1 src/filesystem/microsoft-fs.md ~ "微软文件系统"
	1 1 src/btrfs/4.19-btrfs-forced-readonly.md ~ "4.19 btrfs文件系统变成只读的问题"
	1 1 src/filesystem/tmpfs-oom.md ~ "tmpfs不断写导致oom的问题"
	# cve
	1 1 src/cve/nfs-cve.md ~ "nfs cve"
	1 1 src/cve/smb-cve.md ~ "smb cve"
	1 1 src/cve/others-cve.md ~ "未分类的cve"
	# Linux环境
	1 1 src/macos/qemu-kvm-install-macos.md ~ "QEMU/KVM安装macOS系统"
	1 1 src/userspace-environment/ghostwriter-makdown.md ~ "ghostwriter: 一款makdown编辑器"
	1 1 src/userspace-environment/mosquitto-mqtt.md ~ "使用mosquitto搭建MQTT服务器"
	1 1 src/windows/wine.md ~ "Linux使用wine运行Windows软件"
	1 1 src/userspace-environment/eulerlauncher.md ~ "macOS下用EulerLauncher运行openEuler"
	# 其他
	1 1 src/windows/windows.md ~ "Windows系统"
	1 1 src/wubi/wubi.md ~ "五笔输入法"
	1 1 src/keybord/keybord.md ~ "键盘配置"
	1 1 src/free-software/free-software.md ~ "自由软件介绍"
	1 1 src/lorawan/stm32-linux.md ~ "STM32 Linux开发环境"
	1 1 src/lorawan/lorawan.md ~ "LoRaWAN"
	1 1 src/health/tooth-clean.md ~ "牙齿护理"
	1 1 src/game/black-myth-wukong.md ~ "黑神话：悟空"
	1 1 src/IELTS/IELTS.md ~ "雅思备考笔记"
	1 1 src/recipe/recipe.md ~ "菜谱"
	# 翻译
	1 1 src/blog-web/translation.md ~ "翻译"
		# kernel
		1 1 src/translation/kernel/sched-design-CFS.rst ~ "CFS Scheduler"
		1 1 src/translation/kernel/sched-eevdf.rst ~ "EEVDF Scheduler"
		1 1 src/translation/kernel/sched-ext.rst ~ "Extensible Scheduler Class"
		1 1 src/translation/kernel/An-EEVDF-CPU-scheduler-for-Linux.md ~ "An EEVDF CPU scheduler for Linux"
		1 1 src/translation/kernel/Completing-the-EEVDF-scheduler.md ~ "Completing the EEVDF scheduler"
		1 1 src/translation/kernel/ceph.rst ~ "Ceph Distributed File System"
		1 1 src/translation/kernel/kernel-doc.rst ~ "doc-guide/kernel-doc.rst"
		1 1 src/translation/kernel/gdb-kernel-debugging.rst ~ "dev-tools/gdb-kernel-debugging.rst"
		1 1 src/translation/kernel/kgdb.rst ~ "dev-tools/kgdb.rst"
		# nfs
		1 1 src/translation/nfs/kernel-doc-client-identifier.rst ~ "NFSv4 client identifier"
		1 1 src/translation/nfs/cthon-nfs-tests-readme.md ~ "Connectathon NFS tests README"
		1 1 src/translation/nfs/bugzilla-redhat-bug-2176575.md ~
			"Red Hat Bugzilla - Bug 2176575 - intermittent severe NFS client performance drop via nfs_server_reap_expired_delegations looping?"
		1 1 src/translation/nfs/pnfs.com.md ~ "pnfs.com"
		1 1 src/translation/nfs/kernel-doc-pnfs.md ~ "kernel doc: Reference counting in pnfs"
		1 1 src/translation/nfs/pnfs-development.md ~ "linux-nfs.org PNFS Development"
		1 1 src/translation/nfs/kernel-doc-nfs41-server.md ~ "kernel doc: NFSv4.1 Server Implementation"
		1 1 src/translation/nfs/kernel-doc-pnfs-block-server.md ~ "kernel doc: pNFS block layout server user guide"
		1 1 src/translation/nfs/kernel-doc-pnfs-scsi-server.md ~ "kernel doc: pNFS SCSI layout server user guide"
		1 1 src/translation/nfs/kernel-doc-nfs-idmapper.rst ~ "kernel doc: NFS ID Mapper"
		1 1 src/translation/nfs/man-nfsidmap.md ~ "nfs idmap相关man手册"
		1 1 src/translation/smb/libsmb2-readme.rst ~ "libsmb2 README"
		# smb
		1 1 src/translation/smb/ms-smb.md ~ "[MS-SMB]: Server Message Block (SMB) Protocol"
		1 1 src/translation/smb/ms-smb2.md ~ "[MS-SMB2]: Server Message Block (SMB) Protocol Versions 2 and 3"
		1 1 src/translation/smb/ksmbd-kernel-doc.md ~ "KSMBD kernel doc"
		1 1 src/translation/smb/ksmbd-tools-readme.md ~ "ksmbd-tools README"
		1 1 src/translation/smb/kernel-doc-cifs-introduction.rst ~ "kernel doc: admin-guide/cifs/introduction.rst"
		1 1 src/translation/smb/kernel-doc-cifs-todo.rst ~ "kernel doc: admin-guide/cifs/todo.rst"
		# btrfs
		1 1 src/translation/btrfs/btrfs-doc.rst ~ "BTRFS documentation"
		# wine
		1 1 src/translation/wine/building-wine-winehq-wiki.md ~ "Building Wine - WineHQ Wiki"
		1 1 src/translation/wine/box64-docs-X64WINE.md ~ "box64 Installing Wine64"
		1 1 src/translation/wine/box86-docs-X86WINE.md ~ "box86 Installing Wine (and winetricks)"
		# tests
		1 1 src/translation/tests/ltp-readme.md ~ "Linux Test Project README"
		1 1 src/translation/tests/ltp-network-tests-readme.md ~ "LTP Network Tests README"
		1 1 src/translation/tests/xfstests-readme.md ~ "xfstests README"
		1 1 src/translation/tests/xfstests-readme.config-sections.md ~ "xfstests README.config-sections"
		1 1 src/translation/tests/syzkaller.md ~ "syzkaller - kernel fuzzer"
		1 1 src/translation/tests/kdevops-readme.md ~ "kdevops README"
		1 1 src/translation/tests/kdevops-nfs.md ~ "kdevops docs/nfs.md"
		# qemu
		1 1 src/translation/qemu/qemu-networking-nat.md ~ "QEMU Documentation/Networking/NAT"
		# systemtap
		1 1 src/translation/systemtap/systemtap-readme.md ~ "systemtap README"
	# 书法
	1 1 src/calligraphy/calligraphy.md ~ "书法: 左手练字"
	1 1 tmp/calligraphy/zhaomengfu/danbabei.md calligraphy/zhaomengfu/danbabei.html "胆巴碑译文"
	1 1 tmp/calligraphy/zhaomengfu/chibifu.md calligraphy/zhaomengfu/chibifu.html "赤壁赋译文"
	1 1 tmp/calligraphy/zhaomengfu/luoshenfu.md calligraphy/zhaomengfu/luoshenfu.html "洛神赋译文"
	1 1 tmp/calligraphy/zhaomengfu/jianzhuan.md calligraphy/zhaomengfu/jianzhuan.html "汲黯传译文"
	1 1 tmp/calligraphy/lingfeijing.md calligraphy/lingfeijing.html "灵飞经译文"
	1 1 tmp/calligraphy/shengjiaoxu.md calligraphy/shengjiaoxu.html "圣教序译文"
	1 1 src/calligraphy/written.md ~ "左手写过的字"
)
