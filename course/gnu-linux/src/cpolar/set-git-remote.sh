if [ $# -ne 1 ]; then
	echo "用法: bash $0 <本地机器~/code中的仓库目录>"
	exit 1
fi
repo=$1

. /home/chenxiaosong/code/blog/course/gnu-linux/src/cpolar/common.sh

cd ~/code/$repo
git remote remove cpolar
git remote add cpolar ssh://$ssh_user@$address:$port/home/chenxiaosong/code/$repo

