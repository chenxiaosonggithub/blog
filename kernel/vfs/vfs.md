[toc]

# 通过 inode 获取文件名

```c
struct dentry *tmp = NULL;
hlist_for_each_entry(tmp, &inode->i_dentry, d_u.d_alias) {
        if (inode->i_sb && tmp && tmp->d_inode == inode) {
                tmp->d_name.name;
                break;  
        }  
}
```