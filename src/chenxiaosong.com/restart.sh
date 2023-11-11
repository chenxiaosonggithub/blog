src_path=/home/sonvhi/chenxiaosong/code/
dst_path=/var/www/
repalace_ip=172.20.26.131

cd ${src_path}pictures/
git pull origin master
cd ${src_path}blog/
git pull origin master
cd ${HOME}

bash ${src_path}blog/src/chenxiaosong.com/link.sh
bash ${src_path}blog/src/chenxiaosong.com/create-html.sh
# # 如果部署在局域网，替换成局域网ip
# find ${dst_path}html/ -type f -exec sed -i 's/chenxiaosong.com/'${repalace_ip}'/g' {} +
# # default文件本来是个软链接，执行完sed后变成了文件
# sed -i 's/chenxiaosong.com/'${repalace_ip}'/g' /etc/nginx/sites-enabled/default
# iptables -F # 根据情况决定是否要清空防火墙规则
service nginx restart
