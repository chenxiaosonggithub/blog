if [ $# -ne 1 ]; then
	echo "用法: bash $0 <本地文件(复制到远程机器~/forVM目录中>"
	exit 1
fi

script_dir=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
. $script_dir/common.sh
scp -P $port $1 $ssh_user@$address:/home/chenxiaosong/forVM/
