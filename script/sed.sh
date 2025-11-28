. ~/.top-path
code_path=${MY_CODE_TOP_PATH}
MY_ECHO_DEBUG=0

# 导入其他脚本
. ${code_path}/blog/src/blog-web/common-lib.sh

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

sed_repo() {
	local repo=$1
	local repo_path="${code_path}/${repo}"

	if [ ! -d "${repo_path}" ]; then
		return
	fi
	cd "${repo_path}"

	echo -e "$(comm_green_color)" "\n${repo}:" "$(comm_no_color)"

	while IFS= read -r file; do
		if [[ "${file}" == "." || "${file}" == ".." || \
		      "${file}" == ".git" ]]; then
			continue
		fi

		grep -rHnT "${old_string}" "${file}"
		local grep_res=$?
		if [[ "${grep_res}" -ne 0 ]]; then
			continue
		fi

		if [ -f "${file}" ]; then
			sed -i "s|${old_string}|${new_string}|g" "${file}"
		elif [ -d "${file}" ]; then
			find "${file}" -type f -exec sed -i "s|${old_string}|${new_string}|g" {} +
		fi
	done < <(printf "%s\n" "$(ls -1 -a)")
}

. ${code_path}/blog/src/blog-web/repos.sh
. ${code_path}/private-blog/script/repos.sh

if [[ -z ${target_repo} ]]; then
	element_count="${#repos_array[@]}" # 总个数
	count_per_line=2
	for ((index=0; index<${element_count}; index=$((index + ${count_per_line})))); do
		is_push_github=${repos_array[${index}]}
		repo=${repos_array[${index}+1]}
		sed_repo ${repo}
	done
else
	sed_repo ${target_repo}
fi

