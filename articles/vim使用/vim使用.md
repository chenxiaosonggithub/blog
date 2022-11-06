编写本文档的目的是为了查找命令方便，也希望可以给同样喜爱vim的朋友一些参考。

本人使用的系统是Fedora。

至于vim最基础的知识，可以在shell下输入`vimtutor`命令查看，网上也有很多翻译的文档，请自行搜索。

# 联系方式

大家如果发现写错的地方或有一些想法想交流的，欢迎评论或发送邮件到<u>lioneie＠163.com</u>。

# vim配置

编辑配置文件 `vim ~/.vimrc` ，以下是我所使用的配置 ：

```
set number              "显示行号
syntax on               "语法高亮
set paste               "粘贴不自动缩进
set ruler               "右下角显示位置
set hlsearch            "搜索高亮
set fdm=indent          "indent缩进折叠，syntax语法折叠
set pastetoggle=<F9>    "F9粘贴设置切换
"set ts=4                "一个tab键等于4个空格宽度
"set sw=4                "按<键和>键缩进时，移动4个空格
"set expandtab           "tab转化为空格
set mouse-=a			"鼠标选择文字不会进入visual模式
colorscheme desert      "支持的color查看/usr/share/vim/vim82/colors/（vim82是vim版本）
set ic                  "set ic忽略大小写(ignore case), set noic 不忽略大小写
set cscopequickfix=a-,c-,d-,e-,f-,g-,i-,s-,t- "cscope打开quickfix窗口
```

加载其他的.vimrc，在~/.vimrc中加入以下内容：

`auto bufread      vim打开时所在的路径      so         .vimrc的路径/.vimrc` 

# vim快捷键

多文件查找：

```
:help vimgrep		（查看帮助文档）

:vimgrep /pattern/*		（当前目录下查找模式pattern）
:vimgrep /pattern/**	（当前目录和子目录下查找模式pattern）
:vimgrep /pattern/**/*	（子目录下查找模式pattern，不含当前目录）

:cn		（查找下一个）
:cp		（查找上一个）
:cw		（打开quickfix窗口）
```

多文件替换：

```
:args **/**				（打开当前目录和子目录下的所有文件）
:args **/*.c			（打开当前目录和子目录下的.c文件）
:args *					（打开当前目录下的所有文件）
:args *.c				（打开当前目录下的.c文件）
:args */*.c				（打开下一级目录下的.c文件，不含当前目录）

:argdo %s/old/new/gc | update	（old替换成new，需要确认，update表示自动保存）
```

查找：

```
*  	向后查找单词
#	向前查找单词
/\c		不区分大小写向后查找（向前查找用?）
/\<word\>	匹配头尾向后查找（向前查找用?）
```

替换：

```
:%s/old/new/gc
加g表示替换一行中的所有，不加g表示只替换一行中的第一个
加c表示需要确认，不加c表示不需要确认
加%表示替换所有行，不加%表示替换当前行

:n,ms/old/new/gc	（替换第n行到第m行）
省略n表示从当前行开始替换
m为$时表示最后一行
```

跳转（cscope提供的跳转快捷键查看[cscope](#cscope)）：

```
ctrl加]	ctags提供的跳转定义
:ts		显示定义列表
ctrl加t	ctags提供的跳回
gd	局部变量跳转
gf	跳到头文件
ctrl加o	后退跳转
ctrl加i	前进跳转
```

文件回车符设置：

```
:set ff?	（查看文件的回车符类型）
:set ff=unix	（设置为unix回车符）
:set ff=dos		（设置为dos回车符）
```

折叠：

```
zc zC zm zM	折叠
zo zO zr zR	展开
```

可视：

```
v	小写v按字符选择可视范围
V	大写V按行选择可视范围
ctrl+v	块选择可视范围
多行插入	ctrl+v按块选择多行然后按下大写i
```

其他操作：

```
撤销行	大写U
撤销10次	10u
不断重做	.(点号)
删除到行首	d^
删除到行尾	d$
选中可视范围后，按<键向前缩进，按>键向后缩进
不选中可视范围时，按两次<键向前缩进，按两次>键向后缩进
取消查找高亮	:nohlsearch (简写成noh)
大写J		将当前行和下一行合并
```
# ctags

安装ctags：`sudo dnf install ctags -y`。

使用`ctags -R`编译代码生成`tags`文件，在`tags`文件所在目录打开`vim`即可加载`tags`文件。

`ctrl加]`跳转定义，`:ts`显示定义列表，`ctrl加t`回退

加载tags文件	`:set tags+=文件路径/tags`

# cscope

安装cscope：`sudo dnf install cscope -y`。

将脚本文件[cscope_maps.vim](https://github.com/lioneie/csdn/blob/master/vim%E4%BD%BF%E7%94%A8/cscope_maps.vim)放到`~/.vim/plugin/`路径下，即可使用快捷键（快捷键种类查看 `:cs help`），如`:cs find s word`查找word引用可使用快捷键`ctrl加\加s`（按顺序依次按3个键）。

使用`cscope -Rqbk`（当需要包含`/usr/include`头文件时，不使用`-k`选项）编译代码生成`cscope.out`文件，在`cscope.out`文件所在目录打开`vim`即可加载`cscope.out`文件

# leaderf

TODO

# spacevim

TODO

# 浏览器插件vimium

我是自由软件狂热者，平时工作环境基本都是字符界面，在图形界面下也是用键盘代替鼠标，键盘使用的是自定义的HHKB（可用键盘移动鼠标光标）。在浏览器中搜索资料时，移动鼠标光标效率太低，可以使用浏览器插件vimium。

以自由软件浏览器firefox为例，说明vimium的安装和使用。

firefox浏览器 **Add-ons -> Extensions -> Find more add-ons -> Vimium-FF** 。

至于使用帮助，按 ? （问号）会弹出**Vimium Help**弹窗，可以查看快捷键的提示，基本和vim的使用一致。
