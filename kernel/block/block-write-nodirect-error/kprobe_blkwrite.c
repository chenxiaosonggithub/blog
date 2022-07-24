// SPDX-License-Identifier: GPL-2.0-only
/*
 * Here's a sample kernel module showing the use of kprobes to dump a
 * stack trace and selected registers when kernel_clone() is called.
 *
 * For more information on theory of operation of kprobes, see
 * Documentation/trace/kprobes.rst
 *
 * You will see the trace data in /var/log/messages and on the console
 * whenever kernel_clone() is invoked to create a new process.
 */

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/init.h>
#include <linux/syscalls.h>

#define FILE_NAME "/root/chenxiaosong/blkwrite-error/file"
#define EXPECT_FILE_SZ		(40*1024*1024)

static char expect_buf[EXPECT_FILE_SZ];
static struct file *file = NULL;

static int __init kprobe_init(void)
{
	loff_t pos;
	long res;

	file = filp_open(FILE_NAME, O_RDONLY, 0644);

	if (IS_ERR(file)) {
		printk("error occured while opening file %s, exiting...\n", FILE_NAME);
		file = NULL;
		return 0;
	}

	pos =0;
	res = kernel_read(file, expect_buf, EXPECT_FILE_SZ, &pos);

	if (res > 0) {
		printk("kernel_read success, res: %ld\n", res);
	} else {
		printk("read data fail, res: %ld\n", res);
		filp_close(file, NULL);  
		file = NULL;
	}

	return 0;
}

static void __exit kprobe_exit(void)
{
	if(file) {
		filp_close(file, NULL);
	}
}

module_init(kprobe_init)
module_exit(kprobe_exit)
MODULE_LICENSE("GPL");
