rm /var/www/html/ -rf
mkdir -p /var/www/html/
mkdir -p /var/www/html/self-introduction/
mkdir -p /var/www/html/chenxiaosong.com
mkdir -p /var/www/html/nfs
mkdir -p /var/www/html/linux

# --standalone：此选项指示 pandoc 生成一个完全独立的输出文件，包括文档标题、样式表和其他元数据，使输出文件成为一个完整的文档。
# --metadata encoding=gbk：这个选项允许您添加元数据。在这种情况下，您将 encoding 设置为 gbk，指定输出 HTML 文档的字符编码为 GBK。这对于确保生成的文档以正确的字符编码进行保存非常重要。
# --toc：这个选项指示 pandoc 生成一个包含文档目录（Table of Contents，目录）的 HTML 输出。TOC 将包括文档中的章节和子章节的链接，以帮助读者导航文档。
# /home/sonvhi/chenxiaosong/code/blog 请替换为具体的路径
# 自我介绍
pandoc /home/sonvhi/chenxiaosong/code/blog/src/self-introduction/index.md -o /var/www/html/index.html --metadata title="陈孝松个人主页" --from markdown --to html --standalone --metadata encoding=gbk --toc
pandoc /home/sonvhi/chenxiaosong/code/blog/src/self-introduction/photos.md -o /var/www/html/self-introduction/photos.html --metadata title="陈孝松照片" --from markdown --to html --standalone --metadata encoding=gbk --toc
pandoc /home/sonvhi/chenxiaosong/code/blog/src/self-introduction/openharmony.md -o /var/www/html/self-introduction/openharmony.html --metadata title="陈孝松OpenHarmony贡献" --from markdown --to html --standalone --metadata encoding=gbk --toc
pandoc /home/sonvhi/chenxiaosong/code/blog/src/self-introduction/blog.md -o /var/www/html/self-introduction/blog.html --metadata title="陈孝松博客" --from markdown --to html --standalone --metadata encoding=gbk --toc
# nfs
pandoc /home/sonvhi/chenxiaosong/code/blog/src/nfs/4.19-null-ptr-deref-in-nfs_updatepage.md -o /var/www/html/nfs/4.19-null-ptr-deref-in-nfs_updatepage.html --metadata title="4.19 nfs_updatepage空指针解引用问题" --from markdown --to html --standalone --metadata encoding=gbk --toc
pandoc /home/sonvhi/chenxiaosong/code/blog/src/nfs/nfs-handle-writeback-errors-correctly.md -o /var/www/html/nfs/nfs-handle-writeback-errors-correctly.html --metadata title="nfs回写错误处理不正确的问题" --from markdown --to html --standalone --metadata encoding=gbk --toc
# 网站搭建
pandoc /home/sonvhi/chenxiaosong/code/blog/src/chenxiaosong.com/chenxiaosong.com.md -o /var/www/html/chenxiaosong.com/chenxiaosong.com.html --metadata title="如何快速搭建一个简陋的个人网站" --from markdown --to html --standalone --metadata encoding=gbk --toc
# Linux
pandoc /home/sonvhi/chenxiaosong/code/blog/src/linux-config/linux-config.md -o /var/www/html/linux/linux-config.html --metadata title="Linux配置文件" --from markdown --to html --standalone --metadata encoding=gbk --toc

# pictures是我的私有仓库
cp /home/sonvhi/chenxiaosong/code/pictures/pictures/ /var/www/html/ -rf

chown -R www-data:www-data /var/www/

# -type f：这个选项告诉 find 只搜索普通文件（不包括目录和特殊文件）。
# -exec chmod 400 {} +：这个部分告诉 find 对每个找到的文件执行 chmod 400 操作。{} 表示找到的文件的占位符，+ 表示一次处理多个文件以提高效率。
find /var/www -type f -exec chmod 400 {} +

# -type d：这个选项告诉find只搜索目录（不包括普通文件）。
find /var/www -type d -exec chmod 500 {} +
