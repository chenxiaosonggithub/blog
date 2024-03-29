array=(5 6)
image_type=`basename $(pwd)`
dst_path=$(pwd)/../../vm/
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
	gdb_port=`expr 5550 + $element`
	sed -i "s/10055/100${format_num}/g" ${dst_path}/${element}.${image_type}/start.sh
	sed -i "s/${image_type}.qcow2.updating/image.qcow2/g" ${dst_path}/${element}.${image_type}/start.sh
	echo "-drive file=nvme,if=none,format=raw,cache=writeback,file.locking=off,id=b_nvme_1 \\" >> ${dst_path}/${element}.${image_type}/start.sh
	echo "-device nvme,drive=b_nvme_1,serial=d_b_nvme_1 \\" >> ${dst_path}/${element}.${image_type}/start.sh
	echo "-gdb tcp::${gdb_port} \\" >> ${dst_path}/${element}.${image_type}/start.sh
done

echo "###############successful####################"
