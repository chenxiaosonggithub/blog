// SPDX-License-Identifier: GPL-2.0-only
/*
 * Copyright (C) 2025
 * ChenXiaoSong (chenxiaosong@chenxiaosong.com)
 */

#include <linux/kernel.h>
#include <linux/module.h>

static int __init kernel_open_file_init(void)
{
	struct file *filp = filp_open("/mnt/file", O_CREAT | O_RDWR, 0666);
	if (IS_ERR(filp)) {
		printk("%s:%d, open file fail\n", __func__, __LINE__);
		return PTR_ERR(filp);
	}
	printk("%s:%d, open file success\n", __func__, __LINE__);
	return 0;
}

static void __exit kernel_open_file_exit(void)
{
}

module_init(kernel_open_file_init)
module_exit(kernel_open_file_exit)
MODULE_LICENSE("GPL");
