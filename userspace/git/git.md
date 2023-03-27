[toc]

# git log 函数

```shell
git log -L :function:file
```

# github添加另一个ssh key

```shell
ssh-keygen -t ed25519-sk -C "YOUR_EMAIL"
eval "$(ssh-agent -s)" # 启动 SSH 代理
ssh-add ~/.ssh/id_ed25519 # 将 SSH 私钥添加到 SSH 代理
```
