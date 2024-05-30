// SPDX-License-Identifier: GPL-2.0-only
/*
 * Copyright (C) 2022 ChenXiaoSong
 */
#include <linux/kernel.h>
#include <linux/module.h>

extern int debug_xfs_log;

static int __init debug_xfs_log_init(void)
{
	debug_xfs_log = 1;
	return 0;
}

static void __exit debug_xfs_log_exit(void)
{
	debug_xfs_log = 0;
}

module_init(debug_xfs_log_init)
module_exit(debug_xfs_log_exit)
MODULE_LICENSE("GPL");

