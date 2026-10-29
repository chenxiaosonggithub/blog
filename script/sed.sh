code_path=${MY_CODE_TOP_PATH}
MY_ECHO_DEBUG=0

# 导入其他脚本
. "${code_path}/blog/src/blog-web/common-lib.sh"
. "${code_path}/blog/script/common-lib.sh"

# 检查参数
if [ $# -lt 2 ]; then
        echo "用法: bash $0 <被替换的老字符串> <替换的新字符串>"
        exit 1
fi
old_string=$1
new_string=$2

target_repo=""
if [ $# -eq 3 ]; then
	target_repo=$3
fi

sed_entry() {
	local file=$1
	if ! grep -rHnT -- "${old_string}" "${file}"; then
		return
	fi

	if [ -f "${file}" ]; then
		sed -i "s|${old_string}|${new_string}|g" -- "${file}"
	elif [ -d "${file}" ]; then
		# 保持原行为：入口有匹配时，处理该目录下的所有普通文件。
		find "./${file}" -type f -exec sed -i "s|${old_string}|${new_string}|g" -- {} +
	fi
}

. "${code_path}/blog/src/blog-web/repos.sh"
. "${code_path}/private-blog/script/repos.sh"

script_for_each_repo_entry sed_entry "${target_repo}"

