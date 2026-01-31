blog_path=/home/chenxiaosong/code/blog
. $blog_path/src/blog-web/repos.sh

clone_repos()
{
	local element_count="${#repos_array[@]}" # 总个数
	local count_per_line=2
	for ((index=0; index<${element_count}; index=$((index + ${count_per_line})))); do
		# is_push_github=${repos_array[${index}]}
		local repo=${repos_array[${index}+1]}
		if [ ! -d "$blog_path/$repo" ]; then
			git clone -o gitee git@gitee.com:chenxiaosonggitee/$repo.git
		fi
	done
}

cp_config_file()
{
	bash ${blog_path}/course/gnu-linux/src/config-file/cp-to-home.sh
}

fedora_physical()
{
	sudo dnf install -y ibus*wubi* openssh-server vim virt-manager git
	cp_config_file
	clone_repos
}


