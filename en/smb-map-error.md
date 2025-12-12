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

# Patches to Be Tested

David Howells's patches;

  - [[PATCH 1/2] cifs: Label SMB2 statuses with errors](https://lore.kernel.org/linux-cifs/782536.1765465397@warthog.procyon.org.uk/)
  - [[PATCH 2/2] cifs: Autogenerate SMB2 error mapping table](https://lore.kernel.org/linux-cifs/782578.1765465450@warthog.procyon.org.uk/)

ChenXiaoSong's patches;

  - [[PATCH 1/3] smb/client: use bsearch() to find target in smb2_error_map_table array](https://github.com/chenxiaosonggithub/tmp/blob/master/gnu-linux/smb/patch/smb2maperror/0001-smb-client-use-bsearch-to-find-target-in-smb2_error_.patch)
  - [[PATCH 2/3] smb/client: introduce smb2_get_err_map()](https://github.com/chenxiaosonggithub/tmp/blob/master/gnu-linux/smb/patch/smb2maperror/0002-smb-client-introduce-smb2_get_err_map.patch)
  - [[PATCH 3/3] smb/client: introduce smb2maperror KUnit tests](https://github.com/chenxiaosonggithub/tmp/blob/master/gnu-linux/smb/patch/smb2maperror/0003-smb-client-introduce-smb2maperror-KUnit-tests.patch)

# KUnit Test Results

Build the kernel with `CONFIG_SMB_KUNIT_TESTS` enabled.

After running `modprobe cifs`, test results are as follows:
```sh
[   18.929796] Key type cifs.spnego registered
[   18.931004] Key type cifs.idmap registered
[   18.932162] KTAP version 1
[   18.932963] 1..1
[   18.933845]     KTAP version 1
[   18.934734]     # Subtest: smb2_maperror
[   18.935817]     # module: cifs
[   18.935819]     1..2
[   18.937479]     ok 1 maperror_test_check_sort
[   18.937951]     ok 2 maperror_test_check_search
[   18.939158] # smb2_maperror: pass:2 fail:0 skip:0 total:2
[   18.940408] # Totals: pass:2 fail:0 skip:0 total:2
[   18.941897] ok 1 smb2_maperror
```

All KUnit test cases passed!

