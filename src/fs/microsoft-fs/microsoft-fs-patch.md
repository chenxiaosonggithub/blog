[toc]

# fs/ntfs3: fix null pointer dereference in d_flags_for_inode

https://lore.kernel.org/lkml/CAP_9mL7O7YyW56HBorZ7727m22NjbQcfcu_J4_XOBoXigQvGCg@mail.gmail.com/t/

```shell
ntfs_fill_super
  ntfs_iget5()
    ntfs_read_mft
      inode->i_op = NULL
      if (!is_rec_base(rec))
      goto ok
  d_make_root
    d_instantiate
      __d_instantiate
        d_flags_for_inode
          if (unlikely(!inode->i_op->lookup)) // inode->i_op == NULL
```