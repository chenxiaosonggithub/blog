[toc]

# 27 | 文件系统：项目成果要归档，我们就需要档案库

# 28 | 硬盘文件系统：如何最合理地组织档案库的文档？

一块(block)的大小是扇区大小的整数倍，默认是 4K

```c
struct ext4_inode
	__le32  i_block[EXT4_N_BLOCKS];/* Pointers to blocks */

#define EXT4_NDIR_BLOCKS                12
#define EXT4_IND_BLOCK                  EXT4_NDIR_BLOCKS
#define EXT4_DIND_BLOCK                 (EXT4_IND_BLOCK + 1)
#define EXT4_TIND_BLOCK                 (EXT4_DIND_BLOCK + 1)
#define EXT4_N_BLOCKS                   (EXT4_TIND_BLOCK + 1)

struct ext4_extent_header // size: 12 bytes
	__le16  eh_entries;     /* number of valid entries */
	__le16  eh_depth;       /* has tree real underlying blocks? */
struct ext4_extent
struct ext4_extent_idx
```
如果文件不大，inode 里面的 i_block 中，可以放得下一个 ext4_extent_header 和 4 项 ext4_extent:
4 bytes * 15 = 60 bytes
60 bytes / 12 = 5 = 1 * ext4_extent_header + 4 * ext4_extent

除了根节点，其他的节点都保存在一个块 4k 里面:
4096 - 12 = 4084
4084 / 12 = 340

每个 extent 最大能表示 128MB 的数据, 340个extend 表示42.5GB:
4096 * 8bit * 4096Byte = 2^27Byte = 128MByte

```c
SYSCALL_DEFINE3(open
  do_sys_open
    do_filp_open
      path_openat
        do_last
          lookup_open
            if (!dentry->d_inode && (open_flag & O_CREAT))
            // dir_inode->i_op->create
            ext4_create // ext4_dir_inode_operations
              ext4_new_inode_start_handle
                __ext4_new_inode
                  ext4_read_inode_bitmap
                  find_inode_bit
                    ext4_find_next_zero_bit
```

```c
struct ext4_group_desc                                                         
{                                                                              
  __le32  bg_block_bitmap_lo;     /* Blocks bitmap block */              
  __le32  bg_inode_bitmap_lo;     /* Inodes bitmap block */              
  __le32  bg_inode_table_lo;      /* Inodes table block */               
};

struct ext4_super_block {
  __le32  s_inodes_count;         /* Inodes count */
  ...
  __le32  s_blocks_count_lo;      /* Blocks count */         
  __le32  s_r_blocks_count_lo;    /* Reserved blocks count */
  __le32  s_free_blocks_count_lo; /* Free blocks count */    
  ...
  __le32  s_blocks_per_group;     /* # Blocks per group */
  __le32  s_inodes_per_group;     /* # Inodes per group */
  ...
  // 有用的48位，2^48 个块是 1EB
  __le32  s_blocks_count_hi;      /* Blocks count */         
  __le32  s_r_blocks_count_hi;    /* Reserved blocks count */
  __le32  s_free_blocks_count_hi; /* Free blocks count */    
```

sparse_super 特性: 超级块和块组描述符表的副本只会保存在块组索引为 0、3、5、7 的整数幂里

Meta Block Groups 特性: 每个元块组（Meta Block Group）里面的块组描述符表仅仅包括自己的，一个元块组包含 64 个块组，这样一个元块组中的块组描述符表最多 64 项。块组描述符表也是 64 项，备份三份，在元块组的第一个，第二个和最后一个块组的开始处。

```c
struct ext4_dir_entry {                                             
        __le32  inode;                  /* Inode number */          
        __le16  rec_len;                /* Directory entry length */
        __le16  name_len;               /* Name length */           
        char    name[EXT4_NAME_LEN];    /* File name */             
};                                                                  

struct ext4_dir_entry_2 {                                           
        __le32  inode;                  /* Inode number */          
        __le16  rec_len;                /* Directory entry length */
        __u8    name_len;               /* Name length */           
        __u8    file_type;                                          
        char    name[EXT4_NAME_LEN];    /* File name */             
};                                                                  

```