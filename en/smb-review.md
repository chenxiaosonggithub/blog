# SMB patches I have contributed

[Click here to see SMB patches contributed by ChenXiaoSong](https://chenxiaosong.com/en/smb-contribution.html).

# SMB patches I have reviewed

The following are the SMB patches I have reviewed, listed with the most recent first.

- Review: [235e32320a47 ksmbd: fix use-after-free in __ksmbd_close_fd() via durable scavenger](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=235e32320a47)

- [[PATCH v5 0/7] smb: fix some bugs, move duplicate definitions into common header file, part 2](https://lore.kernel.org/linux-cifs/20260303151317.136332-1-zhang.guodong@linux.dev/)
  - Review: [95e1d378ce30 smb: move filesystem_vol_info into common/fscc.h](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=95e1d378ce30)
  - Review: [31884d4bc981 smb: move file_basic_info into common/fscc.h](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=31884d4bc981)
  - Review: [a5e581093b1d smb: move some definitions from common/smb2pdu.h into common/fscc.h](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=a5e581093b1d)

- Review: [bc1a64d23641 smb: client: add missing MODULE_DESCRIPTION() to smb1maperror_test](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=bc1a64d23641)

- Review: [59ea368431dd smb/client: move smb2maperror declarations to smb2proto.h](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=59ea368431dd)

- [[PATCH v3 00/13] smb: improve search speed of SMB1 maperror](https://lore.kernel.org/linux-cifs/20260402141839.461257-1-huiwen.he@linux.dev/)
  - Review: [85274a3bd40f smb/client: introduce KUnit tests to check DOS/SRV err mapping search](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=85274a3bd40f)
  - Review: [8c028dd086ad smb/client: check if SMB1 DOS/SRV error mapping arrays are sorted](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=8c028dd086ad)
  - Review: [95e6b7340957 smb/client: use binary search for SMB1 DOS/SRV error mapping](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=95e6b7340957)
  - Review: [58ac796bb3c0 smb/client: autogenerate SMB1 DOS/SRV to POSIX error mapping](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=58ac796bb3c0)
  - Review: [cd4e653a2f75 smb/client: annotate smberr.h with POSIX error codes](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=cd4e653a2f75)
  - Review: [669c3eedaefa smb/client: move ERRnetlogonNotStarted to DOS error class](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=669c3eedaefa)
  - Review: [e3ac6352a84d smb/client: introduce KUnit test to check ntstatus_to_dos_map search](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=e3ac6352a84d)
  - Review: [010ad1e895db smb/client: check if ntstatus_to_dos_map is sorted](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=010ad1e895db)
  - Review: [3c6c23ed9424 smb/client: use binary search for NT status to DOS mapping](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=3c6c23ed9424)
  - Review: [772d5920c3d4 smb/client: refactor ntstatus_to_dos() to return mapping entry](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=772d5920c3d4)
  - Review: [c825f6b7432a smb/client: replace nt_errs with ntstatus_to_dos_map](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=c825f6b7432a)
  - Review: [415c5b8c9a41 smb/client: autogenerate SMB1 NT status to DOS error mapping](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=415c5b8c9a41)
  - Review: [378f75b7d6ea smb/client: annotate nterr.h with DOS error codes](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=378f75b7d6ea)

- Review: [53cf44fa7271 smb/client: avoid null-ptr-deref when tests fail in test_cmp_map()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=53cf44fa7271)

- Review: [34420cb92dbb smb/client: ensure smb2_mapping_table rebuild on cmd changes](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=34420cb92dbb) (Author: Huiwen He <hehuiwen@kylinos.cn>)

- Review: [309b44ed6844 ksmbd: fix memory leaks and NULL deref in smb2_lock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=309b44ed6844) (Author: Werner Kasselman <werner@verivus.com>)
  - Review: [Re: [PATCH] ksmbd: fix memory leaks and NULL deref in smb2_lock()](https://lore.kernel.org/linux-cifs/308acd9f-58d9-4519-aaa6-be96f140177d@chenxiaosong.com/)
  - Review: [Re: [PATCH] ksmbd: fix memory leaks and NULL deref in smb2_lock()](https://lore.kernel.org/linux-cifs/9192ff4b-770a-411b-af5d-ab06d20248f8@chenxiaosong.com/)
  - Review: [Re: [PATCH v2] ksmbd: fix memory leaks and NULL deref in smb2_lock()](https://lore.kernel.org/linux-cifs/02e11b2c-a472-46ac-95a4-ffe7013c3133@chenxiaosong.com/)

- Review: [48623ec358c1 ksmbd: fix use-after-free and NULL deref in smb_grant_oplock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=48623ec358c1) (Author: Werner Kasselman <werner@verivus.com>)
  - Review: [Re: [PATCH] ksmbd: fix use-after-free and NULL deref in smb_grant_oplock()](https://lore.kernel.org/linux-cifs/6b98c261-b17b-45a8-ab09-efdb0d658f4e@chenxiaosong.com/)
  - Review: [Re: [PATCH] ksmbd: fix use-after-free and NULL deref in smb_grant_oplock()](https://lore.kernel.org/linux-cifs/1e0882ea-4e59-4b70-b1ae-90fde86c252b@chenxiaosong.com/)
  - Review: [Re: [PATCH v3] ksmbd: fix use-after-free and NULL deref in smb_grant_oplock()](https://lore.kernel.org/linux-cifs/435dda9f-93f5-41db-9d21-70371d31857b@chenxiaosong.com/)
  - Review: [Re: [PATCH] ksmbd: fix use-after-free and NULL deref in smb_grant_oplock()](https://lore.kernel.org/linux-cifs/7ecf9af4-096a-45f5-9d00-fc7ae750e7db@chenxiaosong.com/)

- Review: [40e75e42f49c smb: client: fix open handle lookup in cifs_open()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=40e75e42f49c) (Author: Paulo Alcantara <pc@manguebit.org>)

- Review: [88d37abb366b smb/client: only export symbol for 'smb2maperror-test' module](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=88d37abb366b) (Author: Ye Bin <yebin10@huawei.com>)

<!--
TODO:
- [Re: [PATCH v3 4/5] smb: introduce struct create_posix_ctxt_rsp](https://lore.kernel.org/linux-cifs/c9d1c233-facd-4387-bed2-b2c1dbc88cbe@linux.dev/)
- [Re: [PATCH 25/37] cifs: SMB1 split: Split SMB1 protocol defs into smb1pdu.h](https://lore.kernel.org/linux-cifs/b3895f58-2c70-441b-8975-77c121ee2950@linux.dev/)
-->
- [[PATCH v5 0/7] smb: fix some bugs, move duplicate definitions into common header file, part 2](https://lore.kernel.org/linux-cifs/20260303151317.136332-1-zhang.guodong@linux.dev/) (Author: ZhangGuoDong <zhangguodong@kylinos.cn>)
  - Review: [8098179dc981 smb/client: remove unused SMB311_posix_query_info()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=8098179dc981)
  - Review: [9621b996e4db smb/client: fix buffer size for smb311_posix_qinfo in SMB311_posix_query_info()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=9621b996e4db)
  - Review: [12c43a062acb smb/client: fix buffer size for smb311_posix_qinfo in smb2_compound_op()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=12c43a062acb)
  - Review: [6f0402539b7d smb: update some doc references](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=6f0402539b7d)

- [Re: [PATCH v4 5/5] smb: introduce struct file_posix_info](https://lore.kernel.org/linux-cifs/e2763a4a-48ad-4fb5-8f40-4b78882fbc0e@chenxiaosong.com/)
- [Re: [PATCH v4 5/5] smb: introduce struct file_posix_info](https://lore.kernel.org/linux-cifs/634dbb0b-9a5d-4f3d-ab5f-f4dc75e3527e@chenxiaosong.com/)
- [Re: [PATCH v4 5/5] smb: introduce struct file_posix_info](https://lore.kernel.org/linux-cifs/87181afa-553a-475c-8f08-3c292ba30ffb@chenxiaosong.com/)

- Review: [c15e7c62feb3 smb/server: Fix another refcount leak in smb2_open()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=c15e7c62feb3) (Author: Guenter Roeck <linux@roeck-us.net>)
  - Review: [Re: [PATCH] smb/server: Fix another refcount leak in smb2_open()](https://lore.kernel.org/linux-cifs/32c1704c-7c9e-4dbe-b852-0fff0124ddc4@chenxiaosong.com/)
  - Review: [Re: [PATCH v2 1/1] smb/server: fix refcount leak in smb2_open()](https://lore.kernel.org/linux-cifs/739c9e8d-238a-4f2d-938c-ed0ab9706098@chenxiaosong.com/)
  - Review: [Re: [PATCH v2 1/1] smb/server: fix refcount leak in smb2_open()](https://lore.kernel.org/linux-cifs/90fdfba1-e0be-4656-87fc-1921d233da37@chenxiaosong.com/)

- [Re: [PATCH v2 1/1] smb/server: fix refcount leak in smb2_open()](https://lore.kernel.org/linux-cifs/739c9e8d-238a-4f2d-938c-ed0ab9706098@chenxiaosong.com/)
- [Re: [PATCH v2 1/1] smb/server: fix refcount leak in smb2_open()](https://lore.kernel.org/linux-cifs/90fdfba1-e0be-4656-87fc-1921d233da37@chenxiaosong.com/)
- [Re: [PATCH v3 4/5] smb: introduce struct create_posix_ctxt_rsp](https://lore.kernel.org/linux-cifs/c9d1c233-facd-4387-bed2-b2c1dbc88cbe@linux.dev/)

- Review: [ebbbc4bfad4c smb: client: fix potential UAF and double free in smb2_open_file()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=ebbbc4bfad4c) (Author: Paulo Alcantara <pc@manguebit.org>)
  - Review: [Re: [PATCH] smb: client: fix potential UAF and double free it smb2_open_file()](https://lore.kernel.org/linux-cifs/bfa4a0be-8429-4ea1-8bd6-691c3a47ff00@linux.dev/)
  - Review: [Re: [PATCH] smb: client: fix potential UAF and double free it smb2_open_file()](https://lore.kernel.org/linux-cifs/cbedb833-0cf9-467e-8751-e975b965c467@linux.dev/)

- [Re: xfstests failed test cases](https://lore.kernel.org/linux-cifs/9751f02d-d1df-4265-a7d6-b19761b21834@linux.dev/)
- [Re: xfstests failed test cases](https://lore.kernel.org/linux-cifs/f1b9cd58-8a61-4fa7-a7e9-198c2c468c59@linux.dev/)
- [xfstests failed test cases](https://lore.kernel.org/linux-cifs/bcd3d847-c38f-4c88-af07-3da09dad476b@linux.dev/)
- [Re: Decimated subseconds in smbinfo filebasicinfo timestamp output](https://lore.kernel.org/linux-cifs/f063be7f-7d09-4f07-9a44-7c8f1484de25@linux.dev/)
- [Decimated subseconds in smbinfo filebasicinfo timestamp output](https://lore.kernel.org/linux-cifs/shU8wpo2oNyUu4RkVuN0VHmIES1SzKRN9in6AJDn4EKDDGwMkzl2ShJ8i-4AfFOSKDDnEhxZVGH_w8y9JxO683d_QQzMJOig7eOb0AmaFBs=@denisons.org/)
- [Re: [PATCH 25/37] cifs: SMB1 split: Split SMB1 protocol defs into smb1pdu.h](https://lore.kernel.org/linux-cifs/b3895f58-2c70-441b-8975-77c121ee2950@linux.dev/)

- Review and Ack: [fa2fd0b10f66 smb: client: fix UBSAN array-index-out-of-bounds in smb2_copychunk_range](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=fa2fd0b10f66) (Author: Henrique Carvalho <henrique.carvalho@suse.com>)
  - Review: [Re: generic/013 failure to Samba](https://lore.kernel.org/linux-cifs/2feaf0ac-172d-431c-805c-7b3440f1ebd5@linux.dev/)
  - Review: [Re: generic/013 failure to Samba](https://lore.kernel.org/linux-cifs/141824e7-50ab-4072-b611-5db5fa01bb86@linux.dev/)

- Review: [cb6d5aa9c0f1 cifs: Fix memory and information leak in smb3_reconfigure()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=cb6d5aa9c0f1) (Author: Zilin Guan <zilin@seu.edu.cn>)

- [Re: [PATCH] ksmbd: Fix to handle removal of rfc1002 header from smb_hdr](https://lore.kernel.org/linux-cifs/cb002f72-3e2a-4d23-b08d-f6d987a29661@linux.dev/)
- [Re: [PATCH 2/2] cifs: Autogenerate SMB2 error mapping table](https://lore.kernel.org/linux-cifs/8f3290fe-d74c-4cd6-86f4-017c52e1872e@linux.dev/)
- [Re: [PATCH 1/2] cifs: Label SMB2 statuses with errors](https://lore.kernel.org/linux-cifs/ff731375-b565-49f0-985b-7cb9022206d6@linux.dev/)
- [Re: [PATCH 1/2] cifs: Label SMB2 statuses with errors](https://lore.kernel.org/linux-cifs/f82a5d14-e4cc-46b5-be22-ce447dc65cbc@linux.dev/)

