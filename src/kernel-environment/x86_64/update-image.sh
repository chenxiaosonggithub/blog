# make olddefconfig -j8 && make bzImage -j8 && make modules -j8 && make modules_install INSTALL_MOD_PATH=mod -j8
# -append "quiet console=ttyS0 IP=192.168.122.2 root=/dev/vda1 rw kmemleak=on" \ # quiet: 不打印信息
kernel_version=x86_64-linux

qemu-system-x86_64 \
-enable-kvm \
-cpu host \
-smp 16 \
-m 4096 \
-kernel /home/sonvhi/chenxiaosong/code/$kernel_version/arch/x86/boot/bzImage \
-virtfs local,id=kmod_dev,path=/home/sonvhi/sonvhi/home/sonvhi/chenxiaosong/,readonly,mount_tag=9p,security_model=none \
-vga none \
-nographic \
-append "nokaslr console=ttyS0 root=/dev/vda rw kmemleak=on" \
-device virtio-scsi-pci \
-drive file=x86_64-bullseye.qcow2.updating,if=none,format=qcow2,cache=writeback,file.locking=off,id=root \
-device virtio-blk,drive=root,id=d_root \
-net nic,model=virtio,macaddr=00:11:22:33:44:55 \
-net bridge,br=virbr0 \
