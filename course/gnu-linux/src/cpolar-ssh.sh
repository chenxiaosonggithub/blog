email_account=<你的邮箱账号>
password=<你的密码>
tunnel_name=kylin # 隧道名称
ssh_user=chenxiaosong # ssh用户名

now_time=$(date +"%Y%m%d-%H%M%S") # 用于生成临时文件

csrf_token=$(curl -s 'https://dashboard.cpolar.com/login' | sed -n 's/.*name="csrf_token" value="\([^"]*\)".*/\1/p')
# echo "${csrf_token}" | tee token-$now_time.txt

curl 'https://dashboard.cpolar.com/login' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data-urlencode "login=$email_account" \
  --data-urlencode "password=$password" \
  --data-urlencode "csrf_token=$csrf_token" \
  -c cookies-$now_time.txt

curl -b cookies-$now_time.txt https://dashboard.cpolar.com/status > status-$now_time.html
rm cookies-$now_time.txt

# 获取隧道名称的下一行
tunnel_str=$(awk "/<td>$tunnel_name<\/td>/ { getline; print; exit }" "status-$now_time.html")
rm status-$now_time.html
tunnel=$(echo "$tunnel_str" | grep -o '">tcp://[^<]*' | sed 's/">tcp:\/\///')
if [ -z "$tunnel" ]; then
	echo "未找到隧道名称$tunnel_name"
	exit 1
fi

address=$(echo "$tunnel" | cut -d: -f1)
port=$(echo "$tunnel" | cut -d: -f2)
ssh_cmd="ssh -p $port $ssh_user@$address"

echo "$ssh_cmd"
$ssh_cmd

