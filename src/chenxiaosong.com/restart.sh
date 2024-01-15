# 运行命令不断检查 while true; do bash restart.sh; sleep 90; done

is_public_ip=true # 是否公网的ip

src_path=/home/sonvhi/chenxiaosong/code # 替换成你的仓库路径
dst_path=/var/www/html
repalace_ip=172.20.23.55 # 内网要替换的ip

is_restart=false

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
        bash ${src_path}/blog/src/chenxiaosong.com/link.sh
        bash ${src_path}/blog/src/chenxiaosong.com/create-html.sh
        # 如果部署在局域网，替换成局域网ip
        if [ ${is_public_ip} = false ]; then
            find ${dst_path}/ -type f -name '*.html' -exec sed -i 's/chenxiaosong.com/'${repalace_ip}'/g' {} +
            # default文件本来是个软链接，执行完sed后变成了文件
            sed -i 's/chenxiaosong.com/'${repalace_ip}'/g' /etc/nginx/sites-enabled/default
        fi
        iptables -F # 根据情况决定是否要清空防火墙规则
        service nginx restart # 重启nginx服务，docker中不支持systemd
    else
        echo "no change"
    fi
}

do_extra_things() {
}

update_others_blog() {
    # 如果是局域网ip，就不更新其他人的博客
    if [ ${is_public_ip} = false ]; then
        return
    fi
    update_repo liujiayao false
    if [ ${is_restart} = true ]; then
        echo "update liujiayao"
        bash ${src_path}/liujiayao/src/create-html.sh
    fi
    update_repo fanglaijiu false
    if [ ${is_restart} = true ]; then
        echo "update fanglaijiu"
        bash ${src_path}/fanglaijiu/src/create-html.sh
    fi
}

update_repo pictures ${is_public_ip} # 部署在公网服务器就推到github
update_repo blog ${is_public_ip} # 部署在公网服务器就推到github
restart_all
do_extra_things
update_others_blog
