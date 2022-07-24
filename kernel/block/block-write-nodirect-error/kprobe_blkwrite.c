// SPDX-License-Identifier: GPL-2.0-only
/*
 * Copyright (C) 2022 ChenXiaoSong
 */

#define SECTOR_SZ		(512)
#define EXT4_BS			(4096)
#define PART_OFFSET_SEC		(10485760) // Unit: @SECTOR_SZ
#define DEV_NAME		"sda"
#define EXPECT_FILE_NAME 	"/mnt/file-expect"
#define EXPECT_FILE_SZ		(40*1024*1024)
#define SCSI_BUF_SZ		(1280*1024)
// Unit: @SECTOR_SZ
#define FIRST_SEC_OF_RANGE(ext4_blk)	((ext4_blk)*EXT4_BS/SECTOR_SZ + PART_OFFSET_SEC)
#define LAST_SEC_OF_RANGE(ext4_blk)	((ext4_blk)*EXT4_BS/SECTOR_SZ + PART_OFFSET_SEC + EXT4_BS/SECTOR_SZ - 1)
#define SCSI_SEC_RANGE_MIN0	FIRST_SEC_OF_RANGE(75776)
#define SCSI_SEC_RANGE_MAX0	 LAST_SEC_OF_RANGE(75776)
#define SCSI_SEC_RANGE_MIN1	FIRST_SEC_OF_RANGE(75777)
#define SCSI_SEC_RANGE_MAX1	 LAST_SEC_OF_RANGE(75777)
#define SCSI_SEC_RANGE_MIN2	FIRST_SEC_OF_RANGE(75778)
#define SCSI_SEC_RANGE_MAX2	 LAST_SEC_OF_RANGE(86015)

#define DECLARE_SEC_RANGE_ARR \
	static struct disk_sec_range sec_range_arr[] = {\
		{SCSI_SEC_RANGE_MIN0, SCSI_SEC_RANGE_MAX0},\
		{SCSI_SEC_RANGE_MIN1, SCSI_SEC_RANGE_MAX1},\
		{SCSI_SEC_RANGE_MIN2, SCSI_SEC_RANGE_MAX2},\
	};

#define pr_fmt(fmt) "%s: " fmt, __func__

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/init.h>
#include <linux/syscalls.h>
#include <linux/kprobes.h>

#include <linux/bio.h>
#include <linux/bitops.h>
#include <linux/blkdev.h>
#include <linux/completion.h>
#include <linux/kernel.h>
#include <linux/export.h>
#include <linux/init.h>
#include <linux/pci.h>
#include <linux/delay.h>
#include <linux/hardirq.h>
#include <linux/scatterlist.h>
#include <linux/blk-mq.h>
#include <linux/ratelimit.h>
#include <asm/unaligned.h>

#include <scsi/scsi.h>
#include <scsi/scsi_cmnd.h>
#include <scsi/scsi_dbg.h>
#include <scsi/scsi_device.h>
#include <scsi/scsi_driver.h>
#include <scsi/scsi_eh.h>
#include <scsi/scsi_host.h>
#include <scsi/scsi_transport.h> /* __scsi_init_queue() */
#include <scsi/scsi_dh.h>

#include <trace/events/scsi.h>

#include <../drivers/scsi/scsi_debugfs.h>
#include <../drivers/scsi/scsi_priv.h>
#include <../drivers/scsi/scsi_logging.h>

struct disk_sec_range {
	sector_t min;
	sector_t max;
};

static char symbol[KSYM_NAME_LEN] = "scsi_dispatch_cmd";
module_param_string(symbol, symbol, KSYM_NAME_LEN, 0644);
DECLARE_SEC_RANGE_ARR

/* For each probe you need to allocate a kprobe structure */
static struct kprobe kp = {
	.symbol_name	= symbol,
};

static char expect_buf[EXPECT_FILE_SZ];
static char scsi_buf[SCSI_BUF_SZ];
static struct file *file = NULL;

static bool scsi_is_write(struct scsi_cmnd *cmd)
{
	return (cmd->cmnd[0] == WRITE_6) || (cmd->cmnd[0] == WRITE_10) ||
	       (cmd->cmnd[0] == WRITE_12) || (cmd->cmnd[0] == WRITE_16);
}

