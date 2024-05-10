# 运行命令不断检查 while true; do bash restart.sh; sleep 90; done

is_public_ip=true # 是否公网的ip
repalace_ip=10.42.20.221 # 内网要替换的ip

src_path=/home/sonvhi/chenxiaosong/code # 替换成你的仓库路径
dst_path=/var/www/html

is_restart=false # 是否重新启动

# 更新git仓库代码
# $1: 仓库名， $2: 是否推送到github
update_repo() {
    # 如果是局域网ip，就不更新仓库
    if [ ${is_public_ip} = false ]; then
        is_restart=true
        return
    fi
    cd ${src_path}/${1}/
    timeout 20 git fetch origin # 最多20秒超时，有时会因为网络原因卡住
    local_head=$(git rev-parse HEAD)
    origin_head=$(git rev-parse origin/master)
    if [ "${local_head}" != "${origin_head}" ]; then
        timeout 20 git pull origin master
        is_restart=true
        if [ ${2} = true ]; then
            timeout 20 git push github master
        fi
    fi
    cd -
}

restart_all() {
    if [ ${is_restart} = true ]; then
        echo "recreate html, restart service"
        bash ${src_path}/blog/src/chenxiaosong.com/link-config.sh
        bash ${src_path}/blog/src/chenxiaosong.com/create-html.sh
        # 部署在局域网
        if [ ${is_public_ip} = false ]; then
            bash ${src_path}/private-blog/scripts/create-html.sh
            find ${dst_path}/ -type f -name '*.html' -exec sed -i 's/chenxiaosong.com/'${repalace_ip}'/g' {} +
            find ${dst_path}/ -type f -name '*.html' -exec sed -i 's/https:\/\/'${repalace_ip}'/http:\/\/'${repalace_ip}'/g' {} +
            # 邮箱替换回来
            find ${dst_path}/ -type f -name '*.html' -exec sed -i 's/chenxiaosong@'${repalace_ip}'/chenxiaosong@chenxiaosong.com/g' {} +
            # default文件本来是个软链接，执行完sed后变成了文件
            bash ${src_path}/blog/src/chenxiaosong.com/copy-private-config.sh
            sed -i 's/chenxiaosong.com/'${repalace_ip}'/g' /etc/nginx/sites-enabled/default
        fi
        iptables -F # 根据情况决定是否要清空防火墙规则
        service nginx restart # 重启nginx服务，docker中不支持systemd
    else
        echo "no change"
    fi
}

update_others_blog() {
    # 如果是局域网ip，就不更新其他人的博客
    if [ ${is_public_ip} = false ]; then
        return
    fi
    bash ${src_path}/private-blog/scripts/update-others-blog.sh
}

update_repo pictures ${is_public_ip} # 部署在公网服务器就推到github
update_repo blog ${is_public_ip} # 部署在公网服务器就推到github
restart_all
update_others_blog
