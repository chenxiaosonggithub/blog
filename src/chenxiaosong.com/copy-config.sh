blog_path=/home/sonvhi/chenxiaosong/code/blog # 请替换为具体的路径
config_file=/etc/nginx/sites-enabled/default
rm ${config_file}
cp ${blog_path}/src/chenxiaosong.com/nginx-config ${config_file}
cat ${blog_path}/../private-blog/scripts/others-nginx-config > ${config_file}
