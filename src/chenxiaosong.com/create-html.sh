src_path=/home/sonvhi/chenxiaosong/code/
dst_path=/var/www/

rm ${dst_path}html/ -rf
mkdir -p ${dst_path}html/
mkdir -p ${dst_path}html/self-introduction/
mkdir -p ${dst_path}html/chenxiaosong.com
mkdir -p ${dst_path}html/kernel
mkdir -p ${dst_path}html/nfs
mkdir -p ${dst_path}html/linux
mkdir -p ${dst_path}html/free-software
mkdir -p ${dst_path}html/health

# --standalone：此选项指示 pandoc 生成一个完全独立的输出文件，包括文档标题、样式表和其他元数据，使输出文件成为一个完整的文档。
# --metadata encoding=gbk：这个选项允许您添加元数据。在这种情况下，您将 encoding 设置为 gbk，指定输出 HTML 文档的字符编码为 GBK。这对于确保生成的文档以正确的字符编码进行保存非常重要。
# --toc：这个选项指示 pandoc 生成一个包含文档目录（Table of Contents，目录）的 HTML 输出。TOC 将包括文档中的章节和子章节的链接，以帮助读者导航文档。
pandoc_common_options="--from markdown --to html --standalone --metadata encoding=gbk --toc"
# 自我介绍
pandoc ${src_path}blog/src/self-introduction/index.md -o ${dst_path}html//index.html --metadata title="陈孝松个人主页" ${pandoc_common_options}
pandoc ${src_path}blog/src/self-introduction/photos.md -o ${dst_path}html/self-introduction/photos.html --metadata title="陈孝松照片" ${pandoc_common_options}
pandoc ${src_path}blog/src/self-introduction/openharmony.md -o ${dst_path}html/self-introduction/openharmony.html --metadata title="陈孝松OpenHarmony贡献" ${pandoc_common_options}
pandoc ${src_path}blog/src/self-introduction/blog.md -o ${dst_path}html/self-introduction/blog.html --metadata title="陈孝松博客" ${pandoc_common_options}
# Linux内核
pandoc ${src_path}blog/src/kernel-environment/kernel-environment.md -o ${dst_path}html/kernel/kernel-environment.html --metadata title="Linux内核编译与调试环境" ${pandoc_common_options}
# nfs
pandoc ${src_path}blog/src/nfs/4.19-null-ptr-deref-in-nfs_updatepage.md -o ${dst_path}html/nfs/4.19-null-ptr-deref-in-nfs_updatepage.html --metadata title="4.19 nfs_updatepage空指针解引用问题" ${pandoc_common_options}
pandoc ${src_path}blog/src/nfs/nfs-handle-writeback-errors-correctly.md -o ${dst_path}html/nfs/nfs-handle-writeback-errors-correctly.html --metadata title="nfs回写错误处理不正确的问题" ${pandoc_common_options}
# 网站搭建
pandoc ${src_path}blog/src/chenxiaosong.com/chenxiaosong.com.md -o ${dst_path}html/chenxiaosong.com/chenxiaosong.com.html --metadata title="如何快速搭建一个简陋的个人网站" ${pandoc_common_options}
# Linux
pandoc ${src_path}blog/src/userspace-environment/userspace-environment.md -o ${dst_path}html/linux/userspace-environment.html --metadata title="Linux环境安装与配置" ${pandoc_common_options}
pandoc ${src_path}blog/src/linux-config/linux-config.md -o ${dst_path}html/linux/linux-config.html --metadata title="Linux配置文件" ${pandoc_common_options}
# 自由软件
pandoc ${src_path}blog/src/free-software/free-software.md -o ${dst_path}html/free-software/free-software.html --metadata title="自由软件介绍" ${pandoc_common_options}
# 运动与健康
pandoc ${src_path}blog/src/health/tooth-clean.md -o ${dst_path}html/health/tooth-clean.html --metadata title="牙齿护理" ${pandoc_common_options}

# pictures是我的私有仓库
cp ${src_path}pictures/pictures/ ${dst_path} -rf

chown -R www-data:www-data ${dst_path}

# -type f：这个选项告诉 find 只搜索普通文件（不包括目录和特殊文件）。
# -exec chmod 400 {} +：这个部分告诉 find 对每个找到的文件执行 chmod 400 操作。{} 表示找到的文件的占位符，+ 表示一次处理多个文件以提高效率。
find ${dst_path} -type f -exec chmod 400 {} +

# -type d：这个选项告诉find只搜索目录（不包括普通文件）。
find ${dst_path} -type d -exec chmod 500 {} +
