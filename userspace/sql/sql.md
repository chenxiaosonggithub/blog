[toc]

# mysql

下载: https://dev.mysql.com/downloads/mysql/, 选择“Windows (x86, 64-bit), ZIP Archive”。

```shell
cd mysql-8.0.32-winx64/bin
./mysqld --initialize --console # 初始化数据，会生成默认密码
./mysqld install # 会提示已经安装
net start mysql # 结束mysqld进程后，只需要执行此命令，不需要前面的命令
```

更改密码：

```shell
.\mysql -u root -p # 注意如果是在windows下，只能在cmd中执行，不能在shell中(如git shell)执行
mysql> ALTER USER 'root'@'localhost' IDENTIFIED BY 'new_password';
mysql> FLUSH PRIVILEGES;
```
