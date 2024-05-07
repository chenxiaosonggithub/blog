# 删除private的内容
src_path=/home/sonvhi/chenxiaosong/code
dst_path=/tmp/blog-courses

mkdir ${dst_path} -p
cp ${src_path}/blog/courses/kernel/kernel.md ${dst_path}
find ${dst_path} -type f -name '*.md' -exec perl -i -pe 's/<!-- private begin -->.*?<!-- private end -->//g' {} + # 只能在同一行内，必须放在前面
find ${dst_path} -type f -name '*.md' -exec sed -i '/<!-- private begin -->/,/<!-- private end -->/d' {} + # 只能按行为单位删除
# 把注释全部删除
find ${dst_path} -type f -name '*.md' -exec perl -i -pe 's/<!--.*?-->//g' {} + # 只能在同一行内，必须放在前面
find ${dst_path} -type f -name '*.md' -exec sed -i '/<!--/,/-->/d' {} + # 只能按行为单位删除
