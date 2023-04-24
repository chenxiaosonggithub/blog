# 在 root 下执行 ssh-copy-id -p 55555 chenxiaosong.com
# 在 root 下执行本脚本 bash monitor-ssh.sh
while true
do
	ssh -p 55555 -q sonvhi@chenxiaosong.com exit
	if [ $? != 0 ]
	then
		echo "ssh fail"
		echo `date`
		systemctl restart ssh-reverse.service
	fi
	sleep 10
done
