# git log

查看帮助文档`man 1 git log`：
```sh
       -L<start>,<end>:<file>, -L:<funcname>:<file>
           跟踪给定 <start>,<end> 或函数名正则表达式 <funcname> 所定义的行范围的演变，位于 <file> 内。您不可以提供任何路径规范限定符。目前此功能仅限于从单个修订版本开始的遍历，即您只能提供零个或一个正面修订参数，<start> 和 <end>（或 <funcname>）必须存在于起始修订版本中。您可以多次指定此选项。隐含--patch。可以使用 --no-patch 抑制补丁输出，但当前尚未实现其他差异格式（即 --raw、--numstat、--shortstat、--dirstat、--summary、--name-only、--name-status、--check）。

           <start> 和 <end> 可以采用以下形式之一：

           •   数字

               如果 <start> 或 <end> 是数字，则指定绝对行号（从 1 开始计数）。

           •   /正则表达式/

               此形式将使用与给定 POSIX 正则表达式匹配的第一行。如果 <start> 是正则表达式，则它将从前一个 -L 范围的末尾开始搜索，如果有的话，否则从文件开头开始搜索。如果 <start> 是 ^/正则表达式/，则它将从文件的开头开始搜索。如果 <end> 是正则表达式，则它将从由 <start> 给出的行开始搜索。

           •   +偏移量 或 -偏移量

               这仅对 <end> 有效，并将指定相对于由 <start> 给出的行之前或之后的行数。

           如果 :<funcname> 出现在 <start> 和 <end> 的位置，则它是一个正则表达式，表示从第一行与 <funcname> 匹配的 funcname 行开始，直到下一个 funcname 行。:<funcname> 从前一个 -L 范围的末尾开始搜索，如果有的话，否则从文件的开头开始搜索。^:<funcname> 从文件的开头开始搜索。函数名称的确定方式与 git diff 解析补丁块标题的方式相同（请参见 gitattributes(5) 中关于定义自定义块标题的说明）。
```

以内核主线代码[fs/namespace.c](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/namespace.c?id=8f6f76a6a29f)文件为例，查看`do_new_mount`函数：
```sh
git log -L :do_new_mount:fs/namespace.c
```

我们发现列出的却是`do_new_mount_fc`的修改记录，因为`do_new_mount_fc`包含字符串`do_new_mount`，又在`do_new_mount()`函数前面，解决方法是在`do_new_mount`后面再加个`\(`：
```sh
git log -L :do_new_mount\(:fs/namespace.c
```

# github给另一个账户添加另一个ssh key

如果我们有两个github账号，两个账号不能在网站上添加同一个ssh key，这时我们就要再生成一个ssh key，还要将ssh私钥添加到ssh代理：
```sh
ssh-keygen -t ed25519-sk -C "YOUR_EMAIL" # 生成新的key
eval "$(ssh-agent -s)" # 启动 SSH 代理
ssh-add ~/.ssh/id_ed25519 # 将 SSH 私钥添加到 SSH 代理
```
