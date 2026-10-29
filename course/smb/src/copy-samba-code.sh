vm_path=/root/code/samba/
pm_path=/tmp/9p/samba/ # physical machine path

if [ $# -ne 1 ]; then
	echo "Usage: $0 \${is src path vm}"
	exit 1
fi


if [[ $1 == 1 ]]; then
	samba_src_root=${vm_path}
	dst_path=${pm_path}
else
	dst_path=${vm_path}
	samba_src_root=${pm_path}
fi

if [[ ! -d "${samba_src_root}" ]]; then
	echo "源目录不存在"
	exit
fi
if [[ ! -d "${dst_path}" ]]; then
	echo "目标目录不存在"
	exit
fi

copy_modify_files() {
	cd ${samba_src_root}
	git status -s | while IFS= read -r line; do
		# 提取状态和文件名
		status=$(echo "$line" | cut -c1-2)
		file=$(echo "$line" | cut -c4-)
		# echo "status:${status}, file:${file}"
		echo "copy ${file}"
		cp -rf ${samba_src_root}/${file} ${dst_path}/${file}
	done
}

copy_modify_files

