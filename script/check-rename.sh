. ~/.top-path
code_path=${MY_CODE_TOP_PATH}
MY_ECHO_DEBUG=0

# 导入其他脚本
. ${code_path}/blog/src/blog-web/common-lib.sh

# 检查参数
if [ $# -lt 2 ]; then
        echo "用法: bash $0 <仓库名> <重命名前的文件夹名（前后都不含/）>"
        exit 1
fi
rename_repo=$1
origin_dir=$2

prefix_str=""
if [[ "${rename_repo}" != "blog" ]]; then
	prefix_str="${rename_repo}/"
fi

bash ${code_path}/blog/script/grep.sh ${prefix_str}${origin_dir}
bash ${code_path}/blog/script/grep.sh /${rename_repo}/raw/master/${origin_dir}
bash ${code_path}/blog/script/grep.sh /${rename_repo}/blob/master/${origin_dir}
bash ${code_path}/blog/script/grep.sh /${rename_repo}/tree/master/${origin_dir}

