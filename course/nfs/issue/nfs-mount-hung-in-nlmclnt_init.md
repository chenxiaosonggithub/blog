# 问题描述

内核版本:
```sh
uname -a
  # Linux xxxx 4.19.90-24.4.v2101.ky10.x86_64 #1 SMP Mon May 24 12:14:55 CST 2021 x86_64 x86_64 x86_64 GNU/Linux
```

加了`nolock`选项可以挂载成功:
```sh
mount -t nfs -o vers=3,nolock 192.168.53.225:/tmp/s_test /mnt
```

不加`nolock`选项，挂载卡住:
```sh
mount -t nfs -o vers=3 192.168.53.225:/tmp/s_test /mnt
```

查看进程栈:
```sh
cat /proc/64997/stack
[<0>] nlmclnt_init+0x1d/0xa0 [lockd]
[<0>] nfs_start_lockd+0xd7/0x110 [nfs]
[<0>] nfs_init_server+0x1a1/0x2d0 [nfs]
[<0>] nfs_create_server+0x57/0x1b0 [nfs]
[<0>] nfs3_create_server+0xb/0x30 [nfsv3]
[<0>] nfs_try_mount+0x14f/0x2c0 [nfs]
[<0>] nfs_fs_mount+0x627/0xdc0 [nfs]
[<0>] mount_fs+0x35/0x160
[<0>] vfs_kern_mount.part.28+0x54/0x120
[<0>] do_mount+0x5c2/0xc60
[<0>] ksys_mount+0x80/0xd0
[<0>] __x64_sys_mount+0x21/0x30
[<0>] do_syscall_64+0x5b/0x1d0
[<0>] entry_SYSCALL_64_after_hwframe+0x44/0xa9
```

# 调试 {#debug}

用以下脚本保存所有线程的栈:
```sh
output_file=stacks.txt
# grep_string="mount"
# full_cmd_result=$(ps aux | grep "${grep_string}" | grep -v "grep ${grep_string}")
full_cmd_result=$(ps aux | sed '1d') # 删除标题行
pids=$(echo "${full_cmd_result}" | awk '{print $2}')
> ${output_file} # 清空

if [ -z "$pids" ]; then
    echo "没有找到进程"
    exit 0
fi

echo "找到以下进程：" >> ${output_file}
echo "${full_cmd_result}" >> ${output_file}

echo -e "\n获取进程栈信息：" >> ${output_file}
for pid in $pids; do
    if [ -d "/proc/$pid" ]; then
        # 遍历该进程的所有线程
        for task in /proc/$pid/task/*; do
            tid=$(basename "$task")  # 提取线程ID
            echo -e "\n=============== 进程 $pid 线程 $tid $(echo -n "$(</proc/$pid/task/$tid/comm)") 栈信息 ===============" >> ${output_file}
            sudo cat /proc/$pid/task/$tid/stack >> ${output_file}
            echo "=======================================================" >> ${output_file}
        done
    else
        echo "进程 $pid 已退出" >> ${output_file}
    fi
done
```

找到两种栈:
```sh
cat /proc/23462/stack
[<0>] nfs_free_server+0x22/0x90 [nfs]
[<0>] nfs_kill_super+0x2b/0x40 [nfs]
[<0>] deactivate_locked_super+0x3f/0x70
[<0>] cleanup_mnt+0x3b/0x80
[<0>] task_work_run+0x8a/0xb0
[<0>] exit_to_usermode_loop+0xeb/0xf0
[<0>] do_syscall_64+0x1a3/0x1d0
[<0>] entry_SYSCALL_64_after_hwframe+0x44/0xa9

cat /proc/65384/stack
[<0>] nlmclnt_init+0x1d/0xa0 [lockd]
[<0>] nfs_start_lockd+0xd7/0x110 [nfs]
[<0>] nfs_init_server+0x1a1/0x2d0 [nfs]
[<0>] nfs_create_server+0x57/0x1b0 [nfs]
[<0>] nfs3_create_server+0xb/0x30 [nfsv3]
[<0>] nfs_try_mount+0x14f/0x2c0 [nfs] 
[<0>] nfs_fs_mount+0x627/0xdc0 [nfs]
[<0>] mount_fs+0x35/0x160 
[<0>] vfs_kern_mount.part.28+0x54/0x120
[<0>] do_mount+0x5c2/0xc60
[<0>] ksys_mount+0x80/0xd0
[<0>] __x64_sys_mount+0x21/0x30 
[<0>] do_syscall_64+0x5b/0x1d0
[<0>] entry_SYSCALL_64_after_hwframe+0x44/0xa9
```

```sh
rpm2cpio kernel-debuginfo-4.19.90-24.4.v2101.ky10.x86_64.rpm | cpio -div
./scripts/faddr2line usr/lib/debug/lib/modules/4.19.90-24.4.v2101.ky10.x86_64/kernel/fs/lockd/lockd.ko.debug nlmclnt_init+0x1d/0xa0
  # nlmclnt_init+0x1d/0xa0:
  # nlmclnt_init at /usr/src/debug/kernel-4.19.90/linux-4.19.90-24.4.v2101.ky10.x86_64/fs/lockd/clntlock.c:60
  # 60: if (status < 0)，应该是执行到59行: status = lockd_up(nlm_init->net);
./scripts/faddr2line usr/lib/debug/lib/modules/4.19.90-24.4.v2101.ky10.x86_64/kernel/fs/nfs/nfs.ko.debug nfs_free_server+0x22/0x90
  # nfs_free_server+0x22/0x90:
  # nfs_free_server at /usr/src/debug/kernel-4.19.90/linux-4.19.90-24.4.v2101.ky10.x86_64/fs/nfs/client.c:924
  # 924: if (!IS_ERR(server->client_acl))
```

# 代码分析

```c
mount
  ksys_mount
    do_mount
      vfs_kern_mount
        mount_fs
          nfs_fs_mount
            nfs_try_mount
              nfs3_create_server
                nfs_create_server
                  nfs_init_server
                    nfs_start_lockd
                      nlmclnt_init
                        lockd_up // 等待锁释放
```

