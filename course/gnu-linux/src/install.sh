if [ $# -ne 2 ]; then
	echo "用法: $0 <fedora/ubuntu> <physical/docker/vm>"
	exit 1
fi
distribution=$1
machine=$2

code_path=/home/chenxiaosong/code/
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
}

fedora_docker()
{
	sudo dnf group install development-tools -y
	sudo dnf -y install ncurses-devel clang llvm flex bison bc kmod pahole lld ccache openssl-devel openssl
	sudo dnf -y install vim emacs global tmux wget
	cd $code_path
	wget https://ftp.gnu.org/pub/gnu/global/global-6.6.14.tar.gz
	tar xvf global-6.6.14.tar.gz
	rm global-6.6.14.tar.gz -rf
}

case "$distribution-$machine" in
fedora-physical)
	fedora_physical
	;;
fedora-docker)
	fedora_docker
	;;
ubuntu-physical)
	ubuntu_physical
	;;
*)
	echo "Invalid argument: $distribution $machine"
	;;
esac

