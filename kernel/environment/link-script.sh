arch_array=(x86_64 aarch64 arm32 armhf i386)
release_array=(bullseye bullseye bullseye bullseye bullseye)

num=${#arch_array[@]}
idx=0
while(( $idx < $num ))
do
	dst_path=/home/sonvhi/chenxiaosong/qemu-kernel/base_image/${arch_array[$idx]}-${release_array[$idx]}/create-qcow2.sh
	rm ${dst_path}
	ln -s /home/sonvhi/chenxiaosong/code/blog/kernel/environment/${arch_array[$idx]}/create-qcow2.sh ${dst_path}
	dst_path=/home/sonvhi/chenxiaosong/qemu-kernel/base_image/${arch_array[$idx]}-${release_array[$idx]}/update-image.sh
	rm ${dst_path}
	ln -s /home/sonvhi/chenxiaosong/code/blog/kernel/environment/${arch_array[$idx]}/update-image.sh ${dst_path}
	idx=`expr ${idx} + 1`
done
