[toc]

# nginx配置

```shell
apt install nginx -y
```

`vim /etc/nginx/sites-enabled/default`:
```shell
autoindex on; # 在 root /var/www/html 后添加

# 网页重定向
location /code-server {
    # permanent（永久） 或 redirect（临时）, 默认 redirect
    rewrite ^/code-server$ http://chenxiaosong.com:8888 redirect;
}

# 转发, 但对vue工程用npm run serve启动的服务无法正常访问
location /code-server/ { # 注意code-server后面有斜杠
        # 端口后面也要有斜杠
        proxy_pass http://127.0.0.1:8888/;
        # 不指定默认用1.0
        proxy_http_version 1.1;
        # 将客户端请求头中的 Upgrade 字段的值传递给后端服务器，常用于在进行 WebSocket 连接时，告知后端服务器进行协议升级
        proxy_set_header Upgrade $http_upgrade;
        # 设置了请求头中的 Connection 字段的值为 "upgrade"，它告诉后端服务器要升级连接协议
        proxy_set_header Connection "upgrade";
        # 设置了请求头中的 Host 字段的值为客户端请求中的 Host 值，它确保将客户端请求中的原始主机头信息传递给后端服务器
        proxy_set_header Host $host; # 如果是vue用npm run serve启动的服务，$host要替换成ip
}
```

```shell
service nginx restart # 在docker中
systemctl restart nginx
```

# pandoc

将markdown转换成html:
```shell
apt-get install pandoc -y
pandoc input.md -o index.html --from markdown --to html --standalone --metadata encoding=gbk --metadata title="陈孝松" --toc
```

