[toc]

# 安装系统

从[网站](https://www.raspberrypi.org/software/operating-systems/#raspberry-pi-os-32-bit)下载“Raspberry Pi OS with desktop and recommended software”。

向SD卡烧录系统：
```shell
sudo dd bs=4M if=解压之后的img of=/dev/sdb
```

# 软件安装

```shell
# 解决git无法显示中文
git config --global core.quotepath false

# 安装五笔，需要重启
sudo apt-get update -y
sudo apt install ibus*wubi* -y

# 安装firefox
# sudo apt update -y
# sudo apt-get install iceweasel -y

sudo apt update -y
# 安装emacs
sudo apt install emacs -y
# 安装gvim
sudo apt install vim-gtk3 -y
```

```shell
chromium-browser --proxy-server="https=127.0.0.1:1080;http=127.0.0.1:1080;ftp=127.0.0.1:1080"
```

