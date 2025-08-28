// SPDX-License-Identifier: GPL-2.0-only
/*
 * Copyright (C) 2025
 * ChenXiaoSong (chenxiaosong@chenxiaosong.com)
 */

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/fs.h>

struct super_cb_data {
	struct super_block *sb;
};

static void nfs_super_cb(struct super_block *sb, void *arg)
{
	struct super_cb_data *sd = arg;
	struct inode *inode;

	sd->sb = sb;
	printk("%s:%d, sb:%p\n", __func__, __LINE__, sb);
	spin_lock(&sb->s_inode_list_lock);
	list_for_each_entry(inode, &sb->s_inodes, i_sb_list) {
		printk("%s:%d, inode:%p\n", __func__, __LINE__, inode);
	}
	spin_unlock(&sb->s_inode_list_lock);
}

static int __init debug_init(void)
{
	struct file_system_type *nfs_fs_type;
	struct super_cb_data sd = {
		.sb = NULL,
	};

	nfs_fs_type = get_fs_type("nfs");
	if (!nfs_fs_type)
		return -ENODEV;

	iterate_supers_type(nfs_fs_type, nfs_super_cb, &sd);

	return 0;
}

static void __exit debug_exit(void)
{
	printk("%s:%d\n", __func__, __LINE__);
}

module_init(debug_init)
module_exit(debug_exit)
MODULE_LICENSE("GPL");

