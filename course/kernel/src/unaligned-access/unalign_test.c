#include <linux/kernel.h>
#include <linux/module.h>

struct test_struct {
	int a;
	int b;
	int c;
};

static int __init unalign_test_init(void)
{
	struct test_struct data = { 0x101, 0, 0 };
	u8 *ptr = (u8 *)&data;
	int unaligned_data = *(__le32 *)(ptr);
	printk("unaligned_data:%d\n", unaligned_data);
	return 0;
}

static void __exit unalign_test_exit(void)
{
}

module_init(unalign_test_init)
module_exit(unalign_test_exit)
MODULE_LICENSE("GPL");

