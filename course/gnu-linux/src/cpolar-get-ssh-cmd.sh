input_file=status.html
ssh_script=cpolar.sh

> ${ssh_script}

if [ ! -f "$input_file" ]; then
    echo "错误: 文件不存在 - $input_file"
    exit 1
fi

# 提取所有隧道地址
tunnels=$(grep -o '">tcp://[^<]*' "$input_file" | sed 's/">tcp:\/\///')

if [ -z "$tunnels" ]; then
    echo "未找到隧道信息"
    exit 0
fi

echo "找到的隧道:"
echo "----------------------------------------"

# 处理每个隧道
counter=0
while IFS= read -r tunnel; do
    ((counter++))
    address=$(echo "$tunnel" | cut -d: -f1)
    port=$(echo "$tunnel" | cut -d: -f2)
    
    # 生成 SSH 命令
    ssh_cmd="ssh -p $port sonvhi@$address"
    
    # 输出结果
    echo "隧道 $counter: $tunnel"
    echo "SSH 命令: $ssh_cmd"
    echo "----------------------------------------"
    
    # 保存到文件
    echo "$ssh_cmd" >> ${ssh_script}
done <<< "$tunnels"

# 最终输出
echo ""
echo "共找到 $counter 个隧道"
echo "所有 SSH 命令已保存到 ${ssh_script}"
