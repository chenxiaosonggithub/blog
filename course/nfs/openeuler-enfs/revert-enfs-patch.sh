array=(
bc954e6ba5c8 # nfs/enfs: make some functions static in enfs_multipath_client.c
5c582afec128 # nfs/enfs: remove enfs_init() and enfs_fini()
c591cbd93842 # nfs/enfs: format get_ip_to_str() in shard_route.c
c214f4604204 # nfs/enfs: unlock uniformly at the end of function in shard_route.c
7d7c14ce5591 # nfs/enfs: support debugging ip and dns list
ef21a71a781b # nfs/enfs: fix error when showing dns list
59da5fcc7897 # nfs/enfs: fix alignment between struct rpc_clnt and rpc_clnt_reserve
0b85eddf5ae7 # nfs/enfs: set CONFIG_SUNRPC_ENFS=y by default
068e87b7ffc2 # nfs/enfs: fix memory leak of shard_view_ctrl when removing nfs module
0f58edce8611 # nfs/enfs: remove unnecessary shard_should_stop in shard_route.c
11caad69b1bf # nfs/enfs: remove enfs_uuid_debug in shard_route.c
23ee6e77f816 # nfs/enfs: remove usage of list_entry_is_head() in shard_route.c
918127ac2167 # sunrpc: remove redundant rpc_task_release_xprt() of enfs
1b175bd74767 # nfs/enfs: remove judgement about enfs_option in nfs_multipath_client_info_init()
d11adecaa2cf # nfs/enfs: remove nfs_multipath_client_info_free_work()
fddc2e489dfb # nfs/enfs: fix typos in shard_route.c
a08dbac46462 # nfs/enfs: remove unused functions in shard_route.c
219d679b1436 # nfs/enfs: make some functions static in shard_route.c
341daeb30f7a # nfs/enfs: introduce DEFINE_PARSE_FH_FUNC to define parse_fh()
ca593c48d1e1 # nfs/enfs: fix memory leak when free view_table
c91d7a809058 # nfs/enfs: use DEFINE_CLEAR_LIST_FUNC to define enfs_clear_shard_view()
2d5981287b67 # nfs/enfs: introduce DEFINE_CLEAR_LIST_FUNC to define enfs_clear_fs_info()
f42fc08b9416 # nfs/enfs: fix memory leak in enfs_delete_fs_info()
d6f01631a69c # nfs/enfs: fix double free of multipath_client_info
b29f941d7c64 # nfs/enfs: fix null-ptr-deref in shard_update_work()
69ccb9f7620d # nfs/enfs: use enfs_log_error() instead of pr_err() in enfs
de09a3d1076c # nfs/enfs: use enfs_log_info() instead of pr_info() in enfs
4fa937704cd7 # nfs/enfs: cleanups in enfs/shard_route.c
fac67ff637aa # nfs/enfs: use enfs_log_debug() instead of pr_debug() to debug enfs
28504d23f777 # nfs/enfs: remove unused code in enfs/dns_internal.h
74cbdf25fcf1 # nfs/enfs: use enfs_log_debug() instead of dfprintk() to debug enfs
e6faa11b2905 # nfs: use dfprintk() to debug enfs
9ec2dde4a003 # sunrpc, nfs: CONFIG_ENFS should select CONFIG_SUNRPC_ENFS
2b5eae5c990f # sunrpc, nfs: fix build errors when CONFIG_SUNRPC_ENFS=m && CONFIG_ENFS=m && CONFIG_NFS=y
53806d18641c # nfs: fix build errors when CONFIG_ENFS=m && CONFIG_NFS_FS=y
f4f81ee1ead7 # nfs: fix enfs mount failure when CONFIG_ENFS=y
# [[OLK-6.6]fix enfs bug](https://gitee.com/openeuler/kernel/pulls/16775/commits)
ae72360a5e6b # fix review issue
9ef9b8c08d76 # fix enfs bug
# [[OLK-6.6][eNFS]add nfs feature to support multipath](https://gitee.com/openeuler/kernel/pulls/16028/commits)
18e360871c3f # add enfs feature
)

revert_enfs() {
	local element_count="${#array[@]}" #
	local count_per_line=1
	for ((index=0; index<${element_count}; index=$((index + ${count_per_line})))); do
		local commit=${array[${index}]}
		git revert ${commit} --no-edit
	done
}

revert_enfs

