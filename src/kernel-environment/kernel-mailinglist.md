[点击这里跳转到陈孝松个人主页:chenxiaosong.com](http://chenxiaosong.com/)。

说到Linux内核，很多人可能会认为只有Linus这样的神才懂。但事实是任何人都能参与，比如我这样能力差的也参与到Linux内核社区了。

可能很多人早就想贡献Linux内核了，但就是不知道怎么开始。

# 1. 内核社区

Linux内核社区主要以邮件交流为主，以下是一些常用的网站。

[社区主页](https://www.kernel.org/)

[邮件列表](https://lore.kernel.org/)

[按模块划分的patchwork](https://patchwork.kernel.org/)

[bugzilla](https://bugzilla.kernel.org/)

[mainline仓库](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git)

[linux-next仓库](https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git)（速度慢）

[linux-next国内仓库](http://kernel.source.codeaurora.cn/pub/scm/linux/kernel/git/next/linux-next.git)

[Mainland China Mirror](https://kernel.source.codeaurora.cn/)

# 2. 修改内核代码

你可以通过[syzkaller测试](https://syzkaller.appspot.com/upstream)发现内核bug，也可以通过阅读内核代码发现bug或进行重构。

可以参考内核仓库中的补丁，或[我提交的补丁](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/log/?qt=grep&q=chenxiaosong)。

# 3. 生成patch文件

以下命令会生成补丁文件：
```shell
# 最后一次commit，next表示linux-next仓库（非必须）
git format-patch --subject-prefix="PATCH next" -1

# 指定commit号
git format-patch --subject-prefix="PATCH next" -1 commit号

# 如果是第2个版本或第3个版本，需要指定v2或v3
git format-patch --subject-prefix="PATCH next,v2" -1

# 如果内容不变，重新发送（比如加一个抄送的人）
git format-patch --subject-prefix="PATCH next,resend,v2" -1

# 从指定的commit号数向前3个，共生成3个补丁
git format-patch --subject-prefix="PATCH next,resend,v2" -3 commit号

# 生成补丁集
git format-patch --subject-prefix="PATCH next,resend,v2" -3 commit号 --cover-letter
# 编辑0000-cover-letter.patch, 可参考patchwork上其他补丁的写法
vim 0000-cover-letter.patch
```

# 4. 邮箱配置

## 4.1. 163邮箱配置

此处以163邮箱为例，说明邮箱的配置方法，其他邮箱类似。

默认情况下，163邮箱只能在网页和网易邮箱大师登录。如果要用git通过163邮箱发送邮件则需要对163邮箱进行配置。

在[pc端网页](mail.163.com)登录163邮箱，点击“设置 --> POP3/SMTP/IMAP”，开启SMTP服务，会弹出授权密码窗口，记下这个授权密码（也可以在下方新增授权密码或删除）。

## 4.2. foxmail邮箱（qq邮箱）配置

在[pc端网页](https://mail.qq.com/)登录foxmail邮箱，点击"Settings -> Third-party Services -> IMAP/SMTP", 点击"Generate Authorization Code"生成在`.gitconfig`和[thunderbird](https://www.thunderbird.net)中登录的密码。


# 5. git发送邮件

安装：
```shell
sudo yum install git-email -y
```
163邮箱`~/.gitconfig`：
```
[user]
	email = chenxiaosongemail@163.com
	name = ChenXiaoSong
[core]
	editor = vim 
	quotepath = false
[sendemail]
	from = chenxiaosongemail@163.com
	smtpserver = smtp.163.com
	smtpuser = chenxiaosongemail@163.com
	smtpencryption = ssl 
	smtppass = 此处填写163邮箱的授权密码
	smtpserverport = 994 
```

foxmail邮箱`~/.gitconfig`：
```shell
[user]
        email = chenxiaosongemail@foxmail.com
        name = ChenXiaoSong
[core]
        editor = vim 
        quotepath = false
[sendemail]
        from = chenxiaosongemail@foxmail.com
        smtpserver = smtp.qq.com
        smtpuser = chenxiaosongemail@foxmail.com
        smtpencryption = ssl 
        smtppass = 此处填写qq邮箱的授权密码
```

获取maintainer邮箱：
```shell
./scripts/get_maintainer.pl file1.patch
```
发送邮件：
```shell
git send-email --to=to1@example.com,to2@example.com --cc=cc1@example.com,cc2@example.com file1.patch file2.patch
```

# thunderbird邮件客户端

最新版本的[thunderbird](https://www.thunderbird.net/)默认使用html格式发送和显示，需要更改配置，参考[Plain text e-mail - Thunderbird](http://kb.mozillazine.org/Plain_text_e-mail_-_Thunderbird#Send_plain_text_messages)。

依次点击 `Account Settings -> Composition & Addressing -> Composition -> 取消勾选Compose messages in HTML format`。

还有，不建议订阅内核任何模块的邮件列表，因为太多了，一旦订阅邮箱基本就爆了，可以在[邮件列表网站](https://lore.kernel.org/)上选择对应的模块在线浏览，如果需要回复，可以把邮件下载下来保存成文件，然后用thunderbird打开文件，然后就可以回复了。