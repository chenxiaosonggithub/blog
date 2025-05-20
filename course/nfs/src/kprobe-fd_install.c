// SPDX-License-Identifier: GPL-2.0-only
/*
 * Copyright (C) 2025
 * ChenXiaoSong (chenxiaosong@chenxiaosong.com)
 */

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/kprobes.h>
#include <mydebug.h>

#define DEBUG_FILE_NAME	"/mnt/dir/file"
#define DEBUG_BUFFER_SIZE	4096

#define DEBUG_NFS_TYPE	"nfs" // v3: nfs, v4: nfs4
// void fd_install(unsigned int fd, struct file *file)
static char symbol[KSYM_NAME_LEN] = "fd_install";

static struct kprobe kp = {
	.symbol_name	= symbol,
};

static int __kprobes handler_pre(struct kprobe *p, struct pt_regs *regs)
{
	unsigned int fd;
	struct file *file;
	struct dentry *tmp;

// x86_64函数参数用到的寄存器: RDI, RSI, RDX, RCX, R8, R9
#ifdef CONFIG_X86
	fd = (unsigned int)regs->di;
	file = (struct file *)regs->si;
#endif
// aarch64函数参数用到的寄存器: X0 ~ X7
#ifdef CONFIG_ARM64
	fd = (unsigned int)regs->regs[0];;
	file = (struct file *)regs->regs[1];;
#endif

	struct inode *inode = file_inode(file);
	if (!inode || !inode->i_sb || !inode->i_sb->s_type ||
	    !inode->i_sb->s_type->name ||
	    strcmp(inode->i_sb->s_type->name, DEBUG_NFS_TYPE))
		return 0;

	hlist_for_each_entry(tmp, &inode->i_dentry, d_u.d_alias) {
		printk("%s:%d, file name:%s, comm:%s, pid:%d\n", __func__, __LINE__,
		       tmp->d_name.name, current->comm, current->pid);
		mydebug_dump_stack();
	}

	return 0;
}

static int __init kprobe_init(void)
{
	int ret;
	kp.pre_handler = handler_pre;

	ret = register_kprobe(&kp);
	if (ret < 0) {
		pr_err("register_kprobe failed, returned %d\n", ret);
		return ret;
	}
	pr_info("Planted kprobe at %p\n", kp.addr);
	return 0;
}

static void __exit kprobe_exit(void)
{
	unregister_kprobe(&kp);
	pr_info("kprobe at %p unregistered\n", kp.addr);
}

module_init(kprobe_init)
module_exit(kprobe_exit)
MODULE_LICENSE("GPL");

