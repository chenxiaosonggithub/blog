src_path=/home/sonvhi/chenxiaosong/code
dst_path=/var/www

rm ${dst_path}/html/ -rf

# --standalone：此选项指示 pandoc 生成一个完全独立的输出文件，包括文档标题、样式表和其他元数据，使输出文件成为一个完整的文档。
# --metadata encoding=gbk：这个选项允许您添加元数据。在这种情况下，您将 encoding 设置为 gbk，指定输出 HTML 文档的字符编码为 GBK。这对于确保生成的文档以正确的字符编码进行保存非常重要。
# --toc：这个选项指示 pandoc 生成一个包含文档目录（Table of Contents，目录）的 HTML 输出。TOC 将包括文档中的章节和子章节的链接，以帮助读者导航文档。
pandoc_common_options="--from markdown --to html --standalone --metadata encoding=gbk --toc --css http://chenxiaosong.com/stylesheet.css"

# 每一行代表： markdown文件相对路径 html文件相对路径 网页标题
array=(
    # 自我介绍
    src/self-introduction/index.md index.html '陈孝松个人主页'
    src/self-introduction/photos.md photos.html '陈孝松照片'
    src/self-introduction/openharmony.md openharmony.html "陈孝松OpenHarmony贡献"
    src/self-introduction/blog.md blog.html "陈孝松博客"
    # Linux内核
    src/kernel-environment/kernel-build.md kernel/kernel-build.html "Linux内核编译"
    src/kernel-environment/kernel-gdb.md kernel/kernel-gdb.html "GDB调试Linux内核"
    src/kernel-environment/kernel-crash-vmcore.md kernel/kernel-crash-vmcore.html "crash解析vmcore"
    src/kernel-environment/kernel-qemu-kvm.md kernel/kernel-qemu-kvm.html "QEMU/KVM环境搭建与使用"
    src/kernel-environment/kernel-mailinglist.md kernel/kernel-mailinglist.html "怎么贡献Linux内核社区"
    # nfs
    src/nfs/nfs-handle-writeback-errors-correctly.md nfs/nfs-handle-writeback-errors-correctly.html "nfs回写错误处理不正确的问题"
    src/nfs/4.19-null-ptr-deref-in-nfs_updatepage.md nfs/4.19-null-ptr-deref-in-nfs_updatepage.html '4.19 nfs_updatepage空指针解引用问题'
    src/nfs/4.19-null-ptr-deref-in-nfs_readpage_async.md nfs/4.19-null-ptr-deref-in-nfs_readpage_async.html '4.19 nfs_readpage_async空指针解引用问题'
    src/nfs/4.19-aarch64-null-ptr-deref-in-nfs_readpage_async.md nfs/4.19-aarch64-null-ptr-deref-in-nfs_readpage_async.html "aarch64架构 4.19 nfs_readpage_async空指针解引用问题"
    # 网站搭建
    src/chenxiaosong.com/chenxiaosong.com.md chenxiaosong.com/chenxiaosong.com.html "如何快速搭建一个简陋的个人网站"
    # Linux
    src/userspace-environment/userspace-environment.md linux/userspace-environment.html "Linux环境安装与配置"
    src/linux-config/linux-config.md linux/linux-config.html "Linux配置文件"
    src/ssh-reverse/ssh-reverse.md linux/ssh-reverse.html "反向ssh和内网穿透"
    src/docker/docker.md linux/docker.html "Docker安装与使用"
    # 自由软件
    src/free-software/free-software.md free-software/free-software.html "自由软件介绍"
    # 运动与健康
    src/health/tooth-clean.md health/tooth-clean.html "牙齿护理"
    # 其他
    src/wubi/wubi.md others/wubi.html "五笔输入法"
    # private
    src/v2ray/v2ray.md private/v2ray.html "v2ray代理服务器"
)
element_count="${#array[@]}"
for ((index=0; index<${element_count}; index=$((index + 3)))); do
    dst_file=${dst_path}/html/${array[${index}+1]}
    dst_dir="$(dirname "${dst_file}")"
    if [ ! -d "${dst_dir}" ]; then
        mkdir -p "${dst_dir}"
    fi
    pandoc ${src_path}/blog/${array[${index}]} -o ${dst_file} --metadata title="${array[${index}+2]}" ${pandoc_common_options}
done

# pictures是我的私有仓库
cp ${src_path}/pictures/pictures/ ${dst_path}/html/ -rf

# css样式
cp ${src_path}/blog/src/chenxiaosong.com/stylesheet.css ${dst_path}/html/

chown -R www-data:www-data ${dst_path}/

# -type f：这个选项告诉 find 只搜索普通文件（不包括目录和特殊文件）。
# -exec chmod 400 {} +：这个部分告诉 find 对每个找到的文件执行 chmod 400 操作。{} 表示找到的文件的占位符，+ 表示一次处理多个文件以提高效率。
find ${dst_path}/ -type f -exec chmod 400 {} +

# -type d：这个选项告诉find只搜索目录（不包括普通文件）。
find ${dst_path}/ -type d -exec chmod 500 {} +
