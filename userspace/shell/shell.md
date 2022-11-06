[toc]

# 循环读文件每一行

```shell
while read line
do
  echo $line
done < file.txt
```

# sed

```shell
# 替换
sed -i "s/old/new/g" file
```

# 数字计算

```shell
val=`expr 5555 + $num`
```

# awk

两行数字相减，不换行输出：
```shell
echo -e "num:1\nnum:2\nnum:5" > file
# printf 不换行，prev没赋值过默认为0
cat file | awk -F ':' '{print $2}' | awk '{printf $1-prev; printf " "; prev=$1}'
```

# cut

```shell
uname -r # 5.10.17-v7l+
uname -r | cut -d '-' -f 1 | cut -d '.' -f 1,2 # 5.10
```