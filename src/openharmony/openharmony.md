[toc]

# 环境

[大禹系列｜HH-SCDAYU200开发套件（Quad-core Cortex-A55 up to 2.0GHz）](http://www.hihope.org/pro/pro1.aspx?mtt=54)。

## docker环境

在宿主机环境上可能会遇到各种各样的问题，可以使用 docker 编译, 以ubuntu22.04为例，说明环境的搭建。

```shell
# 获取代码环境
sudo apt-get update && sudo apt-get install python3 python3-pip -y
sudo apt-get install git git-lfs -y
mkdir -p ~/.local/bin/
curl -s https://gitee.com/oschina/repo/raw/fork_flow/repo-py3 > ~/.local/bin/repo
chmod a+x ~/.local/bin/repo
vim ~/.bashrc               # 编辑环境变量
export PATH=~/.local/bin:$PATH     # 在环境变量的最后添加一行repo路径信息
source ~/.bashrc            # 应用环境变量
pip3 install -i https://repo.huaweicloud.com/repository/pypi/simple requests
sudo ln -s /usr/bin/python3 /usr/bin/python

# 编译环境
docker pull ubuntu:22.04
docker run --name openharmony --hostname openharmony -it -v "$PWD":/usr/src/myapp -w /usr/src/myapp ubuntu:22.04 bash
apt-get update && apt-get install binutils git git-lfs gnupg flex bison gperf build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z1-dev ccache libgl1-mesa-dev libxml2-utils xsltproc unzip m4 bc gnutls-bin python3 python3-pip ruby libtinfo-dev libtinfo5 -y
apt install file -y
apt-get install default-jdk -y # 如果报错: javac: command not found
apt install libelf-dev -y # error: Cannot resolve BTF IDs for CONFIG_DEBUG_INFO_BTF
apt-get install libssl-dev -y # scripts/extract-cert.c:21:10: fatal error: 'openssl/bio.h' file not found
apt install liblz4-tool -y # /bin/sh: 1: lz4c: not found
apt-get install genext2fs -y # make-boot.sh: line 22: genext2fs: command not found
apt-get install cpio -y
exit

# 镜像和容器处理
rm ubuntu-openharmony:22.04.tar
docker ps -a # 查看容器
docker export openharmony > ubuntu-openharmony:22.04.tar # 导出
docker rm openharmony # 删除容器
docker image rm ubuntu-openharmony:22.04 # 先删除镜像
cat ubuntu-openharmony:22.04.tar | docker import - ubuntu-openharmony:22.04 # 导入到镜像
docker image ls # 查看镜像

# 进入docker
docker run --name rm-openharmony --hostname rm-workspace --rm -it -v "$PWD":/usr/src/myapp -w /usr/src/myapp ubuntu-openharmony:22.04 bash # --rm: 退出后删除容器
docker run --name rm-openharmony --hostname rm-workspace -it -v "$PWD":/usr/src/myapp -w /usr/src/myapp ubuntu-openharmony:22.04 bash # 退出后不删除容器
```

[`hb`工具安装](https://gitee.com/openharmony/docs/blob/master/zh-cn/device-dev/quick-start/quickstart-pkg-install-tool.md)

## 获取代码

[HiHope_DAYU200 搭建开发环境](https://gitee.com/hihope_iot/docs/blob/master/HiHope_DAYU200/%E5%BC%80%E5%8F%91%E7%8E%AF%E5%A2%83%E6%90%AD%E5%BB%BA%E7%BC%96%E8%AF%91%E6%8C%87%E5%8D%97.md)。

还可以参考openharmony[获取源码](https://gitee.com/openharmony/docs/blob/master/zh-cn/device-dev/quick-start/quickstart-pkg-sourcecode.md)

```shell
repo init -u https://gitee.com/openharmony/manifest.git -b master --no-repo-verify
repo sync -c
repo forall -c 'git lfs pull'

bash build/prebuilts_download.sh
```

# 编译

```shell
# 镜像输出在 out/rk3568/packages/phone/images 目录下
./build.sh --product-name rk3568 --ccache --target-cpu arm64
./build.sh --product-name rk3568 --ccache --target-cpu arm64 --fast-rebuild # 增量编译时跳过一些已经完成的步骤
./build.sh --product-name rk3568 --ccache --target-cpu arm64 --build-target dfs_service --fast-rebuild
```

## qemu 运行调试环境

[device_qemu](https://gitee.com/openharmony/device_qemu#https://gitee.com/openharmony/device_qemu/blob/HEAD/arm_mps3_an547/README_zh.md)

[QEMU教程 for arm - linux](https://gitee.com/openharmony/device_qemu/blob/HEAD/arm_virt/linux/README_zh.md)

```shell
# 编译qemu-arm-linux-headless失败: https://gitee.com/openharmony/device_qemu/issues/I6AH7L?from=project-issue
docker run --rm -v "$PWD":/usr/src/myapp -w /usr/src/myapp ubuntu-openharmony:22.04 ./build.sh --product-name qemu-arm-linux-headless --ccache --jobs 64

docker run --rm -v "$PWD":/usr/src/myapp -w /usr/src/myapp ubuntu-openharmony:22.04 ./build.sh --product-name qemu-arm-linux-min --ccache --jobs 64
```

## 烧写

linux上压缩：
```shell
zip -jr images.zip out/rk3568/packages/phone/images/
```

[烧写工具及指南](https://gitee.com/hihope_iot/docs/tree/master/HiHope_DAYU200/%E7%83%A7%E5%86%99%E5%B7%A5%E5%85%B7%E5%8F%8A%E6%8C%87%E5%8D%97)。

特别需要注意的是：软件路径中不要含有中文，尤其是对英文版的windows系统。

windows安装`DriverAssitant_v5.1.1\DriverInstall.exe`后，打开`RKDevTool.exe`， 配置以下路径：
```
0x00000000 Loader MiniLoaderAll.bin
0x00000000 Parameter parameter.txt
0x00002000 Uboot uboot.img
0x00006000 resource resource.img
0x00004000 misc 可不选
0x00009000 Boot_linux boot_linux.img
0x00039000 ramdisk ramdisk.img
0x0003B000 System system.img
0x0043B000 Vendor vendor.img
0x0063B000 sys-prod 可不选
0x00654000 chip-prod 可不选
0x0066D000 updater updater.img
0x00677000 Userdata userdata.img
```

配置重新导出为文件`config.cfg`。

winodws usb线连接rk3568板子上的`usb3.0 OTG`，在rk3568板子上按`reset`键，再长按`vol+/recovery`键，进入loader模式，点击`RKDevTool`工具上的`执行`按钮。可以只烧录`System`和`Userdata`（包含数据库）。

`scp_dfs_service_so.bat`:
```shell
scp -r -P 55555 sonvhi@chenxiaosong.com:/home/sonvhi/chenxiaosong/code/openharmony/openharmony/out/rk3568/filemanagement/dfs_service/ .
@pause
```

`push_dfs_service_so.bat`:
```shell
hdc shell mount -o rw,remount /

hdc file send .\dfs_service\libcloud_adapter.z.so               /system/lib64/
hdc file send .\dfs_service\libcloud_daemon_kit_inner.z.so      /system/lib64/
hdc file send .\dfs_service\libcloudfiledaemon.z.so             /system/lib64/
hdc file send .\dfs_service\libcloudsync.z.so                   /system/lib64/module/file/
hdc file send .\dfs_service\libcloudsync_kit_inner.z.so         /system/lib64/
hdc file send .\dfs_service\libcloudsync_sa.z.so                /system/lib64/
hdc file send .\dfs_service\libcloudsyncmanager.z.so            /system/lib64/module/file/
hdc file send .\dfs_service\libdistributedfiledaemon.z.so       /system/lib64/
hdc file send .\dfs_service\libdistributedfileutils.z.so        /system/lib64/
hdc file send .\dfs_service\libdistributedfiledentry.z.so        /system/lib64/

hdc shell sync
hdc shell reboot
@pause
```

## 调试

[hdc使用指导](https://docs.openharmony.cn/pages/v3.2/zh-cn/device-dev/subsystems/subsys-toolchain-hdc-guide.md/), [hdc_std使用指导](https://docs.openharmony.cn/pages/v3.1/zh-cn/device-dev/subsystems/subsys-toolchain-hdc-guide.md/)。

`hdc`工具从[每日构建](http://ci.openharmony.cn/workbench/cicd/dailybuild/dailylist)中搜索`ohos-sdk`。

`hdc shell` usb线连接rk3568板子上的`usb3.0 OTG`，**注意不是`DEBUG`串口**。

如果始终无法连接，`win+r`，输入`regedit`回车，找到注册表 `计算机\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{88bae032-5a81-49f0-bc3d-a4ff138216d6}`，确认是否有`Upperfilters`和`Lowerfilters`，删除后重新插拔。

```shell
# 从开发板上获取数据库文件
hdc file recv /data/app/el2/100/database/com.ohos.medialibrary.medialibrarydata/rdb/media_library.db .
hdc file recv /data/app/el2/100/database/com.ohos.medialibrary.medialibrarydata/rdb/media_library.db-wal .
hdc file recv /data/app/el2/100/database/com.ohos.medialibrary.medialibrarydata/rdb/media_library.db-shm .
# 整个文件夹
hdc file recv /data/app/el2/100/database/com.ohos.medialibrary.medialibrarydata/rdb/. .
# 向开发板发送数据库文件
hdc file send .\media_library.db /data/app/el2/100/database/com.ohos.medialibrary.medialibrarydata/rdb
hdc file send .\media_library.db-wal /data/app/el2/100/database/com.ohos.medialibrary.medialibrarydata/rdb
hdc file send .\media_library.db-shm /data/app/el2/100/database/com.ohos.medialibrary.medialibrarydata/rdb
```

## 日志

```shell
# -w 开启日志落盘任务，start表示开始，stop表示停止
# -f 设置日志文件名
# -l 单个日志文件大小
hilog -w start -f cxsTest -l 1M -n 5 -m zlib -j 11
```

## crash调试

当程序crash时，可以把相关日志文件导出来分析：
```shell
hdc file recv /data/log/faultlog/faultlogger/.
```

日志文件如下：
```
Generated by HiviewDFX@OpenHarmony
================================================================
Device info:OpenHarmony 3.2
Build info:OpenHarmony 4.0.7.1
Module name:cloudfiledaemon
Pid:516
Uid:1009
Reason:Signal:SIGSEGV(SEGV_MAPERR)@     (nil) 
Thread name:cloudfiledaemon
#00 pc 0000d2b8 /system/lib/libcloudfiledaemon.z.so(3d07c6d63b58da9d13918497b907cd8a)
#01 pc 000c7718 /system/lib/ld-musl-arm.so.1
#02 pc 00066078 /system/lib/ld-musl-arm.so.1
```

找到 `libcloudfiledaemon` 相关的库文件：
```shell
find out -name "libcloudfiledaemon*"
# 注意要选unstripped: out/rk3568/lib.unstripped/filemanagement/dfs_service/libcloudfiledaemon.z.so
```

找出 `0000d2b8` 对应的代码行:
```shell
prebuilts/gcc/linux-x86/aarch64/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-addr2line -e out/rk3568/lib.unstripped/filemanagement/dfs_service/libcloudfiledaemon.z.so -a 0000d2b8 # 32位
prebuilts/clang/ohos/linux-x86_64/15.0.4/llvm/bin/llvm-addr2line -e out/rk3568/lib.unstripped/filemanagement/dfs_service/libcloudfiledaemon.z.so -a xxxxxxxx # 64位
# foundation/filemanagement/dfs_service/services/cloudfiledaemon/src/fuse_manager/fuse_manager.cpp:353
```

## selinux

有些功能可能会被selinux阻止，可以关闭selinux测试:
```shell
mount -o rw,remount /
echo "SELINUX=permissive" > /etc/selinux/config # 默认是 SELINUX=enforcing
sync
reboot
```

# 读云端文件

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
hilog --baselevel=DEBUG
hilog | grep "CloudFileDaemon\|CLOUDSYNC_SA"

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

# 内核代码

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

# libfuse

[third_party/libfuse](https://gitee.com/chenxiaosonggitee/third_party_libfuse)
```shell
apt install meson -y
apt install cmake -y
apt-get install pkg-config -y
apt install udev -y

git clone https://github.com/libfuse/libfuse.git
cd libfuse
mkdir build; cd build
meson setup ..
meson configure -D buildtype=debug
ninja
ninja install # 运行 example 可以不安装

mkdir mnt
gdb ./example/passthrough_ll
(gdb) set args -o source=/tmp /mnt/cloud_dir -d
(gdb) b lo_lookup
(gdb) r

./example/passthrough_ll -o source=/tmp /mnt/cloud_dir -d
```

# hmdfs和libfuse qemu虚拟机调试

```shell
mkdir -p /mnt/dst
mkdir -p /mnt/cache_dir/dentry_cache/cloud
mkdir -p /mnt/cloud_dir
mkdir -p /mnt/src
echo 123456789 > /mnt/cloud_dir/file1

# 注意复制到其他系统，xattr要重新设置
setfattr -n user.hmdfs_cache -v "/" /mnt/cache_dir/dentry_cache/cloud/cloud_000000000000002f
setfattr -n user.hmdfs_cache -v "/dir1" /mnt/cache_dir/dentry_cache/cloud/cloud_0000000002c55df3
setfattr -n user.hmdfs_cache -v "/dir1/dir2" /mnt/cache_dir/dentry_cache/cloud/cloud_0004ba7c447bbfe1

mount -t hmdfs -o merge,local_dst=/mnt/dst,cache_dir=/mnt/cache_dir,cloud_dir=/mnt/cloud_dir /mnt/src /mnt/dst

ls /mnt/dst/device_view/cloud/
cat /mnt/dst/device_view/cloud/file1

# libfuse
./example/hello_ll /mnt/cloud_dir -d
```

# tdd

生成 dentryfile 代码：
```c
// foundation/filemanagement/dfs_service/test/unittests/cloudsync_sa/dentry/dentry_meta_file_test.cpp
HWTEST_F(DentryMetaFileTest, MetaFileCreate, TestSize.Level1)
{
    std::string cacheDir =
        "/data/service/el2/100/hmdfs/cache/account_cache/dentry_cache/cloud/";
    ForceRemoveDirectory(cacheDir);

    auto mFileRoot = MetaFileMgr::GetInstance().GetMetaFile(100, "/");
    MetaBase mBaseReg1("file1", "fileid1");
    mBaseReg1.size = 10;
    mBaseReg1.mode = S_IFREG;
    EXPECT_EQ(mFileRoot->DoCreate(mBaseReg1), 0);
    MetaBase mBaseReg2("file2", "fileid2");
    mBaseReg2.size = 20;
    mBaseReg2.mode = S_IFREG;
    EXPECT_EQ(mFileRoot->DoCreate(mBaseReg2), 0);
    mFileRoot = nullptr;

    auto mFileDir1 = MetaFileMgr::GetInstance().GetMetaFile(100, "/dir1");
    MetaBase mBaseReg3("file3", "fileid3");
    mBaseReg3.size = 30;
    mBaseReg3.mode = S_IFREG;
    EXPECT_EQ(mFileDir1->DoCreate(mBaseReg3), 0);
    mFileDir1 = nullptr;

    auto mFileDir2 = MetaFileMgr::GetInstance().GetMetaFile(100, "/dir1/dir2");
    MetaBase mBaseReg4("file4", "fileid4");
    mBaseReg4.size = 100*1024;
    mBaseReg4.mode = S_IFREG;
    EXPECT_EQ(mFileDir2->DoCreate(mBaseReg4), 0);
    mFileDir2 = nullptr;

    MetaFileMgr::GetInstance().ClearAll();
}
```

```shell
# 编译结果：
# out/rk3568/exe.unstripped/tests/unittest/filemanagement/dfs_service/dentry_meta_file_test
# out/rk3568/tests/unittest/filemanagement/dfs_service/dentry_meta_file_test
./build.sh --product-name rk3568 --ccache --target-cpu arm64 --build-target dentry_meta_file_test --fast-rebuild
# 从windows复制到 rk3568 板子上
hdc shell rm /data/dentry_meta_file_test -rf
hdc file send .\dentry_meta_file_test /data
hdc shell
chmod a+x /data/dentry_meta_file_test
cd /data/
/data/dentry_meta_file_test --gtest_list_tests
/data/dentry_meta_file_test --gtest_filter=DentryMetaFileTest.MetaFileCreate

chmod -R 777 /data/service/el2/100/hmdfs/cache/account_cache/dentry_cache/
ls -lh /data/service/el2/100/hmdfs/cache/account_cache/dentry_cache/cloud/
ls -lh /mnt/hmdfs/100/account/device_view/cloud/
cat /mnt/hmdfs/100/account/device_view/cloud/dir1/dir2/file4
```

```shell
./build.sh --product-name rk3568 --cacch --target-cpu arm64 --build-target storage_daemon_unit_test --build-target storage_manager_unit_test
```

# xts

https://gitee.com/openharmony/xts_acts

https://gitee.com/openharmony/testfwk_xdevice

# 编程规范

https://gitee.com/openharmony/docs/tree/master/zh-cn/contribute

# android

https://cs.android.com/android/platform/superproject/+/master:packages/providers/MediaProvider/jni/FuseDaemon.cpp

# 多用户

```c
MountManager::CloudMount
  CloudDaemonManagerImpl::StartFuse
    CloudDaemonServiceProxy::StartFuse
      // remote->SendRequest // opToInterfaceMap_[CLOUD_DAEMON_CMD_START_FUSE]
      CloudDaemonStub::HandleStartFuseInner
        CloudDaemon::StartFuse
          FuseManager::GetInstance().StartFuse
```

# clean

```cpp
CloudSyncService::Clean
  DataSyncManager::CleanCloudFile
    GalleryDataSyncer::Clean // DataSyncer::Clean
      DataSyncer::CleanInner
        FileDataHandler::Clean
```
