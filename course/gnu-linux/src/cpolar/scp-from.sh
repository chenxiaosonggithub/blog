if [ $# -ne 1 ]; then
	echo "用法: bash $0 <远程机器~/forVM目录中要复制的文件>"
	exit 1
fi

script_dir=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
. $script_dir/common.sh
scp -P $port $ssh_user@$address:/home/chenxiaosong/forVM/$1 .
