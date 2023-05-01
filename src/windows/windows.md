[toc]

# wsl

应用商店中安装wsl，打开`Turn Windows features on or off` 中的wsl

```shell
# 将WSL 2设置为默认版本
wsl --set-default-version 2
# 启用虚拟机平台功能
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```
重启电脑后，安装
```shell
# 要翻墙才能访问
wsl.exe --list --online
# 默认安装的位置：C:\Users\%username%\AppData\Local\Packages\CanonicalGroupLimited.Ubuntu22.04LTS_79rhkp1fndgsc
wsl.exe --install Ubuntu-22.04

# 其中的VERSION是指wsl的版本
wsl --list --verbose
# 正在运行的
wsl --list --running
# 卸载
wsl --unregister Ubuntu-22.04 # 不会删除数据
wsl --uninstall Ubuntu-22.04 # 删除数据

wsl --export Ubuntu-22.04 D:\chenxiaosong\wsl-backup\Ubuntu-22.04.tar
# wsl --import <发行版名称> <安装路径> <tar文件路径>
wsl --import Ubuntu-22.04 D:\chenxiaosong\wsl-install D:\chenxiaosong\wsl-backup\Ubuntu-22.04.tar

wsl --distribution Ubuntu-22.04 # 开机
wsl --shutdown Ubuntu-22.04 #关机
```

