[toc]

# vue

[vue-element-admin](https://github.com/PanJiaChen/vue-element-admin/blob/master/README.zh-CN.md)

[简单的模板](https://github.com/PanJiaChen/vue-admin-template/blob/master/README-zh.md)

[教程](https://juejin.cn/post/6844903476661583880)

建议通过直接下载[二进制](https://nodejs.org/en/download/)安装nodejs，以下是通过包管理器安装，不建议：
```shell
# ubuntu22.04安装nodejs, 参考: https://github.com/nodesource/distributions/blob/master/README.md
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
```

```shell
# 参考: https://github.com/PanJiaChen/vue-admin-template/blob/master/README-zh.md
git clone https://github.com/PanJiaChen/vue-admin-template.git
cd vue-admin-template
npm install --registry=https://registry.npm.taobao.org # 建议不要直接使用 cnpm 安装以来，会有各种诡异的 bug。可以通过如下操作解决 npm 下载速度慢的问题
# 报错0308010C:digital envelope routines::unsupported，原因：node.js V17版本中最近发布的OpenSSL3.0, 而OpenSSL3.0对允许算法和密钥大小增加了严格的限制，可能会对生态系统造成一些影响
export NODE_OPTIONS=--openssl-legacy-provider
npm run dev
```
