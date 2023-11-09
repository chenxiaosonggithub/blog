[toc]

# mysql

下载: https://dev.mysql.com/downloads/mysql/, 选择“Windows (x86, 64-bit), ZIP Archive”。

以下是[YiShaAdmin](https://github.com/liukuo362573/YiShaAdmin/tree/YiShaAdmin-Net6)的一些操作。

```shell
cd mysql-8.0.32-winx64/bin
./mysqld --initialize --console # 初始化数据，会生成默认密码
./mysqld install # 会提示已经安装
net start mysql # 结束mysqld进程后，只需要执行此命令，不需要前面的命令
```

更改密码：

```shell
.\mysql -u root -p # 注意如果是在windows下，只能在cmd中执行，不能在shell中(如git shell)执行
mysql> ALTER USER 'root'@'localhost' IDENTIFIED BY '123456';
mysql> FLUSH PRIVILEGES; # 重新加载了权限表，以确保当前任何更改用户或权限的操作都会立即生效
```

常见操作：

```shell
mysql> show databases;
mysql> create DATABASE yishaadmin;
mysql> use yishaadmin;
mysql> SELECT DATABASE(); # 查看当前选择的数据库
mysql> source D:/chenxiaosong/code/YiShaAdmin/Document/DatabaseScript/mysql.sql;
mysql> source D:/chenxiaosong/code/YiShaAdmin/Document/DatabaseScript/mysql_data.sql;
mysql> show tables;
```
