```sh
mount -t cifs -o compress,username=root,password=1 //192.168.53.210/test /mnt
dd if=/dev/zero of=/mnt/zeros.bin bs=1M count=10 conv=fsync status=progress
```
