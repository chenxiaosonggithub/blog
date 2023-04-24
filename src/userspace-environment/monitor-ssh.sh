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
