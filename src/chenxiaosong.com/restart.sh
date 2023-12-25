# 运行命令不断检查 while true; do bash restart.sh; sleep 90; done

src_path=/home/sonvhi/chenxiaosong/code # 替换成你的仓库路径
dst_path=/var/www
repalace_ip=172.20.23.55 # 内网要替换的ip
is_replace=false # 是否要替换ip

is_restart=false

# 更新git仓库代码
update_repository() {
    cd ${src_path}/${1}/
    timeout 20 git fetch origin # 最多20秒超时，有时会因为网络原因卡住
    local_head=$(git rev-parse HEAD)
    origin_head=$(git rev-parse origin/master)
    if [ "${local_head}" != "${origin_head}" ]; then
        timeout 20 git pull origin master
        # timeout 20 git push github master
        if [ $? = 0 ]; then
            is_restart=true
        fi
    fi
    cd -
}

update_repository pictures
update_repository blog

add_common() {
    # 先去除common.html文件中其他内容
    sed -i '/<\/header>/,/<\/body>/!d' ${dst_path}/html/common.html # 只保留</header>到</body>的内容
    sed -i '1d;$d' ${dst_path}/html/common.html # 删除第一行和最后一行
    # 插入common.html整个文件
    # find ${dst_path}/html/ -type f -name '*.html' -exec sed -i -e '/<header/r ${dst_path}/html/common.html' {} + # 所有文件
    find ${dst_path}/html/ -type f -name '*.html' | grep -v ${dst_path}/html/index.html \
        | xargs sed -i -e '/<header/r '${dst_path}'/html/common.html' # 在/<header之后插入common.html整个文件, index文件除外
}

if [ ${is_restart} = true ]; then
    echo "recreate html, restart service"
    bash ${src_path}/blog/src/chenxiaosong.com/link.sh
    bash ${src_path}/blog/src/chenxiaosong.com/create-html.sh
    add_common
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
