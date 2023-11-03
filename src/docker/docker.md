[点击这里跳转到陈孝松个人主页:chenxiaosong.com](http://chenxiaosong.com/)。

这篇文章就是记录一些常用的docker操作命令，方便后续查阅。

# 安装docker

参考[Install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)

安装步骤如下：
```sh
sudo apt-get remove docker docker-engine docker.io containerd runc -y
sudo apt-get update -y
sudo apt-get install ca-certificates curl gnupg lsb-release -y
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://repo.huaweicloud.com/docker-ce/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://repo.huaweicloud.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
```

配置docker权限：
```sh
sudo cat /etc/group | grep docker # 如果没有则创建 sudo groupadd docker
groups | grep docker
# sudo gpasswd -a sonvhi docker # 或者使用usermod
sudo usermod -aG docker $USER
su - $USER # 或退出shell重新登录, 但在tmux中不起作用
```

# 镜像和容器

以下是一些常用命令：
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

# 根据镜像启动容器
# -i: 交互式操作
# -t: 终端
# -d: 后台运行
# --privileged: 以特权模式运行容器, 容器将拥有对主机系统硬件的完全访问权限, 如kvm
docker run --rm -v "$PWD":/usr/src/myapp -w /usr/src/myapp workspace-ubuntu:22.04 /bin/gcc -v # 执行命令后立刻删除容器
docker run --name workspace --hostname workspace -it -v /home/sonvhi/chenxiaosong:/home/sonvhi/chenxiaosong -w /home/sonvhi/chenxiaosong workspace-ubuntu:22.04 bash # 前台运行，停止后不删除容器
docker run --name rm-workspace --hostname rm-workspace --rm -itd -v /home/sonvhi/chenxiaosong:/home/sonvhi/chenxiaosong -w /home/sonvhi/chenxiaosong workspace-ubuntu:22.04 bash # 后台运行，停止后删除容器
docker exec -it workspace bash
docker exec -it rm-workspace bash

docker ps -a # 查看容器
docker stop workspace # 停止容器
rm workspace-ubuntu\:22.04.tar
docker export workspace > workspace-ubuntu:22.04.tar # 导出容器
docker rm workspace # 删除容器
docker ps -a # 查看容器
docker image rm workspace-ubuntu:22.04 # 删除镜像
docker image ls # 查看镜像
cat workspace-ubuntu\:22.04.tar | docker import - workspace-ubuntu\:22.04 # 导入镜像
```

docker中的ubuntu2204默认不支持中文，需要安装某些软件：
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
docker run -it -p 2223:22 ubuntu:22.04 bash # 只有 macos 才需要端口映射，linux不需要
apt update -y
apt install net-tools -y
apt install iputils-ping -y
apt install openssh-client -y
apt install openssh-server -y
vim /etc/ssh/sshd_config # PermitRootLogin prohibit-password 改为 PermitRootLogin yes
service ssh restart # docker 中不能使用 systemctl 启动 ssh
```

# macos

macos的docker要想与宿主机通信，要进行端口转发，启动时要加选项`-p 8888:8888`。
```shell
docker run -p 8888:8888 --name codeserver --hostname codeserver -it -v ${PWD}:/home/sonvhi/chenxiaosong -w /home/sonvhi/chenxiaosong codeserver-ubuntu:22.04 bash
docker run -p 8888:8888 --name rm-codeserver --hostname rm-codeserver --rm -itd -v ${PWD}:/home/sonvhi/chenxiaosong -w /home/sonvhi/chenxiaosong codeserver-ubuntu:22.04 bash
docker ps -a
docker stop codeserver
rm codeserver-ubuntu\:22.04.tar
docker export codeserver > codeserver-ubuntu:22.04.tar
docker rm codeserver
docker ps -a
docker image rm codeserver-ubuntu:22.04
docker image ls
cat codeserver-ubuntu\:22.04.tar | docker import - codeserver-ubuntu\:22.04

docker exec -it rm-codeserver bash
```