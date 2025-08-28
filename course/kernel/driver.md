# 字符设备驱动

```c
struct cdev {
	struct kobject kobj;
	struct module *owner;
	const struct file_operations *ops;
	struct list_head list;
	dev_t dev; // 设备号，32位
	unsigned int count;
} __randomize_layout;

// 高12位为主设备号
#define MAJOR(dev)      ((unsigned int) ((dev) >> MINORBITS))
// 低20位为次设备号
#define MINOR(dev)      ((unsigned int) ((dev) & MINORMASK))
// 生成设备号
#define MKDEV(ma,mi)    (((ma) << MINORBITS) | (mi))
```

```c
void cdev_init(struct cdev *cdev, const struct file_operations *fops)  
struct cdev *cdev_alloc(void)                                       
void cdev_put(struct cdev *p)
int cdev_add(struct cdev *p, dev_t dev, unsigned count)
void cdev_del(struct cdev *p)
```

