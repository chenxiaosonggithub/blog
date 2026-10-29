# 运行命令不断检查 while true; do bash restart.sh; sleep 90; done
. /home/chenxiaosong/.bash_profile
blog_src_root=${MY_CODE_TOP_PATH}/blog # 替换为你的仓库路径
. ${blog_src_root}/src/blog-web/common-lib.sh

is_replace_ip=true # 是否要替换ip
other_ip="${1:-$(comm_defaut_local_ip)}" # 内网要替换的ip

comm_create_params "${is_replace_ip}" "${other_ip}"

code_path=${MY_CODE_TOP_PATH} # 替换成你的仓库路径

bash ${code_path}/blog/src/blog-web/do-restart.sh ${is_replace_ip} ${other_ip} true
