# 问题描述

nfsv3的文件占用缓存太多。

# vmcore解析

详细的crash输出请查看以下链接:

- [`20251105 vmcore分析`](https://gitee.com/chenxiaosonggitee/tmp/blob/master/gnu-linux/nfs/nfsv3-cannot-drop-cache/nfsv3-cannot-drop-cache-vmcore-20251105.md)
- [`20251202 vmcore分析`](https://gitee.com/chenxiaosonggitee/tmp/blob/master/gnu-linux/nfs/nfsv3-cannot-drop-cache/nfsv3-cannot-drop-cache-vmcore-20251202.md)



# 虚拟机中调试 {#vm-debug}

挂载:
```sh
mount -t nfs -o vers=3 192.168.53.209:/tmp/s_test /mnt
```

[用户态程序`test.c`请点击这里查看](https://gitee.com/chenxiaosonggitee/tmp/blob/master/gnu-linux/nfs/nfsv3-cannot-drop-cache/test.c)。

编译运行:
```sh
dd if=/dev/random of=/mnt/file bs=1M count=1024 # 文件大小1G
echo 3 > /proc/sys/vm/drop_caches
gcc test.c
./a.out & # 读100M数据
cd /mnt # 进入挂载点
```

## vmcore解析

参考[《内核调试方法》](https://chenxiaosong.com/course/kernel/debug.html#kdump-crash)在虚拟机中导出vmcore。

[详细的crash命令输出请点击这里查看](https://gitee.com/chenxiaosonggitee/tmp/blob/master/gnu-linux/nfs/nfsv3-cannot-drop-cache/nfsv3-cannot-drop-cache-vmcore-debug.md)。

查看地址空间中有`25728`个page，每个page有4K大小，总共`100M`:
```sh
crash> struct address_space.nrpages 0xffff88810437dd38
  nrpages = 25728, # 执行完 echo 3 > /proc/sys/vm/drop_caches 后为 0
```

执行`umount -l`后重新再`mount`（挂载参数一样，路径可以不同），`mount`命令输出中包含inode所在的super block，`files`命令也可以找到:
```sh
crash> mount | grep ffff88812ae61800
ffff8881002ce880 ffff88812ae61800 nfs    192.168.53.209:/tmp/s_test /mnt

crash> foreach files -R mnt
PID: 923      TASK: ffff8881045bcd40  CPU: 14   COMMAND: "a.out"
ROOT: /    CWD: /root 
 FD       FILE            DENTRY           INODE       TYPE PATH
  3 ffff88800ee72a80 ffff888004e1c000 ffff88810437dbc8 REG  /mnt/file
```

执行`umount -l`后重新再`mount`（挂载参数不同），`mount`命令输出中不包含inode所在的super block，`files`命令也找不到:
```sh
crash> mount | grep ffff88812ae61800 # 找不到
crash> foreach files -R mnt # 没有找到
```

# 找出缓存大于特定值的文件

麒麟服务器v10没有vmtouch，可以[在这里下载vmtouch rpm包](https://mirrors.tuna.tsinghua.edu.cn/epel/8/Everything/x86_64/Packages/v/vmtouch-1.3.1-1.el8.x86_64.rpm)。

```sh
mount_point=/mnt
export size_threshold_mb=100

find ${mount_point} -type f -print0 | xargs -0 -n1 -P16 sh -c '
    for file do
        out=$(vmtouch -v "$file")
        pages=$(echo "$out" | awk "/Resident Pages:/ {print \$3}" | cut -d/ -f1)
        mb=$((pages*4096/1024/1024))
        if [ "$mb" -gt ${size_threshold_mb} ]; then
            echo "$file Cached_MB=${mb}"
        fi
    done
  ' sh
```

