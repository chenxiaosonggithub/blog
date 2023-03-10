[toc]

# vue

## 环境

下面以ubuntu22.04为例，说明vue.js的环境准备操作。

建议通过直接下载[二进制](https://nodejs.org/en/download/)安装nodejs。

当然也可以通过包管理器来安装node.js，但不建议，具体参考[nodesource](https://github.com/nodesource/distributions/blob/master/README.md)：
```shell
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt update -y
sudo apt-get install -y nodejs
```

vue.js的开源demo可以参考[vue-element-admin](https://github.com/PanJiaChen/vue-element-admin/blob/master/README.zh-CN.md)，最简单的模板是[vue-admin-template](https://github.com/PanJiaChen/vue-admin-template/blob/master/README-zh.md)。

```shell
git clone https://github.com/PanJiaChen/vue-element-admin.git
cd vue-element-admin
# 建议不要直接使用 cnpm 安装依赖，会有各种诡异的 bug。可以通过如下操作解决 npm 下载速度慢的问题
# 如果没法安装，可以选择在其他网络好的环境上（如国外的网络）先安装，然后再copy node_modules/ 目录
npm install --registry=https://registry.npm.taobao.org
# 如果运行 npm run dev 报错0308010C:digital envelope routines::unsupported，原因：node.js V17版本中最近发布的OpenSSL3.0, 而OpenSSL3.0对允许算法和密钥大小增加了严格的限制，可能会对生态系统造成一些影响，通过以下命令解决
export NODE_OPTIONS=--openssl-legacy-provider
npm run dev
```

按照提示，在浏览器中访问 http://localhost:9527/

## vue-element-admin

[教程](https://juejin.cn/post/6844903476661583880)
