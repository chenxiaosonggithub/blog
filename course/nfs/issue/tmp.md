# 问题描述

麒麟server v10系统（内核4.19）执行`ls -l`遍历目录文件所花的时间比SUSE系统更长，
suse的发行版是SUSE Linux Enterprise Server 12 SP5（内核版本4.12.14-120-default）。

# 调试

## 环境准备

在nfs server端(suse)的测试目录下创建足够多的文件:
```sh
counter=200000
path=/tmp/test
rm -rf ${path}
mkdir -p ${path}
cd ${path}

i=0
while true
do
    echo 1234567890 > file${i} # 不要用touch创建文件，因为更慢
    ((i++))
    echo ${i}
    if [ ${i} -eq ${counter} ]
    then
        break
    fi
done
```

nfs server端的配置文件`/etc/exports`如下:
```sh
/tmp *(rw,sync,no_all_squash,no_root_squash,no_subtree_check)
```

nfs client端挂载:
```sh
mount -t nfs -o lookupcache=none,proto=tcp,rsize=262144,wsize=262144,soft,timeo=180,retrans=300 192.168.122.7:/tmp /mnt
mount | grep nfs
    # SUSE Linux Enterprise Server 12 SP5 上的输出
        # 192.168.122.7:/tmp on /mnt type nfs4 (rw,relatime,vers=4.0,rsize=262144,wsize=262144,namlen=255,soft,proto=tcp,timeo=180,retrans=300,sec=sys,clientaddr=192.168.122.251,lookupcache=none,local_lock=none,addr=192.168.122.7)
    # 麒麟server v10系统（内核4.19）上的输出
        # 192.168.122.7:/tmp on /mnt type nfs4 (rw,relatime,vers=4.2,rsize=262144,wsize=262144,namlen=255,soft,proto=tcp,timeo=180,retrans=300,sec=sys,clientaddr=192.168.122.73,lookupcache=none,local_lock=none,addr=192.168.122.7)
```

## 测试

nfs client测试命令:
```sh
echo 3 > /proc/sys/vm/drop_caches
time ls -l /mnt/test/ > /dev/null
```

suse测试结果如下:
```sh
real    2m10.909s
user    0m0.483s
sys     0m31.787s
```

suse内核替换为麒麟的4.19，测试结果如下:
```sh
real    2m18.750s
user    0m0.624s
sys     0m35.437s
```

麒麟系统上测试结果如下:
```sh
real    2m38.525s
user    0m0.487s
sys     0m36.398s
```

