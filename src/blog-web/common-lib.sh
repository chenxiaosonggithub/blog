# --standalone：此选项指示 pandoc 生成一个完全独立的输出文件，包括文档标题、样式表和其他元数据，使输出文件成为一个完整的文档。
# --metadata encoding=gbk：这个选项允许您添加元数据。在这种情况下，您将 encoding 设置为 gbk，指定输出 HTML 文档的字符编码为 GBK。这对于确保生成的文档以正确的字符编码进行保存非常重要。
# --toc：这个选项指示 pandoc 生成一个包含文档目录（Table of Contents，目录）的 HTML 输出。TOC 将包括文档中的章节和子章节的链接，以帮助读者导航文档。
pandoc_common_options="--to html --standalone --metadata encoding=gbk --number-sections --css https://chenxiaosong.com/stylesheet.css"

create_sign() {
    local src_file=$1
    local tmp_html_path=$2

    local html_title="签名"
    local dst_file=${tmp_html_path}/sign.html
    local from_format="--from markdown"
    pandoc ${src_file} -o ${dst_file} --metadata title="${html_title}" ${from_format} ${pandoc_common_options}
    # 先去除sign.html文件中其他内容
    sed -i '/<\/header>/,/<\/body>/!d' ${tmp_html_path}/sign.html # 只保留</header>到</body>的内容
    sed -i '1d;$d' ${tmp_html_path}/sign.html # 删除第一行和最后一行
}

# 要定义数组array
# 每一行代表：
#    是否生成目录
#    是否添加签名
#    源文件，markdown或rst文件相对路径
#    目的文件，html文件相对路径，如果是~，就代表只和源文件的后缀名不同
#    网页标题
create_html() {
    # local array=("${!1}") # 使用间接引用来接收数组，调用的地方 create_html array[@] ${src_path} ${tmp_html_path}
    local src_path=$1
    local tmp_html_path=$2

    local element_count="${#array[@]}" # 总个数
    local count_per_line=5
    for ((index=0; index<${element_count}; index=$((index + ${count_per_line})))); do
        local is_toc=${array[${index}]}
        local is_sign=${array[${index}+1]}
        local ifile=${array[${index}+2]}
        local ofile=${array[${index}+3]}
        local html_title=${array[${index}+4]}
        local pandoc_options=${pandoc_common_options}

        local src_file=${src_path}/${ifile} # 相对路径
        if [[ ${ifile} == '/'* ]]; then
            src_file=${ifile} # 绝对路径
        fi
        if [[ ${ofile} == ~ ]]; then
            ofile="${ifile%.*}.html" # 使用参数扩展去除文件名的后缀，再加.html
        fi
        local dst_file=${tmp_html_path}/${ofile} # 生成的html文件名
        local dst_dir="$(dirname "${dst_file}")" # html文件所在的文件夹
        if [ ! -d "${dst_dir}" ]; then
            mkdir -p "${dst_dir}" # 文件夹不存在就创建
        fi
        from_format="--from markdown"
        if [[ ${src_file} == *.rst ]]; then
            from_format="--from rst" # rst格式
        fi
        if [[ ${is_toc} == 1 ]]; then
            pandoc_options="${pandoc_options} --toc"
        fi
        echo "create ${ofile}"
        pandoc ${src_file} -o ${dst_file} --metadata title="${html_title}" ${from_format} ${pandoc_options}
        if [[ ${is_sign} == 1 ]]; then
            # 在<header之后插入sign.html整个文件
            sed -i -e '/<header/r '${tmp_html_path}'/sign.html' ${dst_file}
        fi
    done
}

change_perm() {
    local html_path=$1

    chown -R www-data:www-data ${html_path}/

    # -type f：这个选项告诉 find 只搜索普通文件（不包括目录和特殊文件）。
    # -exec chmod 400 {} +：这个部分告诉 find 对每个找到的文件执行 chmod 400 操作。{} 表示找到的文件的占位符，+ 表示一次处理多个文件以提高效率。
    find ${html_path}/ -type f -exec chmod 400 {} +

    # -type d：这个选项告诉find只搜索目录（不包括普通文件）。
    find ${html_path}/ -type d -exec chmod 500 {} +
}

remove_comments() {
    local md_path=$1
    local is_public=$2

    local begin_str='<!-- private begin -->'
    local end_str='<!-- private end -->'
    if [[ ${is_public} == true ]]; then
        begin_str='<!-- public begin -->'
        end_str='<!-- public end -->'
    fi

    # 把begin和end之间的内容删除, sed 默认只支持贪婪模式，要支持非贪婪模式要用Perl正则表达式（PCRE）
    find ${md_path} -type f -name '*.md' -exec perl -i -pe "s/${begin_str}.*?${end_str}//g" {} + # 只能在同一行内，必须放在前面
    find ${md_path} -type f -name '*.md' -exec sed -i "/${begin_str}/,/${end_str}/d" {} + # 只能按行为单位删除
    # 正在写的内容就先不放上去
    begin_str='<!-- ing begin -->'
    end_str='<!-- ing end -->'
    find ${md_path} -type f -name '*.md' -exec perl -i -pe "s/${begin_str}.*?${end_str}//g" {} + # 只能在同一行内，必须放在前面
    find ${md_path} -type f -name '*.md' -exec sed -i "/${begin_str}/,/${end_str}/d" {} + # 只能按行为单位删除
    # 把注释全部删除
    find ${md_path} -type f -name '*.md' -exec perl -i -pe 's/<!--.*?-->//g' {} + # 只能在同一行内，必须放在前面
    find ${md_path} -type f -name '*.md' -exec sed -i '/<!--/,/-->/d' {} + # 只能按行为单位删除
}

remove_private() {
    local md_path=$1
    remove_comments $1 false
}

remove_public() {
    local md_path=$1
    remove_comments $1 true
}

