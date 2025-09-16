. ~/.top-path
kernel_version=linux

read stty_rows stty_cols < <(stty size)
qemu-system-aarch64 \
-smp 8 \
-m 4096 \
-machine virt \
-cpu cortex-a72 \
-kernel ${MY_CODE_TOP_PATH}/$kernel_version/aarch64-build/arch/arm64/boot/Image \
--virtfs local,id=kmod_dev,path=${MY_CODE_TOP_PATH},security_model=none,mount_tag=9p \
-device virtio-scsi-pci \
-net nic,model=virtio,macaddr=00:11:22:33:44:55 \
-net tap \
-drive file=aarch64-bullseye.qcow2,if=none,cache=none,id=root,format=qcow2,file.locking=off \
-device virtio-blk,drive=root,id=d_root \
-append "nokaslr console=ttyAMA0 root=/dev/vda rw kmemleak=on kernel_version=${kernel_version} stty_rows=${stty_rows} stty_cols=${stty_cols}" \
-nographic \
