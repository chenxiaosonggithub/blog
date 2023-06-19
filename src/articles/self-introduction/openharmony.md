
OpenHarmony是华为“鸿蒙操作系统”的底座，包含：华为捐献的“鸿蒙操作系统”的基础能力 和 其他参与者的贡献。

注意Gitee网站查看具体代码要先注册登录（这点我也吐槽Gitee）。

# 1. 内核仓库

[动态加载端云场景的dentryfile，读云端文件](https://gitee.com/openharmony/kernel_linux_5.10/pulls/791/commits)

[hmdfs: use 'vfs_iter_read' instead of 'vfs_read' in 'hmdfs_file_read_iter_cloud()](https://gitee.com/openharmony/kernel_linux_5.10/commit/75a864d47e45457de395456c593964b0129f0c5e)

[hmdfs: fix compile warning in hmdfs_file_open_cloud()](https://gitee.com/openharmony/kernel_linux_5.10/pulls/775/commits)

# 2. 分布式文件系统仓库

[dfs: fuse read cloud file](https://gitee.com/openharmony/filemanagement_dfs_service/pulls/258/commits)

[dfs: always read from dentryfile instead from cache when lookup](https://gitee.com/openharmony/filemanagement_dfs_service/pulls/362/commits)

[dfs: fix 'user_data_rw' user open fuse mountpoint fail](https://gitee.com/openharmony/filemanagement_dfs_service/pulls/407/commits)

[dfs: clean up build warnings](https://gitee.com/openharmony/filemanagement_dfs_service/pulls/220/commits)

# 3. 存储管理部件仓库

[add hmdfs mount option 'cloud_dir'](https://gitee.com/openharmony/filemanagement_storage_service/pulls/526/commits)

[storagedaemon: create directory '/data/service/el2/{userid}/hmdfs/fuse'](https://gitee.com/openharmony/filemanagement_storage_service/pulls/530/commits)

[storagedaemon: add fuse umount](https://gitee.com/openharmony/filemanagement_storage_service/pulls/534/commits)

[storagedaemon: mount fuse when cloudfiledaemon is ready](https://gitee.com/openharmony/filemanagement_storage_service/pulls/558/commits)

# 4. 媒体库仓库

[Add 'position' column to medialibrary database](https://gitee.com/openharmony/multimedia_medialibrary_standard/pulls/1551/commits)

[declare napi property 'enum PositionType'](https://gitee.com/openharmony/multimedia_medialibrary_standard/pulls/1623/commits)