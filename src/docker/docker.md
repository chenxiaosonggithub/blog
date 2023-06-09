[toc]

# 安装

https://docs.docker.com/engine/install/ubuntu/
https://repo.huaweicloud.com/docker-ce/linux/ubuntu/gpg
```shell

```shell
sudo apt-get remove docker docker-engine docker.io containerd runc -y
sudo apt-get update -y
sudo apt-get install ca-certificates curl gnupg lsb-release -y
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://repo.huaweicloud.com/docker-ce/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://repo.huaweicloud.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
sudo cat /etc/group | grep docker # 如果没有则创建 sudo groupadd docker
groups | grep docker
# sudo gpasswd -a sonvhi docker # 或者使用usermod
sudo usermod -aG docker $USER
su - $USER # 或退出shell重新登录, 但在tmux中不起作用

cp /etc/apt/sources.list /etc/apt/sources.list.bak
cp sources.list /etc/apt/sources.list # 替换镜像源
apt update -y
apt install build-essential -y
apt-get install libelf-dev libssl-dev -y # 内核源码编译依赖的库
apt install flex -y
apt install bison -y
strings /lib/x86_64-linux-gnu/libc.so.6 |grep GLIBC_
```

# 镜像和容器

```shell
docker pull ubuntu:22.04 # 下载镜像
docker image rm ubuntu:22.04 # 删除镜像
docker image ls # 查看镜像
docker ps -a # 查看容器
docker save xxxxxxxxxx > ubuntu-xxxx:22.04.tar # 保存镜像
docker container prune # 删除全部容器
docker restart xxxxxxx # 重启容器
docker attach xxxxxxxx # 退出后会导致容器停止
docker exec -it xxxxxxxx bash # 退出后不会导致容器停止

# 根据镜像启动容器, -i: 交互式操作, -t: 终端, -d: 后台运行
docker run --rm -v "$PWD":/usr/src/myapp -w /usr/src/myapp workspace-ubuntu:22.04 /bin/gcc -v # 执行命令后立刻删除容器
docker run --name workspace -itd -v /home/sonvhi/chenxiaosong:/home/sonvhi/chenxiaosong -w /home/sonvhi/chenxiaosong workspace-ubuntu:22.04 bash # 停止后不删除容器
docker run --name rm-workspace --rm -itd -v /home/sonvhi/chenxiaosong:/home/sonvhi/chenxiaosong -w /home/sonvhi/chenxiaosong workspace-ubuntu:22.04 bash # 停止后删除容器
docker exec -it workspace bash
docker exec -it rm-workspace bash

docker rm workspace # 删除容器
rm workspace-ubuntu\:22.04.tar
docker export workspace > workspace-ubuntu:22.04.tar # 导出容器
docker image rm workspace-ubuntu:22.04 # 删除镜像
cat workspace-ubuntu\:22.04.tar  | docker import - workspace-ubuntu\:22.04 # 导入镜像
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

ubuntu中默认不能以root登录，作如下更改：
```shell
# 需要注意的是 macos 中要进行端口映射，因为没有像 linux 中的 docker0 网络
docker run -it -p 2223:22 ubuntu:22.04 bash # 只有 macos 才需要，linux不需要，windows建议使用wsl2
apt update -y
apt install net-tools -y
apt install openssh-server -y
vim /etc/ssh/sshd_config # PermitRootLogin prohibit-password 改为 PermitRootLogin yes
service ssh restart # docker 中不能使用 systemctl 启动 ssh
```
