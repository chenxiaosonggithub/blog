dst_dir=$1

cmd="cp"
array=(gitconfig set_proxy.sh origin_xmodmap.txt xmodmap.txt vimrc emacs bash_profile tmux.conf top-path)

if [ -z "$dst_dir" ]
then
	dst_dir=$HOME
fi

for element in ${array[@]}
do
	src=$PWD/$element
	dst=$dst_dir/.$element

	echo $src
	echo $dst
	rm $dst
	$cmd $src $dst
done
