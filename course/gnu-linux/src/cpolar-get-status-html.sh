csrf_token=$(curl -s 'https://dashboard.cpolar.com/login' | sed -n 's/.*name="csrf_token" value="\([^"]*\)".*/\1/p')
echo "${csrf_token}" | tee token.txt
# 替换 YOUR_EMAIL 和 YOUR_PASSWORD 为实际账号
curl 'https://dashboard.cpolar.com/login' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data-urlencode "login=YOUR_EMAIL" \
  --data-urlencode "password=YOUR_PASSWORD" \
  --data-urlencode "csrf_token=$csrf_token" \
  -c cookies.txt
curl -b cookies.txt https://dashboard.cpolar.com/status > status.html