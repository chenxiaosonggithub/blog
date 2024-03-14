这篇文章记录一下我是如何搭建[我那个简陋的个人网站](http://chenxiaosong.com/)。各位朋友如果有更好的建议，请务必联系我。

# 域名和公网ip

首先，得先申请个域名，比如《你的名字拼音全拼.com》，可以在阿里云、腾讯云等平台注册申请。然后还要有一台有公网ip的服务器，我用的是阿里云的服务器。再把这个域名对应到这个公网ip上。

注意默认的80端口要放开。

# 简陋的个人网站

## nginx

Nginx（发音同「engine X」）是异步框架的网页服务器，也可以用作反向代理、负载平衡器和HTTP缓存。

ubuntu安装nginx:
```sh
apt install nginx -y
```
执行脚本[`link.sh`](https://gitee.com/chenxiaosonggitee/blog/blob/master/src/chenxiaosong.com/link.sh)将[`nginx-config`](https://gitee.com/chenxiaosonggitee/blog/blob/master/src/chenxiaosong.com/nginx-config)链接到`/etc/nginx/sites-enabled/default`，具体的配置选项的解释请查看配置文件的具体内容。

重启nginx服务：
```sh
service nginx restart # 在docker中
sudo systemctl restart nginx
```

## pandoc

pandoc用于将markdown或rst（ReStructuredText）格式文件转换成html。

安装：
```sh
apt-get install pandoc -y
```

具体的命令可以参考[`create-html.sh`](https://gitee.com/chenxiaosonggitee/blog/blob/master/src/chenxiaosong.com/create-html.sh)，脚本里写了详细的说明。

## 脚本

[restart.sh](https://gitee.com/chenxiaosonggitee/blog/blob/master/src/chenxiaosong.com/restart.sh)脚本用于更新git仓库，重新生成html文件，以及重启nginx服务。运行命令`while true; do bash restart.sh; sleep 90; done`不断检查。

# 个人域名后缀的邮箱

是不是受够了在qq邮箱、foxmail邮箱、163邮箱名字已经被抢注了，只能在后面加一些乱七八糟的后缀。你有了域名，就可以拥有一个类似 @chenxiaosong.com 结尾的邮箱了。

首先，在[腾讯企业微信网站](https://work.weixin.qq.com/wework_admin/register_wx?from=exmail&bizmail_code=&wwbiz_version=free&wwbiz_merge=true)上注册一个你个人的企业微信。然后以管理员身份登录到[企业微信](https://work.weixin.qq.com/wework_admin/loginpage_wx)，可通过【管理后台->协作->邮件->概况->配置】中绑定专属域名。详细的操作步骤可参考[如何添加/更换/注销域名？](https://open.work.weixin.qq.com/help2/pc/19809?person_id=1)，温馨提醒：若域名历史没有绑定过邮箱使用且无需搬迁历史邮箱数据的，请选择左侧的【立即迁移】入口；反之，需要搬迁历史邮箱数据的，请选择【同步使用】入口迁移数据。

如果还是不知道怎么操作腾讯企业邮箱，请咨询企业微信客服。
