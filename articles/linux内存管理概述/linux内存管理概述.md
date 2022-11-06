本文章是从以前给同事分享的ppt内容整理而来，只是对linux内存管理的知识做一个概述，内容也有待补充和修改。

后续会再针对里面的某些知识点专门写一些文章。

# 简介

> 本文章的内容绝大多取材于以下2本书：
>
> Linux内核设计与实现-原书第3版 -- （美）Robert Love 著   陈莉君   康华   译
>
> 深入Linux内核-第3版 -- DANIEL P.BOVET & MARCO CESATI 著   陈莉君 张琼声  张宏伟 译

操作系统 ----- 横跨软件和硬件的桥梁
内存寻址 ----- 操作系统设计的硬件基础之一

![在这里插入图片描述](http://47.97.36.184/pictures/mm-logical-addr-translation.png#pic_center)

让我们带着这样的一个问题来看接下来的内容：

**为什么有时使用free命令和top命令查看到的已用内存不一样？**

# 硬件分段

首先需要说明的是Linux系统是未利用段机制的。
但X86的段机制还是值得学习的。

<img src="http://47.97.36.184/pictures/mm-segment.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2xpb241NDQzMDE=,size_16,color_FFFFFF,t_70#pic_center" alt="在这里插入图片描述" width="60%"/>

<img src="http://47.97.36.184/pictures/mm-segment-selector.png#pic_center" alt="在这里插入图片描述" width="67%" />

> 这两张图是从pdf书上截图的，需要重画 TODO

通过**段选择符**找到描述符表中的**段描述符**

**段描述符**包含

```
段线性首地址
段长度
是否在内存中
代码段还是数据段
```

Linux更喜欢**分页**，但x86处理器无法绕过分段
RISC体系结构（如ARM）分段支持有限
Linux让x86所有的段都从0地址开始
Linux逻辑地址 == 线性地址
Linux的权限管理等都交由**分页机制**来完成

# Linux分页

<img src="http://47.97.36.184/pictures/mm-paging.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2xpb241NDQzMDE=,size_16,color_FFFFFF,t_70#pic_center" alt="在这里插入图片描述" width="67%" />

不同体系结构对位数的划分不一样
页目录和页表包含以下内容

```
是否在内存中
读写权限
特权级
高速缓存处理方式
页框大小（页表）
```


通过物理地址扩展机制，分页使32位线性地址可以访问64G物理内存（处理器管脚36个）

<img src="http://47.97.36.184/pictures/mm-cache.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2xpb241NDQzMDE=,size_16,color_FFFFFF,t_70#pic_center" alt="在这里插入图片描述" width="60%" />

内存中的页表，访问速度慢
页面高速缓存，90%命中高速缓存，10%需要访问内存

# 进程地址空间

<img src="http://47.97.36.184/pictures/mm-virt-addr-space.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2xpb241NDQzMDE=,size_16,color_FFFFFF,t_70#pic_center" alt="在这里插入图片描述" width="50%;" />

每个运行的进程虚拟地址空间4G
每个进程私有空间前3G，称为**用户空间**
后1G空间所有进程共享，称为**内核空间**

<img src="http://47.97.36.184/pictures/mm-layout.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2xpb241NDQzMDE=,size_16,color_FFFFFF,t_70#pic_center" alt="在这里插入图片描述" width="33%;" />

**TEXT段**：程序代码段
**DATA段**：静态初始化的数据，所以有初值的全局变量（不为0）和static变量在data区
**BSS段**：Block Started by Symbol，通常是指用来存放程序中**未初始化或初始化为0**的全局变量的一块内存区域，在程序载入时由内核清0

用户态的进程运行时，可能只有少量页装入物理内存
当访问的虚拟内存页面未装入物理内存时，处理器会产生一个缺页异常
缺页异常发生时，操作系统将从磁盘或交换文件（SWAP）中将要访问的页装入物理内存
Linux总是**尽量延后**分配用户空间的内存

# 伙伴算法

伙伴算法的目的是对内存中的空闲碎片回收，让内存的利用率达到最大
把所有空闲页面分为12个块链表，每个链表中的块分别含有2，4，8 。。。个页面
大小相同、物理地址连续的2个页块被称为伙伴
工作原理：在满足大小要求的链表中查找是否有空闲块，有则直接分配，否则在更大的块中查找。逆过程为块的合并

如申请大小为2^3 = 8的页块，却在块大小为2^5 = 32的链表上找到空闲块
先将32个页面对半等分，前一半分配使用，另一半插入块大小为16的链表
继续将前一半大小为16的页块等分，一半分配，另一半插入大小为8的链表
回收的过程与上述分配过程相反

# 回收页框

当系统负载较低时，内存中大部分由磁盘高速占用
系统负载增加时，内存大部分由进程页占用，高速缓存缩小
页框回收算法从用户态进程和内核高速缓存中回收页框
在万不得已的情况下，甚至会结束一些进程

虚拟内存允许进程使用比实际物理内存大的空间
Linux交换子系统在磁盘上建立swap area，专门用于存放没有磁盘映射的页（如动态分配的内存）
而有磁盘映射的页（如程序段）则直接丢弃
当需要访问该内存中不存在的页时，会触发缺页异常，相应的异常处理程序从磁盘换入RAM中缺失的页

# 模拟器与虚拟机

Bochs：x86硬件平台的开源模拟器，帮助文档少，只能模拟x86处理器

QEMU：quick emulation，高速度、跨平台的开源模拟器，能模拟x86、arm等处理器，与Linux的KVM配合使用，能达到与真实机接近的速度

第1类虚拟机监控程序：直接在主机硬件上运行，直接向硬件调度资源，速度快。如Linux的KVM（免费）、Windows的Hyper-V（收费）

第2类虚拟机监控程序：在常规操作系统上以软件层或应用的形式运行，速度慢。如Vmware Workstation、Oracal VirtualBox
