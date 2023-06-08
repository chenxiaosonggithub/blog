if [[ $1 == 1 ]]
then
	echo "set proxy"
	export http_proxy=http://localhost:1081
	export https_proxy=http://localhost:1081
elif [[ $1 == 0 ]]
then
	echo "unset proxy"
	export http_proxy=
	export https_proxy=
else
	echo "wrong parameter"
fi
