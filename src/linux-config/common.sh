array=(origin_xmodmap.txt xmodmap.txt vimrc emacs bash_profile gitconfig tmux.conf set_proxy.sh)

dst_dir=$1
if [ -z "$dst_dir" ]
then
	dst_dir=$HOME
fi

for element in ${array[@]}
do
	src=$PWD/config-files/$element
	dst=$dst_dir/.$element

	echo $src
	echo $dst
	rm $dst
	$cmd $src $dst
done
