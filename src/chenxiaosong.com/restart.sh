# 运行命令不断检查 while true; do bash restart.sh; sleep 60; done

src_path=/home/sonvhi/chenxiaosong/code
dst_path=/var/www
repalace_ip=172.20.23.55

restart=false

update_repository() {
    cd ${src_path}/${1}/
    timeout 20 git fetch origin
    local_head=$(git rev-parse HEAD)
    origin_head=$(git rev-parse origin/master)
    if [ "${local_head}" != "${origin_head}" ]; then
        timeout 20 git pull origin master
        restart=true
    fi
    cd -
}

update_repository pictures
update_repository blog

add_common() {
    sed -i '/<\/header>/,/<\/body>/!d' /var/www/html/common.html
    sed -i '1d;$d' /var/www/html/common.html
    find ${dst_path}/html/ -type f -name '*.html' -exec sed -i -e '/<header/r /var/www/html/common.html' {} +
}

if [ ${restart} = true ]; then
    echo "recreate html, restart service"
    bash ${src_path}/blog/src/chenxiaosong.com/link.sh
    bash ${src_path}/blog/src/chenxiaosong.com/create-html.sh
    add_common
    # # 如果部署在局域网，替换成局域网ip
    # find ${dst_path}/html/ -type f -name '*.html' -exec sed -i 's/chenxiaosong.com/'${repalace_ip}'/g' {} +
    # # default文件本来是个软链接，执行完sed后变成了文件
    # sed -i 's/chenxiaosong.com/'${repalace_ip}'/g' /etc/nginx/sites-enabled/default
    # iptables -F # 根据情况决定是否要清空防火墙规则
    service nginx restart
else
    echo "no change"
fi
