BSP开发中，如果替换存储介质，要对新的存储介质进行读写测试（速率测试、数据一致性测试、压力测试等）。

本文档介绍对裸块设备进行读写测试的方法。

# 裸块设备与文件系统

> 这一节的内容是从以前记的笔记中找到的，很多都是摘抄自网上的其他文章，如果发现和你写的文章雷同，请联系我，我会加上引用。

文件系统是操作系统用于明确存储设备（常见的是磁盘，也有基于NAND Flash的固态硬盘）或分区上的文件的方法和数据结构；即在存储设备上组织文件的方法。

裸设备(raw device)，也叫裸分区（原始分区），是一种没有经过格式化，不被Unix通过文件系统来读取的特殊块设备文件。由应用程序负责对它进行读写操作。不经过文件系统的缓冲。它是不被操作系统直接管理的设备。这种设备少了操作系统这一层，I/O效率更高。

因为使用裸设备避免了再经过Unix操作系统这一层，所以使用裸设备对于读写频繁的应用程序来说，可以极大地提高性能。当然，这是以磁盘的 I/O 非常大，磁盘I/O已经成为系统瓶颈的情况下才成立。如果磁盘读写确实非常频繁，以至于磁盘读写成为系统瓶颈的情况成立，那么采用裸设备确实可以大大提高性能。

而且，由于使用的是原始分区，没有采用文件系统的管理方式，对于Unix维护文件系统的开销也都没有了，比如不用再维护i-node，空闲块等，这也能够帮助提高性能。

使用文件系统的风险在于，当系统突然掉电时，文件系统缓冲中会有一些数据并未写入相应磁盘中，但是应用程序已经认为写入数据完成，从而造成数据不一致。

使用RAW设备时，每一次数据库写入数据都真实的写在相应存储介质中，不存在数据不一致的情况。

文件系统一方面是为了管理方便,另外一方面是为了最大的调度IO资源。使用了文件系统会有很多裸设备所没有的好处,比如有自己的预读写机制,自己的缓存机制,这样也可能导致了很多时候文件系统的使用效率比裸设备好。

采用文件系统，就会涉及到文件系统的缓存(pagecache)。因为文件系统的缓存，会导致写操作比写祼设备的速度要慢，读操作一般会比采用祼设备要快。

裸设备的空间大小管理不灵活。在放置裸设备的时候，需要预先规划好裸设备上的空间使用。还应当保留一部分裸设备以应付突发情况。但这也造成了空间浪费。裸设备的创建、更改权限、扩展大小等 都需要使用root用户完成。

一般文件系统的性能比不上裸设备，且需要日志维护、OS维护和管理文件系统的开销。

如果一个系统在系统资源(包括CPU,内存，IO)不存为瓶颈时，同时读操作又多于写操作时，一般情况下采用文件系统会比采用祼设备要快。如果能够预估到系统资源可能会成为瓶颈，或者写操作又较多时，应该考虑采用祼设备。

# 读写测试

完整的读写测试代码请查看我写的[block_test.c](https://github.com/lioneie/csdn/blob/master/block%E8%AE%BE%E5%A4%87%E8%AF%BB%E5%86%99%E6%B5%8B%E8%AF%95/block_test.c)。

也可以参考[ltp-ddt](https://github.com/rogerq/ltp-ddt)项目的[filesystem_test_suite](https://github.com/rogerq/ltp-ddt/tree/master/testcases/ddt/filesystem_test_suite/src/testcases)。

代码也很简单，这里我是用系统调用接口open、read、write等直接操作裸块设备，当然你也可以直接用dd命令来测试。



文件[block_test.c](https://github.com/lioneie/csdn/blob/master/block%E8%AE%BE%E5%A4%87%E8%AF%BB%E5%86%99%E6%B5%8B%E8%AF%95/block_test.c)中，读测试时，以只读方式打开块设备：

```c
// 打开块设备
fdes = open((const char *)file_ptr, O_RDONLY);
```

把块设备中数据读到数组buff_ptr中并进行数据校验：
```c
for (i = 0; i < loopcount; i++) 
{
	read_ret = read(fdes, buff_ptr, buff_size);
	...
	// 检查数据一致性
	if(is_check)
	{
		...
	}
}
```



文件[block_test.c](https://github.com/lioneie/csdn/blob/master/block%E8%AE%BE%E5%A4%87%E8%AF%BB%E5%86%99%E6%B5%8B%E8%AF%95/block_test.c)中，写测试时，以只写方式打开块设备：

```c
// 打开块文件
fdes = open((const char *)file_ptr, O_WRONLY);
```

将数组buff_ptr中的数据写入到块设备中：

```c
for (i = 0; i < loopcount; i++) 
{
	write_ret = write(fdes, buff_ptr, buff_size);
    ...
}
```



在读写开始时启动定时器，读写结束时停止定时器，然后计算出读写速率：

```c
/** @fn : start_timer
  * @brief : 启动计时器
  * @param *ptimer_handle : 时间结构体
  * @return : None
*/
static void start_timer(struct timeval *ptimer_handle)

/** @fn : stop_timer
  * @brief : 停止计时器
  * @param *ptimer_handle : 开始的时间
  * @return : 经过的时间, 单位：微秒
*/
static unsigned long stop_timer(struct timeval *ptimer_handle)
```



至于压力测试和稳定性测试，可以自己写个脚本进行长时间的不断循环读写。