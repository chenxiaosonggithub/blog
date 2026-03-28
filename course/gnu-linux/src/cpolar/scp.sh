if [ $# -ne 1 ]; then
	echo "用法: bash $0 <远程机器~/forVM目录中要复制的文件>"
	exit 1
fi

. /home/chenxiaosong/code/blog/course/gnu-linux/src/cpolar/common.sh
scp -P $port $ssh_user@$address:/home/chenxiaosong/forVM/$1 .
