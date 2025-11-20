openeuler_path=/home/sonvhi/chenxiaosong/code/openeuler-kernel
openeuler_patch_path=${openeuler_path}/enfs-patch/

if [ $# -ne 1 ]; then
	echo "用法: bash $0 <revert/format-patch/no-action>"
	exit 1
fi

if [[ ! -d "${openeuler_path}" ]]; then
	echo "openeuler内核仓库不存在"
	exit
fi

operation=$1

enfs_patch_array=(
	b46237072d12 # nfs/enfs: cleanups in pm_set_path_state()
	456df8f077c4 # nfs/enfs: prefer normal rpc transport over unstable one
	1c9eb515727c # nfs/enfs: introduce reconnect time KUnit tests
	e961e79037be # nfs/enfs: set PM_STATE_UNSTABLE if path is unstable
	9220b0cf32cf # nfs/enfs: introduce enum PM_STATE_UNSTABLE
	9b3a7b07e0df # nfs/enfs: remove duplicate EOPNOTSUPP definition
	5797e07079ce # nfs/enfs: remove enfs_tp_common.h
	2ce743a252aa # nfs/enfs: remove ping_execute_workq_lock
	8f2393a3b9b0 # nfs/enfs: remove lookupcache_workq_lock
	6887a78ae29e # nfs/enfs: remove redundant flush_workqueue() before destroy_workqueue()
	965d05feb591 # nfs/enfs: return more nuanced error in NfsExtendProcInfoExtendEncode() and NfsExtendProcInfoExtendDecode()
	d2f0e013f9f8 # nfs/enfs: handle error returned by NfsExtendProcInfoExtendEncode()
	ba6ad67f35cf # nfs/enfs: fix possible null-ptr-deref in exten_call.c
	b6300d7bb68a # nfs/enfs: free memory uniformly at the end of function in exten_call.c
	b31506834cd7 # nfs/enfs: fix possible memory leak in exten_call.c
	c83bfa180d2e # nfs/enfs: reload config when re-adding enfs module
	01f8a9007306 # nfs/enfs: recreate shard info when re-adding enfs module
	960de6c02b85 # nfs/enfs: remove duplicate definitions
	22519a440ab8 # nfs/enfs: fix some cleanup issues
	96155a2ffed0 # nfs/enfs: fix finding root uuid issue
	0fbb6e383e68 # nfs/enfs: introduce is_enfs_debug()
	0e7a7ac73257 # nfs/enfs: get rpc procedure number from rpc_procinfo in get_uuid_from_task()
	24f295baf843 # sunrpc: do not set enfs transport in rpc_task_set_client()
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

enfs_revert() {
	local element_count="${#enfs_patch_array[@]}"
	local count_per_line=1
	for ((index=0; index<${element_count}; index=$((index + ${count_per_line})))); do
		local commit=${enfs_patch_array[${index}]}
		git revert ${commit} --no-edit
		if [[ $? != 0 ]]; then
			echo "revert ${commit} fail!!!"
			git show ${commit} --oneline
			return
		fi
	done
}

enfs_format_patch() {
	rm ${openeuler_patch_path} -rf
	mkdir ${openeuler_patch_path}
	cd ${openeuler_patch_path}

	local element_count="${#enfs_patch_array[@]}"
	local count_per_line=1
	for ((index=0; index<${element_count}; index=$((index + ${count_per_line})))); do
		local commit=${enfs_patch_array[${index}]}
		git format-patch -1 ${commit} --stdout > ${commit}.patch
	done
}

case "${operation}" in
"revert")
	enfs_revert
	;;
"format-patch")
	enfs_format_patch
	;;
"no-action")
	;;
*)
	echo "operation is wrong"
	exit
;;
esac

