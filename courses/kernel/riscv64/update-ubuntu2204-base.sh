# https://ubuntu.com/download/risc-v, ubuntu-22.04.1-preinstalled-server-riscv64+unmatched.img
# qemu-img convert -p -f raw -O qcow2 riscv64-ubuntu2204.img riscv64-ubuntu2204.qcow2
qemu-system-riscv64 \
-machine virt -nographic -m 4096 -smp 4 \
-bios /usr/lib/riscv64-linux-gnu/opensbi/generic/fw_jump.elf \
-kernel /home/sonvhi/chenxiaosong/code/riscv-linux/build/arch/riscv/boot/Image \
-append "nokaslr root=/dev/vda1 rw console=ttyS0" \
-drive file=riscv64-ubuntu2204.qcow2.updating,format=qcow2,if=virtio \
-device virtio-net-device,netdev=net0 -netdev user,id=net0,host=10.0.2.10,hostfwd=tcp::10055-:22 \
