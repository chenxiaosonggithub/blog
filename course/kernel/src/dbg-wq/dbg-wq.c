#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/slab.h>
#include <linux/workqueue.h>
#include <linux/delay.h>

struct my_info {
	struct work_struct work;
	int data;
};

struct workqueue_struct *my_wq;

struct my_info *info;

static void my_workfn(struct work_struct *work)
{
	// struct my_info *info = container_of(work, struct my_info, work);
	printk("%s:%d, sleep begin\n", __func__, __LINE__);
	// 如果没有调用destroy_workqueue()，在sleep期间执行 rmmod 会发生panic
	msleep(20 * 1000);
	printk("%s:%d, sleep end\n", __func__, __LINE__);
}

static int __init debug_wq_init(void)
{
	int ret = 0;
	my_wq = create_workqueue("my_wq");
	if (!my_wq)
		return -ENOMEM;

	info = kmalloc(sizeof(*info), GFP_ATOMIC);
	if (!info) {
		ret = -ENOMEM;
		goto wq_fail;
	}

	INIT_WORK(&info->work, my_workfn);
	info->data = 5;
	queue_work(my_wq, &info->work);

	return ret;

wq_fail:
	destroy_workqueue(my_wq);
	my_wq = NULL;

	return ret;
}

static void __exit debug_wq_exit(void)
{
	destroy_workqueue(my_wq);
	kfree(info);
}

module_init(debug_wq_init)
module_exit(debug_wq_exit)
MODULE_LICENSE("GPL");
