mod_cfg() {
	local build_dir=x86_64-build
	local mnt_point=/tmp/9p
	local knl_base_dir=${mnt_point}/$1 # 修改成内核代码目录
	mkdir $mnt_point
	mkdir /lib/modules -p
	mount -t 9p -o trans=virtio 9p $mnt_point
	local knl_vers=$(uname -r)
	local target=${knl_base_dir}/${build_dir}/mod/lib/modules/${knl_vers}
	local link_name=/lib/modules/${knl_vers}
	rm ${link_name} -rf
	ln -s ${target} ${link_name}
	# 重新链接build目录
	rm /lib/modules/${knl_vers}/build
	ln -s ${knl_base_dir}/${build_dir}/ /lib/modules/${knl_vers}/build

}

for param in $(cat /proc/cmdline); do
	case $param in
	kernel_version=*)
		kernel_version=${param#*=}
		echo ${kernel_version}
		mod_cfg ${kernel_version}
		;;
	nokaslr)
		nokaslr=${param}
		echo ${nokaslr}
		;;
	esac
done
