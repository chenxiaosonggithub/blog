mkdir workdir
# wiki： https://github.com/google/syzkaller/blob/master/docs/linux/setup_ubuntu-host_qemu-vm_x86-64-kernel.md
# 参考： https://i-m.dev/posts/20200313-143737.html
# syz.cfg，只测 chmod 系统调用: "enable_syscalls": ["chmod"],
/home/sonvhi/go/src/github.com/google/syzkaller/bin/syz-manager -config=my.cfg
