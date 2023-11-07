src_path=/home/sonvhi/chenxiaosong/code/
dst_path=/var/www/

cd ${src_path}pictures/
git pull origin master
cd ${src_path}blog/
git pull origin master
cd ${HOME}

sudo bash ${src_path}blog/src/chenxiaosong.com/link.sh
sudo bash ${src_path}blog/src/chenxiaosong.com/create-html.sh
# 如果部署在局域网，替换成局域网ip
# sudo find ${dst_path}html/ -type f -exec sed -i 's/chenxiaosong.com/172.20.26.131/g' {} +
# sudo sed -i 's/chenxiaosong.com/172.20.26.131/g' /etc/nginx/sites-enabled/default
# sudo iptables -F # 根据情况决定是否要清空防火墙规则
sudo systemctl restart nginx
