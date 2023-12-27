# 运行命令不断检查 while true; do bash restart.sh; sleep 90; done

src_path=/home/sonvhi/chenxiaosong/code # 替换成你的仓库路径
dst_path=/var/www
is_replace=false # 是否要替换ip
repalace_ip=172.20.23.55 # 内网要替换的ip
is_push_github=false # 是否要推送到github

is_restart=false

# 更新git仓库代码
update_repository() {
    cd ${src_path}/${1}/
    timeout 20 git fetch origin # 最多20秒超时，有时会因为网络原因卡住
    local_head=$(git rev-parse HEAD)
    origin_head=$(git rev-parse origin/master)
    if [ "${local_head}" != "${origin_head}" ]; then
        if [ ${is_push_github} = true ]; then
            timeout 20 git push github origin/master
            if [ $? = 0 ]; then
                git pull origin master # 一定成功
                is_restart=true
            fi
        else
            git pull origin master # 一定成功
            is_restart=true
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
        if [ ${is_replace} = true ]; then
            find ${dst_path}/html/ -type f -name '*.html' -exec sed -i 's/chenxiaosong.com/'${repalace_ip}'/g' {} +
            # default文件本来是个软链接，执行完sed后变成了文件
            sed -i 's/chenxiaosong.com/'${repalace_ip}'/g' /etc/nginx/sites-enabled/default
        fi
        iptables -F # 根据情况决定是否要清空防火墙规则
        service nginx restart # 重启nginx服务，docker中不支持systemd
    else
        echo "no change"
    fi
}

update_repository pictures
update_repository blog
restart_all