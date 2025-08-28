target_module=cifs # 修改成你要调试的模块名
ko_path=x86_64-build/fs/smb/client/cifs.ko # 修改成你要调试的模块ko路径，运行gdb命令的相对路径
text_addr=$(cat /sys/module/${target_module}/sections/.text)
data_addr=$(cat /sys/module/${target_module}/sections/.data)
bss_addr=$(cat /sys/module/${target_module}/sections/.bss)
echo "add-symbol-file ${ko_path} ${text_addr} -s .data ${data_addr} -s .bss ${bss_addr}"