# 问题描述

[samba](https://gitlab.com/samba-team/samba)最新代码服务启动失败，2025.05.22测试时提交记录是`57a57a189bd  lib/torture: assert that a test doesn't create new talloc children of context->ev`.

# 二分

二分定位到以下几个记录:
```sh
有问题 0b8be756eb3 wafsamba: Adjust 'match' logic to override paths in config.check()
编译有问题 6e504e022d0 dynconfig/wscript: Adjust default cleanup for waf 2.1.5
编译有问题 4c7d3cc74b8 wafsamba: Adjust for waf 2.1.5 case of some Options.options attributes
编译有问题 e8bf7f501cd wafsamba: Adjust for waf 2.1.5 wafsamba_options_parse_cmd_args return
编译有问题 307121c0f1a third_party: Update waf to version 2.1.5
没问题 f8428b56488 wafsamba: Set env variables before calling command
```

# 调试

打开调试开头，修改`/etc/samba/smb.conf`:
```sh
[global]
# 设置日志级别（调试级别 1~10，级别越高日志越详细）
log level = 4
# 定义日志文件路径（默认通常是/var/log/samba/）
log file = /var/log/samba/log.%m
```

