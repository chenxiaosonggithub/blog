
# `log` {#log}

单行显示补丁，前面再加上时间:
```sh
# --oneline：简化每条提交的显示。
# --date=short：以简短的日期格式（YYYY-MM-DD）显示时间。
# --format="%ad %h %s"：自定义输出格式，其中：
# %a Author, %c Commit
# %ad %cd：显示提交的日期（由 --date 指定的格式），%d: 不包含时分秒
# %ai %ci：显示提交的 日期和时间，%i: 包含时分秒
# %h：显示提交的简短哈希值。
# %s：显示提交的信息。
# %an：提交者的名字。
# %ae：提交者的邮箱。
git log --oneline --date=short --format="%cd %h %s %an <%ae>" --author=yourname
```

`git log -L<start>,<end>:<file>, -L:<funcname>:<file>`（查看帮助文档`man 1 git log`），以内核主线代码[fs/namespace.c](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/namespace.c?id=8f6f76a6a29f)文件为例，查看`do_new_mount`函数:
```sh
git log -L:do_new_mount:fs/namespace.c
```

我们发现列出的却是`do_new_mount_fc`的修改记录，因为`do_new_mount_fc`包含字符串`do_new_mount`，又在`do_new_mount()`函数前面，解决方法是在`do_new_mount`后面再加个`\(`:
```sh
git log -L:do_new_mount\(:fs/namespace.c
```

# `name-rev` {#name-rev}
在内核开发过程中我们经常需要找某个commit提交记录是哪个版本引入的，使用以下命令
```sh
git name-rev <commit>
```

# github 22端口没法ssh

在`~/.ssh/config`中添加:
```sh
Host github.com
  HostName ssh.github.com
  Port 443
```

# 两个github账号

如果我们有两个github账号，两个账号不能在网站上添加同一个ssh key，这时我们就要再生成一个ssh key:
```sh
# 生成id_rsa_2和id_rsa_2.pub
ssh-keygen -f ~/.ssh/id_rsa_2
# 创建配置文件
cat <<EOF > ~/.ssh/config
# 10.42.20.225 改成本机的ip
Host 10.42.20.225
  HostName 10.42.20.225
  User sonvhi
Host github.com
  HostName ssh.github.com
  Port 443
  User git
  IdentityFile ~/.ssh/id_rsa
  IdentitiesOnly yes
# 指定账号: specifiedaccount
Host github.com-specifiedaccount
  HostName ssh.github.com
  Port 443
  User git
  IdentityFile ~/.ssh/id_rsa_2
  IdentitiesOnly yes
EOF
# 重新设置url，specifiedaccount为指定的账号名
git remote set-url origin git@github.com-specifiedaccount:specifiedaccount/repo-name.git
```

如果报错`Bad owner or permissions on ~/.ssh/config`，需要修改文件权限:
```sh
chown $(whoami):$(id -gn) ~/.ssh/config
```

# `cherry-pick`或`am` {#cherry-pick-or-am}

`cherry-pick`多个`commit`:
```sh
git cherry-pick <commit1>..<commitN> # 不包含commit1
```

<!-- public begin -->
如果多个commit中包含有Merge的commit，直接cherry-pick多个会报错`error: 提交 xxxx 是一个合并提交但未提供 -m 选项`，可以把`git log --oneline`的输出放到文件`commits.txt`中，把Merge相关的commit删除，并删除掉每行的后面的commit信息，每行只保留commit号，然后用以下脚本`cherry-pick`（各位朋友如果有什么更好的方法请一定要联系告诉我）:
```sh
# tac 从最后一行开始 cherry-pick
tac commits.txt | while IFS= read -r commit; do
	git cherry-pick $commit
	if [ $? -eq 0 ]; then
		echo "合并成功"
	else
		echo "合并失败"
		return
	fi
done
echo "全部合并成功"
```
<!-- public end -->

`git cherry-pick`或`git am`合补丁时如果有冲突，在解决完冲突后，在`commit`信息中在`Conflicts:`后列出冲突文件，如:
```sh
Conflicts:
        include/linux/sunrpc/clnt.h
[Commit xxxxxxxxx ("xxx: here is subject") 这里描述冲突的原因，如果后面还有补丁就用封号;
 Commit xxxxxxxxx ("xxx: here is subject") 最后一个补丁用点号.]
```

# `format-patch` {#format-patch}

查看帮助文档`man git format-patch`:
```
--stat[=<width>[,<name-width>[,<count>]]]
           生成一个 diffstat。默认情况下，文件名部分将使用尽可能多的空间，其余部分用于图形部分。最大宽度默认为终端宽度，如果未连接终端则为 80 列，可以通过 <width> 覆盖。文件名部分的宽度可以通过在逗号后提供另一个宽度 <name-width> 来限制。图形部分的宽度可以通过使用 --stat-graph-width=<width> 来限制（影响所有生成统计图的命令），或通过设置 diff.statGraphWidth=<width>（不影响 git format-patch）。通过提供第三个参数 <count>，可以限制输出到前 <count> 行，如果有更多行，则以 ... 结尾。

           这些参数也可以单独设置，使用 --stat-width=<width>、--stat-name-width=<name-width> 和 --stat-count=<count>。
```

如果文件名较长，可以用以下命令让补丁中的路径显示完整:
```sh
git format-patch -3 --cover-letter --stat=300,200
```

# `git stash` {#stash}

```sh
# 保存已跟踪文件在工作目录和暂存区的所有修改
git stash save "描述信息"
# 也保存未跟踪的文件
git stash save "描述信息" -u # --include-untracked
# 保存被忽略的文件（通常不建议）
git stash save "描述信息" -a # --all
# 列出
git stash list
# 恢复指定的 stash，不会自动删除这个 stash
git stash apply stash@{n}
# 恢复暂存状态（就是哪些已经执行过git add）
git stash apply stash@{n} --index
# 恢复栈顶的 stash（最近保存的 stash@{0}），这个 stash 会从栈中删除
git stash pop
# 删除 stash
git stash drop stash@{n}
# 清空整个 stash 栈（删除所有 stash）
git stash clear
# 显示简略diff（相当于git show --stat）
git stash show stash@{n}
# 显示完整diff（patch格式）
git stash show -p stash@{n}
# 创建一个名为 new-branch-name 的新分支
# 然后在这个新分支上应用指定的 stash@{n}（相当于 apply）
# 如果应用成功，会自动删除这个 stash
git stash branch new-branch-name stash@{n}
```

