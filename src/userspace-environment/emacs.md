这篇文章记录一下emacs环境以及我常用的emacs快捷键，更多的内容请查看emacs的教学文档和帮助文档。

# 安装与配置

我使用的配置文件[.emacs](https://gitee.com/chenxiaosonggitee/blog/blob/master/src/linux-config/config-files/emacs)。

```
M-x package-refresh-contents 刷新包存储库中可用的包内容
M-x package-list-packages 显示当前已安装的包和可用的包，安装需要的包，如evil（模拟vim）
```

如果你使用的是cscope插件来浏览代码，将[cscope-indexer](https://gitee.com/chenxiaosonggitee/cscope/blob/configure.chenxiaosong/contrib/xcscope/cscope-indexer)所在路径添加到PATH中。关于cscope的更多内容请查看[《vim编辑器》](http://chenxiaosong.com/linux/vim.html)。

如果你使用的是gtags插件（要先安装`apt install global -y`）来浏览代码，在配置文件中添加[xcscope.el](https://gitee.com/chenxiaosonggitee/cscope/blob/configure.chenxiaosong/contrib/xcscope/xcscope.el)所在的路径`(add-to-list 'load-path  "/your_path/cscope/contrib/xcscope")`。使用`gtags`命令生成索引文件，Linux内核代码使用`make gtags`生成索引文件。

# 常用快捷键

```
C-<chr>: ctrl和<chr>键同时按

M-<chr>: meta(alt)和<chr>键同时按，等效 ESC放开后再按<chr>

C-x     字符扩展。  C-x 之后输入另一个字符或者组合键。
M-x     命令名扩展。M-x 之后输入一个命令

字符界面启动： emacs -nw

退出： C-x C-c
取消： C-g
取消ESC： 再按两次ESC

下一屏： C-v
上一屏： M-v
滚动几行： C-u 8 C-v, C-u 8 M-v
光标所在行 中间-顶端-底端 切换： C-l

上下左右： C-p, C-n, C-b, C-f
移动单词： M-f, M-b
行头行尾： C-a, C-e
句头句尾： M-a, M-e
首行尾行： M-<, M->
重复： C-u 8, M-8
插入多个字符（插入8个*）： C-u 8 *

C-f 帮助文档： C-h k C-f

删除光标前后(注意<DEL>是Backspace)： <DEL>, C-d
删除前面后面单词： M-<DEL>, M-d
删除到行尾句尾： C-k（再次按删除换行符）, M-k
删除到行首： C-u 0 C-k

移除选择文字： C-@（C-<SPC>）移动光标后 C-w
复制选择文字： C-@ 移动光标后 M-w
召回yanking： C-y
召回以前的： M-y
撤销undo： C-/ 或 C-x u 或 C-_

寻找文件： C-x C-f
保存： C-x C-s

列出缓冲区： C-x C-b
选择缓冲区： C-x b
保存当前缓冲区： C-x C-s
保存多个缓冲区： C-x s
在列表中删除缓冲区： 标记为删除 d, 标记为保留 m, 删除 x

替换： M-% 或 M-x replace-string

恢复： M-x recover-file

切换模式： M-x text-mode, M-x fundamental-mode
查看主模式文档： C-h m
自动折行 auto fill 辅模式： M-x auto-fill-mode
设置行边界： C-x f
手动折行： M-q

向上向下搜索： C-r, C-s

关闭当前窗口： C-x 0
关闭其他窗格（只保留当前窗格）: C-x 1 
上下两个窗格： C-x 2
左右两个窗格： C-x 3
在其他窗格打开文件： C-x 4 C-f
其他窗格滚动： C-M-v, C-M-S-v
移到其他窗格： C-x o
创建关闭窗口： M-x make-frame, M-x delete-frame

递归编辑： 替换时又进行搜索
离开递归编辑： 3次ESC

帮助： C-h C-h 或 C-h ? 或 F1 F1 或 M-x help
命令名称： C-h c C-p
命令帮助： C-h k C-p
函数： C-h f previous-line
变量： C-h v
相关命令搜索（Command Apropos）： C-h a
手册： C-h i emacs使用手册 m emacs
emacs使用手册： C-h r

剪切矩形块： C-@ 选择后 C-x r k
粘贴矩形块： C-x r y
插入空格矩形块(向右移)： C-x r o
清除矩形块（变成空格）： C-x r c
插入文字（相当于vim的ctrl+v+大写i）: C-x r t

高亮： M-x highlight-regexp
取消高亮： M-x unhighlight-regexp

跳到指定行： M-g g

键盘宏： 
	开始录制： C-x (
	结束录制： C-x )
	重复：     C-u 8 C-x e

折叠： M-x 然后 hs-hide-all, hs-show-all, hs-hide-block, hs-show-block, hs-toggle-hidding

寻找括号的另一边（注意：开始的括号要在光标里，结束的括号要在光标前）： C-M-n, C-M-p

查看buffer所在目录： C-x C-d

补全： M-/

redo： C-g 后 再 C-/

模式： M-x c-mode, M-x fundamental-mode

折叠缩进(配合outline-minor-mode)： M-x c-mode, M-x evil-mode

复制到 clipboard： C-@ 选择后 M-x copy-rectange-to-register 选择寄存器值（如8），然后在一个新的空的窗格 M-x insert-register 选择寄存器值（如8），然后再全选复制到 clipboard （M-w）

evil 配置： M-x customize-group RET evil RET， 参考： https://evil.readthedocs.io/en/latest/settings.html
```

待确认的功能：
1. 临时切换成 tab键 插入空格，以及空格个数： 暂时通过复制上一行的方式来实现
