blog_path=/home/sonvhi/chenxiaosong/code/blog # 请替换为具体的路径
config_file=/etc/nginx/sites-enabled/default
rm ${config_file}
ln -s ${blog_path}/src/chenxiaosong.com/nginx-config ${config_file}
