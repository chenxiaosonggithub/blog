dst_dir=$1
. /home/chenxiaosong/code/blog/src/blog-web/repos.sh
. /home/chenxiaosong/code/private-blog/script/repos.sh

cp_array=(gitconfig set_proxy.sh origin_xmodmap.txt xmodmap.txt vimrc emacs bash_profile tmux.conf)
ln_array=(/home/chenxiaosong/code/private-blog/agents/)

if [ -z "$dst_dir" ]
then
	dst_dir=$HOME
fi

update_gitconfig()
{
	local kernel_repo=(openeuler-kernel smb-kernel klinux-4.19 klinux kfocal linux stable)

	echo "[safe]" >> ~/.gitconfig

	local element_count="${#repos_array[@]}" # 总个数
	local count_per_line=2
	for ((index=0; index<${element_count}; index=$((index + ${count_per_line})))); do
		local is_push_github=${repos_array[${index}]}
		local repo=${repos_array[${index}+1]}
		echo -e "\tdirectory = /home/chenxiaosong/code/$repo" >> ~/.gitconfig
	done

	for repo in ${kernel_repo[@]}
	do
		echo -e "\tdirectory = /home/chenxiaosong/code/$repo" >> ~/.gitconfig
	done
}

deploy_file()
{
	local element="$1"
	shift
	local base_path=$(basename "$element")
	local src="$element"
	local dst=$dst_dir/.$base_path

	if [[ "$element" != /* ]]; then
		src=$PWD/$element
	fi

	echo "$src"
	echo "$dst"
	rm "$dst"
	"$@" "$src" "$dst"
}

do_copy()
{
	for element in "${cp_array[@]}"
	do
		deploy_file "$element" cp
	done

	update_gitconfig
}

do_link()
{
	for element in "${ln_array[@]}"
	do
		deploy_file "$element" ln -s
	done
}

do_copy
do_link

