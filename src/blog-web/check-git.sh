. ~/.top-path
code_path=${MY_CODE_TOP_PATH}
MY_ECHO_DEBUG=0

# 导入其他脚本
. ${code_path}/blog/src/blog-web/common-lib.sh

not_exist_repos=()
not_clean_repos=()
not_sync_repos=()
gitee_ok_repos=()
github_not_push_repos=()
github_ok_repos=()

# return 0: push成功
# return 非0: push失败
comm_push_github_repo() {
	git remote -v | grep chenxiaosonggithub
	if [ $? -eq 0 ]; then
		git push github master -f
		return $?
	fi
	return 1
}

# 确认git仓库要采取的操作
#   return 0: push/pull完成（或不用push/pull）
#   return 1: 要手动处理
comm_check_pull_push() {
	local repo=$1

	local origin_commit=$(git rev-parse origin/master)
	local master_commit=$(git rev-parse master)
	local contains_origin=$(git branch -a --contains "${origin_commit}")
	local contains_master=$(git branch -a --contains "${master_commit}")
	local remote_contain_origin=false
	local local_contain_origin=false
	local remote_contain_master=false
	local local_contain_master=false

	comm_echo "${repo} origin_commit: ${origin_commit}"
	comm_echo "${repo} master_commit: ${master_commit}"

	if [ "${origin_commit}" == "${master_commit}" ]; then
		comm_echo "${repo}不用push/pull"
		return 0
	fi
	comm_echo "${repo}未push/pull"

	comm_echo "${contains_origin}"
	if echo "${contains_origin}" | grep -q "^  remotes/origin/master"; then
		comm_echo "${repo} origin/master commit is contained in remote branch"
		remote_contain_origin=true
	fi
	if echo "${contains_origin}" | grep -q "^* master"; then
		comm_echo "${repo} origin/master commit is contained in local branch"
		local_contain_origin=true
	fi

	comm_echo "${contains_master}"
	if echo "${contains_master}" | grep -q "^  remotes/origin/master"; then
		comm_echo "${repo} master commit is contained in remote branch"
		remote_contain_master=true
	fi
	if echo "${contains_master}" | grep -q "^* master"; then
		comm_echo "${repo} master commit is contained in local branch"
		local_contain_master=true
	fi

	if [[ "${remote_contain_origin}" == "true" && "${local_contain_origin}" == "false" && \
	      "${remote_contain_master}" == "true" && "${local_contain_master}" == "true" ]]; then
		comm_echo "${repo} should pull"
		# 最好是在调用的地方要保证有修改的情况下不会冲突
		git pull origin master
		if [ $? -eq 0 ]; then
			comm_echo "${repo} pull成功"
			return 0
		fi
		comm_echo "${repo} pull失败"
	elif [[ "${remote_contain_origin}" == "true" && "${local_contain_origin}" == "true" && \
	      "${remote_contain_master}" == "false" && "${local_contain_master}" == "true" ]]; then
		comm_echo "${repo} should push"
		git push origin master
		comm_echo "${repo} push完成"
		return 0
	fi

	comm_echo "${repo}未push/pull，要手动处理"
	return 1
}

comm_check_repo() {
	local path=$1
	shift; local is_push_github=$1
	shift; local -n not_exist_repos_ref=$1
	shift; local -n not_clean_repos_ref=$1
	shift; local -n not_sync_repos_ref=$1
	shift; local -n gitee_ok_repos_ref=$1
	shift; local -n github_not_push_repos_ref=$1
	shift; local -n github_ok_repos_ref=$1

	local -n tmp_repos_ref
	local repo=$(basename "${path}")

	if [ ! -d "${path}" ]; then
		comm_echo "${repo}目录不存在"
		not_exist_repos_ref+=(${repo})
		return
	fi

	cd ${path}
	local status=$(git status -s) # git status -s --untracked-files=no

	local is_repo_clean=true
	if [ ! -z "${status}" ]; then
		echo -e "$(comm_red_color)${repo}$(comm_no_color) 有未提交的更改:"
		git status -s
		not_clean_repos_ref+=(${repo})
		is_repo_clean=false
	fi

	git fetch origin
	if [ $? -ne 0 ]; then
		echo "!!! ${repo} fetch fail !!!"
		exit
	fi

	local is_include_repo=${is_repo_clean} # 有未提交的更改，已经包含到not_clean_repos_ref
	local cmd_res=""
	comm_check_pull_push "${repo}"
	cmd_res=$?
	local is_repo_ok=${is_repo_clean}
	if [[ "${cmd_res}" == 0 ]]; then
		tmp_repos_ref=gitee_ok_repos_ref
	else
		tmp_repos_ref=not_sync_repos_ref
		is_include_repo=true # 未push/pull，即使有未提交，也包含到数组中
		is_repo_ok=false
	fi

	if [[ "${is_include_repo}" == "true" ]]; then
		comm_echo "${repo}被包含到数组中"
		tmp_repos_ref+=(${repo})
	fi

	comm_echo "is_push_github=${is_push_github}"
	if [[ "${is_push_github}" == 1 && "${is_repo_ok}" == true ]]; then
		comm_push_github_repo
		local push_github_result=$?
		if [[ "${push_github_result}" != 0 ]]; then
			github_not_push_repos_ref+=(${repo})
		else
			github_ok_repos_ref+=(${repo})
		fi
	fi
}

comm_print_array() {
	local array=("${!1}")
	local descriptions=("${@:2}")

	local len="${#array[@]}"
	if [ "${len}" -ne 0 ]; then
		echo -e "${descriptions[@]}"
	fi
}

print_result() {
	echo
	comm_print_array "not_exist_repos[@]" "$(comm_yellow_color)" "不存在的仓库:" "${not_exist_repos[@]}" "$(comm_no_color)"
	comm_print_array "gitee_ok_repos[@]" "$(comm_green_color)" "gitee全部搞定的仓库:" "${gitee_ok_repos[@]}"  "$(comm_no_color)"
	comm_print_array "github_ok_repos[@]" "$(comm_green_color)" "github全部搞定的仓库:" "${github_ok_repos[@]}"  "$(comm_no_color)"
	comm_print_array "not_clean_repos[@]" "$(comm_red_color)" "未提交的仓库:" "${not_clean_repos[@]}" "$(comm_no_color)"
	comm_print_array "not_sync_repos[@]" "$(comm_red_color)" "未push/pull的仓库:" "${not_sync_repos[@]}" "$(comm_no_color)"
	comm_print_array "github_not_push_repos[@]" "$(comm_red_color)" "github未push的仓库:" "${github_not_push_repos[@]}" "$(comm_no_color)"
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
		gitee_ok_repos \
		github_not_push_repos \
		github_ok_repos
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
