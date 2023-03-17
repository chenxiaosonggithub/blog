作为程序员，使用google搜索当然是必不可少的，如果使用百度搜索在绝大多数情况下只会得到一些广告。

本文档的编写目的是为了下次重新搭建代理服务器时的查询。

v2ray的github项目为[v2ray-core](https://github.com/v2fly/v2ray-core)。

安装说明请参考[install.md](https://github.com/v2fly/manual/blob/master/zh_cn/chapter_00/install.md)。

配置文件参考[VMess-Websocket](https://github.com/v2fly/v2ray-examples/tree/master/VMess-Websocket)。

# v2ray服务器安装与配置

使用以下命令安装：

```shell
bash <(curl https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)
```

或下载编译好的安装包[v2ray-linux-64.zip](https://github.com/v2fly/v2ray-core/releases/download/v4.36.2/v2ray-linux-64.zip)。

将`/usr/local/etc/config.json`的内容替换成[config_server.json](https://github.com/v2fly/v2ray-examples/blob/master/VMess-Websocket/config_server.json)中的内容，并修改以下内容

```json
...
 "port": 55555,	// 如果出现突然无法访问或不稳定，可以尝试修改端口
...
 "id": "e04ff980-2736-4a2c-853a-43e21bbd6dea",		// 可自定义id
 "alterId": 64 // 客户端的值 <= 服务端的值, 两端都为64时无法使用(原因待分析)
...
```

修改完配置文件后，需要重启v2ray服务：

```shell
sudo systemctl restart v2ray
```

如果启动v2ray服务时报错，检查 `v2ray.service`文件：

```shell
[Service]
User=sonvhi # 修改成当前用户名
...
```

# linux系统客户端安装与配置

使用以下命令安装：

```shell
bash <(curl https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)
```

或下载编译好的安装包[v2ray-linux-64.zip](https://github.com/v2fly/v2ray-core/releases/download/v4.36.2/v2ray-linux-64.zip)。

将`/usr/local/etc/config.json`的内容替换成[config_client.json](https://github.com/v2fly/v2ray-examples/blob/master/VMess-Websocket/config_client.json)中的内容，并修改以下内容：

```json
...
        "address": "请填写服务器ip", // 服务器地址，请修改为你自己的服务器 ip 或域名
        "port": 55555,  // 服务器端口
        "users": [{ 
			"id": "e04ff980-2736-4a2c-853a-43e21bbd6dea",	// 与服务器id一样
...
```

修改完配置文件后，需要重启v2ray服务：

```json
sudo systemctl restart v2ray
```

我用的操作系统是Fedora，配置如下图所示（其他Linux发行版也大同小异）：

![fedora v2ray客户端配置](http://8.222.150.121/pictures/v2ray-fedora-config.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2xpb241NDQzMDE=,size_16,color_FFFFFF,t_70#pic_center)

# macOS系统客户端安装与配置

macOS系统的v2ray客户端的github项目为[Cenmrev/V2RayX](https://github.com/Cenmrev/V2RayX)，安装包为[V2RayX.app.zip](https://github.com/Cenmrev/V2RayX/releases/download/v1.5.1/V2RayX.app.zip)。

安装完成后的配置如下图：

![在这里插入图片描述](http://8.222.150.121/pictures/v2ray-macos-config.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2xpb241NDQzMDE=,size_16,color_FFFFFF,t_70#pic_center)

# Windows系统客户端安装与配置

sorry，我不用Windows系统。
