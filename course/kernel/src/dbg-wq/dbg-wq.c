#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/slab.h>
#include <linux/workqueue.h>
#include <linux/delay.h>

struct my_data {
	struct work_struct work;
	int data;
};

struct my_data *data;

static void my_workfn(struct work_struct *work)
{
	// struct my_data *data = container_of(work, struct my_data, work);
	printk("%s:%d, sleep begin\n", __func__, __LINE__);
	msleep(20 * 1000); // 在这里执行 rmmod dbg_wq 会发生panic
	printk("%s:%d, sleep end\n", __func__, __LINE__);
}

static int __init debug_wq_init(void)
{
	data = kmalloc(sizeof(*data), GFP_ATOMIC);
	if (!data)
		return -1;
	INIT_WORK(&data->work, my_workfn);
	data->data = 5;
	schedule_work(&data->work);
	return 0;
}

static void __exit debug_wq_exit(void)
{
	kfree(data);
}

module_init(debug_wq_init)
module_exit(debug_wq_exit)
MODULE_LICENSE("GPL");
