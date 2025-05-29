. ~/.top-path
code_path=${MY_CODE_TOP_PATH}
MY_ECHO_DEBUG=0

# 导入其他脚本
. ${code_path}/blog/src/blog-web/common-lib.sh

not_exist_repos=()
not_clean_repos=()
not_sync_repos=()
ok_repos=()
github_not_push_repos=()

print_result() {
	echo
	comm_print_array "not_exist_repos[@]" "$(comm_yellow_color)" "不存在的仓库:" "${not_exist_repos[@]}" "$(comm_no_color)"
	comm_print_array "ok_repos[@]" "$(comm_green_color)" "gitee全部搞定的仓库:" "${ok_repos[@]}"  "$(comm_no_color)"
	comm_print_array "not_clean_repos[@]" "$(comm_red_color)" "未提交的仓库:" "${not_clean_repos[@]}" "$(comm_no_color)"
	comm_print_array "not_sync_repos[@]" "$(comm_red_color)" "未push/pull的仓库:" "${not_sync_repos[@]}" "$(comm_no_color)"
	comm_print_array "github_not_push_repos[@]" "$(comm_red_color)" "github未同步的仓库:" "${github_not_push_repos[@]}" "$(comm_no_color)"
}

check_git() {
	local repo=$1
	local is_push_github=$2
	comm_check_repo \
		${code_path}/${repo} \
		${is_push_github} \
		not_exist_repos \
		not_clean_repos \
		not_sync_repos \
		ok_repos \
		github_not_push_repos
}

. ${code_path}/blog/src/blog-web/repos.sh
. ${code_path}/private-blog/script/repos.sh
element_count="${#repos_array[@]}" # 总个数
count_per_line=2
for ((index=0; index<${element_count}; index=$((index + ${count_per_line})))); do
	is_push_github=${repos_array[${index}]}
	repo=${repos_array[${index}+1]}
	check_git ${repo} ${is_push_github}
done
print_result
