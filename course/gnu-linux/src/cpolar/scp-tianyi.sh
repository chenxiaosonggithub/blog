if [ $# -ne 2 ]; then
	echo "用法: bash $0 <from/to> <文件名(远程机器~/forVM目录)>"
	exit 1
fi
from_or_to=$1

tunnel_name=tianyi # 隧道名称
script_dir=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
. $script_dir/common.sh

case $from_or_to in
from)
	scp -r -P $port $ssh_user@$address:/home/chenxiaosong/forVM/$2 .
	;;
to)
	scp -r -P $port $2 $ssh_user@$address:/home/chenxiaosong/forVM/
esac
