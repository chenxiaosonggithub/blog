[toc]

4.19 的代码：
```c
clone
  _do_fork
    copy_process
      alloc_pid
        // 新创建的namespace中的第一个进程
        if (is_child_reaper(pid))
        pid_ns_prepare_proc
          kern_mount_data // 挂载 procfs
            vfs_kern_mount
              mount_fs
                proc_mount
          // 只有namespace的第一个进程创建时才会执行到这里
          ns->proc_mnt = mnt

kthread
  worker_thread
    process_one_work
      proc_cleanup_work
        pid_ns_release_proc
          kern_unmount
            mntput
              mntput_no_expire
                cleanup_mnt
                  deactivate_super
                    deactivate_locked_super
                      proc_kill_sb
```