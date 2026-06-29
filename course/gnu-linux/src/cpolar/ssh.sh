script_dir=$(dirname "$(realpath "${BASH_SOURCE[0]}")")

case "$1" in
1)
	bash $script_dir/aorus-ssh.sh aorus pm
	;;
2)
	bash $script_dir/aorus-ssh.sh code
	;;
3)
	bash $script_dir/aorus-ssh.sh build
	;;
4)
	bash $script_dir/aorus-ssh.sh qemu01
	;;
5)
	bash $script_dir/aorus-ssh.sh qemu02
	;;
*)
	echo "用法: bash $0 <1~5>"
	;;
esac
	
