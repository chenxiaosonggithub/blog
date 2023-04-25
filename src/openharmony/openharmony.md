[toc]

# 环境

[大禹系列｜HH-SCDAYU200开发套件](http://www.hihope.org/pro/pro1.aspx?mtt=54)。

## 编译

以ubuntu22.04为例，说明编译环境的搭建。

[HiHope_DAYU200 搭建开发环境](https://gitee.com/hihope_iot/docs/blob/master/HiHope_DAYU200/%E5%BC%80%E5%8F%91%E7%8E%AF%E5%A2%83%E6%90%AD%E5%BB%BA%E7%BC%96%E8%AF%91%E6%8C%87%E5%8D%97.md)。

还可以参考openharmony[获取源码](https://gitee.com/openharmony/docs/blob/master/zh-cn/device-dev/quick-start/quickstart-pkg-sourcecode.md)

```shell
sudo apt-get update && sudo apt-get install binutils git git-lfs gnupg flex bison gperf build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z1-dev ccache libgl1-mesa-dev libxml2-utils xsltproc unzip m4 bc gnutls-bin python3 python3-pip ruby libtinfo-dev libtinfo5 -y
sudo apt-get install default-jdk -y # 如果报错: javac: command not found
sudo apt install libelf-dev -y # error: Cannot resolve BTF IDs for CONFIG_DEBUG_INFO_BTF
sudo apt-get install libssl-dev -y # scripts/extract-cert.c:21:10: fatal error: 'openssl/bio.h' file not found
sudo apt install liblz4-tool -y # /bin/sh: 1: lz4c: not found
sudo apt-get install genext2fs -y # make-boot.sh: line 22: genext2fs: command not found

git config --global credential.helper store

curl -s https://gitee.com/oschina/repo/raw/fork_flow/repo-py3 > ~/.local/bin/repo
chmod a+x ~/.local/bin/repo
vim ~/.bashrc               # 编辑环境变量
export PATH=~/.local/bin:$PATH     # 在环境变量的最后添加一行repo路径信息
source ~/.bashrc            # 应用环境变量
pip3 install -i https://repo.huaweicloud.com/repository/pypi/simple requests

ulimit -n 10240 # 不确定是否必需

sudo ln -s /usr/bin/python3 /usr/bin/python
repo init -u https://gitee.com/openharmony/manifest.git -b master --no-repo-verify
repo sync -c
repo forall -c 'git lfs pull'

bash build/prebuilts_download.sh
# 镜像输出在out/rk3568/packages/phone/images 目录下
./build.sh --product-name rk3568 --ccache
./build.sh --product-name rk3568 --ccache --fast-rebuild # 增量编译时跳过一些已经完成的步骤
```

## 烧写

[烧写工具及指南](https://gitee.com/hihope_iot/docs/tree/master/HiHope_DAYU200/%E7%83%A7%E5%86%99%E5%B7%A5%E5%85%B7%E5%8F%8A%E6%8C%87%E5%8D%97)。

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

winodws usb线连接rk3568板子上的`usb3.0 OTG`，在rk3568板子上按`reset`键，再长按`vol+/recovery`键，进入loader模式，点击`RKDevTool`工具上的`执行`按钮。可以只烧录`System`和`Userdata`（包含数据库）。

## 调试

[hdc使用指导](https://docs.openharmony.cn/pages/v3.2/zh-cn/device-dev/subsystems/subsys-toolchain-hdc-guide.md/), [hdc_std使用指导](https://docs.openharmony.cn/pages/v3.1/zh-cn/device-dev/subsystems/subsys-toolchain-hdc-guide.md/)。

`hdc`工具从[每日构建](http://ci.openharmony.cn/workbench/cicd/dailybuild/dailylist)中搜索`ohos-sdk`。

# 内核

```shell
mkdir -p /mnt/dst
mkdir -p /mnt/cache_dir/dentry_cache/cloud
mkdir -p /mnt/cloud_dir
echo 123456789 > /mnt/cloud_dir/file1
setfattr -n user.hmdfs_cache -v "/" /mnt/cache_dir/dentry_cache/cloud/cloud_000000000000002f # '/'对应的dentryfile
# setfattr -n user.hmdfs_cache -v "/dir/" /mnt/cache_dir/dentry_cache/cloud/cloud_16e1fe # '/dir/'对应的dentryfile
mkdir -p /mnt/src

mount -t hmdfs -o merge,local_dst=/mnt/dst,cache_dir=/mnt/cache_dir,cloud_dir=/mnt/cloud_dir /mnt/src /mnt/dst

ls /mnt/dst/device_view/cloud/
cat /mnt/dst/device_view/cloud/file1
```

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

# dentryfiletool

https://gitee.com/chenxiaosonggitee/dentryfiletool


