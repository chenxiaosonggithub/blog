# wine

[WineHQ - Run Windows applications on Linux, BSD, Solaris and macOS](https://www.winehq.org/), [Ubuntu WineHQ Repository - WineHQ Wiki](https://wiki.winehq.org/Ubuntu)，有些网络可能安装不了，可以尝试换个网络（也有可能是服务器出了问题，稍后再试试）。

可以尝试下载并直接运行免安装的[putty](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html)，`wine putty.exe`。

或者安装并运行[微信](https://pc.weixin.qq.com/?lang=en_US)，注意c盘的位置在`${HOME}/.wine/drive_c/`，`wine WeChatSetup.exe`安装后，先进入`cd "${HOME}/.wine/drive_c/Program Files/Tencent/WeChat/[3.9.9.43]"`（有空格），再运行`wine WeChat.exe`。

中文字体显示有问题，先安装`sudo apt install winetricks -y`，如果报错不能用，可以下载[源码文件](https://github.com/Winetricks/winetricks/blob/master/src/winetricks)到`/usr/bin/winetricks`，并执行`sudo chown root:root /usr/bin/winetricks`和`sudo chmod 755 /usr/bin/winetricks`，


https://zhuanlan.zhihu.com/p/136328910