[toc]

# 通过 inode 获取文件名

```c
// 取链表中的第一个，文件可能有多个硬链接对应多个dentry，文件夹只可能有一个dentry
container_of(inode->i_dentry, struct dentry, d_u.d_alias);

// 遍历,取链表中的第一个，文件可能有多个硬链接对应多个dentry，文件夹只可能有一个
struct dentry *tmp = NULL;
hlist_for_each_entry(tmp, &inode->i_dentry, d_u.d_alias) {
        // tmp->d_inode 的判断是否多余？是否在某些情况下有必要判断？
        if (inode->i_sb && tmp && tmp->d_inode == inode) {
                tmp->d_name.name;
        }  
}
```
