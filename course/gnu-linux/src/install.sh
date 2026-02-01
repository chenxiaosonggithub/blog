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

tip_fedora_perm()
{
	echo
	echo "virt-manager可能要先在fedora本机上操作，如果远程在ubuntu上操作可能有权限问题"
	echo "如果安装了virt-manager请修改 /etc/group"
	echo "	qemu:x:107:chenxiaosong (增加)"
	echo "	libvirt:x:988:chenxiaosong (增加)"
	echo "	kvm:x:36:qemu (这个不用改)"
	echo
}

common_setup()
{
	cp_config_file
	clone_all_repos
	sudo chmod 700 /bin/systemctl
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

fedora_physical()
{
	sudo dnf install -y ibus*wubi* openssh-server vim virt-manager git
	# 安装docker, 需要国外的网络
	export  http_proxy=http://10.42.20.206:7890
	export https_proxy=http://10.42.20.206:7890
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

	common_setup
	tip_fedora_perm
}

ubuntu_physical()
{
	# todo: apt install
	common_setup

	echo "现在可以执行:"
	echo "	docker pull ubuntu:24.04"
	echo "	docker tag ubuntu:24.04 raw-ubuntu:24.04"
	echo "	docker tag ubuntu:24.04 workspace-ubuntu:24.04"
	echo "	docker rmi ubuntu:24.04 (或 docker image rm ubuntu:24.04)"
	echo "启动和更新镜像请参考以下两个脚本(需要修改docker_name和image_name):"
	echo "	/home/chenxiaosong/code/blog/course/gnu-linux/src/start-docker.sh"
	echo "	/home/chenxiaosong/code/blog/course/gnu-linux/src/update-docker-image.sh"
}

fedora_docker()
{
	sudo dnf group install development-tools -y
	sudo dnf -y install ncurses-devel clang llvm flex bison bc kmod pahole lld ccache openssl-devel openssl
	sudo dnf -y install bridge-utils iptables dnsmasq net-tools
	sudo dnf -y install vim emacs global tmux wget ps ping
	sudo dnf install @virtualization -y

	cd $code_path
	wget https://ftp.gnu.org/pub/gnu/global/global-6.6.14.tar.gz
	tar xvf global-6.6.14.tar.gz
	rm global-6.6.14.tar.gz -rf

	cfg_qemu
}

ubuntu_docker()
{
	apt-get update -y
	apt install -y sudo
	sudo apt install -y vim git build-essential qemu-system flex bison bc kmod pahole libelf-dev libssl-dev libncurses-dev zstd

	apt install -y language-pack-zh-hans fonts-wqy-zenhei fonts-wqy-microhei
	echo "export LANG=zh_CN.UTF-8" >> ~/.bashrc
	echo "export LANGUAGE=zh_CN:zh" >> ~/.bashrc
	echo "export LC_ALL=zh_CN.UTF-8" >> ~/.bashrc

	apt install -y net-tools iputils-ping openssh-client openssh-server
	# todo
	echo "修改 /etc/ssh/sshd_config # PermitRootLogin prohibit-password 改为 PermitRootLogin yes"
	service ssh restart # docker 中不能使用 systemctl 启动 ssh

	apt install bash-completion -y # 为了解决docker 中git不会自动补全
	echo "source /usr/share/bash-completion/completions/git" >> ~/.bashrc

	apt install bridge-utils iptables dnsmasq net-tools -y
	cfg_qemu

	source ~/.bashrc
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

