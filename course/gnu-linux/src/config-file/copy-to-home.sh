dst_dir=$1
. /home/chenxiaosong/code/blog/src/blog-web/repos.sh
. /home/chenxiaosong/code/private-blog/script/repos.sh

array=(gitconfig set_proxy.sh origin_xmodmap.txt xmodmap.txt vimrc emacs bash_profile tmux.conf top-path)

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

do_copy()
{
	for element in ${array[@]}
	do
		local src=$PWD/$element
		local dst=$dst_dir/.$element

		echo $src
		echo $dst
		rm $dst
		cp $src $dst
	done

	update_gitconfig
}

do_copy

