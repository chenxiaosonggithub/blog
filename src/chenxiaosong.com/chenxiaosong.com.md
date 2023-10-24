首先，欢迎各位朋友到[我的个人主页:chenxiaosong.com](http://chenxiaosong.com/)。

这篇文章记录一下我是如何搭建[我那个简陋的个人网站](http://chenxiaosong.com/)。各位朋友如果有更好的建议，请务必联系我。

# 域名和公网ip

首先，得先申请个域名，比如《你的名字.com》，可以在阿里云、腾讯云等平台注册申请。然后还要有一台有公网ip的服务器，我用的是阿里云的服务器。再把这个域名对应到这个公网ip上。

注意默认的80端口要放开。

# nginx

Nginx（发音同「engine X」）是异步框架的网页服务器，也可以用作反向代理、负载平衡器和HTTP缓存。

ubuntu安装nginx:
```shell
apt install nginx -y
```
执行脚本[`src/chenxiaosong.com/link.sh`](https://github.com/chenxiaosonggithub/blog/blob/master/src/chenxiaosong.com/link.sh)将[`src/chenxiaosong.com/nginx-config`](https://github.com/chenxiaosonggithub/blog/blob/master/src/chenxiaosong.com/nginx-config)链接到`/etc/nginx/sites-enabled/default`，具体的配置选项的解释请查看配置文件的具体内容。

重启nginx服务：
```shell
service nginx restart # 在docker中
sudo systemctl restart nginx
```

# pandoc

pandoc用于将markdown转换成html。

安装：
```shell
apt-get install pandoc -y
```

具体的命令可以参考[`src/self-introduction/create-html.sh`](https://github.com/chenxiaosonggithub/blog/blob/master/src/self-introduction/create-html.sh)，脚本里写了详细的说明。