/* Just copy from scsi_dispatch_cmd() */
static bool check_cmd(struct scsi_cmnd *cmd)
{
	struct Scsi_Host *host;

	if (!cmd || !cmd->device || !cmd->device->host)
		return false;

	host = cmd->device->host;

	/* check if the device is still usable */
	if (unlikely(cmd->device->sdev_state == SDEV_DEL)) {
		return false;
	}
	/* Check to see if the scsi lld made this device blocked. */
	if (unlikely(scsi_device_blocked(cmd->device))) {
		return false;
	}
	/*
	 * Before we queue this command, check if the command
	 * length exceeds what the host adapter can handle.
	 */
	if (cmd->cmd_len > cmd->device->host->max_cmd_len) {
		return false;
	}
	if (unlikely(host->shost_state == SHOST_DEL)) {
		return false;
	}
	return true;
}

static void check_scsi_data(struct scsi_cmnd *cmd)
{
	int i = 0;
	bool condition;
	int range_cnt = sizeof(sec_range_arr) / sizeof(struct disk_sec_range);
	bool is_write = scsi_is_write(cmd);
	sector_t sec = cmd->request->__sector;
	unsigned int len = cmd->request->__data_len;
	long expect_offset;

	condition = (is_write && cmd->request->rq_disk != NULL &&
	             !strncmp(cmd->request->rq_disk->disk_name, DEV_NAME, 3));
	if (!condition) {
		return;
	}

	condition = false;
	expect_offset = 0;
	for (i = 0; i < range_cnt; i++) {
		struct disk_sec_range range = sec_range_arr[i];
		if (sec >= range.min && sec <= range.max) {
			condition = true;
			expect_offset += (sec-range.min) * SECTOR_SZ;
			break;
		}
		expect_offset += (range.max-range.min+1) * SECTOR_SZ;
	}
	if (!condition) {
		return;
	}

	sg_copy_to_buffer(cmd->sdb.table.sgl, cmd->sdb.table.nents,
			   scsi_buf, len);
	if (memcmp(expect_buf+expect_offset, scsi_buf, len) != 0) {
		printk("scsi check data error, sector:%ld, len:%d, "
		       "expect offset:%ld\n", sec, len, expect_offset);
	}
}

/* kprobe pre_handler: called just before the probed instruction is executed */
static int __kprobes handler_pre(struct kprobe *p, struct pt_regs *regs)
{
	struct scsi_cmnd *cmd;
#ifdef CONFIG_X86
	cmd = (struct scsi_cmnd *)regs->di;
#endif
#ifdef CONFIG_ARM64
	cmd = (struct scsi_cmnd *)regs->x0;
#endif

	if (!check_cmd(cmd)) {
		return 0;
	}

	check_scsi_data(cmd);

	/* A dump_stack() here will give a stack backtrace */
	return 0;
}

/* kprobe post_handler: called after the probed instruction is executed */
static void __kprobes handler_post(struct kprobe *p, struct pt_regs *regs,
				unsigned long flags)
{
}

static int __init kprobe_init(void)
{
	loff_t pos;
	long res;
	int ret;

	kp.pre_handler = handler_pre;
	kp.post_handler = handler_post;

	ret = register_kprobe(&kp);
	if (ret < 0) {
		pr_err("register_kprobe failed, returned %d\n", ret);
		return ret;
	}
	pr_info("Planted kprobe at %p\n", kp.addr);

	file = filp_open(EXPECT_FILE_NAME, O_RDONLY, 0644);

	if (IS_ERR(file)) {
		printk("error occured while opening file %s, exiting...\n",
		       EXPECT_FILE_NAME);
		file = NULL;
		return 0;
	}

	pos = 0;
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
	unregister_kprobe(&kp);
	pr_info("kprobe at %p unregistered\n", kp.addr);
	if(file) {
		filp_close(file, NULL);
	}
}

module_init(kprobe_init)
module_exit(kprobe_exit)
MODULE_LICENSE("GPL");
