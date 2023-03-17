

# 参考资料

> 先附上参考资料，也方便自己查询。
>
> 原理性的知识就不做分析了，参考资料里的大佬分析得都很好。

[蜗窝科技](http://www.wowotech.net/)网站的[mmc](http://www.wowotech.net/tag/mmc)和[emmc](http://www.wowotech.net/tag/emmc)相关的文章，[Linux Kernel Internals](https://linux.codingbelief.com/zh/)。

[Hacker_Albert](https://blog.csdn.net/weixin_41028621)博客[mmc](https://blog.csdn.net/weixin_41028621/category_9731440.html)相关的文章。

《**Linux设备驱动开发详解-基于最新的Linux 4.0内核**》--宋宝华  编著

# mmc驱动代码分析

> 本文章的分析基于linux-4.9.259版本内核，可通过163镜像站下载[linux-4.9.259.tar.xz](http://mirrors.163.com/kernel/v4.x/linux-4.9.259.tar.xz)。

MMC/SD存储卡的驱动位于内核源码的目录drivers/mmc下，下面又分为card、core、host3个子目录。card层实际上跟Linux的块设备子系统对接，实现块设备驱动以及完成请求，但是具体的协议经过core层的接口，最终通过host完成传输，因此整个**MMC子系统的框架**如下图所示。card目录除实现标准的MMC/SD存储卡以外，还包含一些SDIO外设和驱动。core目录除了给card提供接口外，也定义好了host驱动的框架。

<img src="http://8.222.150.121/pictures/mmc-subsystem.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2xpb241NDQzMDE=,size_16,color_FFFFFF,t_70#pic_center" alt="在这里插入图片描述" width="20%"/>

> 上图**MMC子系统的框架**是通过Fedora33系统的LibreOffice Draw软件画的，谁说Linux只有字符界面，画图，视频，什么都行。

`card/block.c` 文件 的`mmc_blk_init`初始化块设备，通过

```c
res = register_blkdev(MMC_BLOCK_MAJOR, "mmc");
```

注册块设备。再通过

```c
res = mmc_register_driver(&mmc_driver);
```

向core层注册mmc驱动。



其中`mmc_driver`结构体有2个重要成员函数，`mmc_blk_probe`函数是在检测到mmc卡插入时执行，`mmc_blk_remove`函数是在mmc卡移除时执行。

```c
static struct mmc_driver mmc_driver = {
    .drv        = {  
        .name   = "mmcblk",
        .pm = &mmc_blk_pm_ops,
    },   
    .probe      = mmc_blk_probe,
    .remove     = mmc_blk_remove,
    .shutdown   = mmc_blk_shutdown,
};
```



`core/bus.c`文件下的`mmc_bus_probe`调用`mmc_blk_probe`。

```c
static struct bus_type mmc_bus_type = {
    .name       = "mmc",
    .dev_groups = mmc_dev_groups,
    .match      = mmc_bus_match,
    .uevent     = mmc_bus_uevent,
    .probe      = mmc_bus_probe,
    .remove     = mmc_bus_remove,
    .shutdown   = mmc_bus_shutdown,
    .pm     = &mmc_bus_pm_ops,
}; 
```

> mmc_bus_type的分析 **TODO**



函数调用顺序为：`mmc_blk_probe-> mmc_blk_alloc-> mmc_blk_alloc_req-> mmc_init_queue`。

`mmc_blk_alloc_req`函数中，通过

```c
md->disk->fops = &mmc_bdops;
```

指定块设备操作的函数，当应用层执行`open、close、ioctl`等操作时调用相应的接口：

```c
static const struct block_device_operations mmc_bdops = {
    .open           = mmc_blk_open,
    .release        = mmc_blk_release,
    .getgeo         = mmc_blk_getgeo,
    .owner          = THIS_MODULE,
    .ioctl          = mmc_blk_ioctl,
#ifdef CONFIG_COMPAT
    .compat_ioctl       = mmc_blk_compat_ioctl,
#endif
};

```



在`mmc_init_queue`中通过

```c
mq->queue = blk_init_queue(mmc_request_fn, lock);
```

绑定了请求处理函数`mmc_request_fn`。再通过

```c
mq->thread = kthread_run(mmc_queue_thread, mq, "mmcqd/%d%s", host->index, subname ? subname : "");
```

运行mmc对应的内核线程`mmc_queue_thread`。



当应用层调用`read，write`等接口时，`mmc_request_fn`函数会唤醒mmc对应的内核线程`mmc_queue_thread`来处理请求。mmc对应的内核线程`mmc_queue_thread`执行`mmc_blk_issue_rq`函数，`mmc_blk_issue_rq`函数再调用`mmc_blk_issue_rw_rq`，`mmc_blk_issue_rw_rq`函数最终会调用core层的`mmc_start_req`函数。

`mmc_start_req`函数里调用host驱动的`mmc_host_ops`成员函数（位于文件`host/sdhci.c`）：

```c
static const struct mmc_host_ops sdhci_ops = {
    .request    = sdhci_request,
    .post_req   = sdhci_post_req,
    .pre_req    = sdhci_pre_req,
    .set_ios    = sdhci_set_ios,
    .get_cd     = sdhci_get_cd,
    .get_ro     = sdhci_get_ro,
    .hw_reset   = sdhci_hw_reset,
    .enable_sdio_irq = sdhci_enable_sdio_irq,
    .start_signal_voltage_switch    = sdhci_start_signal_voltage_switch,
    .prepare_hs400_tuning       = sdhci_prepare_hs400_tuning,
    .execute_tuning         = sdhci_execute_tuning,
    .select_drive_strength      = sdhci_select_drive_strength,
    .card_event         = sdhci_card_event,
    .card_busy  = sdhci_card_busy,
};
```



接下来以Samsung SoC平台为例子分析host driver（文件`host/sdhci-s3c.c`）：

注册platfom驱动：

```c
static struct platform_driver sdhci_s3c_driver = { 
    .probe      = sdhci_s3c_probe,
    .remove     = sdhci_s3c_remove,
    .id_table   = sdhci_s3c_driver_ids,
    .driver     = { 
        .name   = "s3c-sdhci",
        .of_match_table = of_match_ptr(sdhci_s3c_dt_match),
        .pm = &sdhci_s3c_pmops,
    },  
};

module_platform_driver(sdhci_s3c_driver);
```

当设备和驱动匹配时调用`sdhci_s3c_driver`中的成员函数`sdhci_s3c_probe`。

`sdhci_s3c_probe`函数先初始化参数，其中`sdhci_s3c_ops`为`sdhci_ops`类型，是host driver要实现的核心内容，由于各个host的硬件有所差异，所以实际和硬件交互的驱动部分还是在host driver中实现：

```c
static struct sdhci_ops sdhci_s3c_ops = {
    .get_max_clock      = sdhci_s3c_get_max_clk,
    .set_clock      = sdhci_s3c_set_clock,
    .get_min_clock      = sdhci_s3c_get_min_clock,
    .set_bus_width      = sdhci_s3c_set_bus_width,
    .reset          = sdhci_reset,
    .set_uhs_signaling  = sdhci_set_uhs_signaling,
};
```

`sdhci_s3c_probe`函数最后调用`sdhci_add_host`注册`sdhci_host`，在注册之前已经设置的信息有：sdhci的寄存器的映射过后的基地址、quirks、quirks2、中断号、提供给sdhci core用来操作硬件的操作函数 等。

上面讲到的`mmc_start_req`函数调用Samsung SoC平台的`sdhci_s3c_ops`成员函数（通过`struct mmc_host_ops sdhci_ops`里的成员函数调用）。



未完待续。。。
