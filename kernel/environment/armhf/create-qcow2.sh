array=(12)
image_type=armhf-bullseye
dst_path=$(pwd)/../../
idx=0

for element in ${array[@]}
do
	if [ ! -d "${dst_path}/${element}.${image_type}" ]
	then
		echo "*******************${element}.${image_type}: path do not exist************"
		exit 1
	fi
	rm ${dst_path}/${element}.${image_type}/image.qcow2 -rf
	qemu-img create -F qcow2 -b $(pwd)/${image_type}.qcow2 -f qcow2 ${dst_path}${element}.${image_type}/image.qcow2
	if [ $? -ne 0 ]
	then
		exit 1
	fi

	cp update-image.sh ${dst_path}/${element}.${image_type}/start.sh
	format_num=$(printf "%02d\n" ${element})
	sed -i "s/00:11:22:33:44:55/00:11:22:33:44:${format_num}/g" ${dst_path}/${element}.${image_type}/start.sh
	sed -i "s/${image_type}.qcow2.updating/image.qcow2/g" ${dst_path}/${element}.${image_type}/start.sh
	sed -i "s/tap55/tap${element}/g" ${dst_path}/${element}.${image_type}/start.sh
	sudo tunctl -t tap${element} -u sonvhi
	sudo brctl addif virbr0 tap${element}
	sudo ip link set tap${element} up # 激活
	idx=`expr ${idx} + 1`
done

echo "###############successful####################"
