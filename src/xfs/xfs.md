# 工具软件

<!-- https://access.redhat.com/documentation/zh-cn/red_hat_enterprise_linux/8/html/managing_file_systems/comparison-of-tools-used-with-ext4-and-xfs_getting-started-with-an-ext4-file-system -->

- `xfs_metadump -o image-file meta-file`: 将 XFS 文件系统元数据复制到文件中。选项`-o`表示禁用文件名和扩展属性的混淆。
- `xfs_mdrestore meta-file restore-file`: 将 XFS 元数据转储映像恢复到文件系统映像中。
- `xfs_db -r image-file`: 调试xfs文件系统，`-r`表示只读。