# 问题描述

在我写[用户态nfs server搭建](https://chenxiaosong.com/course/nfs/environment.html#userspace-server-environment)时，刚开始尝试导出的是`/tmp`目录，发现无法导出成功。

也许最后可能定位出来不是一个问题，但把这个过程记录一下还是挺有意思的，至少可以熟悉一下nfs-ganesha的代码。

# 调试

在`/etc/ganesha/ganesha.conf`配置文件添加以下配置:
```sh
LOG {
        # Default log level for all components
        Default_Log_Level = DEBUG;
}
```

重启并保存日志:
```sh
rm -rf /var/log/journal/* # 日志太多可以清空
systemctl daemon-reload
systemctl start nfs-ganesha
journalctl -u nfs-ganesha -b --no-pager > tmpfs-log.txt
```

有以下日志:
```sh
May 03 13:09:20 localhost.localdomain nfs-ganesha[1263]: [main] populate_posix_file_systems :FSAL :DEBUG :Ignoring /tmp because type tmpfs
```

# 补丁

回退补丁[`e21025367 Fixed GPFS create export issue during claim_posix_filesystem`](https://github.com/nfs-ganesha/nfs-ganesha/commit/e21025367)就能导出tmpfs。

这个补丁是为了解决[export fails due to stale dev id entry in avl tree (issue with resolve_posix_filesystem())](https://github.com/nfs-ganesha/nfs-ganesha/issues/857)。

