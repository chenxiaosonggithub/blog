[toc]

# 第十八章 Ext2和Ext3文件系统

## 18.1 Ext2的一般特征

## 18.2 Ext2磁盘数据结构

p733

<img src="http://chenxiaosong.com/pictures/ext2-blk-grp.png" width="66%" />

块位图中有 `8*b` 个位，所以每组中也有 `8*b` 个块，其中 `b` 是块大小（单位Byte）。

所以block group的总数大约是 `s/(每组中的块个数)`，其中`s`为分区所包含的总块数。

> 例如：
>
> 32GB的Ext2分区，块大小为4KB。
>
> 块位图的位数有8*4K = 32K，每组中也有32K个块。
>
> 分区的总块数为32GB/4KB = 8M，所以block group的总数大约 8M/32K = 256
>
> > 1K = 2^10, 1M = 2^20, 1G = 2^30

### 18.2.1超级块

p733

<img src="http://chenxiaosong.com/pictures/ext2-blk-grp.png" width="66%" />

```c
// include/linux/ext2_fs.h 
struct ext2_super_block {
	__le32  s_inodes_count;         /* Inodes count */
	__le32  s_blocks_count;         /* Blocks count */
	...
	// 1024 * 2^s_log_block_size
	__le32  s_log_block_size;       /* Block size */
	// == s_log_block_size
	__le32  s_log_frag_size;        /* Fragment size */
	__le32  s_blocks_per_group;     /* # Blocks per group */
	__le32  s_frags_per_group;      /* # Fragments per group */
	__le32  s_inodes_per_group;     /* # Inodes per group */
	...
	__le16  s_def_resuid;           /* Default uid for reserved blocks */
	__le16  s_def_resgid;           /* Default gid for reserved blocks */
	...
	__le16  s_mnt_count;            /* Mount count */
	__le16  s_max_mnt_count;        /* Maximal mount count */
	...
	__le16  s_state;                /* File system state */
	...
	__le32  s_lastcheck;            /* time of last check */
	__le32  s_checkinterval;        /* max. time between checks */
};
```

### 18.2.2 组描述符和位图

p735

<img src="http://chenxiaosong.com/pictures/ext2-blk-grp.png" width="66%" />

```c
// include/linux/ext2_fs.h
struct ext2_group_desc
{
	__le32  bg_block_bitmap;                /* Blocks bitmap block */
	__le32  bg_inode_bitmap;                /* Inodes bitmap block */
	__le32  bg_inode_table;         /* Inodes table block */
	__le16  bg_free_blocks_count;   /* Free blocks count */
	__le16  bg_free_inodes_count;   /* Free inodes count */
	__le16  bg_used_dirs_count;     /* Directories count */
	__le16  bg_pad;
	__le32  bg_reserved[3];
};
```

### 18.2.3 索引节点表

p736

```c
// include/linux/ext2_fs.h
struct ext2_inode {
	__le16  i_mode;         /* File mode */
	__le16  i_uid;          /* Low 16 bits of Owner Uid */
	__le32  i_size;         /* Size in bytes */
	__le32  i_atime;        /* Access time */
	__le32  i_ctime;        /* Creation time */
	__le32  i_mtime;        /* Modification time */
	__le32  i_dtime;        /* Deletion Time */
	__le16  i_gid;          /* Low 16 bits of Group Id */
	__le16  i_links_count;  /* Links count */
	__le32  i_blocks;       /* Blocks count */
	__le32  i_flags;        /* File flags */
	union   osd1;                           /* OS dependent 1 */
	__le32  i_block[EXT2_N_BLOCKS];/* Pointers to blocks */
	__le32  i_generation;   /* File version (for NFS) */
	__le32  i_file_acl;     /* File ACL */
	__le32  i_dir_acl;      /* Directory ACL */
	__le32  i_faddr;        /* Fragment address */
	union   osd2;                           /* OS dependent 2 */
};
```

