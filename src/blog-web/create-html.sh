. ~/.top-path
src_path=${MY_CODE_TOP_PATH}/blog # 替换为你的仓库路径
tmp_html_path=/tmp/blog-html-tmp # 临时的html文件夹，生成html完成后再重命名，防止生成html的过程中网站不能访问
html_path=/var/www/html
sign_html=${tmp_html_path}/sign.html
en_sign_html=${tmp_html_path}/en-sign.html
is_set_html_path=false # 是否指定html路径

is_replace_ip=$1
other_ip=$2
if [ $# -ge 3 ]; then
	html_path=$3
	echo "set html path ${html_path}"
	is_set_html_path=true
fi

# 导入其他脚本
. ${src_path}/src/blog-web/common-lib.sh
. ${src_path}/src/blog-web/array.sh

my_init() {
	mkdir -p ${html_path}
	rm -rf ${tmp_html_path}
	mkdir -p ${tmp_html_path}
	rm -rf $(comm_tmp_src_path)
	mkdir -p $(comm_tmp_src_path)
	mkdir -p $(comm_tmp_src_path)/tmp
	cp -rf ${src_path}/* $(comm_tmp_src_path)
	cp -rf ${src_path}/../tmp/* $(comm_tmp_src_path)/tmp/
	bash ${src_path}/course/course.sh
	comm_rm_private $(comm_tmp_src_path)
}

my_exit() {
	rm ${html_path}/* -rf # 如果是git仓库，不删除.git
	mv ${tmp_html_path}/* ${html_path}
	rm ${tmp_html_path} -rf
	rm -rf $(comm_tmp_src_path)
}

copy_files() {
	local path=$1

	local src_full_path=$(comm_tmp_src_path)/${path}
	local dst_full_path=${tmp_html_path}/${path}
	local dst_dir_path=$(dirname "${dst_full_path}")
	mkdir -p ${dst_dir_path}
	cp -rf ${src_full_path} ${dst_full_path}
}

copy_to_github_io() {
	# css样式
	cp $(comm_tmp_src_path)/src/blog-web/stylesheet.css ${tmp_html_path}/
	# 图片
	cp $(comm_tmp_src_path)/tmp/picture/ ${tmp_html_path}/picture -rf
	# godot
	cp $(comm_tmp_src_path)/tmp/godot/ ${tmp_html_path}/ -rf
	# txt
	copy_files tmp/btrfs/btrfs-forced-readonly-log.txt
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
		bash ${src_path}/../private-blog/script/update-sign.sh ${sign_file}
	fi
}

do_change_perm() {
	# 如果指定html路径，就不更改权限
	if [ ${is_set_html_path} = true ]; then
		return
	fi
	comm_change_nginx_perm ${tmp_html_path}
}

my_init
comm_create_sign ${src_path}/src/blog-web/sign.md ${sign_html}
comm_create_sign ${src_path}/src/blog-web/en-sign.md ${en_sign_html}
update_lan_sign
comm_create_html comm_array[@] $(comm_tmp_src_path) ${tmp_html_path} ${sign_html} ${is_replace_ip} ${other_ip}
copy_to_github_io
do_change_perm
my_exit
