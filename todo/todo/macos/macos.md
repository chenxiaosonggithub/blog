[toc]

# 制作iso镜像

从 App Store 下载 macOS 安装程序(注意只能下载最新的)，或者从 Hackintosh 网站之类的网站下载。

使用以下命令：
```shell
# 具体大小可以查看 /Applications/Install macOS Ventura.app/Contents/SharedSupport/SharedSupport.dmg的大小，比这个文件稍微大一些
# 比如 SharedSupport.dmg 文件 12G, 大概需要 13.8G 的空间，如果空间不足，在使用 createinstallmedia 命令时会提示，重新生成更大的空间就可以
hdiutil create -o /tmp/Ventura -size 13G -volname Ventura -layout SPUD -fs JHFS+
hdiutil attach /tmp/Ventura.dmg -noverify -mountpoint /Volumes/Ventura
# 如果空间不够时，会提示
sudo /Applications/Install\ macOS\ Catalina.app/Contents/Resources/createinstallmedia --volume /Volumes/Catalina --nointeraction
# 执行完上面的命令后，挂载点文件夹名字变了
hdiutil detach /Volumes/Install macOS Ventura
# 不直接将 SharedSupport.dmg 转换为 iso，是为了确保镜像文件的兼容性和稳定性
hdiutil convert /tmp/Ventura.dmg -format UDTO -o ~/Desktop/Ventura # 自动添加 .cdr 后缀名
mv ~/Desktop/Ventura.cdr ~/Desktop/Ventura.iso
rm /tmp/Ventura.dmg
```

# 虚拟机安装

安装[VMware Fusion](https://www.vmware.com/cn/products/fusion/fusion-evaluation.html)，购买注册码, 支持正版。

"Macintosh HD"默认不是“APFS“文件系统，而且已格式化的文件系统只有80+G大小，需要在“磁盘工具”中”抹掉“重新格式化为APFS, 才能全部利用磁盘空间。
