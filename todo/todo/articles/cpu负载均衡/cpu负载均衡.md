本文章的内容取材于以下教材：

>深入Linux内核-第3版 第7章 -- DANIEL P.BOVET & MARCO CESATI 著   陈莉君 张琼声  张宏伟 译
>

示例代码使用的版本是kernel2.6.11，可以从163开源镜像站下载[linux-2.6.11.tar.xz](http://mirrors.163.com/kernel/v2.6/linux-2.6.11.tar.xz)。



Linux一直坚持采用对称多处理器模型，内核不会对某个cpu有任何偏向。

主要关注以下3种多处理器类型：

1. **标准的多处理器体系结构**：机器所共有的RAM芯片集被所有cpu共享。
2. **超线程**：立刻执行几个执行线程的微处理器，包括几个内部寄存器的拷贝。当前线程访问内存时处理器使用它的机器周期去执行另一个线程。一个超线程物理cpu  可以看成  几个不同的逻辑cpu。
3. **NUMA**：把cpu和RAM以本地“节点”为单位分组，一个“节点”包含一个cpu和几个RAM芯片。cpu访问本地RAM芯片非常快（几乎没竞争）。

# 调度域

下图给出3个调度域分层实例，对应3种多处理器机器体系结构：

> 这个图是从pdf书上截图的

![](http://chenxiaosong.com/pictures/3example-sched-domain-hierarchies.png)

所有物理cpu调度域描述符存放在每cpu变量中：

```c
// 位于 kernel/sched.c 文件
static DEFINE_PER_CPU(struct sched_domain, phys_domains);
```

cpu调度域描述符结构体：

```c
// 位于 include/linux/sched.h
struct sched_domain {
    // 指向父调度域描述符
    struct sched_domain *parent;    /* top domain must be null terminated */
    // 调度域中的每个组，指向链表中的第一个  
    struct sched_group *groups; /* the balancing groups of the domain */
    ...
    // 当NOT_IDLE时乘以这个因子
    unsigned int busy_factor;   /* less balancing by factor if busy */
    ...
    // 查看SD_LOAD_BALANCE等7个宏定义
    int flags;          /* See SD_* */
    // 上次平衡操作的时间                                                      
    unsigned long last_balance; /* init to jiffies. units in jiffies */        
    // 平衡操作的周期
    unsigned int balance_interval;  /* initialise to 1. units in ms. */
    ...
};
```

# rebalance_tick函数

```c
// 每经过一次时钟节拍，由scheduler_tick调用
// this_cpu: 本地cpu下标
// this_rq: 本地运行队列的地址
// idle: SCHED_IDLE表示cpu空闲（当前进程是swapper进程），NOT_IDLE表示cpu不空闲
static void rebalance_tick(int this_cpu, runqueue_t *this_rq,
               enum idle_type idle)
{
    ...
    struct sched_domain *sd;
    // 更新运行队列的平均工作量
    old_load = this_rq->cpu_load;
    this_load = this_rq->nr_running * SCHED_LOAD_SCALE;
    if (this_load > old_load)
        old_load++;
    this_rq->cpu_load = (old_load + this_load) / 2;
	// 在所有调度域上的循环，从基本域到最上层的域
    for_each_domain(this_cpu, sd) {
        ...
        interval = sd->balance_interval;                                       
        // NOT_IDLE 时，时间较长，大概10ms处理一次逻辑cpu对应的调度域，大概100ms处理一次物理cpu对应的调度域
        // SCHED_IDLE 时，大概一到两个节拍处理一次对应于逻辑和物理cpu的调度域  
        if (idle != SCHED_IDLE)
            interval *= sd->busy_factor;                                       
        ...
        if (j - sd->last_balance >= interval) {                                
            //在调度域上执行重新平衡的操作
            if (load_balance(this_cpu, this_rq, sd, idle)) {
                /* We've pulled tasks over so no longer idle */                
                idle = NOT_IDLE;                                               
            }
            sd->last_balance += interval;                                      
        }                                                                      
    }                                                                          
}

```

# load_balance函数

```c
// 检查调度域是否处于严重的不平衡状态
// 把最繁忙的组中的一些进程迁移到本地cpu的运行队列，进而减轻不平衡状态         
// this_cpu: 本地cpu下标
// this_rq: 本地运行队列的地址
// sd: 指向被检查的调度域的描述符
// idle: SCHED_IDLE表示cpu空闲（当前进程是swapper进程），NOT_IDLE表示cpu不空闲 
static int load_balance(int this_cpu, runqueue_t *this_rq,                     
            struct sched_domain *sd, enum idle_type idle)                      
{
    ...
    // 获取自旋锁
    spin_lock(&this_rq->lock);
    schedstat_inc(sd, lb_cnt[idle]);                                           
    
    // 分析调度域中各组的工作量
    // inbalance: 为了恢复平衡而被迁移到本地运行队列中的进程数
    group = find_busiest_group(sd, this_cpu, &imbalance, idle);
    ...
    
    // 找到最繁忙的组中的最繁忙的cpu
    busiest = find_busiest_queue(group); 
    if (busiest->nr_running > 1) {
        // double_lock_balance 函数中，为了避免死锁，先释放this_rq->lock，再获得2个锁
        double_lock_balance(this_rq, busiest);
        // 把最繁忙的运行队列中的一些进程迁移到this_rq
        nr_moved = move_tasks(this_rq, this_cpu, busiest,
                        imbalance, sd, idle);
        spin_unlock(&busiest->lock);
    }
    spin_unlock(&this_rq->lock);
    
    // 没有迁移成功，调度域还是不平衡
    if (!nr_moved) {
        ...
        if (unlikely(sd->nr_balance_failed > sd->cache_nice_tries+2)) {
            ...
            if (!busiest->active_balance) {
                // 平衡操作处于活跃状态
                busiest->active_balance = 1;
                busiest->push_cpu = this_cpu;
                wake = 1;
            }
            // busiest->lock锁在此处释放
            spin_unlock(&busiest->lock);
            // 唤醒migration内核线程
            // migration内核线程会调用move_tasks
            if (wake)
                wake_up_process(busiest->migration_thread);
			...
        }
        ...
    } else {
        ...
    }

    return nr_moved;

out_balanced:
    spin_unlock(&this_rq->lock);
    // 延迟调度
    ...
    return 0;
}

```

# move_tasks函数

```c
// 把进程从源运行队列迁移到本地运行队列                                        
// this_cpu: 本地cpu下标
// this_rq: 本地运行队列的地址
// busiest: 源运行队列描述符，最繁忙                                           
// max_nr_move: 被迁移进程的最大数
// sd: 在其中执行平衡操作的调度域的描述符地址
// idle: SCHED_IDLE表示cpu空闲（当前进程是swapper进程），NOT_IDLE表示cpu不空闲 
static int move_tasks(runqueue_t *this_rq, int this_cpu, runqueue_t *busiest,  
              unsigned long max_nr_move, struct sched_domain *sd,              
              enum idle_type idle)                                             
{
    ...
    if (busiest->expired->nr_active) {
        // 分析busiest运行队列的过期进程                                       
        array = busiest->expired;
        dst_array = this_rq->expired;                                          
    } else {
        array = busiest->active;
        dst_array = this_rq->active;                                           
    }

new_array:
    /* Start searching at priority 0: */
    idx = 0;
skip_bitmap:
    // 从优先级高的进程开始分析
    if (!idx)
        idx = sched_find_first_bit(array->bitmap);
    else
        idx = find_next_bit(array->bitmap, MAX_PRIO, idx);
    if (idx >= MAX_PRIO) {
        if (array == busiest->expired && busiest->active->nr_active) {
            // 扫描busiest运行队列的活动进程
            array = busiest->active;
            dst_array = this_rq->active;
            goto new_array;
        }
        goto out;
    }
	...
skip_queue:
    ...
    // TODO: 分析 can_migrate_task
    if (!can_migrate_task(tmp, busiest, this_cpu, sd, idle)) {
        if (curr != head)
            goto skip_queue;
        idx++;
        goto skip_bitmap;
    }
	...
    // 可以迁移进程，把候选进程迁移到本地运行队列
    // 在pull_task函数中，调用dequeue_task、enqueue_task
    // 在pull_task函数最后，如果刚被迁移的进程比当前进程拥有更高的动态优先级，就调用resched_task()抢占本地cpu的当前进程
    pull_task(busiest, array, tmp, this_rq, dst_array, this_cpu);
    pulled++;
	...
out:
    return pulled;
}
```

