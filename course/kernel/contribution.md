# Linux内核上游（Upstream）mainline仓库贡献 {#mainline}

[点击查看kernel.org网站Linux内核邮件列表我和社区的沟通](https://lore.kernel.org/all/?q=chenxiaosong)

[点击查看kernel.org网站上我的Linux内核上游仓库提交记录](https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/log/?qt=grep&q=chenxiaosong)（加载需要一丢丢时间哈，可以直接查看下面列出的补丁链接）
<!-- 主线: https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/log/?qt=grep&q=chenxiaosong -->

Linux内核是我现在的工作，更是我的兴趣和信仰（自由软件），在内核社区里可以让我这个小菜鸟直接和世上最顶尖的程序员交流。

主要从事的方向是**文件系统**（nfs，smb等），修复多个**内核社区CVE**（通用漏洞披露，Common Vulnerabilities and Exposures）。

下面按时间顺序列出所有的补丁，最新的补丁放在前面。

## SMB贡献 {#mainline-smb}

[点击这里查看我的SMB贡献](https://chenxiaosong.com/course/smb/contribution.html)。

我的内核补丁大部分都是SMB方向的。

## 内核其他模块贡献 {#mainline-others}

- [NFSv4, NFSD: move enum nfs_cb_opnum4 to include/linux/nfs4.h](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=52e89100754b2e888cb63bf2d19e65d809497cd6)（[邮件列表](https://lore.kernel.org/all/tencent_03EDD0CAFBF93A9667CFCA1B68EDB4C4A109@qq.com/)）
- [NFSv4.x: Fail client initialisation if state manager thread can't run](https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/commit/?id=b4e4f66901658fae0614dea5bf91062a5387eda7)（这个补丁是maintainer剽窃我的，[我的补丁请查看这里](https://lore.kernel.org/linux-nfs/20221112073055.1024799-1-chenxiaosong2@huawei.com/)）
- [NFSv4: check FMODE_EXEC from open context mode in nfs4_opendata_access()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=d564d2c4c2445cb0972453933dc87c2dcaac8597)（[查看分析](https://chenxiaosong.com/course/kernel/my-patch/CVE-2022-24448.html)）
- [CVE-2022-24448](https://nvd.nist.gov/vuln/detail/CVE-2022-24448): [NFS: make sure open context mode have FMODE_EXEC when file open for exec](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=6f1c1d95dc93b52a8ef9cc1f3f610c2d5e6b217b)（[查看分析](https://chenxiaosong.com/course/kernel/my-patch/CVE-2022-24448.html)）
- [btrfs: add might_sleep() annotations](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=a4c853af0c511d7e0f7cb306bbc8a4f1dbdb64ca)（[邮件列表](https://lore.kernel.org/all/20221116142354.1228954-2-chenxiaosong2@huawei.com/)）
- [CVE-2022-49033](https://nvd.nist.gov/vuln/detail/CVE-2022-49033): [btrfs: qgroup: fix sleep from invalid context bug in btrfs_qgroup_inherit()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=f7e942b5bb35d8e3af54053d19a6bf04143a3955)（[邮件列表](https://lore.kernel.org/all/20221116142354.1228954-3-chenxiaosong2@huawei.com/)）
- [nfsd: use DEFINE_SHOW_ATTRIBUTE to define nfsd_file_cache_stats_fops](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=1342f9dd3fc219089deeb2620f6790f19b4129b1)
- [nfsd: use DEFINE_SHOW_ATTRIBUTE to define nfsd_reply_cache_stats_fops](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=64776611a06322b99386f8dfe3b3ba1aa0347a38)
- [nfsd: use DEFINE_SHOW_ATTRIBUTE to define client_info_fops](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=1d7f6b302b75ff7acb9eb3cab0c631b10cfa7542)
- [nfsd: use DEFINE_SHOW_ATTRIBUTE to define export_features_fops and supported_enctypes_fops](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=9beeaab8e05d353d709103cafa1941714b4d5d94)
- [nfsd: use DEFINE_PROC_SHOW_ATTRIBUTE to define nfsd_proc_ops](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=0cfb0c4228a5c8e2ed2b58f8309b660b187cef02)
- [debugfs: use DEFINE_SHOW_ATTRIBUTE to define debugfs_regset32_fops](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=19029f3f47c7f2dd796cecd001619a37034d658a)
- [mtd: rawnand: remove misguided comment of nand_get_device()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=ddfa68d415c749390e6a89f760b5edfa2774ad7b)
- [ntfs: fix BUG_ON in ntfs_lookup_inode_by_name()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=1b513f613731e2afc05550e8070d79fac80c661e)（[邮件列表](https://lore.kernel.org/all/20220809064730.2316892-1-chenxiaosong2@huawei.com/)）
- [xfs: fix NULL pointer dereference in xfs_getbmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=001c179c4e26d04db8c9f5e3fef9558b58356be6)（[查看分析](https://chenxiaosong.com/course/kernel/my-patch/xfs-fix-NULL-pointer-dereference-in-xfs_getbmap.html)）
- [CVE-2023-26607](https://nvd.nist.gov/vuln/detail/CVE-2023-26607): [ntfs: fix use-after-free in ntfs_ucsncmp()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=38c9c22a85aeed28d0831f230136e9cf6fa2ed44)（[邮件列表](https://lore.kernel.org/all/20220709064511.3304299-1-chenxiaosong2@huawei.com/)）
- [NFS: remove redundant code in nfs_file_write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=064109db53ecc5d88621d02f36da9f33ca0d64bd)
- [NFS: Don't report ENOSPC write errors twice](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=e6005436f6cc9ed13288f936903f0151e5543485)（这个补丁是maintainer剽窃我的，[我的补丁请查看这里](https://chenxiaosong.com/course/kernel/my-patch/nfs-handle-writeback-errors-incorrectly.html)）
- [CVE-2022-24448](https://nvd.nist.gov/vuln/detail/CVE-2022-24448): [NFSv4: fix open failure with O_ACCMODE flag](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=b243874f6f9568b2daf1a00e9222cacdc15e159c)（[查看分析](https://chenxiaosong.com/course/kernel/my-patch/CVE-2022-24448.html)）
- [CVE-2022-24448](https://nvd.nist.gov/vuln/detail/CVE-2022-24448): [Revert "NFSv4: Handle the special Linux file open access mode"](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=ab0fc21bc7105b54bafd85bd8b82742f9e68898a)（[查看分析](https://chenxiaosong.com/course/kernel/my-patch/CVE-2022-24448.html)）
- [CVE-2022-48931](https://nvd.nist.gov/vuln/detail/CVE-2022-48931): [configfs: fix a race in configfs_{,un}register_subsystem()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=84ec758fb2daa236026506868c8796b0500c047d)（[查看分析](https://chenxiaosong.com/course/kernel/my-patch/configfs-fix-a-race-in-configfs_-un-register_subsyst.html)）
- [apparmor: fix doc warning](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=aa4ceed7c3276852031a3e3d6fa767ff1858831f)
- [nfs_common: fix doc warning](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=5823e40055166cdf959a77e7b5fe75998b0b9b1f)
- [tomoyo: fix doc warnings](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=98eaa63e96273de075f3ce4eac0f18b33d28b84c)
- [x86/sgx: Correct kernel-doc's arg name in sgx_encl_release()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=1d3156396cf6ea0873145092f4e040374ff1d862)
- [KVM: SVM: fix doc warnings](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=02ffbe6351f5c88337143bcbc649832ded7445c0)
- [Smack: fix doc warning](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=fe6bde732be8c4711a878b11491d9a2749b03909)
- [perf: qcom: Remove redundant dev_err call in qcom_l3_cache_pmu_probe()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=5ca54404e68de8560ca15e8d0e6b625fd05ceeaf)

# Linux内核上游（Upstream）其他贡献 {#upstream-other}

除了mainline仓库的补丁外，还有以下补丁:

- stable仓库linux-4.19.y分支: [VFS: Fix memory leak caused by concurrently mounting fs with subtype](https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/commit/?h=linux-4.19.y&id=8033f109be4a1d5b466284e8ab9119c04f2a334b)，[2021年11月2日提的补丁](https://lore.kernel.org/all/20211102142206.3972465-1-chenxiaosong2@huawei.com/)，[到半年后2022年5月13日才合入stable仓库linux-4.19.y分支](https://lore.kernel.org/all/20220513142228.347780404@linuxfoundation.org/)。
- 邮件列表: 补丁集: [NFS回写错误处理不正确的问题](https://chenxiaosong.com/course/kernel/my-patch/nfs-handle-writeback-errors-incorrectly.html)（未合入主线）
- 邮件列表: [[PATCH 4.19] NFS: fix null-ptr-deref in nfs_inode_add_request()](https://lore.kernel.org/all/20241209085410.601489-1-chenxiaosong@chenxiaosong.com/)


# openEuler的nfs多路径（nfs+）贡献 {#openeuler-enfs}

[点击这里查看我的openEuler nfs+贡献](https://chenxiaosong.com/enfs-contribution.html)。

