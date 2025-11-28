# 套接字

套接字接口（socket interface）是两台机器的进程间进行通信的一种方法。这里顺便提一下，Windows系统通过Windows Sockets技术规范（简称WinSock）实现套接字接口，套接字服务由`Winsock.dll`提供。

套接字（socket）是一种通信机制，让两台机器的开发工作可以跨网络进行。

[可以试试《Linux程序设计（第4版）》的代码例子](https://gitee.com/chenxiaosonggitee/tmp/tree/master/gnu-linux/book-src/beginning-linux-programming-4th-edition/780470147627-code-ch15/chapter15)。至于用户态的使用，这里就不介绍了，感兴趣的朋友可以查看《Linux程序设计（第4版）》和《UNIX环境高级编程（第3版）》，[点击这里从百度网盘下载pdf电子书](https://chenxiaosong.com/baidunetdisk)。

```sh
# fedora无法安装
apt install xinetd -y # debian
```

`/etc/xinetd.d/daytime`配置文件修改如下:
```sh
  disable         = no
```

重启服务
```sh
killall -HUP xinetd
```

# 网络设备驱动

参考《Linux设备驱动开发详解：基于最新的Linux 4.0内核》。

Linux网络设备程序的体系结构分为4层:

- 网络协议接口层: `dev_queue_xmit()`发送数据，`netif_rx()`接收数据。
- 网络设备接口层: 描述具体网络设备属性和操作的`struct net_device`。
- 设备驱动功能层: 通过`struct net_device_ops`中的`ndo_start_xmit()`启动发送操作，通过中断处理（如`dm9000_interrupt()`）触发接收操作，如`dm9000_rx()`完成数据包的生成及递交给上层。`netdev_priv()`获取私有数据。
- 网络设备与媒介层: 完成数据包发送和接收的物理实体，可以是虚拟的。

