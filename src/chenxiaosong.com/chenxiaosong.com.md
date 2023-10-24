首先，欢迎各位朋友到[我的个人主页:chenxiaosong.com](http://chenxiaosong.com/)。

这篇文章记录一下我是如何搭建[我那个简陋的个人网站](http://chenxiaosong.com/)。各位朋友如果有更好的建议，请务必联系我。

# 域名和公网ip

首先，得先申请个域名，比如《你的名字.com》，可以在阿里云、腾讯云等平台注册申请。然后还要有一台有公网ip的服务器，我用的是阿里云的服务器。再把这个域名对应到这个公网ip上。

# nginx

Nginx（发音同「engine X」）是异步框架的网页服务器，也可以用作反向代理、负载平衡器和HTTP缓存。

ubuntu安装nginx:
```shell
apt install nginx -y
```

`vim /etc/nginx/sites-enabled/default`:
```shell

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

