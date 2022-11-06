[toc]

写文档，最爽的格式就是markdown。
以前我用的markdown编辑器是typora，但心里一直别扭着，因为typora是非自由非开源的软件。

最近尝试了几款自由开源的markdown编辑器，但都不够理想，不是功能不完善就是缺陷多。
最后决定使用[ghostwriter](https://wereturtle.github.io/ghostwriter/download.html)，这个markdown编辑器功能挺完善，但缺陷也不少。怎么办呢？我决定解决缺陷，完善她（没写错，就是她，很美）。

我刚解决了一个**严重的preview显示缺陷**，大家可以先使用源码安装。

[github源码](https://github.com/lioneie/ghostwriter.git)（forked from [wereturtle/ghostwriter](https://github.com/wereturtle/ghostwriter)）。

# Fedora下安装

ghostwriter是跨平台的，在Linux、macOS、Windows下都能运行，这里我只介绍Fedora（Linux）下的编译运行，其他平台请参考[README.md](https://github.com/lioneie/ghostwriter/blob/master/README.md)。

先安装Fedora下编译所需的软件：

```shell
sudo dnf install qt-devel qt5-qtbase-devel qt5-qtsvg-devel qt5-qtmultimedia-devel qt5-qtwebengine-devel hunspell-devel qt5-linguist -y
```

在[源码](https://github.com/lioneie/ghostwriter.git)目录下编译：
```shell
qmake-qt5
make
# 安装命令可不执行
#make install
```

运行软件：
```shell
cd build/release/
./ghostwriter
```

尽情的享受自由开源的ghostwriter吧！！！

# preview显示缺陷

前段时间（今天是2021.06.06）刚用ghostwriter时，一个很明显的preview显示缺陷摆在我面前：preview中文显示不完整，刚开始不想用她，但其他功能挺完善的，最后还是决定自己解决缺陷。

现在把这个缺陷介绍一下，也希望各位朋友能和我一起完善ghostwriter。

导致这个缺陷的[commit](https://github.com/lioneie/ghostwriter/commit/795de8ba2b3717e23543170c40f2dd2379530a33)：

```c
// src/cmarkgfmapi.cpp
-    cmark_parser_feed(parser, text.toLatin1().data(), text.length());
+    cmark_parser_feed(parser, text.toUtf8().data(), text.length());
```

定位到这个原因后，我修改成如下代码：

```c
// src/cmarkgfmapi.cpp
cmark_parser_feed(parser, text.toLatin1().data(), text.toLocal8Bit().length());
```

中文是Unicode编码，一个汉字占2个字节，而`QString.length()`一个汉字只当成一个字节，需要修改成`QString.toLocal8Bit().length()`。

你没看错，就是这么容易解决，参与到自由软件就是这么简单，参与到开源软件就是这么简单。
