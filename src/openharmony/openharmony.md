[toc]

# 环境

[大禹系列｜HH-SCDAYU200开发套件（Quad-core Cortex-A55 up to 2.0GHz）](http://www.hihope.org/pro/pro1.aspx?mtt=54)。

## 获取代码

以ubuntu22.04为例，说明编译环境的搭建。

[HiHope_DAYU200 搭建开发环境](https://gitee.com/hihope_iot/docs/blob/master/HiHope_DAYU200/%E5%BC%80%E5%8F%91%E7%8E%AF%E5%A2%83%E6%90%AD%E5%BB%BA%E7%BC%96%E8%AF%91%E6%8C%87%E5%8D%97.md)。

还可以参考openharmony[获取源码](https://gitee.com/openharmony/docs/blob/master/zh-cn/device-dev/quick-start/quickstart-pkg-sourcecode.md)

```shell
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

repo init -u https://gitee.com/openharmony/manifest.git -b master --no-repo-verify
repo sync -c
repo forall -c 'git lfs pull'

bash build/prebuilts_download.sh
```

## docker编译

在宿主机环境上可能会遇到各种各样的问题，可以使用 docker 编译

[`hb`工具安装](https://gitee.com/openharmony/docs/blob/master/zh-cn/device-dev/quick-start/quickstart-pkg-install-tool.md)

```shell
docker pull ubuntu:22.04
docker run -it -v "$PWD":/usr/src/myapp -w /usr/src/myapp ubuntu:22.04 bash
apt-get update && apt-get install binutils git git-lfs gnupg flex bison gperf build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z1-dev ccache libgl1-mesa-dev libxml2-utils xsltproc unzip m4 bc gnutls-bin python3 python3-pip ruby libtinfo-dev libtinfo5 -y
apt install file -y
apt-get install default-jdk -y # 如果报错: javac: command not found
apt install libelf-dev -y # error: Cannot resolve BTF IDs for CONFIG_DEBUG_INFO_BTF
apt-get install libssl-dev -y # scripts/extract-cert.c:21:10: fatal error: 'openssl/bio.h' file not found
apt install liblz4-tool -y # /bin/sh: 1: lz4c: not found
apt-get install genext2fs -y # make-boot.sh: line 22: genext2fs: command not found
apt-get install cpio -y
exit

rm ubuntu-openharmony:22.04.tar
docker ps -a # 查看容器
docker export xxxxxxxxx > ubuntu-openharmony:22.04.tar # 导出
docker container prune # 删除容器
docker image rm ubuntu-openharmony:22.04 # 先删除镜像
ubuntu-openharmony:22.04.tar | docker import - ubuntu-openharmony:22.04 # 导入到镜像
docker image ls # 查看镜像

# 镜像输出在 out/rk3568/packages/phone/images 目录下
docker run --rm -v "$PWD":/usr/src/myapp -w /usr/src/myapp ubuntu-openharmony:22.04 ./build.sh --product-name rk3568 --ccache
docker run --rm -v "$PWD":/usr/src/myapp -w /usr/src/myapp ubuntu-openharmony:22.04 ./build.sh --product-name rk3568 --ccache --fast-rebuild # 增量编译时跳过一些已经完成的步骤
docker run --rm -v "$PWD":/usr/src/myapp -w /usr/src/myapp ubuntu-openharmony:22.04 ./build.sh --product-name rk3568 --ccache --build-target dfs_service --fast-rebuild
```

## qemu 环境

[device_qemu](https://gitee.com/openharmony/device_qemu#https://gitee.com/openharmony/device_qemu/blob/HEAD/arm_mps3_an547/README_zh.md)

[QEMU教程 for arm - linux](https://gitee.com/openharmony/device_qemu/blob/HEAD/arm_virt/linux/README_zh.md)

```shell
# 编译qemu-arm-linux-headless失败: https://gitee.com/openharmony/device_qemu/issues/I6AH7L?from=project-issue
docker run --rm -v "$PWD":/usr/src/myapp -w /usr/src/myapp ubuntu-openharmony:22.04 ./build.sh --product-name qemu-arm-linux-headless --ccache --jobs 64

docker run --rm -v "$PWD":/usr/src/myapp -w /usr/src/myapp ubuntu-openharmony:22.04 ./build.sh --product-name qemu-arm-linux-min --ccache --jobs 64
```

## 烧写

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
# 向开发板发送数据库文件
hdc file send .\media_library.db /data/app/el2/100/database/com.ohos.medialibrary.medialibrarydata/rdb
hdc file send .\media_library.db-wal /data/app/el2/100/database/com.ohos.medialibrary.medialibrarydata/rdb
hdc file send .\media_library.db-shm /data/app/el2/100/database/com.ohos.medialibrary.medialibrarydata/rdb
```

# dentryfiletool

https://gitee.com/chenxiaosonggitee/dentryfiletool

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
mkdir -p /data/service/el2/100/hmdfs/cache/cloud_cache/dentry_cache/cloud/

# windows cmd
hdc file send D:\chenxiaosong\workspace\dentryfile\cloud_000000000000002f /data/service/el2/100/hmdfs/cache/account_cache/dentry_cache/cloud
hdc file send D:\chenxiaosong\workspace\dentryfile\cloud_000000000000002f /data/service/el2/100/hmdfs/cache/cloud_cache/dentry_cache/cloud/
hdc file send D:\chenxiaosong\workspace\dentryfile\cloud_0000000000000612 /data/service/el2/100/hmdfs/cache/account_cache/dentry_cache/cloud
hdc file send D:\chenxiaosong\workspace\dentryfile\cloud_0000000000000612 /data/service/el2/100/hmdfs/cache/cloud_cache/dentry_cache/cloud/
hdc file send D:\chenxiaosong\workspace\dentryfile\cloud_000000000016cfa5 /data/service/el2/100/hmdfs/cache/account_cache/dentry_cache/cloud
hdc file send D:\chenxiaosong\workspace\dentryfile\cloud_000000000016cfa5 /data/service/el2/100/hmdfs/cache/cloud_cache/dentry_cache/cloud/

setfattr -n user.hmdfs_cache -v "/" /data/service/el2/100/hmdfs/cache/account_cache/dentry_cache/cloud/cloud_000000000000002f
setfattr -n user.hmdfs_cache -v "/" /data/service/el2/100/hmdfs/cache/cloud_cache/dentry_cache/cloud/cloud_000000000000002f
setfattr -n user.hmdfs_cache -v "/a" /data/service/el2/100/hmdfs/cache/account_cache/dentry_cache/cloud/cloud_0000000000000612
setfattr -n user.hmdfs_cache -v "/a" /data/service/el2/100/hmdfs/cache/cloud_cache/dentry_cache/cloud/cloud_0000000000000612
setfattr -n user.hmdfs_cache -v "/a/b" /data/service/el2/100/hmdfs/cache/account_cache/dentry_cache/cloud/cloud_000000000016cfa5
setfattr -n user.hmdfs_cache -v "/a/b" /data/service/el2/100/hmdfs/cache/cloud_cache/dentry_cache/cloud/cloud_000000000016cfa5
chmod -R 777 /data/service/el2/100/
ls /mnt/hmdfs/100/account/device_view/cloud/
cat /mnt/hmdfs/100/account/device_view/cloud/file4
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

# qemu调试

```shell
mkdir -p /mnt/dst
mkdir -p /mnt/cache_dir/dentry_cache/cloud
mkdir -p /mnt/cloud_dir
mkdir -p /mnt/src
echo 123456789 > /mnt/cloud_dir/file1

# 注意复制到其他系统，xattr要重新设置
setfattr -n user.hmdfs_cache -v "/" /mnt/cache_dir/dentry_cache/cloud/cloud_000000000000002f
setfattr -n user.hmdfs_cache -v "/o" /mnt/cache_dir/dentry_cache/cloud/cloud_0000000000000620
setfattr -n user.hmdfs_cache -v "/o/p" /mnt/cache_dir/dentry_cache/cloud/cloud_0000000000170441
setfattr -n user.hmdfs_cache -v "/o/p/q" /mnt/cache_dir/dentry_cache/cloud/cloud_000000005666fe23
setfattr -n user.hmdfs_cache -v "/o/p/q/r" /mnt/cache_dir/dentry_cache/cloud/cloud_0000014458a00786
setfattr -n user.hmdfs_cache -v "/o/p/q/r/s" /mnt/cache_dir/dentry_cache/cloud/cloud_0004c190b0bc442a
setfattr -n user.hmdfs_cache -v "/o/p/q/r/s/t" /mnt/cache_dir/dentry_cache/cloud/cloud_11daa02772bbe7cf
setfattr -n user.hmdfs_cache -v "/a" /mnt/cache_dir/dentry_cache/cloud/cloud_0000000000000612
setfattr -n user.hmdfs_cache -v "/a/b" /mnt/cache_dir/dentry_cache/cloud/cloud_000000000016cfa5

mount -t hmdfs -o merge,local_dst=/mnt/dst,cache_dir=/mnt/cache_dir,cloud_dir=/mnt/cloud_dir /mnt/src /mnt/dst

ls /mnt/dst/device_view/cloud/
cat /mnt/dst/device_view/cloud/file1

# libfuse
./example/hello_ll /mnt/cloud_dir -d
```
