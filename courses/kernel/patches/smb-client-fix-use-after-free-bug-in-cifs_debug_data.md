[`d328c09ee9f1 smb: client: fix use-after-free bug in cifs_debug_data_proc_show()`](https://lore.kernel.org/all/20231030201956.2660-2-pc@manguebit.com/)

[openeuler的pr](https://gitee.com/openeuler/kernel/pulls/8522)

`struct cifs_ses`的`srv_lock`成员是在补丁`d7d7a66aacd6 cifs: avoid use of global locks for high contention data`中引入的。