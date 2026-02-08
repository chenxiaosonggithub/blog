if [ $# -ne 2 ]; then
	echo "用法: $0 <fedora/ubuntu> <physical/docker/vm>"
	exit 1
fi
distribution=$1
machine=$2

top_path=/home/chenxiaosong
code_path=$top_path/code/
. ${code_path}/blog/src/blog-web/repos.sh
. ${code_path}/private-blog/script/repos.sh

clone_all_repos()
{
	local element_count="${#repos_array[@]}" # 总个数
	local count_per_line=2
	for ((index=0; index<${element_count}; index=$((index + ${count_per_line})))); do
		# is_push_github=${repos_array[${index}]}
		local repo=${repos_array[${index}+1]}
		if [ ! -d "$code_path/$repo" ]; then
			cd $code_path
			git clone -o gitee git@gitee.com:chenxiaosonggitee/$repo.git
		fi
	done
}

cp_config_file()
{
	cd ${code_path}/blog/course/gnu-linux/src/config-file
	bash cp-to-home.sh
}

tip_perm()
{
	echo
	echo "fedora如果安装了virt-manager请修改 /etc/group"
	echo "	libvirt:x:988:chenxiaosong (增加)"
	echo "ubuntu virt-manager使用前可以要先重启一下（应该也有办法不重启就能用），如果在远程操作可能有权限问题，但可通过以下方式解决:"
	echo "  sudo chown libvirt-qemu:kvm image.qcow2 # 在本地环境操作virt-manager会直接修改"
	echo
}

physical_common()
{
	cp_config_file
	clone_all_repos
	sudo chmod 700 /bin/systemctl
	echo "source /usr/share/bash-completion/completions/git" >> ~/.bashrc
	source ~/.bashrc

	echo "执行以下脚本复制脚本:"
	echo "  cp /home/chenxiaosong/code/tmp/gnu-linux/install/tianyi/* ~ # 10.42.20.206"
	echo "  cp /home/chenxiaosong/code/tmp/gnu-linux/install/aorus/* ~ # 10.42.20.210"
	echo "  cp /home/chenxiaosong/code/tmp/gnu-linux/install/chown-blog.sh ~"

	sudo cp /home/chenxiaosong/code/tmp/gnu-linux/install/smb.conf /etc/samba/
	echo "samba新增用户: sudo pdbedit -a -u $USER"
	echo "samba重启服务:"
	echo "  sudo systemctl restart smbd # ubuntu"
	echo "  sudo systemctl restart smb # fedora"
}

docker_common()
{
	cp /home/chenxiaosong/code/blog/course/kernel/src/build.sh /home/chenxiaosong/code/
	echo "source /usr/share/bash-completion/completions/git" >> ~/.bashrc
	source ~/.bashrc
	cp /home/chenxiaosong/code/tmp/gnu-linux/install/emacs.d/ ~/.emacs.d -rf
}

cfg_docker()
{
	sudo usermod -aG docker $USER
	sudo mkdir /etc/systemd/system/docker.service.d/
	sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf <<-'EOF'
[Service]
 Environment="HTTP_PROXY=http://10.42.20.206:7890/"
Environment="HTTPS_PROXY=http://10.42.20.206:7890/"
EOF
	sudo systemctl daemon-reload
	sudo systemctl restart docker
}

cfg_qemu()
{
	mkdir -p $top_path/qemu-kernel/bash-image/fedora
	mkdir -p $top_path/qemu-kernel/vm/1.fedora
	mkdir -p $top_path/qemu-kernel/vm/2.fedora
	cp $code_path/blog/course/kernel/src/x86_64/update-base.sh $top_path/qemu-kernel/bash-image/fedora
	cp $code_path/blog/course/kernel/src/x86_64/create-qcow2.sh $top_path/qemu-kernel/bash-image/fedora
	cp $code_path/tmp/gnu-linux/kernel/etc-qemu-ifup /etc/qemu-ifup
	sudo chmod 755 /etc/qemu-ifup
}

cfg_9p() {
	echo
	echo "virt-manager中以9p挂载家目录，设置权限:"
	echo "getfacl /home/chenxiaosong
# file: ../chenxiaosong
# owner: chenxiaosong
# group: chenxiaosong
user::rwx
user:libvirt-qemu:--x
group::r-x
mask::r-x
other::---"
	echo "# sudo setfacl -x u:libvirt-qemu /home/chenxiaosong # 删除user:libvirt-qemu:--x"
	echo "sudo setfacl -m u:libvirt-qemu:rwx /home/chenxiaosong # user:libvirt-qemu:rwx"
	echo "# sudo setfacl -m u:libvirt-qemu:x /home/chenxiaosong # 重新生成user:libvirt-qemu:--x"
	echo "sudo setfacl -m m:rwx /home/chenxiaosong # mask::rwx"
	echo "sudo setfacl -m g::rwx /home/chenxiaosong # group::rwx"
	echo "# sudo setfacl -m o::rwx /home/chenxiaosong # 这个不能设置，否则不能免密登录"
	echo
}

cfg_proxy()
{
	export  http_proxy=http://10.42.20.206:7890
	export https_proxy=http://10.42.20.206:7890
}

install_code_server()
{
	curl -fsSL https://code-server.dev/install.sh | sh
	sudo systemctl enable --now code-server@$USER
	echo "请修改 ${HOME}/.config/code-server/config.yaml, 当不需要密码时修改成auth: none"
	echo "然后再执行 sudo systemctl restart code-server@$USER"
	echo "浏览器输入http://localhost:8888（8888是config.yaml配置文件中配置的端口）"
}

fedora_physical()
{
	sudo dnf install -y ibus*wubi* openssh-server vim virt-manager git samba
	sudo systemctl enable sshd
	sudo systemctl restart sshd

	physical_common

	# 安装docker, 需要国外的网络
	cfg_proxy
	sudo dnf config-manager addrepo --from-repofile https://download.docker.com/linux/fedora/docker-ce.repo
	sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
	sudo systemctl enable --now docker
	cfg_docker
	echo "现在可以执行:"
	echo "	docker pull fedora:latest"
	echo "	docker tag fedora:latest raw-fedora:latest"
	echo "	docker tag fedora:latest workspace-fedora:latest"
	echo "	docker rmi fedora:latest (或 docker image rm fedora:latest)"
	echo "启动和更新镜像请查看以下两个脚本:"
	echo "	/home/chenxiaosong/code/blog/course/gnu-linux/src/start-docker.sh"
	echo "	/home/chenxiaosong/code/blog/course/gnu-linux/src/update-docker-image.sh"

	# cp /home/chenxiaosong/code/tmp/gnu-linux/install/aorus/* ~ # 10.42.20.210

	tip_perm
	install_code_server
}

ubuntu_physical()
{
	sudo apt-get update -y
	sudo apt install -y openssh-server net-tools git virt-manager vim tmux pm-utils samba virtiofsd cifs-utils wakeonlan vim-gtk3
	sudo apt install -y nginx pandoc jq apache2-utils
	sudo apt install bash-completion -y
	sudo systemctl enable ssh
	sudo systemctl restart ssh

	physical_common

	cfg_proxy
	sudo apt update -y
	sudo apt install ca-certificates curl -y
	sudo install -m 0755 -d /etc/apt/keyrings
	sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc # 可能要尝试多次
	sudo chmod a+r /etc/apt/keyrings/docker.asc
	sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF
	sudo apt update -y
	sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y # 最新版本
	cfg_docker
	echo "现在可以执行:"
	echo "	docker pull ubuntu:24.04"
	echo "	docker tag ubuntu:24.04 raw-ubuntu:24.04"
	echo "	docker tag ubuntu:24.04 workspace-ubuntu:24.04"
	echo "	docker rmi ubuntu:24.04 (或 docker image rm ubuntu:24.04)"
	echo "启动和更新镜像请参考以下两个脚本(需要修改docker_name和image_name):"
	echo "	/home/chenxiaosong/code/blog/course/gnu-linux/src/start-docker.sh"
	echo "	/home/chenxiaosong/code/blog/course/gnu-linux/src/update-docker-image.sh"

	tip_perm
	install_code_server
	# cfg_9p
}

fedora_docker()
{
	sudo dnf group install development-tools -y
	sudo dnf -y install ncurses-devel clang llvm flex bison bc kmod pahole lld ccache openssl-devel openssl
	sudo dnf -y install bridge-utils iptables dnsmasq net-tools
	sudo dnf -y install vim emacs global tmux wget ps ping
	sudo dnf install @virtualization -y
	sudo dnf install -y nginx pandoc jq httpd-tools
	sudo dnf install bash-completion -y

	if [ ! -d "$code_path/global-6.6.14" ]; then
		cd $code_path
		wget https://ftp.gnu.org/pub/gnu/global/global-6.6.14.tar.gz
		tar xvf global-6.6.14.tar.gz
		rm global-6.6.14.tar.gz -rf
	fi

	cfg_qemu
	cp_config_file
	docker_common
}

ubuntu_docker()
{
	apt-get update -y
	apt install -y sudo
	sudo apt install -y vim git build-essential qemu-system flex bison bc kmod pahole libelf-dev libssl-dev libncurses-dev zstd
	apt install bash-completion -y # 为了解决docker 中git不会自动补全
	sudo apt install -y nginx pandoc jq apache2-utils

	apt install -y language-pack-zh-hans fonts-wqy-zenhei fonts-wqy-microhei
	echo "export LANG=zh_CN.UTF-8" >> ~/.bashrc
	echo "export LANGUAGE=zh_CN:zh" >> ~/.bashrc
	echo "export LC_ALL=zh_CN.UTF-8" >> ~/.bashrc

	apt install -y net-tools iputils-ping openssh-client openssh-server
	sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/g" /etc/ssh/sshd_config
	service ssh restart # docker 中不能使用 systemctl 启动 ssh

	apt install bridge-utils iptables dnsmasq net-tools -y
	cfg_qemu
	cp_config_file

	docker_common
}

fedora_vm()
{
	# fedora 启动的时候等待: A start job is running for /dev/zram0，解决办法: 删除 zram 的配置文件
	mv /usr/lib/systemd/zram-generator.conf /usr/lib/systemd/zram-generator.conf.bak

	sudo dnf install -y git samba cifs-utils
	sudo dnf group install development-tools -y
	sudo yum install -y acl attr automake bc dbench dump e2fsprogs fio gawk gcc \
		gdbm-devel git indent kernel-devel libacl-devel libaio-devel \
		libcap-devel libtool liburing-devel libuuid-devel lvm2 make psmisc \
		python3 quota sed sqlite udftools  xfsprogs
	sudo yum -y install btrfs-progs exfatprogs f2fs-tools ocfs2-tools xfsdump xfsprogs-devel

	mkdir -p /home/chenxiaosong/code
	cd /home/chenxiaosong/code
	git clone https://gitee.com/chenxiaosonggitee/blog.git
	cd /home/chenxiaosong/code
	git clone https://git.kernel.org/pub/scm/fs/xfs/xfstests-dev.git
	cd /home/chenxiaosong/code/blog/course/gnu-linux/src/config-file
	bash cp-to-home.sh
	cd /home/chenxiaosong/code/blog/course/kernel/src/script
	command cp parse-cmdline.sh ~

	# samba
	command cp /home/chenxiaosong/code/blog/course/smb/src/test/smb.conf /etc/samba/
	command cp /home/chenxiaosong/code/blog/course/smb/src/samba-svr-setup.sh ~
	bash ~/samba-svr-setup.sh
	printf "1\n1\n" | pdbedit -a -u root # -a: 新增，这里的用户名必须是系统用户名（在/etc/passwd中有）

	# ksmbd
	command cp /home/chenxiaosong/code/blog/course/smb/src/ksmbd-svr-setup.sh ~
}

case "$distribution-$machine" in
fedora-physical)
	fedora_physical
	;;
fedora-docker)
	fedora_docker
	;;
fedora-vm)
	fedora_vm
	;;
ubuntu-physical)
	ubuntu_physical
	;;
ubuntu-docker)
	ubuntu_docker
	;;
*)
	echo "Invalid argument: $distribution $machine"
	;;
esac

