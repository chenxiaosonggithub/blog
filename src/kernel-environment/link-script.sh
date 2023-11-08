base_image_path=/home/sonvhi/chenxiaosong/qemu-kernel/base_image

arch_array=(	x86_64		aarch64		arm32		armhf		i386		riscv64)
release_array=(	bullseye	bullseye	bullseye	bullseye	bullseye	ubuntu2204)

num=${#arch_array[@]}
idx=0
while(( $idx < $num ))
do
	dst_path=${base_image_path}/${arch_array[$idx]}-${release_array[$idx]}/create-qcow2.sh
	rm ${dst_path}
	ln -s ${PWD}/${arch_array[$idx]}/create-qcow2.sh ${dst_path}
	dst_path=${base_image_path}/${arch_array[$idx]}-${release_array[$idx]}/update-base.sh
	rm ${dst_path}
	ln -s ${PWD}/${arch_array[$idx]}/update-base.sh ${dst_path}
	idx=`expr ${idx} + 1`
done
