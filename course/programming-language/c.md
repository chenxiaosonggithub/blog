# dump stack

```sh
apt install binutils -y
gcc -o dump-stack dump-stack.c -rdynamic
gcc -o dump-stack dump-stack.c -rdynamic -g # 如果有static函数要加-g
./dump-stack # #1 ./dump-stack(+0x12df) [0x625a07fc32df]
addr2line -e dump-stack 0x12df -f -p
```

