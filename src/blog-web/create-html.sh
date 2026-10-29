blog_src_root=${MY_CODE_TOP_PATH}/blog # 博客源码仓库根目录

# 导入其他脚本
. ${blog_src_root}/src/blog-web/common-lib.sh

# 入口脚本已创建配置时直接共用；也保留带参数独立生成的用法。
if [ $# -gt 0 ]; then
	comm_create_params "$@" || exit 1
elif [ -z "${COMM_PARAMS_FILE:-}" ]; then
	comm_create_params || exit 1
fi

html_path=$(comm_get_param html_path) || exit 1
tmp_html_path=$(comm_get_param tmp_html_path) || exit 1
sign_html=$(comm_get_param sign_html) || exit 1
en_sign_html=$(comm_get_param en_sign_html) || exit 1
is_replace_ip=$(comm_get_param is_replace_ip) || exit 1
other_ip=$(comm_get_param ip_addr) || exit 1
is_change_perm=$(comm_get_param is_change_perm) || exit 1

. ${blog_src_root}/src/blog-web/array.sh

my_init() {
	mkdir -p ${html_path}
	rm -rf ${tmp_html_path}
	mkdir -p ${tmp_html_path}
}

my_exit() {
	rm ${html_path}/* -rf # 如果是git仓库，不删除.git
	mv ${tmp_html_path}/* ${html_path}
	rm ${tmp_html_path} -rf
}

copy_files() {
	local src_path=$1
	local dst_path=${src_path}
	local is_dst_dir=false
	if [ $# -ge 2 ]; then
		dst_path=$2
	fi
	if [ $# -ge 3 ]; then
		is_dst_dir=$3
	fi

	local src_full_path=${blog_src_root}/${src_path}
	local dst_full_path=${tmp_html_path}/${dst_path}
	local dst_dir_path=$(dirname "${dst_full_path}") # 上一级目录
	if [[ "${is_dst_dir}" == true ]]; then
		mkdir -p ${dst_full_path}
	else
		mkdir -p ${dst_dir_path}
	fi
	cp -rf ${src_full_path} ${dst_full_path}
}

copy_to_github_io() {
	# css样式
	cp ${blog_src_root}/src/blog-web/stylesheet.css ${tmp_html_path}/
	# 图片
	cp ${blog_src_root}/tmp/picture/ ${tmp_html_path}/picture -rf
	# godot
	cp ${blog_src_root}/tmp/gnu-linux/godot/ ${tmp_html_path}/ -rf
	# txt
	copy_files tmp/gnu-linux/btrfs/btrfs-forced-readonly-log.txt
	# smb3-posix-spec
	copy_files 'tmp/gnu-linux/smb/smb3-posix-spec/*.html' tmp/gnu-linux/smb/smb3-posix-spec/ true
}

# 局域网签名
update_lan_sign() {
	local sign_file=${tmp_html_path}/sign.html
	# 局域网的处理
	if [[ ${is_replace_ip} == true ]]; then
		comm_file_replace_ip ${sign_file} ${other_ip}
		# 内网主页
		sed -i 's/主页/内网主页/g' ${sign_file}
		# 在<ul>之后插入公网主页
		sed -i -e '/<ul>/a<li><a href="https://chenxiaosong.com/">公网主页: chenxiaosong.com</a></li>' ${sign_file}
		# 私有仓库的脚本更改签名
		bash ${blog_src_root}/../private-blog/script/update-sign.sh ${sign_file}
	fi
}

do_change_perm() {
	# 自定义输出目录不更改权限。
	if [ "${is_change_perm}" != true ]; then
		return
	fi
	comm_change_nginx_perm ${tmp_html_path}
}

my_init
comm_create_html_body ${blog_src_root}/src/blog-web/sign.md ${sign_html}
comm_create_html_body ${blog_src_root}/src/blog-web/en-sign.md ${en_sign_html}
update_lan_sign
comm_create_html comm_array[@] "${blog_src_root}" "${tmp_html_path}" "${sign_html}"
bash ${blog_src_root}/course/course.sh
copy_to_github_io
do_change_perm
my_exit
