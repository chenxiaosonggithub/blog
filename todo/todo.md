# qemu虚拟机启动时指定ip

```shell
[root@192 ~]# cat /lib/systemd/system/qemu-vm-setup.service
[Unit]
Description=QEMU VM Setup

[Service]
Type=oneshot
ExecStart=/root/qemu-vm-setup.sh

[Install]
WantedBy=default.target
```

```shell
[root@192 ~]# cat qemu-vm-setup.sh 
#!/bin/sh

dev=$(ip link show | awk '/^[0-9]+: en/ {sub(":", "", $2); print $2}')
ip=$(awk '/IP=/ { print gensub(".*IP=([0-9.]+).*", "\\1", 1) }' /proc/cmdline)

if test -n "$ip"
then
	gw=$(echo $ip | sed 's/[.][0-9]\+$/.1/g')
	ip addr add $ip/24 dev $dev
	ip link set dev $dev up
	ip route add default via $gw dev $dev
fi
```

# ftrace

https://cloud.tencent.com/developer/article/1429041

```shell
#!/bin/bash
func_name=do_dentry_open

echo nop > /sys/kernel/debug/tracing/current_tracer
echo 0 > /sys/kernel/debug/tracing/tracing_on
echo $$ > /sys/kernel/debug/tracing/set_ftrace_pid # 当前脚本程序的pid
echo function_graph > /sys/kernel/debug/tracing/current_tracer
echo $func_name > /sys/kernel/debug/tracing/set_graph_function
echo 1 > /sys/kernel/debug/tracing/tracing_on
exec "$@" # 用 $@ 进程替换当前shell进程，并且保持PID不变, 注意后面的命令不会执行

cat /sys/kernel/debug/tracing/trace > ftrace_output
```

# tracepoint & kprobe

```shell
find -name /sys/kernel/debug/tracing/events/ nfs_getattr_enter # 查找 nfs_getattr_enter 文件
echo 1 > /sys/kernel/debug/tracing/events/nfs/nfs_getattr_enter/enable # 使能函数的tracepoint

# 可以用 kprobe 跟踪的函数
cat /sys/kernel/debug/tracing/available_filter_functions

# wb_bytes 在 nfs_page 结构体中的偏移为 56， x32代表32位（4字节）
# 注意x86_64第四个参数的寄存器和系统调用不一样（普通函数为 cx，系统调用为 r10），使用 man syscall 查看系统调用参数寄存器, 注意 rdi 寄存器要写成 di
echo 'p:p_nfs_end_page_writeback nfs_end_page_writeback wb_bytes=+56(%di):x32' >> /sys/kernel/debug/tracing/kprobe_events
echo 1 > /sys/kernel/debug/tracing/events/kprobes/p_nfs_end_page_writeback/enable
echo stacktrace > /sys/kernel/debug/tracing/events/kprobes/p_nfs_end_page_writeback/trigger
echo '!stacktrace' > /sys/kernel/debug/tracing/events/kprobes/p_nfs_end_page_writeback/trigger
echo 0 > /sys/kernel/debug/tracing/events/kprobes/p_nfs_end_page_writeback/enable
echo '-:p_nfs_end_page_writeback' > /sys/kernel/debug/tracing/kprobe_events

# 注意要用单引号
echo 'r:r_nfs4_atomic_open nfs4_atomic_open ret=$retval' >> /sys/kernel/debug/tracing/kprobe_events
echo 1 > /sys/kernel/debug/tracing/events/kprobes/r_nfs4_atomic_open/enable
echo stacktrace > /sys/kernel/debug/tracing/events/kprobes/r_nfs4_atomic_open/trigger
echo '!stacktrace' > /sys/kernel/debug/tracing/events/kprobes/r_nfs4_atomic_open/trigger
echo 0 > /sys/kernel/debug/tracing/events/kprobes/r_nfs4_atomic_open/enable
echo '-:r_nfs4_atomic_open' > /sys/kernel/debug/tracing/kprobe_events

echo 0 > /sys/kernel/debug/tracing/trace # 清除trace信息
cat /sys/kernel/debug/tracing/trace_pipe

/sys/kernel/debug/tracing/trace_options # 这个文件是干嘛的？
```

# openharmony读云端文件

