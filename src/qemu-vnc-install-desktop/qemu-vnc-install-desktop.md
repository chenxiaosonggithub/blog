<!--
https://blog.csdn.net/u011795345/article/details/78681213
https://cloud.tencent.com/developer/article/2148538

virt-install --virt-type kvm --name kylin-desktop --vcpus=4 --ram 4096 --cdrom=Kylin-Desktop-V10-SP1-General-Release-2303-ARM64.iso --disk image.qcow2,format=qcow2 --network network=default --graphics vnc,listen=0.0.0.0,port=5955 --os-type=linux
-->

安装图形界面发行版时，要么在物理机上安装，要么在virt-manager上安装，如果我们想在没有图形界面的server环境上用命令行安装一个图形界面发行版，可以使用qemu+vnc来实现。下面我们以麒麟系统桌面发行版安装为例说明qemu+vnc的安装过程。

首先挂载iso文件，并把文件复制出来：
```sh
mkdir mnt
sudo mount Kylin-Desktop-V10-SP1-General-Release-2303-X86_64.iso mnt -o loop
mkdir tmp
cp mnt/. tmp/ -rf
sudo umount mnt
```

创建qcow2文件，并运行虚拟机：
```sh
qemu-img create -f qcow2 Kylin-Desktop-V10-SP1-General-Release-2303-X86_64.qcow2 512G
qemu-system-x86_64 \
-m 4096M \
-smp 16 \
-boot c \
-cpu host \
--enable-kvm \
-hda Kylin-Desktop-V10-SP1-General-Release-2303-X86_64.qcow2 \
-cdrom Kylin-Desktop-V10-SP1-General-Release-2303-X86_64.iso \
-kernel tmp/casper/vmlinuz \
-initrd tmp/casper/initrd.lz \
-vnc :1
```

vnc客户端可以使用ubuntu自带的Remmina（当然也可以使用其他vnc客户端），连接`${server_ip}:5901`，端口`5901`是由`-vnc :1`决定的（`5900 + 1`）。

安装完成后，再运行：
```sh
qemu-system-x86_64 \
-enable-kvm \
-cpu host \
-smp 16 \
-m 4096 \
-device virtio-scsi-pci \
-drive file=Kylin-Desktop-V10-SP1-General-Release-2303-X86_64.qcow2,if=none,format=qcow2,cache=writeback,file.locking=off,id=root \
-device virtio-blk,drive=root,id=d_root \
-net nic,model=virtio,macaddr=00:11:22:33:44:55 \
-net bridge,br=virbr0 \
-vnc :1
```

但arm64的麒麟桌面系统没法这样安装，暂时还没找到原因。

可以在arm芯片的mac电脑中用vmware fusion安装arm64的ubuntu。