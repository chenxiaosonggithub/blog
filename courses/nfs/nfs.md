# nfs client 结构体

## 超级块

由于nfs没有磁盘超级块，所以只有内存超级块结构体`struct nfs_server`，在`nfs_get_tree_common()`函数中赋值`fc->s_fs_info = server`。
```c

```

## 超级块操作

```c
const struct super_operations nfs_sops = { 
        .alloc_inode    = nfs_alloc_inode, 
        .free_inode     = nfs_free_inode,  
        .write_inode    = nfs_write_inode, 
        .drop_inode     = nfs_drop_inode,  
        .statfs         = nfs_statfs,      
        .evict_inode    = nfs_evict_inode, 
        .umount_begin   = nfs_umount_begin,
        .show_options   = nfs_show_options,
        .show_devname   = nfs_show_devname,
        .show_path      = nfs_show_path,   
        .show_stats     = nfs_show_stats,  
};                                         

static const struct super_operations nfs4_sops = { 
        .alloc_inode    = nfs_alloc_inode,         
        .free_inode     = nfs_free_inode,          
        .write_inode    = nfs4_write_inode,        
        .drop_inode     = nfs_drop_inode,          
        .statfs         = nfs_statfs,              
        .evict_inode    = nfs4_evict_inode,        
        .umount_begin   = nfs_umount_begin,        
        .show_options   = nfs_show_options,        
        .show_devname   = nfs_show_devname,        
        .show_path      = nfs_show_path,           
        .show_stats     = nfs_show_stats,          
};                                                 
```

## 索引节点

nfs没有磁盘索引节点，只有内存索引节点`struct nfs_inode`。

```c

```

## 索引节点操作

