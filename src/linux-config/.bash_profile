# Get the aliases and functions
# if [ -f ~/.bashrc ]; then
#         . ~/.bashrc
# fi

sw_path=/home/sonvhi/chenxiaosong/sw/
cscope_path=/home/sonvhi/chenxiaosong/code/cscope/contrib/xcscope/
re2c_path=/home/sonvhi/chenxiaosong/sw/re2c/bin/
qemu_path=/home/sonvhi/chenxiaosong/sw/qemu/bin/
autossh_path=/home/sonvhi/chenxiaosong/sw/autossh/bin/
nodejs_path=/home/sonvhi/chenxiaosong/sw/nodejs/bin/
dotnet_path=/home/sonvhi/chenxiaosong/sw/dotnet
# gcc_path=/home/sonvhi/chenxiaosong/sw/gcc/bin/
export GOROOT=/home/sonvhi/chenxiaosong/sw/go1.18.3.linux-amd64
export PATH=$GOROOT/bin:$cscope_path:$sw_path:$re2c_path:$qemu_path:$autossh_path:${nodejs_path}:$gcc_path:${dotnet_path}:$PATH

# 设置 terminal 标签名称， 用法： title tab name
function title() {
	if [[ -z "$ORIG" ]]; then
		ORIG=$PS1
	fi
	TITLE="\[\e]2;$*\a\]"
	PS1=${ORIG}${TITLE}
}

stty -ixon # 搜索历史命令，ctrl + s不锁屏
