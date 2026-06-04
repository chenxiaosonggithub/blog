tunnel_name=tianyi # 隧道名称
script_dir=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
. $script_dir/common.sh

if [ $# -eq 1 ]; then
	# do_ssh ". eth-aorus.sh $@; exec bash -l"
	do_ssh ". eth-aorus.sh $@"
else
	do_ssh
fi

