# -append "quiet console=ttyS0 IP=192.168.122.2 root=/dev/vda1 rw kmemleak=on" \ # quiet: 不打印信息
kernel_version=i386-linux

qemu-system-i386-latest \
-enable-kvm \
-smp 8 \
-m 2048 \
-kernel /home/sonvhi/chenxiaosong/code/$kernel_version/build/arch/x86/boot/bzImage \
-virtfs local,id=kmod_dev,path=/home/sonvhi/chenxiaosong/,readonly,mount_tag=9p,security_model=none \
-vga none \
-nographic \
-append "console=ttyS0 root=/dev/vda rw kmemleak=on" \
-device virtio-scsi-pci \
-drive file=i386-bullseye.qcow2.updating,if=none,format=qcow2,cache=writeback,file.locking=off,id=root \
-device virtio-blk,drive=root,id=d_root \
-net nic,model=virtio,macaddr=00:11:22:33:44:55 \
-net bridge,br=virbr0 \
