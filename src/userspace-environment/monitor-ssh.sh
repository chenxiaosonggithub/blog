# 在 root 下执行 ssh-copy-id -p 55555 chenxiaosong.com
# 在 root 下执行本脚本 bash monitor-ssh.sh
while true
do
	ssh -p 55555 -o ConnectTimeout=1 -q sonvhi@hk.chenxiaosong.com exit
	if [ $? != 0 ]
	then
		echo `date` >> /home/sonvhi/chenxiaosong/tmpfs/ssh-monitor-fail.log
		systemctl restart ssh-reverse.service
	else
		echo `date` >> /home/sonvhi/chenxiaosong/tmpfs/ssh-monitor-success.log
	fi

	sleep 30
done
