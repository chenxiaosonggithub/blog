// SPDX-License-Identifier: GPL-2.0-only
/*
 * Copyright (C) 2025
 * ChenXiaoSong (chenxiaosong@chenxiaosong.com)
 */

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/kprobes.h>

#define DEBUG_FILE_NAME	"/mnt/dir/file"
#define DEBUG_BUFFER_SIZE	4096

static struct file *filp;

static int __init kernel_open_file_init(void)
{
	ssize_t ret;
	char *buffer;

	buffer = kzalloc(DEBUG_BUFFER_SIZE, GFP_KERNEL);
	if (!buffer) {
		ret = -ENOMEM;
		goto out;
	}

	filp = filp_open(DEBUG_FILE_NAME, O_CREAT | O_RDWR, 0666);
	if (IS_ERR(filp)) {
		printk("%s:%d, open file fail\n", __func__, __LINE__);
		ret = PTR_ERR(filp);
		goto out_kfree;
	}
	printk("%s:%d, open file success\n", __func__, __LINE__);

	filp->f_pos = 0;
	ret = kernel_read(filp, buffer, DEBUG_BUFFER_SIZE, &filp->f_pos);
	if (ret < 0) {
		printk("%s:%d, read fail\n", __func__, __LINE__);
		goto out_filp_close;
	}
	printk("%s:%d, read success, data: %s\n", __func__, __LINE__, buffer);

	kfree(buffer);

	return 0;

out_filp_close:
	filp_close(filp, NULL);
out_kfree:
	kfree(buffer);
out:
	return ret;
}

static void __exit kernel_open_file_exit(void)
{
	filp_close(filp, NULL);
	printk("%s:%d, close file\n", __func__, __LINE__);
}

module_init(kernel_open_file_init)
module_exit(kernel_open_file_exit)
MODULE_LICENSE("GPL");

