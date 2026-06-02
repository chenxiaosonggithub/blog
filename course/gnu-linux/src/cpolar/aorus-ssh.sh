tunnel_name=tianyi # 隧道名称
script_dir=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
. $script_dir/common.sh

if [ $# -ne 1 ]; then
	echo "用法: bash $0 <tmux session name>"
	exit 1
fi

do_ssh ". eth-aorus.sh $1; exec bash -l"

