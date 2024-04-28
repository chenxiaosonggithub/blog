# https://github.com/google/syzkaller/blob/master/docs/linux/setup_linux-host_qemu-vm_riscv64-kernel.md
# cp /home/sonvhi/chenxiaosong/code/buildroot-2022.02.1/output/images/rootfs.ext2 .
# qemu-img convert -p -f raw -O qcow2 rootfs.ext2 rootfs.ext2.qcow2
# ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- make Image
# ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- make modules_install INSTALL_MOD_PATH=mod
qemu-system-riscv64-latest \
-machine virt \
-nographic \
-bios /home/sonvhi/chenxiaosong/code/opensbi/build/platform/generic/firmware/fw_jump.bin \
-kernel /home/sonvhi/chenxiaosong/code/riscv64-linux/arch/build/riscv/boot/Image \
-append "root=/dev/vda rw console=ttyS0" \
-object rng-random,filename=/dev/urandom,id=rng0 \
-device virtio-rng-device,rng=rng0 \
-drive file=rootfs.ext2.qcow2,if=none,format=qcow2,id=hd0 \
-device virtio-blk-device,drive=hd0 \
-netdev user,id=net0,host=10.0.2.10,hostfwd=tcp::10022-:22 \
-device virtio-net-device,netdev=net0
