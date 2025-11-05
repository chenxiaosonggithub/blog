src_path=/tmp/9p/samba/
dst_path=/root/code/samba/

if [[ ! -d "${src_path}" ]]; then
	echo "源目录不存在"
	exit
fi
if [[ ! -d "${dst_path}" ]]; then
	echo "目标目录不存在"
	exit
fi

copy_modify_files() {
	cd ${src_path}
	git status -s | while IFS= read -r line; do
		# 提取状态和文件名
		status=$(echo "$line" | cut -c1-2)
		file=$(echo "$line" | cut -c4-)
		# echo "status:${status}, file:${file}"
		echo "copy ${file}"
		cp -rf ${src_path}/${file} ${dst_path}/${file}
	done
}

copy_modify_files

