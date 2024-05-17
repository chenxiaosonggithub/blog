if [ $# -ne 3 ]; then
    echo "Usage: $0 \${is_public_ip} \${repalace_ip} \${is_restart}"
    return
fi

is_public_ip=$1
repalace_ip=$2 # 内网要替换的ip
is_restart=$3

src_path=/home/sonvhi/chenxiaosong/code # 替换成你的仓库路径
dst_path=/var/www/html
config_file=/etc/nginx/sites-enabled/default

copy_public_config() {
    rm ${config_file}
    cp ${src_path}/blog/src/chenxiaosong.com/nginx-config ${config_file}
    cat ${src_path}/blog/../private-blog/scripts/others-nginx-config >> ${config_file}
}

copy_lan_config() {
    rm ${config_file}
    cp ${src_path}/blog/src/chenxiaosong.com/lan-nginx-config ${config_file}
}

restart_all() {
    echo "recreate html, restart service"
    copy_public_config
    bash ${src_path}/blog/src/chenxiaosong.com/create-html.sh
    # 部署在局域网
    if [ ${is_public_ip} = false ]; then
        bash ${src_path}/private-blog/scripts/create-html.sh
        find ${dst_path}/ -type f -name '*.html' -exec sed -i 's/chenxiaosong.com/'${repalace_ip}'/g' {} +
        find ${dst_path}/ -type f -name '*.html' -exec sed -i 's/https:\/\/'${repalace_ip}'/http:\/\/'${repalace_ip}'/g' {} +
        # 邮箱替换回来
        find ${dst_path}/ -type f -name '*.html' -exec sed -i 's/chenxiaosong@'${repalace_ip}'/chenxiaosong@chenxiaosong.com/g' {} +
        copy_lan_config
        sed -i 's/chenxiaosong.com/'${repalace_ip}'/g' /etc/nginx/sites-enabled/default
    fi
    iptables -F # 根据情况决定是否要清空防火墙规则
    service nginx restart # 重启nginx服务，docker中不支持systemd
}

update_others_blog() {
    # 如果是局域网ip，就不更新其他人的博客
    if [ ${is_public_ip} = false ]; then
        return
    fi
    bash ${src_path}/private-blog/scripts/update-others-blog.sh ${is_restart}
}

restart_all
update_others_blog
