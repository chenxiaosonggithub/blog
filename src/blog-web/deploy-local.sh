# 运行命令不断检查 while true; do bash deploy-local.sh; sleep 90; done
. /home/chenxiaosong/.bash_profile
blog_src_root=${MY_CODE_TOP_PATH}/blog # 替换为你的仓库路径
. ${blog_src_root}/src/blog-web/common-lib.sh

comm_create_params true "${1:-$(comm_defaut_local_ip)}" || exit 1
is_replace_ip=$(comm_get_param is_replace_ip) || exit 1
html_path=$(comm_get_param html_path) || exit 1

code_root=${MY_CODE_TOP_PATH} # 替换成你的仓库路径
config_file=/etc/nginx/sites-enabled/default

copy_config() {
	rm ${config_file}
	bash ${code_root}/blog/src/blog-web/create-nginx-404.sh
	mv ${code_root}/blog/src/blog-web/nginx-config.full ${config_file}
	if [ ${is_replace_ip} = true ]; then
		# 局域网删除ssl相关配置
		sed -i '/# ssl begin/,/# ssl end/d' ${config_file} # 只能按行为单位删除
	fi
}

restart_private() {
	# 部署在局域网
	if [ ${is_replace_ip} = true ]; then
		bash ${code_root}/private-blog/script/create-html.sh
	fi
}

restart_all() {
	echo "recreate html, restart service"
	copy_config
	bash ${code_root}/blog/src/blog-web/create-html.sh
	ls_array=( # index.html有内容的路径，需要生成ls.html
		""
		"en"
	)
	comm_generate_index "${html_path}" ls_array[@]
	restart_private
	iptables -F # 根据情况决定是否要清空防火墙规则
	service nginx restart # 重启nginx服务，docker中不支持systemd
}

restart_all
