mod_cfg() {
	local build_dir=x86_64-build
	local mnt_point=/tmp/9p # 内核仓库的上一级目录
	local knl_base_dir=${mnt_point}/$1 # 修改成内核代码目录
	if findmnt ${mnt_point} >/dev/null; then
		echo "${mnt_point} is mounted"
		return
	fi
	mkdir $mnt_point -p
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
	echo "/lib/modules/${knl_vers}/build is ready"
}

is_serial_console() {
	local tty_dev=$(tty)
	echo "tty: ${tty_dev}"

	case "$tty_dev" in
	/dev/ttyS* | /dev/ttyAMA*)
		echo "serial console"
		return 0
		;;
	esac

	echo "not serial console"
	return 1
}

for param in $(cat /proc/cmdline); do
	case $param in
	kernel_version=*)
		kernel_version=${param#*=}
		echo "kernel_version=${kernel_version}"
		mod_cfg ${kernel_version}
		;;
	stty_rows=*)
		if ! is_serial_console; then
			echo "do not set stty rows"
			continue
		fi
		stty_rows=${param#*=}
		echo "stty_rows=${stty_rows}"
		stty rows ${stty_rows}
		echo "stty rows ${stty_rows}"
		;;
	stty_cols=*)
		if ! is_serial_console; then
			echo "do not set stty cols"
			continue
		fi
		stty_cols=${param#*=}
		echo "stty_cols=${stty_cols}"
		stty cols ${stty_cols}
		echo "stty cols ${stty_cols}"
		;;
	esac
done
