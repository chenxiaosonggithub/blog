# 问题描述

在我写[用户态nfs server搭建](https://chenxiaosong.com/course/nfs/nfsd.html#userspace-server-environment)时，刚开始尝试导出的是`/tmp`目录，发现无法导出成功。

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

# 解决

```sh
--- a/src/FSAL/localfs.c
+++ b/src/FSAL/localfs.c
@@ -945,8 +945,7 @@ int populate_posix_file_systems(const char *path)
                    strcasecmp(mnt->mnt_type, "configfs") == 0 ||
                    strcasecmp(mnt->mnt_type, "binfmt_misc") == 0 ||
                    strcasecmp(mnt->mnt_type, "rpc_pipefs") == 0 ||
-                   strcasecmp(mnt->mnt_type, "vboxsf") == 0 ||
-                   strcasecmp(mnt->mnt_type, "tmpfs") == 0) {
+                   strcasecmp(mnt->mnt_type, "vboxsf") == 0) {
                        LogDebug(COMPONENT_FSAL, "Ignoring %s because type %s",
                                 mnt->mnt_dir, mnt->mnt_type);
                        continue;
```

