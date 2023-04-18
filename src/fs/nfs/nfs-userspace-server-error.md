[toc]

mainline nfs server, 4.19 nfs client:
```shell
mount -t nfs -o vers=4.1 localhost:/s_test /mnt
rm /mnt/dir -rf && mkdir /mnt/dir

for ((i=1; i<=500; i++))
do
  nfs4_setfacl -a A:fdg:${i}:RX /mnt/dir
done

nfs4_getfacl /mnt/dir | wc

# if turn off the gro, can not reproduce
ethtool -K eth0 gro off # qemu can not turn off
ethtool -k eth0 | grep generic-receive-offload
```

```c
// 4.19
xs_tcp_data_receive
  mdelay(10)

// mainline
xs_stream_data_receive
  mdelay(10) // can not reproduce
```

```shell
277e4ab7d530 SUNRPC: Simplify TCP receive code by switching to using iterators
2b86e3aaf993 nfsd: eliminate an unnecessary acl size limit
```
