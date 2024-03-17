源码安装之前，也建议先通过apt安装wine，安装完后运行环境就准备好了。

- [WineHQ - Run Windows applications on Linux, BSD, Solaris and macOS](https://www.winehq.org/)
- [Winetricks - WineHQ Wiki](https://wiki.winehq.org/Winetricks)

# 运行环境

x86_64下使能32位架构：
```sh
sudo dpkg --add-architecture i386
sudo apt-get update -y
```

aarch64下使能32位架构：
```sh
sudo dpkg --add-architecture armhf
sudo apt-get update -y
```

x86_64参考[Ubuntu WineHQ Repository - WineHQ Wiki](https://wiki.winehq.org/Ubuntu)，有些网络可能安装不了，可以尝试换个网络（也有可能是服务器出了问题，稍后再试试）。

aarch64用如下命令安装：
```sh
sudo apt install -y wine libwine
```

可以尝试下载并直接运行免安装的[putty](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html)，x86_64架构下执行`wine putty.exe`（下载x86_64版本），aarch64架构下执行`wine64 wine-arm64.exe`（下载arm64版本）。

x86_64下安装并运行[微信](https://pc.weixin.qq.com/?lang=en_US)，注意c盘的位置在`${HOME}/.wine/drive_c/`，`wine WeChatSetup.exe`安装后，先进入`cd "${HOME}/.wine/drive_c/Program Files/Tencent/WeChat/[3.9.9.43]"`（有空格），再运行`wine WeChat.exe`。

中文字体显示有问题，先安装`sudo apt install winetricks -y`，如果报错不能用，可以下载[源码文件](https://github.com/Winetricks/winetricks/blob/master/src/winetricks)到`/usr/bin/winetricks`，并执行`sudo chown root:root /usr/bin/winetricks`和`sudo chmod 755 /usr/bin/winetricks`，但不知道搞什么东西，始终没法安装字体。

最好是安装ubuntu中文或麒麟系统，这样中文显示就默认没有问题。

# 编译环境

- [gitlab源码](https://gitlab.winehq.org/wine/wine)
- [Developers - WineHQ Wiki](https://wiki.winehq.org/Developers)

首先安装[Building Wine - WineHQ Wiki](https://wiki.winehq.org/Building_Wine)中`Satisfying Build Dependencies`一节提到的依赖，其中ubuntu安装debian一列的软件：
```sh
# Generally necessary
sudo apt install -y gcc-mingw-w64 libasound2-dev libpulse-dev libdbus-1-dev libfontconfig-dev libfreetype-dev libgnutls28-dev libgl-dev libunwind-dev libx11-dev libxcomposite-dev libxcursor-dev libxfixes-dev libxi-dev libxrandr-dev libxrender-dev libxext-dev
# Needed for many applications
sudo apt install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libosmesa6-dev libsdl2-dev libudev-dev libvulkan-dev
# Rare or domain-specific
sudo apt install -y libcapi20-dev libcups2-dev libgphoto2-dev libsane-dev libkrb5-dev samba-dev ocl-icd-opencl-dev libpcap-dev libusb-1.0-0-dev libv4l-dev
```
注意以上命令只是我自己整理方便后续部署时查阅，如果你安装的话最好查看网页，因为我不确定是否会新增一些依赖，毕竟wine软件在不断的发展。

上面的开发依赖软件安装后，运行`./configure`后还是会报错或警告，根据报错或警告信息继续安装以下软件：
```sh
# 报错
sudo apt-get install -y flex bison gettext
sudo apt install -y libpcsclite-dev # x86_64下没用，还是报 libpcsclite not found, smart cards won't be supported.
sudo apt install -y libwayland-dev # 安装了还是报 Wayland 32-bit development files not found, the Wayland driver won't be supported.

## opengl，用 glxinfo | grep "OpenGL" 能看到输出，但安装完后还是会有告警信息：No OpenGL library found on this system. OpenGL and Direct3D won't be supported.
### 所以opengl的告警应该和以下软件无关，而是和i386相关的软件中的某个相关（不确定是哪个）
### sudo apt-get install -y mesa-utils libglu1-mesa-dev freeglut3 freeglut3-dev
```

## x86架构

```sh
sudo apt install -y gcc-multilib # i386
sudo apt-get install -y libx11-dev:i386 libfreetype-dev:i386
sudo apt-get install -y libxrender-dev:i386 libgnutls28-dev:i386 libvulkan-dev:i386 libxcursor-dev:i386 libxi-dev:i386 libxext-dev:i386 libxrandr-dev:i386 libxfixes-dev:i386 libxcomposite-dev:i386 libosmesa6-dev:i386 ocl-icd-opencl-dev:i386 libpcap-dev:i386 libdbus-1-dev:i386 libsane-dev:i386 libusb-1.0-0-dev:i386 libv4l-dev:i386 libgphoto2-dev:i386 libpulse-dev:i386 libudev-dev:i386 libsdl2-dev:i386 libcapi20-dev:i386 libcups2-dev:i386 libfontconfig-dev:i386 
sudo apt-get install -y libgstreamer1.0-dev:i386 libgstreamer-plugins-base1.0-dev:i386
sudo apt install -y libwayland-dev:i386 # 安装了还是报 Wayland 32-bit development files not found, the Wayland driver won't be supported.

# 以下软件不能安装，不能安装，不能安装，安装了你的系统就完了，写出来只是记录一下曾经尝试的过程
## 本来是为了解决 libkrb5 32-bit development files not found (or too old), Kerberos won't be supported.
### 但安装会出错，所以不能安装这个软件
### sudo apt-get install -y libkrb5-dev:i386
## 本来是为了解决 libnetapi not found, Samba NetAPI won't be supported.
### 但安装后图形界面没了，所以不能安装这个软件
### sudo apt-get install -y samba-dev:i386
## 安装后图形界面没了，所以不能安装这个软件，其实这个软件并不需要
### sudo apt-get install -y libpcsclite-dev:i386
```

## arm架构

```sh
sudo apt-get install -y libx11-dev:armhf libfreetype-dev:armhf
sudo apt-get install -y libxrender-dev:armhf libgnutls28-dev:armhf libvulkan-dev:armhf libxcursor-dev:armhf libxi-dev:armhf libxext-dev:armhf libxrandr-dev:armhf libxfixes-dev:armhf libxcomposite-dev:armhf libosmesa6-dev:armhf ocl-icd-opencl-dev:armhf libpcap-dev:armhf libdbus-1-dev:armhf libsane-dev:armhf libusb-1.0-0-dev:armhf libv4l-dev:armhf libgphoto2-dev:armhf libpulse-dev:armhf libudev-dev:armhf libsdl2-dev:armhf libcapi20-dev:armhf libcups2-dev:armhf libfontconfig-dev:armhf 
sudo apt-get install -y libgstreamer1.0-dev:armhf libgstreamer-plugins-base1.0-dev:armhf
sudo apt install -y libwayland-dev:armhf # 安装了还是报 Wayland 32-bit development files not found, the Wayland driver won't be supported.
sudo apt install -y clang lld
```

## 编译

再运行以下命令编译安装：
```sh
# wine源码在 wine-dirs/wine-source
cd wine-dirs/wine64-build/ # 先到64位编译目录
../wine-source/configure --enable-win64 --prefix=/你要安装的路径
make -j12 # 12换成你的cpu核数wine-dirs
make install -j12 # 这时还无法运行微信

cd ../wine32-build/ # 再到32位编译目录
# x86_64
PKG_CONFIG_PATH=/usr/lib32 ../wine-source/configure --with-wine64=../wine64-build --prefix=/你要安装的路径
# aarch64
../wine-source/configure --with-wine64=../wine64-build --prefix=/你要安装的路径
make -j12
make install -j12 # 这时可以运行微信了
```

# 编译后运行

aarch64下还要安装box软件，32位box安装参考[ptitSeb/box86/blob/master/docs/COMPILE.md](https://github.com/ptitSeb/box86/blob/master/docs/COMPILE.md)，64位box安装参考[ptitSeb/box64/blob/main/docs/COMPILE.md](https://github.com/ptitSeb/box64/blob/main/docs/COMPILE.md)。

aarch64下使用以下命令运行x86架构下的exe程序，注意`wine`是x86_64的Linux下编译出来的：
```sh
box64 wine putty.exe
box86 wine putty.exe
```

http://www.opensound.com/download.cgi

https://arcolinux.com/

https://github.com/utmapp/UTM



sudo apt install fonts-liberation fonts-wine glib-networking libpulse0 gstreamer1.0-plugins-good gstreamer1.0-x libaa1 libaom3 libasound2-plugins  libcaca0 libcairo-gobject2 libcodec2-dev libdav1d6 libdv4 libgdk-pixbuf-2.0-0 libgomp1 libgpm2 libiec61883-0 libjack-jackd2-0 libmp3lame0 libncurses6 libncursesw6 libnuma1 libodbc2 libproxy1v5 libraw1394-11 librsvg2-2 librsvg2-common libsamplerate0 libshine3 libshout3 libslang2 libsnappy1v5 libsoup2.4-1 libsoxr0 libspeex1 libspeexdsp1 libtag1v5 libtag1v5-vanilla libtwolame0 libva-drm2 libva-x11-2 libva2 libvdpau1 libvkd3d-shader1 libvkd3d1 libvpx7 libwavpack1 libwebpmux3 libx265-199 libxdamage1 libxvidcore4 libzvbi-common libzvbi0 mesa-va-drivers mesa-vdpau-drivers va-driver-all vdpau-driver-all vkd3d-compiler