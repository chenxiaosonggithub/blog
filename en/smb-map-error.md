# Patches to Be Tested

- [[PATCH v6 0/5] smb: improve search speed of SMB2 maperror](https://lore.kernel.org/linux-cifs/20251225021035.656639-1-chenxiaosong.chenxiaosong@linux.dev/)

# KUnit Test Results

Build the kernel with `CONFIG_SMB_KUNIT_TESTS` enabled.

After running `modprobe cifs`, test results are as follows:
```sh
[   93.361488] Key type cifs.spnego registered
[   93.362679] Key type cifs.idmap registered
[   93.363845] KTAP version 1
[   93.364620] 1..1
[   93.365454]     KTAP version 1
[   93.366330]     # Subtest: smb2_maperror
[   93.367404]     # module: cifs
[   93.367405]     1..1
[   93.369173]     ok 1 maperror_test_check_search
[   93.369175] ok 1 smb2_maperror
```

All KUnit test cases passed!

# Minor Suggestions

## [[PATCH 1/2] cifs: Label SMB2 statuses with errors](https://lore.kernel.org/linux-cifs/782536.1765465397@warthog.procyon.org.uk/)

Hi David,

Did you use a script to update these macros? If so, could you put it in the commit message? I'm concerned that manual edits might introduce typos.

Just like the shell commands I used in this patch: [[PATCH 06/30] smb/client: add parentheses to NT error code definitions containing bitwise OR operator](https://lore.kernel.org/linux-cifs/20251208062100.3268777-7-chenxiaosong.chenxiaosong@linux.dev/)

Of course, your changes would require a more complex script.

## [[PATCH 2/2] cifs: Autogenerate SMB2 error mapping table](https://lore.kernel.org/linux-cifs/782578.1765465450@warthog.procyon.org.uk/)

Hi David,

`STATUS_SUCCESS` and `STATUS_WAIT_0` are both zero, and since zero indicates success, they are not needed.

The following status codes have duplicate values. We should update the status strings to make the log messages more explicit, as done in my patch: [[PATCH v4 09/10] smb/client: update some SMB2 status strings](https://lore.kernel.org/linux-cifs/20251206151826.2932970-10-chenxiaosong.chenxiaosong@linux.dev/).

- `STATUS_ABANDONED_WAIT_0`, `STATUS_ABANDONED`
- `STATUS_FWP_TOO_MANY_CALLOUTS`, `STATUS_FWP_TOO_MANY_BOOTTIME_FILTERS`

