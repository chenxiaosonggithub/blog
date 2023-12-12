# https://github.com/google/syzkaller/blob/master/docs/linux/setup_linux-host_qemu-vm_arm-kernel.md
# sudo tunctl -t tap55 -u sonvhi
# sudo brctl addif virbr0 tap55
# sudo ip link set tap55 up # 激活
version=arm32-linux
kernel_path=/home/sonvhi/chenxiaosong/code/${version}

qemu-system-arm \
-m 1024 \
-smp 4 \
-net nic,macaddr=00:11:22:33:44:55,model=lan9118 \
-net tap,ifname=tap55,script=no \
-machine vexpress-a15 \
-dtb ${kernel_path}/arch/arm/boot/dts/vexpress-v2p-ca15-tc1.dtb \
-drive file=arm32-bullseye.qcow2.updating,if=none,cache=none,id=root,format=qcow2,file.locking=off \
-device sd-card,drive=root,id=d_root \
-kernel ${kernel_path}/build/arch/arm/boot/zImage \
-append "console=ttyAMA0 root=/dev/mmcblk0 rw kmemleak=on" \
-vga none \
-nographic \
