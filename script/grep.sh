code_path=${MY_CODE_TOP_PATH}
MY_ECHO_DEBUG=0

# 导入其他脚本
. "${code_path}/blog/src/blog-web/common-lib.sh"

# 检查参数
if [ $# -lt 1 ]; then
        echo "用法: bash $0 <要查找的字符串>"
        exit 1
fi
string=$1

target_repo=""
if [ $# -eq 2 ]; then
	target_repo=$2
fi

grep_entry() {
	grep -rHnT -- "${string}" "$1"
}

. "${code_path}/blog/src/blog-web/repos.sh"
. "${code_path}/private-blog/script/repos.sh"

comm_for_each_repo_entry grep_entry "${target_repo}"

