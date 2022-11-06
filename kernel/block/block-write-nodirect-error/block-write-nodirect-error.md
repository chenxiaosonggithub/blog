[toc]

```shell
dd if=/dev/random of=file-expect bs=1048576 count=40
cp file-expect file
debugfs:  stat file        # (0-10239):45056-55295
dd if=file-expect of=3rd-right bs=1 skip=8192 count=4096
dd if=/dev/zero of=wrong-1page bs=1 count=4096

dd if=wrong-1page of=/dev/sda2 bs=1 seek=184557568 count=3 # 写第3个错误的页，45056 * 4096 + 8192
dd if=3rd-right of=/dev/sda2 bs=1 seek=184557568 count=4096 # 写第3个正确的页，45056 * 4096 + 8192

dd if=file-expect of=/dev/sda2 bs=4096 seek=45056 count=10240 # 把 file 重置, 全部正确

echo 3 > /proc/sys/vm/drop_caches
```
