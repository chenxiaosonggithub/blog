本文内容取材于以下教材：

> 《Linux设备驱动开发详解-基于最新的Linux 4.0内核》第10章 --宋宝华  编著

设备的硬件中断会打断进程的调度，与所有其他的操作系统一样，中断服务程序的执行时间要尽量小。但有时中断需要完成的工作量却很大，因此必须要把中断处理程序分为2部分：顶半部（Top Half）和底半部（Botton Half）。

一般在中断顶半部服务程序中只是简单的读取寄存器中断状态和清除中断标志等工作量小的任务，然后将底半部处理程序挂到设备的底半部执行队列中去。

Linux底半部的机制有：tasklet、工作队列、softirq（软中断）、threaded_irq（线程化中断）。

tasklet和softirq运行于软中断上下文，属于原子上下文的一种，**不允许休眠和调度**。

工作队列和threaded_irq运行于进程上下文（内核线程），**允许休眠和调度**。

# tasklet

tasklet执行时机通常是顶半部返回的时候。

定义tasklet和底半部函数，并关联起来：

```c
void xxx_do_tasklet(unsigned long data);
// 第3个参数为传入 xxx_do_tasklet 的参数
DECLARE_TASKLET(xxx_tasklet, xxx_do_tasklet, 0);
```

设备驱动模块加载函数和卸载函数：

```c
//模块加载函数
int __init xxx_init(void)
{
    ...
	//申请中断
    res = request_irq(xxx_irq, xxx_interrupt, 0, "xxx", NULL);
    ...
    return IRQ_HANDLED;
}

//模块卸载函数
void __exit xxx_exit(void)
{
    ...
    //释放中断
    free_irq(xxx_irq, xxx_interrupt);
    ...
}
```

中断处理顶半部：

```c
iqrreturn_t xxx_interrupt(int irq, void *dev_id)
{
    ...
    //使系统在适当的时候进行调度
    tasklet_schedule(&xxx_tasklet);
    ...
}
```

中断处理底半部：

```c
void xxx_do_tasklet(unsigned long data)
{
    ...
}
```

# 工作队列

与tasklet类似，定义工作队列和关联的函数：

```c
struct work_struct xxx_wq;
void xxx_do_work(struct work_struct *work);
```

模块加载函数：

```c
int __init xxx_init(void)
{
    ...
	//申请中断
    res = request_irq(xxx_irq, xxx_interrupt, 0, "xxx", NULL);
    ...
    //初始化工作队列
    INIT_WORK(&xxx_wq, xxx_do_work);
    ...
    return IRQ_HANDLED;
}
```

模块卸载函数：

```c
void __exit xxx_exit(void)
{
    ...
    //释放中断
    free_irq(xxx_irq, xxx_interrupt);
    ...
}
```

中断处理顶半部：

```c
iqrreturn_t xxx_interrupt(int irq, void *dev_id)
{
    ...
    //使系统在适当的时候进行调度
    schedule_work(&xxx_wq);
    ...
}
```

中断处理底半部：

```c
void xxx_do_work(struct work_struct *work)
{
    ...
}
```

# softirq和threaded_irq

软中断（softirq）的执行时机是顶半部返回的时候，tasklet是基于软中断实现的。一般情况下驱动**不会直接使用**softirq。



threaded_irq：

```c
//irq: 中断号
//handler: 顶半部中断处理函数，中断发生时dev_id参数传递给这个函数
//thread_fn: 为中断号分配一个对应的内核线程，只针对这个中断号
//irqflags: 中断处理的属性
int request_threaded_irq(unsigned int irq, irq_handler_t handler, irq_handler_t thread_fn, 
                         unsigned long irqflags, const char *dev_name, void *dev_id);
//devm_表示申请的是内核managed的资源，不需要显式释放，类似java的垃圾回收机制
int devm_request_threaded_irq(struct device *dev, unsigned int irq, 
                              irq_handler_t handler, irq_handler_t thread_fn, 			
              				  unsigned long irqflags, const char *dev_name, void *dev_id);
```

如果handler结束时返回值是IRQ_WAKE_THREAD，内核会调度对应的内核线程执行thread_fn函数。

