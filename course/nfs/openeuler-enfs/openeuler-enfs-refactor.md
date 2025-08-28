# 宏定义`DEFINE_CLEAR_LIST_FUNC`

[`0dab7a7f535d !17266 unify log function usage of enfs`](https://gitee.com/openeuler/kernel/tree/0dab7a7f535d)版本时，[`fs/nfs/enfs/shard_route.c`](https://gitee.com/openeuler/kernel/blob/0dab7a7f535d/fs/nfs/enfs/shard_route.c)文件中释放`struct view_table`时发生内在泄露。

`struct view_table`中有几个链表:

- `fs_head`: 在`update_fs_info()`中加入链表，在`enfs_delete_fs_info()`中释放内存失败
- `shard_head`: 在`update_shard_view()`中加入链表，在`viewtable_delete_all_shard()`中释放内存
- `lif_head`: 在`enfs_update_lif_info()`（函数未被调用）中加入链表，没有释放内存
- `ls_head`: 在`update_ls_info()`中加入链表，没有释放内存

# 宏定义`DEFINE_CLEAR_LIST_FUNC`

用以下脚本删除函数的一些公共内容（注意脚本执行后还需要手动再处理一下）:
```sh
file_name=fs/nfs/enfs/shard_route.c
array=(
        "^static const struct nfs_fh \*parse_" "parse_"
        "(struct rpc_message \*msg)$" ""
        " \*args = msg->rpc_argp;" ""
        "return args->" ""
)

del_common_str() {
        local element_count="${#array[@]}"
        local count_per_line=2

        for ((index=0; index<${element_count}; index=$((index + ${count_per_line})))); do
                local old_str=${array[${index}]}
                local new_str=${array[${index}+1]}

                sed -i "s|${old_str}|${new_str}|g" ${file_name}
        done
}

del_common_str
```
