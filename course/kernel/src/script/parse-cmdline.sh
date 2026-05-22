mod_cfg() {
	local mnt_point=/tmp/9p # 内核仓库的上一级目录
	if findmnt ${mnt_point} >/dev/null; then
		echo "${mnt_point} is mounted"
		return
	fi
	mkdir $mnt_point -p
	mkdir /lib/modules -p
	mount -t 9p -o trans=virtio 9p $mnt_point
	local knl_vers=$(uname -r)
	local target=${mnt_point}/mod/lib/modules/${knl_vers}
	local link_name=/lib/modules/${knl_vers}
	rm ${link_name} -rf
	ln -s ${target} ${link_name}
	# 重新链接build目录
	rm /lib/modules/${knl_vers}/build
	ln -s ${mnt_point}/ /lib/modules/${knl_vers}/build
	echo "/lib/modules/${knl_vers}/build is ready"
}

for param in $(cat /proc/cmdline); do
	case $param in
	kernel_version=*)
		kernel_version=${param#*=}
		echo "kernel_version=${kernel_version}"
		mod_cfg ${kernel_version}
		;;
	esac
done

