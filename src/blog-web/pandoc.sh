blog_src_root=${MY_CODE_TOP_PATH}/blog # 替换为你的仓库路径
# 导入其他脚本
. ${blog_src_root}/src/blog-web/common-lib.sh

# 检查参数
if [ $# -ne 3 ]; then
	echo "用法: bash $0 <源文件> <输出文件> <标题>"
	exit 1
fi

do_pandoc() {
	local src_file=$1
	local dst_file=$2
	local html_title=$3
	local from_format="--from markdown"
	if [[ ${src_file} == *.rst ]]; then
		from_format="--from rst" # rst格式
	fi
	local pandoc_options="$(comm_get_pandoc_options) --toc"
	pandoc ${src_file} -o ${dst_file} --metadata title="${html_title}" ${from_format} ${pandoc_options}
}

do_pandoc $1 $2 $3

