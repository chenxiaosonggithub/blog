# 用法:
#   1. 定义 tunnel_name 变量，填写网站上的隧道名称
#   2. 调用 do_ssh
#   3. 执行 bash common.sh

# tunnel_name=<填写网站上的隧道名称>
script_dir=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
cache_dir=$script_dir/cache/
cache_file=$cache_dir/cache-${tunnel_name}.txt
mkdir -p $cache_dir
. $cache_dir/account.txt

if [ -z "$email" ] && [ -z "$password" ]; then
	echo "请在account.txt中填写cpolar邮箱账号(email)和密码(password)"
	exit 1
fi
ssh_user=chenxiaosong # ssh用户名

is_cache_valid()
{
	if [[ -f "$cache_file" ]]; then
		. $cache_file
	fi
	if [ -n "$address" ] && [ -n "$port" ]; then
		ssh -p $port -o ConnectTimeout=5 -q $ssh_user@$address exit
		if [ $? == 0 ]; then
			echo "缓存的端口和地址可用"
			return 0
		fi
	fi
	echo "缓存的端口或地址无效，需要重新登录并解析"
	return 1
}

login_and_parse()
{
	local now_time=$(date +"%Y%m%d-%H%M%S") # 用于生成临时文件

	local csrf_token=$(curl -s 'https://dashboard.cpolar.com/login' | sed -n 's/.*name="csrf_token" value="\([^"]*\)".*/\1/p')
	# echo "${csrf_token}" | tee token-$now_time.txt

	curl 'https://dashboard.cpolar.com/login' \
	  -H 'Content-Type: application/x-www-form-urlencoded' \
	  --data-urlencode "login=$email" \
	  --data-urlencode "password=$password" \
	  --data-urlencode "csrf_token=$csrf_token" \
	  -c cookies-$now_time.txt

	curl -b cookies-$now_time.txt https://dashboard.cpolar.com/status > status-$now_time.html
	rm cookies-$now_time.txt

	# 获取隧道名称的下一行
	local tunnel_str=$(awk "/<td>$tunnel_name<\/td>/ { getline; print; exit }" "status-$now_time.html")
	rm status-$now_time.html
	local tunnel=$(echo "$tunnel_str" | grep -o '">tcp://[^<]*' | sed 's/">tcp:\/\///')
	if [ -z "$tunnel" ]; then
		echo "未找到隧道名称$tunnel_name"
		exit 1
	fi

	address=$(echo "$tunnel" | cut -d: -f1)
	port=$(echo "$tunnel" | cut -d: -f2)

	echo "address=$address" > $cache_file
	echo "port=$port"      >> $cache_file
}

do_ssh()
{
	ssh_cmd="ssh -t -p $port $ssh_user@$address"
	echo "$ssh_cmd"
	$ssh_cmd $@
}

if ! is_cache_valid; then
	login_and_parse
fi

# do_ssh # 定义 tunnel_name 变量后，取消注释就可以远程登录
