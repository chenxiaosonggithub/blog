script_dir=$(dirname "$(realpath "${BASH_SOURCE[0]}")")

case "$1" in
1|2|3|4|5|6|7)
	bash "$script_dir/aorus-ssh.sh" "$1"
	;;
*)
	echo "用法: bash $0 <1~5>"
	;;
esac
	
