It is really enjoyable and exciting to contribute to SMB.

[Click here to see my emails on the SMB mailing list](https://lore.kernel.org/linux-cifs/?q=chenxiaosong).

[Click here to see my upstream Linux kernel commit history on kernel.org](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/log/?qt=grep&q=chenxiaosong)
（The page may take a moment to load, you can directly check the patch links listed below）
<!-- next: https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/log/?qt=grep&q=chenxiaosong -->

[Click here to see my other kernel module patches](https://chenxiaosong.com/course/kernel/contribution.html).

# 2026

- [[PATCH cifs-utils v3 0/1] smbinfo: add notify subcommand](https://lore.kernel.org/linux-cifs/20260107043109.1456095-1-chenxiaosong.chenxiaosong@linux.dev/)
- [[PATCH cifs-utils] cifs.upcall: fix calloc() argument order in main()](https://lore.kernel.org/linux-cifs/20251219041552.317198-1-chenxiaosong.chenxiaosong@linux.dev/)
- Review: [Decimated subseconds in smbinfo filebasicinfo timestamp output](https://lore.kernel.org/linux-cifs/shU8wpo2oNyUu4RkVuN0VHmIES1SzKRN9in6AJDn4EKDDGwMkzl2ShJ8i-4AfFOSKDDnEhxZVGH_w8y9JxO683d_QQzMJOig7eOb0AmaFBs=@denisons.org/)

- Review: [40e75e42f49c smb: client: fix open handle lookup in cifs_open()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=40e75e42f49c) (Author: Paulo Alcantara <pc@manguebit.org>)

- Review: [88d37abb366b smb/client: only export symbol for 'smb2maperror-test' module](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=88d37abb366b) (Author: Ye Bin <yebin10@huawei.com>)

- Review: [Re: [PATCH v4 5/5] smb: introduce struct file_posix_info](https://lore.kernel.org/linux-cifs/e2763a4a-48ad-4fb5-8f40-4b78882fbc0e@chenxiaosong.com/)
- Review: [Re: [PATCH v4 5/5] smb: introduce struct file_posix_info](https://lore.kernel.org/linux-cifs/634dbb0b-9a5d-4f3d-ab5f-f4dc75e3527e@chenxiaosong.com/)
- Review: [Re: [PATCH v4 5/5] smb: introduce struct file_posix_info](https://lore.kernel.org/linux-cifs/87181afa-553a-475c-8f08-3c292ba30ffb@chenxiaosong.com/)

- Review: [c15e7c62feb3 smb/server: Fix another refcount leak in smb2_open()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=c15e7c62feb3) (Author: Guenter Roeck <linux@roeck-us.net>)
  - Review: [Re: [PATCH] smb/server: Fix another refcount leak in smb2_open()](https://lore.kernel.org/linux-cifs/32c1704c-7c9e-4dbe-b852-0fff0124ddc4@chenxiaosong.com/)
  - Review: [Re: [PATCH v2 1/1] smb/server: fix refcount leak in smb2_open()](https://lore.kernel.org/linux-cifs/739c9e8d-238a-4f2d-938c-ed0ab9706098@chenxiaosong.com/)
  - Review: [Re: [PATCH v2 1/1] smb/server: fix refcount leak in smb2_open()](https://lore.kernel.org/linux-cifs/90fdfba1-e0be-4656-87fc-1921d233da37@chenxiaosong.com/)

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

- [[PATCH] smb/client: make SMB2 maperror KUnit tests a separate module](https://lore.kernel.org/linux-cifs/20260221080712.491144-1-chenxiaosong.chenxiaosong@linux.dev/)
  - [7d0bf050a587 smb/client: make SMB2 maperror KUnit tests a separate module](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=7d0bf050a587)

- [[PATCH 0/7] smb/client: update SMB1 maperror, part 2](https://lore.kernel.org/linux-cifs/20260122052402.2209206-1-chenxiaosong.chenxiaosong@linux.dev/)
  - [3774289f525c smb/client: move NT_STATUS_MORE_ENTRIES](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=3774289f525c)
  - [617a5d2473dc smb/client: rename to NT_ERROR_INVALID_DATATYPE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=617a5d2473dc)
  - [fa34d0a57033 smb/client: rename to NT_STATUS_SOME_NOT_MAPPED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=fa34d0a57033)
  - [4da735c48a27 smb/client: map NT_STATUS_PRIVILEGE_NOT_HELD](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=4da735c48a27)
  - [3e5f08342860 smb/client: map NT_STATUS_MORE_PROCESSING_REQUIRED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=3e5f08342860)
  - [e4424687fc6d smb/client: map NT_STATUS_BUFFER_OVERFLOW](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=e4424687fc6d)
  - [ba39063ca3ee smb/client: map NT_STATUS_NOTIFY_ENUM_DIR](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=ba39063ca3ee)

- [[PATCH 00/17] smb/client: update SMB1 maperror](https://lore.kernel.org/linux-cifs/20260121114912.2138032-1-chenxiaosong.chenxiaosong@linux.dev/) (Author: Huiwen He <hehuiwen@kylinos.cn>)
  - Review: [fbcdc61e7846 smb/client: remove useless comment in mapping_table_ERRSRV](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=fbcdc61e7846)
  - Review: [be9fc9033a0a smb/client: remove some literal NT error codes from ntstatus_to_dos_map](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=be9fc9033a0a)
  - Review: [199e7a1a2ed9 smb/client: add NT_STATUS_VOLUME_NOT_UPGRADED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=199e7a1a2ed9)
  - Review: [0bf7e53fec61 smb/client: add NT_STATUS_NO_USER_KEYS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=0bf7e53fec61)
  - Review: [ded739a08228 smb/client: add NT_STATUS_WRONG_EFS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=ded739a08228)
  - Review: [3988b5675296 smb/client: add NT_STATUS_NO_EFS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=3988b5675296)
  - Review: [2ef4f6b46f3c smb/client: add NT_STATUS_NO_RECOVERY_POLICY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=2ef4f6b46f3c)
  - Review: [47b84c745ba0 smb/client: add NT_STATUS_RANGE_NOT_FOUND](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=47b84c745ba0)
  - Review: [fbf88e79c53e smb/client: add NT_STATUS_DECRYPTION_FAILED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=fbf88e79c53e)
  - Review: [2ed0cdab5fcc smb/client: add NT_STATUS_ENCRYPTION_FAILED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=2ed0cdab5fcc)
  - Review: [096be7202493 smb/client: add NT_STATUS_DIRECTORY_IS_A_REPARSE_POINT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=096be7202493)
  - Review: [7982ddb7af9b smb/client: add NT_STATUS_VOLUME_DISMOUNTED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=7982ddb7af9b)
  - Review: [563318fa6dcc smb/client: add NT_STATUS_BIOS_FAILED_TO_CONNECT_INTERRUPT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=563318fa6dcc)
  - Review: [29aaf48e24b7 smb/client: add NT_STATUS_VARIABLE_NOT_FOUND](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=29aaf48e24b7)
  - Review: [ac635d68bac8 smb/client: rename ERRinvlevel to ERRunknownlevel](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=ac635d68bac8)
  - Review: [cd55c6e31189 smb/client: add NT_STATUS_OS2_INVALID_LEVEL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=cd55c6e31189)
  - Review: [b0a22915942f smb/client: map NT_STATUS_INVALID_INFO_CLASS to ERRbadpipe](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=b0a22915942f)

- [[PATCH v9 0/1] smb: improve search speed of SMB2 maperror](https://lore.kernel.org/linux-cifs/20260118091313.1988168-1-chenxiaosong.chenxiaosong@linux.dev/)
  - Review: [10dfb0738a9d cifs: Label SMB2 statuses with errors](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=10dfb0738a9d) (Author: David Howells <dhowells@redhat.com>)
    - Review: [Re: [PATCH 1/2] cifs: Label SMB2 statuses with errors](https://lore.kernel.org/linux-cifs/ff731375-b565-49f0-985b-7cb9022206d6@linux.dev/)
    - Review: [Re: [PATCH 1/2] cifs: Label SMB2 statuses with errors](https://lore.kernel.org/linux-cifs/f82a5d14-e4cc-46b5-be22-ce447dc65cbc@linux.dev/)
  - Review: [c527e13a7a66 cifs: Autogenerate SMB2 error mapping table](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=c527e13a7a66) (Author: David Howells <dhowells@redhat.com>)
    - Review: [Re: [PATCH 2/2] cifs: Autogenerate SMB2 error mapping table](https://lore.kernel.org/linux-cifs/8f3290fe-d74c-4cd6-86f4-017c52e1872e@linux.dev/)
  - [480afcb19b61 smb/client: introduce KUnit test to check search result of smb2_error_map_table](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=480afcb19b61)
  - [75563adbb91d smb/client: use bsearch() to find target in smb2_error_map_table](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=75563adbb91d)
  - [453382f15b0e smb/client: check whether smb2_error_map_table is sorted in ascending order](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=453382f15b0e)

- Review: [ebbbc4bfad4c smb: client: fix potential UAF and double free in smb2_open_file()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=ebbbc4bfad4c) (Author: Paulo Alcantara <pc@manguebit.org>)
  - Review: [Re: [PATCH] smb: client: fix potential UAF and double free it smb2_open_file()](https://lore.kernel.org/linux-cifs/bfa4a0be-8429-4ea1-8bd6-691c3a47ff00@linux.dev/)
  - Review: [Re: [PATCH] smb: client: fix potential UAF and double free it smb2_open_file()](https://lore.kernel.org/linux-cifs/cbedb833-0cf9-467e-8751-e975b965c467@linux.dev/)

- [[PATCH v3 0/1] smb/client: fix memory leaks](https://lore.kernel.org/linux-cifs/20260202094906.1933479-1-chenxiaosong.chenxiaosong@linux.dev/)
  - [67b3da8d3051 smb/client: fix memory leak in SendReceive()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=67b3da8d3051)
  - [e3a43633023e smb/client: fix memory leak in smb2_open_file()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=e3a43633023e)

# 2025

- Review: [fa2fd0b10f66 smb: client: fix UBSAN array-index-out-of-bounds in smb2_copychunk_range](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=fa2fd0b10f66) (Author: Henrique Carvalho <henrique.carvalho@suse.com>)
  - Review: [Re: generic/013 failure to Samba](https://lore.kernel.org/linux-cifs/2feaf0ac-172d-431c-805c-7b3440f1ebd5@linux.dev/)
  - Review: [Re: generic/013 failure to Samba](https://lore.kernel.org/linux-cifs/141824e7-50ab-4072-b611-5db5fa01bb86@linux.dev/)

- [[PATCH v2 0/1] smb/server: fix some refcount leaks](https://lore.kernel.org/linux-cifs/20251229031518.1027240-1-chenxiaosong.chenxiaosong@linux.dev/)
  - [f416c556997a smb/server: fix refcount leak in smb2_open()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=f416c556997a)
  - [3296c3012a9d smb/server: fix refcount leak in parse_durable_handle_context()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=3296c3012a9d)
  - Review: [xfstests failed test cases](https://lore.kernel.org/linux-cifs/bcd3d847-c38f-4c88-af07-3da09dad476b@linux.dev/)
  - Review: [Re: xfstests failed test cases](https://lore.kernel.org/linux-cifs/f1b9cd58-8a61-4fa7-a7e9-198c2c468c59@linux.dev/)
  - Review: [Re: xfstests failed test cases](https://lore.kernel.org/linux-cifs/9751f02d-d1df-4265-a7d6-b19761b21834@linux.dev/)

- [[PATCH] smb/server: call ksmbd_session_rpc_close() on error path in create_smb2_pipe()](https://lore.kernel.org/linux-cifs/20251228145101.1010774-1-chenxiaosong.chenxiaosong@linux.dev/)
  - [7c28f8eef5ac smb/server: call ksmbd_session_rpc_close() on error path in create_smb2_pipe()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=7c28f8eef5ac)

- Review: [cb6d5aa9c0f1 cifs: Fix memory and information leak in smb3_reconfigure()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=cb6d5aa9c0f1) (Author: Zilin Guan <zilin@seu.edu.cn>)

- [[PATCH v4 0/2] smb/server: fix minimum PDU size](https://lore.kernel.org/linux-cifs/20251220132551.351932-1-chenxiaosong.chenxiaosong@linux.dev/)
  - [4c7d8eb9a79a smb/server: fix minimum SMB2 PDU size](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=4c7d8eb9a79a)
  - [3b9c30eb8f5a smb/server: fix minimum SMB1 PDU size](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=3b9c30eb8f5a)

- Review: [0a70cac78967 ksmbd: Fix to handle removal of rfc1002 header from smb_hdr](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=0a70cac78967) (Author: David Howells <dhowells@redhat.com>)
  - Review: [Re: [PATCH] ksmbd: Fix to handle removal of rfc1002 header from smb_hdr](https://lore.kernel.org/linux-cifs/cb002f72-3e2a-4d23-b08d-f6d987a29661@linux.dev/)

- [[PATCH v2 0/7] smb: move duplicate definitions into common header file, part 2](https://lore.kernel.org/linux-cifs/20251211143228.172470-1-chenxiaosong.chenxiaosong@linux.dev/)
  - [94d5b8dbc5d9 smb: move some SMB1 definitions into common/smb1pdu.h](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=94d5b8dbc5d9)
  - [2b6abb893e71 smb: move File Attributes definitions into common/fscc.h](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=2b6abb893e71)
  - [c97503321ed3 smb: update struct duplicate_extents_to_file_ex](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=c97503321ed3)
  - [2e0d224d8988 smb/server: add comment to FileSystemName of FileFsAttributeInformation](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=2e0d224d8988)
  - [ab0347e67dac smb/client: remove DeviceType Flags and Device Characteristics definitions](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=ab0347e67dac)
  - [08c2a7d2bae9 smb: move file_notify_information to common/fscc.h](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=08c2a7d2bae9)
  - [6539e18517b6 smb: move SMB2 Notify Action Flags into common/smb2pdu.h](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=6539e18517b6)
  - [9ec7629b430a smb: move notify completion filter flags into common/smb2pdu.h](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=9ec7629b430a)
  - [bcdd6cfaf2ec smb: add documentation references for smb2 change notify definitions](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=bcdd6cfaf2ec)

- [[PATCH 00/30] smb: improve search speed of SMB1 maperror](https://lore.kernel.org/linux-cifs/20251208062100.3268777-1-chenxiaosong.chenxiaosong@linux.dev/)
  - [a71a4aab4834 smb/client: add parentheses to NT error code definitions containing bitwise OR operator](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=a71a4aab4834)
  - [a9adafd40165 smb/client: add 4 NT error code definitions](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=a9adafd40165)
  - [98def4eb0244 smb/server: remove unused nterr.h](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=98def4eb0244)
  - [9f99caa8950a smb/client: fix NT_STATUS_UNABLE_TO_FREE_VM value](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=9f99caa8950a)
  - [b2b50fca34da smb/client: fix NT_STATUS_DEVICE_DOOR_OPEN value](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=b2b50fca34da)
  - [a1237c203f17 smb/client: fix NT_STATUS_NO_DATA_DETECTED value](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=a1237c203f17)

- [[PATCH v9 0/1] smb: improve search speed of SMB2 maperror](https://lore.kernel.org/linux-cifs/20260118091313.1988168-1-chenxiaosong.chenxiaosong@linux.dev/)
  - [d8f52650b24d smb/client: update some SMB2 status strings](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=d8f52650b24d9018dfb65d2c60e17636b077e63e)
  - [d159702c9492 smb/client: add two elements to smb2_error_map_table array](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=d159702c9492de46cc1b39b3d83fd0c8a6bdb829)
  - [523ecd976632 smb: rename to STATUS_SMB_NO_PREAUTH_INTEGRITY_HASH_OVERLAP](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=523ecd976632523006c1b442e0eba4fe3c4f7e0c)
  - [bf80d1517dc8 smb/client: remove unused elements from smb2_error_map_table array](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=bf80d1517dc847eb7b4d8b3c14bfe6ed48fa27ae)
  - [6c1eb31ecb97 smb/client: reduce loop count in map_smb2_to_linux_error() by half](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=6c1eb31ecb97c07b4a880d59b3a83665359def36)
  - [01ab0d1640e3 smb/server: rename include guard in smb_common.h](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=01ab0d1640e3)

- [[PATCH v9 0/1] smb: move duplicate definitions to common header file](https://lore.kernel.org/linux-cifs/20251117112838.473051-1-chenxiaosong.chenxiaosong@linux.dev/)
  - [c4a2a49f7df4 smb: move FILE_SYSTEM_ATTRIBUTE_INFO to common/fscc.h](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=c4a2a49f7df48147529158a092edfde1597d12f3)
  - [5003ad718af7 smb: move create_durable_reconn to common/smb2pdu.h](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=5003ad718af7705d6a519445a897843fac88167a)
  - [e7e60e8bfcc5 smb: fix some warnings reported by scripts/checkpatch.pl](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=e7e60e8bfcc5bfff0dc40a3b8ab275a4da6990a0)
  - [95e8c1bfa56e smb: do some cleanups](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=95e8c1bfa56ebbc243779ee23782b30744da02f6)
  - [464b913993a1 smb: move FILE_SYSTEM_SIZE_INFO to common/fscc.h](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=464b913993a14b539e978db10c755bb202ab14ed)
  - [d7edd3892d97 smb: move some duplicate struct definitions to common/fscc.h](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=d7edd3892d97e6746e30f36f4f13f887ec4d80ed)
  - [84d8d4cf8873 smb: move list of FileSystemAttributes to common/fscc.h](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=84d8d4cf8873b4a9da0d76e9ba9d94ec88311cfd)
  - [d8ac9879182a smb: move SMB_NEGOTIATE_REQ to common/smb2pdu.h](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=d8ac9879182a1e1f3b97d166f5ba5e2f1b3e8535)
  - [1172d8598499 smb: move some duplicate definitions to common/smb2pdu.h](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=1172d8598499a006d172bb24bebaa3fdc99064a8)
  - [96721fd29226 smb: move create_durable_rsp_v2 to common/smb2pdu.h](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=96721fd292264d712b7b9a51752ab87de5035db4)
  - [81a45de432c6 smb: move create_durable_handle_reconnect_v2 to common/smb2pdu.h](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=81a45de432c6c7d82821fb09cb9fc1cf58629f3a)
  - [833a75fc9ecc smb: move create_durable_req_v2 to common/smb2pdu.h](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=833a75fc9ecc3856a52223d8c245e52703e0a9f1)
  - [884a1d4e9c09 smb: move MAX_CIFS_SMALL_BUFFER_SIZE to common/smbglob.h](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=884a1d4e9c09b4a0dbe748890bdd48aac8e5a6b6)
  - [4a7f96078032 smb/client: fix CAP_BULK_TRANSFER value](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=4a7f9607803203fe637c12b4ffce9973d85ee169)
  - [9c98f5eec877 smb: move resume_key_ioctl_rsp to common/smb2pdu.h](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=9c98f5eec877976dad1179149038a4b164e236b1)
  - [cc26f593dc19 smb: move copychunk definitions to common/smb2pdu.h](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=cc26f593dc193567bdb059a6ffde58e627a44f65)
  - [7844d50ca239 smb: move smb_sockaddr_in and smb_sockaddr_in6 to common/smb2pdu.h](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=7844d50ca239f0788e732608820f7026cb0cc8fb)
  - [cd311445d9f5 smb: move SMB1_PROTO_NUMBER to common/smbglob.h](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=cd311445d9f5510979f6e9f4344178b9f5a4d981)
  - [36c31540cf52 smb: move get_rfc1002_len() to common/smbglob.h](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=36c31540cf5279262bfd148d8537cd04866499f2)
  - [34cf191bb6a3 smb: move smb_version_values to common/smbglob.h](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=34cf191bb6a349dc88ec2c4f6355fe006ac669e0)
  - [94b955167e3b smb: rename common/cifsglob.h to common/smbglob.h](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=94b955167e3b11372e314f45f4b2fbf4f92493b9)
  - [d877470b5991 smb: move some duplicate definitions to common/cifsglob.h](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=d877470b59910b5c50383d634dda3782386bba51)
  - [CVE-2025-40285](https://nvd.nist.gov/vuln/detail/CVE-2025-40285): [379510a815cb smb/server: fix possible refcount leak in smb2_sess_setup()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=379510a815cb2e64eb0a379cb62295d6ade65df0)
  - [CVE-2025-40286](https://nvd.nist.gov/vuln/detail/CVE-2025-40286): [6fced056d2cc smb/server: fix possible memory leak in smb2_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=6fced056d2cc8d01b326e6fcfabaacb9850b71a4)

- [[PATCH v2 0/6] smb/server: fix return values of smb2_0_server_cmds proc](https://lore.kernel.org/linux-cifs/20251017104613.3094031-1-chenxiaosong.chenxiaosong@linux.dev/)
  - [7d9f51d36b6c smb/server: update some misguided comment of smb2_0_server_cmds proc](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=7d9f51d36b6c24e02b8a379cbaf1a273511ed403)
  - [a3c4445fdbbb smb/server: fix return value of smb2_oplock_break()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=a3c4445fdbbb83aa94ea1778717ef57006164814)
  - [269df046c1e1 smb/server: fix return value of smb2_ioctl()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=269df046c1e15ab34fa26fd90db9381f022a0963)
  - [dafe22bc676d smb/server: fix return value of smb2_query_dir()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=dafe22bc676d4fcb1ccb193c8cc3dda57942509d)
  - [d1a30b9ddc3d smb/server: fix return value of smb2_notify()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=d1a30b9ddc3d4c0e38666bd166d51863cb39f1c4)
  - [c5b462e35373 smb/server: fix return value of smb2_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=c5b462e35373a68a5a7954f5e00383998cc7fe92)

# 2024

- [[PATCH v2 00/12] smb: fix some bugs, move duplicate definitions to common header file, and some small cleanups](https://lore.kernel.org/linux-cifs/20240822082101.391272-1-chenxiaosong@chenxiaosong.com/)
  - [e2fcd3fa0351 smb: add comment to STATUS_MCA_OCCURED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=e2fcd3fa0351ea2133d1238fcc6a9f140c52d36f)
  - [78181a5504a4 smb: move SMB2 Status code to common header file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=78181a5504a401e421e65d0257a33f904e0e7c29)
  - [b51174da743b smb: move some duplicate definitions to common/smbacl.h](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=b51174da743b6b7cd87c02e882ebe60dcb99f8bf)
  - [09bedafc1e2c smb/client: rename cifs_ace to smb_ace](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=09bedafc1e2c5c82aad3cbfe1359e2b0bf752f3a)
  - [251b93ae7380 smb/client: rename cifs_acl to smb_acl](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=251b93ae73805b216e84ed2190b525f319da4c87)
  - [7f599d8fb3e0 smb/client: rename cifs_sid to smb_sid](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=7f599d8fb3e087aff5be4e1392baaae3f8d42419)
  - [3651487607ae smb/client: rename cifs_ntsd to smb_ntsd](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=3651487607ae778df1051a0a38bb34a5bd34e3b7)
  - [5e51224d2afb smb/client: fix typo: GlobalMid_Sem -> GlobalMid_Lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=5e51224d2afbda57f33f47485871ee5532145e18)
  - [2b7e0573a490 smb/server: update misguided comment of smb2_allocate_rsp_buf()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=2b7e0573a49064d9c94c114b4471327cd96ae39c)
  - [0dd771b7d60b smb/server: remove useless assignment of 'file_present' in smb2_open()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=0dd771b7d60b8281f10f6721783c60716d22075f)
  - [CVE-2024-46742](https://nvd.nist.gov/vuln/detail/CVE-2024-46742): [4e8771a3666c smb/server: fix potential null-ptr-deref of lease_ctx_info in smb2_open()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=4e8771a3666c8f216eefd6bd2fd50121c6c437db)（[查看分析](https://chenxiaosong.com/course/kernel/my-patch/CVE-2024-46742.html)）
  - [2186a116538a smb/server: fix return value of smb2_open()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=2186a116538a715b20e15f84fdd3545e5fe0a39b)（[邮件列表](https://lore.kernel.org/all/20240822082101.391272-2-chenxiaosong@chenxiaosong.com/)）

- [[PATCH] ksmbd: remove duplicate SMB2 Oplock levels definitions](https://lore.kernel.org/linux-cifs/20240619161753.385508-1-chenxiaosong@chenxiaosong.com/)
  - [ac5399d48616 ksmbd: remove duplicate SMB2 Oplock levels definitions](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=ac5399d48616644cb6ddfe39f8babe807d5f5cbd)

# 2023

- [[PATCH] ksmbd: fix possible refcount leak in smb2_open()](https://lore.kernel.org/linux-cifs/20230302135804.2583061-1-chenxiaosong2@huawei.com/)
  - [CVE-2023-53061](https://nvd.nist.gov/vuln/detail/CVE-2023-53061): [2624b445544f ksmbd: fix possible refcount leak in smb2_open()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=2624b445544ffc1472ccabfb6ec867c199d4c95c)

# 2022

- [502487847743 cifs: fix missing unlock in cifs_file_copychunk_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=502487847743018c93d75b401eac2ea4c4973123)（[邮件列表](https://patchwork.kernel.org/project/cifs-client/patch/20221119045159.1400244-1-chenxiaosong2@huawei.com/)）
- [542228db2f28 cifs: fix use-after-free on the link name](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=542228db2f28fdf775b301f2843e1fe486e7c797)（[邮件列表](https://patchwork.kernel.org/project/cifs-client/patch/20221104074441.634677-1-chenxiaosong2@huawei.com/)）
- [2b058acecf56 cifs: return the more nuanced writeback error on close()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=2b058acecf56f6b8fac781911a683219b9ca3b7b)（[邮件列表](https://lore.kernel.org/all/20220518145649.2487377-1-chenxiaosong2@huawei.com/)）

