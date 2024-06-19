# 检查参数
if [ $# -ne 2 ]; then
    echo "用法: $0 <文件名> <多少行(行数大于这个值的函数才会打印)>"
    return 1
fi

# 检查文件是否存在
if [ ! -f "$1" ]; then
    echo "文件 '$1' 不存在."
    exit 1
fi

input_file=$1
gt_lines=$2

calc_func_lines() {
    local cur_line_num=0 # 当前在哪一行
    local func_name_line # 函数名
    local func_state=0 # 0: 未开始, 1: 识别到函数名, 2: 识别到'{'
    local begin_line_num # 函数开始的行号
    while IFS= read -r line; do
        ((cur_line_num++))
        # 函数名所在行，不以空格或tab开头，含有'('
        if ! [[ $line =~ ^[[:space:]] ]] && [[ $line == *'('* ]]; then
            func_name_line=$line
            func_state=1
            continue
        fi

        # 函数开始, 以'{'开头
        if [[ $func_state == 1 && $line == '{'* ]]; then
            func_state=2
            begin_line_num=$cur_line_num
            continue
        fi

        # 函数结束, 以'}'开头
        if [[ $func_state == 2 && $line == '}'* ]]; then
            func_state=0
            local func_lines=$((cur_line_num - begin_line_num - 1)) # 函数总行数
            # 大于特定值才打印
            if [ $func_lines -gt $gt_lines ]; then
                echo -e "${func_lines}\t=${cur_line_num}-${begin_line_num}\t${func_name_line}"
            fi
            continue
        fi
    done < "$input_file"
}

calc_func_lines
