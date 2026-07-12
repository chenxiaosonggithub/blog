script_dir=$(dirname "$(realpath "${BASH_SOURCE[0]}")")

case "$1" in
1)
	session="tianyi"
	bash $script_dir/tianyi-ssh.sh "
	export LC_ALL=en_US.UTF-8; \
	if tmux has-session -t $session 2>/dev/null; then \
		tmux att -t $session; \
	else \
		tmux new -t $session; \
	fi \
	"
	;;
2)
	bash $script_dir/aorus-ssh.sh aorus pm
	;;
3)
	bash $script_dir/aorus-ssh.sh code
	;;
4)
	bash $script_dir/aorus-ssh.sh build
	;;
5)
	bash $script_dir/aorus-ssh.sh qemu01
	;;
6)
	bash $script_dir/aorus-ssh.sh qemu02
	;;
*)
	echo "用法: bash $0 <1~5>"
	;;
esac
	
