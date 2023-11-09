[toc]

# 第13章 虚拟文件系统

## 13.1 通用文件系统接口 

## 13.2 文件系统抽象层

## 13.3 Unix文件系统

p212：

DOS和Windows将文件的命名空间分类为驱动字母（如C:），这种将命名空间划分为设备和分区和做法，相当于把硬件细节“泄露”给文件系统抽象层，对用户而言，随意和混淆。

## 13.4 VFS对象及其数据结构

## 13.5 超级块对象

p214：

```c
// include/linux/fs.h
struct super_block {
	...
	const struct super_operations   *s_op;
	...
};

```

## 13.6 超级块操作

```c
// include/linux/fs.h
struct super_operations {
	struct inode *(*alloc_inode)(struct super_block *sb);
	void (*destroy_inode)(struct inode *);
	...
};
```

## 13.7 索引节点对象

```c
// include/linux/fs.h
struct inode {
	struct hlist_node       i_hash;
	struct list_head        i_list;         /* backing dev IO list */
	struct list_head        i_sb_list;
	...
};
```

## 13.8 索引节点操作



# 第14章 块I/O层

## 14.1 剖析一个块设备

**扇区**：块设备中最小的寻址单元，物理磁盘寻址按扇区级进行，2的整数倍，最常见512Byte，CD-ROM扇区2KB。又称作：硬扇区，设备块。

**块**：最小逻辑可寻址单元，文件系统的一种抽象，访问文件系统只能基于块，**内核**执行的磁盘操作按块进行。扇区大小<=块大小（2的整数倍）<=页面大小，通常512Byte，1KB，４KB。又称作：文件块，I/O块。

## 14.2 缓冲区和缓冲区头

## 14.3 bio结构体

```c
// include/linux/bio.h
struct bio {
        sector_t                bi_sector;      /* device address in 512 byte
                                                   sectors */
        struct bio              *bi_next;       /* request queue link */
        struct block_device     *bi_bdev;
        unsigned long           bi_flags;       /* status, command, etc */
        unsigned long           bi_rw;          /* bottom bits READ/WRITE, * top bits priority */
        unsigned short          bi_vcnt;        /* how many bio_vec's */
        unsigned short          bi_idx;         /* current index into bvl_vec */
        unsigned int            bi_phys_segments;
        unsigned int            bi_size;        /* residual I/O count */
        unsigned int            bi_seg_front_size;
        unsigned int            bi_seg_back_size;
        unsigned int            bi_max_vecs;    /* max bvl_vecs we can hold */
        unsigned int            bi_comp_cpu;    /* completion CPU */
        atomic_t                bi_cnt;         /* pin count */
        struct bio_vec          *bi_io_vec;     /* the actual vec list */
        bio_end_io_t            *bi_end_io;
        void                    *bi_private;
#if defined(CONFIG_BLK_DEV_INTEGRITY)
        struct bio_integrity_payload *bi_integrity;  /* data integrity */
#endif  
        bio_destructor_t        *bi_destructor; /* destructor */
        struct bio_vec          bi_inline_vecs[0];
};
```

### 14.3.1 I/O向量

```c
// include/linux/bio.h
struct bio_vec {
        struct page     *bv_page;
        unsigned int    bv_len;
        unsigned int    bv_offset;
};
```

### 14.3.2 新老方法对比

## 14.4 请求队列

```c
// include/linux/blkdev.h
struct request_queue
{
	...
};
// include/linux/blkdev.h
struct request {
	...
};
```

