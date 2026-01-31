if [[ $1 == 1 ]]; then
	echo "set proxy"
	export  http_proxy=http://10.42.20.206:7890
	export https_proxy=http://10.42.20.206:7890
	echo "http_proxy=${http_proxy}"
	echo "https_proxy=${https_proxy}"
elif [[ $1 == 0 ]]; then
	echo "unset proxy"
	export http_proxy=
	export https_proxy=
elif [[ $1 == get ]]; then
	echo "http_proxy=${http_proxy}"
	echo "https_proxy=${https_proxy}"
else
	echo "wrong parameter"
fi
