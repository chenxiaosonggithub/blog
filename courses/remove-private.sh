# 删除private的内容
src_path=/home/sonvhi/chenxiaosong/code
dst_path=/tmp/blog-courses

. ${src_path}/blog/src/chenxiaosong.com/common_lib.sh

cp_to_dst_path() {
    cp ${src_path}/blog/${1} ${dst_path}
}

mkdir ${dst_path} -p
# 复制到/tmp
cp_to_dst_path courses/kernel/kernel.md
cp_to_dst_path courses/kernel/kernel-introduction.md
cp_to_dst_path courses/kernel/kernel-dev-invironment.md
cp_to_dst_path courses/kernel/kernel-book.md
cp_to_dst_path courses/kernel/kernel-source.md
cp_to_dst_path courses/kernel/kernel-fs.md

remove_private ${dst_path}
