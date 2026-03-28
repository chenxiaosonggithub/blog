if [ $# -ne 1 ]; then
	echo "用法: bash $0 <本地机器~/code中的仓库目录>"
	exit 1
fi
repo=$1

script_dir=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
. $script_dir/common.sh

cd ~/code/$repo
git remote remove cpolar
git remote add cpolar ssh://$ssh_user@$address:$port/home/chenxiaosong/code/$repo

