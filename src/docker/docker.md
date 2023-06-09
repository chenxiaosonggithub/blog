[toc]

```shell
docker run --name workspace -itd -v /home/sonvhi/chenxiaosong:/home/sonvhi/chenxiaosong -w /home/sonvhi/chenxiaosong workspace-ubuntu:22.04 bash
docker run --name rm-workspace --rm -itd -v /home/sonvhi/chenxiaosong:/home/sonvhi/chenxiaosong -w /home/sonvhi/chenxiaosong workspace-ubuntu:22.04 bash

docker rm workspace # 删除容器
rm workspace-ubuntu\:22.04.tar
docker export workspace > workspace-ubuntu:22.04.tar
docker image rm workspace-ubuntu:22.04
cat workspace-ubuntu\:22.04.tar  | docker import - workspace-ubuntu\:22.04
```

支持中文：
```shell
apt install -y language-pack-zh-hans
apt install -y fonts-wqy-zenhei
apt install -y fonts-wqy-microhei
echo "export LANG=zh_CN.UTF-8" >> ~/.bashrc
echo "export LANGUAGE=zh_CN:zh" >> ~/.bashrc
echo "export LC_ALL=zh_CN.UTF-8" >> ~/.bashrc
source ~/.bashrc
```