[foundation/filemanagement/dfs_service](https://gitee.com/openharmony/filemanagement_dfs_service)
```c
MountArgument::OptionsToString // 端云场景没执行到

struct fuse_lowlevel_ops fakeOps

MetaFile::DoLookup

DKAssetReadSession

MetaFile::MetaFile
  GetParentMetaFile
    MetaFileMgr::GetMetaFile
      mFile = std::make_shared<MetaFile>(userId, path)

DataSyncer::DataSyncer
  sdkHelper_(userId, bundleName)

// foundation/filemanagement/dfs_service/adapter/cloud_adapter_example/include/dk_error.h
class DKError
```

[third_party/libfuse](https://gitee.com/openharmony/third_party_libfuse)
```c
struct fuse_lowlevel_ops

// third_party/libfuse/example/passthrough_ll.c
lo_read
```

[foundation/filemanagement/storage_service](https://gitee.com/openharmony/filemanagement_storage_service)
```c
MountArgument::OptionsToString

MountArgument::GetFullCloud
```

[kernel/linux/linux-5.10](https://gitee.com/openharmony/kernel_linux_5.10)
```c
fuse_getattr
  fuse_is_bad
```

rk3568调试：
```shell
hilog -p off # -p <on/off>, --privacy <on/off>
hilog -Q pidoff
hilog -Q domainoff
hilog -r
hilog -G 20M
hilog -b D
hilog --baselevel=DEBUG
hilog | grep "CloudFileDaemon\|CLOUDSYNC_SA\|StorageDaemon"

# mount | grep hmdfs
/data/service/el2/100/hmdfs/account on /mnt/hmdfs/100/account type hmdfs (rw,nodev,relatime,insensitive,merge_enable,ra_pages=128,user_id=100,cache_dir=/data/service/el2/100/hmdfs/cache/account_cache/,real_dst=/mnt/hmdfs/100/account,cloud_dir=/mnt/hmdfs/100/cloud,offline_stash,dentry_cache)
/data/service/el2/100/hmdfs/account on /storage/media/100 type hmdfs (rw,nodev,relatime,insensitive,merge_enable,ra_pages=128,user_id=100,cache_dir=/data/service/el2/100/hmdfs/cache/account_cache/,real_dst=/mnt/hmdfs/100/account,cloud_dir=/mnt/hmdfs/100/cloud,offline_stash,dentry_cache)
/data/service/el2/100/hmdfs/non_account on /mnt/hmdfs/100/non_account type hmdfs (rw,nodev,relatime,insensitive,merge_enable,ra_pages=128,user_id=100,cache_dir=/data/service/el2/100/hmdfs/cache/non_account_cache/,real_dst=/mnt/hmdfs/100/non_account,cloud_dir=/mnt/hmdfs/100/cloud,offline_stash,dentry_cache)
/dev/fuse on /mnt/hmdfs/100/cloud type fuse (rw,nosuid,nodev,noexec,noatime,user_id=0,group_id=0,default_permissions,allow_other)

mkdir -p /data/service/el2/100/hmdfs/cache/account_cache/dentry_cache/cloud

# windows cmd
hdc file send D:\chenxiaosong\workspace\dentryfile\cloud_000000000000002f /data/service/el2/100/hmdfs/cache/account_cache/dentry_cache/cloud
hdc file send D:\chenxiaosong\workspace\dentryfile\cloud_0000000000000612 /data/service/el2/100/hmdfs/cache/account_cache/dentry_cache/cloud
hdc file send D:\chenxiaosong\workspace\dentryfile\cloud_000000000016cfa5 /data/service/el2/100/hmdfs/cache/account_cache/dentry_cache/cloud

setfattr -n user.hmdfs_cache -v "/" /data/service/el2/100/hmdfs/cache/account_cache/dentry_cache/cloud/cloud_000000000000002f
setfattr -n user.hmdfs_cache -v "/a" /data/service/el2/100/hmdfs/cache/account_cache/dentry_cache/cloud/cloud_0000000000000612
setfattr -n user.hmdfs_cache -v "/a/b" /data/service/el2/100/hmdfs/cache/account_cache/dentry_cache/cloud/cloud_000000000016cfa5
# chmod -R 777 /data/service/el2/100/
chown -R dfs:dfs /data/service/el2/100/hmdfs/cache/account_cache/dentry_cache
ls /mnt/hmdfs/100/account/device_view/cloud/
cat /mnt/hmdfs/100/account/device_view/cloud/a/b/file3

echo 3 > /proc/sys/vm/drop_caches
```

```shell
08-06 00:39:29.353   486  1360 I C01600/CloudFileDaemon: [fuse_manager.cpp:145->FakeLookup] lookup
08-06 00:39:29.361   486  1362 I C01600/CloudFileDaemon: [fuse_manager.cpp:201->FakeOpen] open /data/service/el2/100/hmdfs/non_account/fake_cloud/file4
08-06 00:39:29.364   486  1364 F C01600/CloudFileDaemon: [fuse_manager.cpp:247->FakeRead] read
```

# openharmony内核代码

```c
mount
  do_mount
    path_mount
      do_new_mount
        vfs_get_tree
          legacy_get_tree
            hmdfs_mount
              mount_nodev
                hmdfs_fill_super
                  hmdfs_cfn_load
                    hmdfs_do_load
                      store_one // 端云场景不走这里
                        load_cfn
                          cfn = create_cfn
                          cfn1 = __find_cfn
                            refcount_inc
                          list_add_tail(&cfn->list, head) // 找不到cfn1，将cfn加到链表中

openat(mode=0, flags=<optimized out>, filename=0x563e18a6a260 "/mnt/dst/device_view/cloud/", dfd=-100)
  do_sys_open
    do_sys_openat2
      do_filp_open
        path_openat
          do_open
            vfs_open
              do_dentry_open
                hmdfs_dir_open_cloud // error = open(inode, f);
                  get_cloud_cache_file
                    filp_open // 在 __alloc_file 中引用计数初始化为1
                    hmdfs_add_cache_list(CLOUD_DEVICE, dentry, filp) // dentry: /mnt/dst/device_view/cloud/, filp: cloud_000000000000002f
                      get_file // 引用计数为2
                  cache_item = hmdfs_find_cache_item
                    list_for_each_entry
                    if (dev_id == item->dev_id)
                  file->private_data = cache_item->filp
                  get_file // 引用计数为3

getdents64(3, [{d_ino=9223512774353131136, d_off=9223512774343131136, d_reclen=32, d_type=DT_REG, d_name="file1"}, {d_ino=9223512774353131137, d_off=18446744073709551615, d_reclen=32, d_type=DT_REG, d_name="file2"}], 32768) = 64
  iterate_dir
    hmdfs_iterate_cloud
      analysis_dentry_file_from_con(sbi=file->f_inode->i_sb->s_fs_info, handler=file->private_data)

statx(buffer=0x7ffe292ddaa0, mask=2, flags=0, filename=0x7ffe292dfe78 "/mnt/dst/device_view/cloud/", dfd=-100)
  do_statx
    user_path_at
      user_path_at_empty
        filename_lookup
          path_lookupat
            lookup_last
              walk_component
                lookup_fast
                  d_revalidate(flags=71, dentry=0xffff888007eb3800)
                    hmdfs_dev_d_revalidate
                  dput(dentry=dentry@entry=0xffff888007eb3800)
                    dentry_kill
                      __dentry_kill
                        hmdfs_dev_d_release
                          hmdfs_clear_cache_dents
                            kref_put
                              release_cache_item

read
  ksys_read
    vfs_read
      new_sync_read
        call_read_iter
          hmdfs_file_read_iter_cloud
```

# openharmony dentry_open和file_open_root

```c
hmdfs_file_open_merge
  lo_p.dentry = hmdfs_get_fst_lo_d
    hmdfs_dm
      return dentry->d_fsdata
  dentry_open

hmdfs_file_open_cloud
  file_open_root
```

# openharmony xts

https://gitee.com/openharmony/xts_acts

https://gitee.com/openharmony/testfwk_xdevice

# openharmony 编程规范

https://gitee.com/openharmony/docs/tree/master/zh-cn/contribute

# openharmony android参考代码

https://cs.android.com/android/platform/superproject/+/master:packages/providers/MediaProvider/jni/FuseDaemon.cpp

# openharmony 多用户

```c
MountManager::CloudMount // filemanagement_storage_service
  CloudDaemonManagerImpl::StartFuse
    CloudDaemonServiceProxy::StartFuse
      // remote->SendRequest // opToInterfaceMap_[CLOUD_DAEMON_CMD_START_FUSE]
      CloudDaemonStub::HandleStartFuseInner
        CloudDaemon::StartFuse
          FuseManager::GetInstance().StartFuse
```

# openharmony fuse可靠性

```c
StorageDaemon::SystemAbilityStatusChangeListener::OnRemoveSystemAbility
  MountManager::UMountCloudForUsers
    MountManager::HmdfsUMount
      UMount2
```

# openharmony clean

```cpp
CloudSyncService::Clean
  DataSyncManager::CleanCloudFile
    GalleryDataSyncer::Clean // DataSyncer::Clean
      DataSyncer::CleanInner
        FileDataHandler::Clean
```

# openharmony syzkaller crash

```shell
ls /mnt/dst/cloud_merge_view/
```

```c
newfstatat
  vfs_fstatat
    vfs_statx
      user_path_at_empty
        filename_lookup
          path_lookupat
            lookup_last
              link_path_walk
                walk_component
                  lookup_slow
                    __lookup_slow
                      dentry = d_alloc_parallel
                      hmdfs_lookup_cloud_merge
                        init_hmdfs_dentry_info_merge
                          mdi = kmem_cache_zalloc(hmdfs_dentry_merge_cachep
                          dentry->d_fsdata = mdi
                        hmdfs_trace_merge
                          mutex_lock(&dm->comrade_list_lock

newfstatat
  vfs_fstatat
    vfs_statx
      user_path_at_empty
        filename_lookup
          path_lookupat
            link_path_walk
              walk_component
                lookup_slow
                  __lookup_slow
                    hmdfs_lookup_cloud_merge
                    dentry = d_alloc_parallel
                    dput
                      dentry_kill
                        __dentry_kill
                          d_release_merge
                            kmem_cache_free(hmdfs_dentry_merge_cachep, dentry->d_fsdata);

__lookup_slow
  d_revalidate
    d_revalidate_merge
      // 永远都返回0，需要重新lookup
```

`47adcf18cec2 hmdfs: fix cloud_merge_view revalidate`合入后：
```c
walk_component
  dentry = lookup_fast() = NULL
  __lookup_slow
    d_revalidate
      d_revalidate_merge
        // 永远都返回1，只lookup一次

walk_component
  dentry = lookup_fast // 第二次不为NULL
```

# openharmony merge view mkdir 属性不对

```c
hmdfs_lookup_cloud_merge
  lookup_merge_normal
    merge_lookup_async
      merge_lookup_work_func // INIT_WORK(&ml_work->work
        link_comrade
    wait_event(mdi->wait_queue, is_merge_lookup_end
  fill_inode_merge
    update_inode_attr

hmdfs_mkdir_cloud_merge
  hmdfs_create_lower_cloud_dentry
    hmdfs_do_ops_cloud_merge
      do_mkdir_cloud_merge
        fill_inode_merge
```

# openharmony cloud merge view dentry 缓存失效问题

```shell
--- a/services/cloudfiledaemon/src/fuse_manager/fuse_manager.cpp
+++ b/services/cloudfiledaemon/src/fuse_manager/fuse_manager.cpp
@@ -374,6 +374,9 @@ static void CloudRelease(fuse_req_t req, fuse_ino_t ino, struct fuse_file_info *
         if (needRemain && res) {
             GetCloudInode(data, cInode->parent)->mFile->DoRemove(*(cInode->mBase));
             LOGD("remove from dentryfile");
+            res = fuse_lowlevel_notify_inval_entry(data->se, cInode->parent, cInode->mBase->name.c_str(),
+                                             strlen(cInode->mBase->name.c_str()));
+            LOGE("fuse_lowlevel_notify_inval_entry res: %d", res);
         }
         cInode->readSession = nullptr;
         LOGD("readSession released");
```

以上补丁打上后，inode释放了，但dentry并未失效:
```shell
[fuse_manager.cpp:363->CloudRelease] /dir1/dir2/file4, sessionRefCount: 1
[fuse_manager.cpp:376->CloudRelease] remove from dentryfile
[fuse_manager.cpp:379->CloudRelease] fuse_lowlevel_notify_inval_entry res: 0
[fuse_manager.cpp:382->CloudRelease] readSession released
[fuse_manager.cpp:256->CloudForget] forget /dir1/dir2/file4, nlookup: 1
[fuse_manager.cpp:242->PutNode] /dir1/dir2/file4, put num: 1,  current refCount: 0
[fuse_manager.cpp:244->PutNode] node released: /dir1/dir2/file4
```

# openharmony 取消下载

```c
DownloadInner
  CloudDownloadCallbackManager::StartDonwload
    downloads_[path].path = path
  DataSyncer::DownloadAssets
    SdkHelper::DownloadAssets
      DKAssetsDownloader::DownLoadAssets

DataSyncer::StopDownloadFile
  CloudDownloadCallbackManager::StopDonwload
```

# openharmony medialibrary沙箱里fuse Socket not connected

```shell
ps -ef | grep media
cd /proc/1059/root/mnt/hmdfs/100/ # 1059 是 com.ohos.medialibrary.medialibrarydata 的进程号
```


# 参考网址

[在Ubuntu下使用QEMU連網](https://www.twblogs.net/a/5e5f6067bd9eee211685777c)

[QEMU中的网络](https://blog.csdn.net/chengbeng1745/article/details/81271024)