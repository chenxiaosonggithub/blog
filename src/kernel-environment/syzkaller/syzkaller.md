[toc]

```shell
CONFIG_KCOV=y
CONFIG_KCOV_INSTRUMENT_ALL=y
CONFIG_KCOV_ENABLE_COMPARISONS=y
CONFIG_DEBUG_FS=y

CONFIG_CMDLINE_BOOL=y
CONFIG_CMDLINE="net.ifnames=0"

CONFIG_E1000=y
CONFIG_E1000E=y
CONFIG_E1000E_HWTS=y

CONFIG_BINFMT_MISC=y
```

配置： https://github.com/google/syzkaller/blob/master/pkg/mgrconfig/config.go

复现：
```shell
./syz-execprog -executor=./syz-executor -repeat=0 -procs=16 -cover=0 ./log0
```
