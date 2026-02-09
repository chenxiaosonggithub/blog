# wireshark

## ppa

```sh
sudo install -m 0755 -d /etc/apt/keyrings
# https://launchpad.net/~wireshark-dev/+archive/ubuntu/stable
# https://keyserver.ubuntu.com/pks/lookup?fingerprint=on&op=index&search=0xA2E402B85A4B70CD78D8A3D9D875551314ECA0F0
sudo curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xa2e402b85a4b70cd78d8a3d9d875551314eca0f0" -o /etc/apt/keyrings/wireshark.asc
sudo chmod a+r /etc/apt/keyrings/wireshark.asc
sudo tee -a /etc/apt/sources.list <<'EOF'
deb [signed-by=/etc/apt/keyrings/wireshark.asc] https://ppa.launchpadcontent.net/wireshark-dev/stable/ubuntu focal main 
deb-src [signed-by=/etc/apt/keyrings/wireshark.asc] https://ppa.launchpadcontent.net/wireshark-dev/stable/ubuntu focal main
EOF

# 图形界面可能会出现弹框阻止，不要在另一台机器上远程安装，要在本机图形界面安装
sudo apt-get update -y
sudo apt search wireshark
sudo apt install -y wireshark
```

## 源码安装

参考:

- [wireshark INSTALL](https://chenxiaosong.com/src/tmp/gnu-linux/translation/wireshark/wireshark-INSTALL.html)
- [Building from source under UNIX or Linux](https://www.wireshark.org/docs/wsug_html_chunked/ChBuildInstallUnixBuild.html)

```sh
sudo bash ./tools/debian-setup.sh
```

注意麒麟桌面v10无法安装这些软件，因为软件依赖关系有问题。

