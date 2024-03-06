# wine使用

- [WineHQ - Run Windows applications on Linux, BSD, Solaris and macOS](https://www.winehq.org/)
- [Ubuntu WineHQ Repository - WineHQ Wiki](https://wiki.winehq.org/Ubuntu)
- [Winetricks - WineHQ Wiki](https://wiki.winehq.org/Winetricks)

注意[Ubuntu WineHQ Repository - WineHQ Wiki](https://wiki.winehq.org/Ubuntu)中有这样一段话：

> 虽然Ubuntu提供了自己的Wine软件包，但这些软件包通常落后于最新版本。为了尽可能简化安装最新版本的Wine，WineHQ有自己的Ubuntu软件库。如果新版本的Wine出现问题，您还可以选择安装您想要的旧版本。WineHQ软件库仅提供AMD64和i386架构的软件包。如果您需要ARM版本，您可以使用Ubuntu提供的软件包。

有些网络可能安装不了，可以尝试换个网络（也有可能是服务器出了问题，稍后再试试），还有中间可能要再执行`sudo apt-get update -y`命令。

可以尝试下载并直接运行免安装的[putty](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html)，`wine putty.exe`。

或者安装并运行[微信](https://pc.weixin.qq.com/?lang=en_US)，注意c盘的位置在`${HOME}/.wine/drive_c/`，`wine WeChatSetup.exe`安装后，先进入`cd "${HOME}/.wine/drive_c/Program Files/Tencent/WeChat/[3.9.9.43]"`（有空格），再运行`wine WeChat.exe`。

中文字体显示有问题，先安装`sudo apt install winetricks -y`，如果报错不能用，可以下载[源码文件](https://github.com/Winetricks/winetricks/blob/master/src/winetricks)到`/usr/bin/winetricks`，并执行`sudo chown root:root /usr/bin/winetricks`和`sudo chmod 755 /usr/bin/winetricks`，但不知道搞什么东西，始终没法安装字体。

最好是安装ubuntu中文或麒麟系统，这样中文显示就默认没有问题。

# 源码安装wine

- [gitlab源码](https://gitlab.winehq.org/wine/wine)
- [Developers - WineHQ Wiki](https://wiki.winehq.org/Developers)

首先安装[Building Wine - WineHQ Wiki](https://wiki.winehq.org/Building_Wine)中`Satisfying Build Dependencies`一节提到的依赖，其中ubuntu安装debian一列的软件：
```sh
# 不确定源码安装是否要打开这个配置，但打开也不会出问题嘛
sudo dpkg --add-architecture i386
# Generally necessary
sudo apt install -y gcc-multilib gcc-mingw-w64 libasound2-dev libpulse-dev libdbus-1-dev libfontconfig-dev libfreetype-dev libgnutls28-dev libgl-dev libunwind-dev libx11-dev libxcomposite-dev libxcursor-dev libxfixes-dev libxi-dev libxrandr-dev libxrender-dev libxext-dev
# Needed for many applications
sudo apt install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libosmesa6-dev libsdl2-dev libudev-dev libvulkan-dev
# Rare or domain-specific
sudo apt install -y libcapi20-dev libcups2-dev libgphoto2-dev libsane-dev libkrb5-dev samba-dev ocl-icd-opencl-dev libpcap-dev libusb-1.0-0-dev libv4l-dev
```
注意以上命令只是我自己整理方便后续部署时查阅，如果你安装的话最好查看网页，因为我不确定是否会新增一些依赖，毕竟wine软件在不断的发展。

还有一些常用编译依赖项：
```sh
sudo apt install -y build-essential 
```

上面的开发依赖软件安装后，运行`./configure`后还是会报错或警告，根据报错或警告信息继续安装以下软件：
```sh
# 报错
sudo apt-get install -y flex bison
sudo apt-get install -y libx11-dev:i386 libfreetype-dev:i386

# 警告
sudo apt-get install -y gettext 
# sudo apt install -y libpcsclite-dev # 没用，还是报 libpcsclite not found, smart cards won't be supported.
## opengl，用 glxinfo | grep "OpenGL" 能看到输出，但安装完后还是会有告警信息：No OpenGL library found on this system. OpenGL and Direct3D won't be supported.
### 所以opengl的告警应该和以下软件无关，而是和i386相关的软件中的某个相关（不确定是哪个）
### sudo apt-get install -y mesa-utils libglu1-mesa-dev freeglut3 freeglut3-dev
## 加到audio组后，还是会有告警：No sound system was found. Windows applications will be silent.
sudo usermod -aG audio $USER
su - $USER
## i386相关
sudo apt-get install -y libxrender-dev:i386 libgnutls28-dev:i386 libvulkan-dev:i386 libxcursor-dev:i386 libxi-dev:i386 libxext-dev:i386 libxrandr-dev:i386 libxfixes-dev:i386 libxcomposite-dev:i386 libosmesa6-dev:i386 ocl-icd-opencl-dev:i386 libpcap-dev:i386 libdbus-1-dev:i386 libsane-dev:i386 libusb-1.0-0-dev:i386 libv4l-dev:i386 libgphoto2-dev:i386 libpulse-dev:i386 libudev-dev:i386 libsdl2-dev:i386 libcapi20-dev:i386 libcups2-dev:i386 libfontconfig-dev:i386 
sudo apt-get install -y libgstreamer1.0-dev:i386 libgstreamer-plugins-base1.0-dev:i386
### sudo apt install -y libwayland-dev libwayland-dev:i386 # 安装了还是报 Wayland 32-bit development files not found, the Wayland driver won't be supported.
## 本来是为了解决 libkrb5 32-bit development files not found (or too old), Kerberos won't be supported.
### 但安装会出错，所以不能安装这个软件
### sudo apt-get install -y libkrb5-dev:i386
## 本来是为了解决 libnetapi not found, Samba NetAPI won't be supported.
### 但安装后图形界面没了，所以不能安装这个软件
### sudo apt-get install -y samba-dev:i386
## 安装后图形界面没了，所以不能安装这个软件，其实这个软件并不需要
### sudo apt-get install -y libpcsclite-dev:i386
```