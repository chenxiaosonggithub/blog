mkdir -p /var/www/html/self-introduction/
mkdir -p /var/www/html/nfs

pandoc /home/sonvhi/chenxiaosong/code/blog/src/articles/self-introduction/index.md -o /var/www/html/index.html --from markdown --to html --standalone --metadata encoding=gbk --metadata title="陈孝松个人主页" --toc
pandoc /home/sonvhi/chenxiaosong/code/blog/src/articles/self-introduction/photos.md -o /var/www/html/self-introduction/photos.html --from markdown --to html --standalone --metadata encoding=gbk --metadata title="陈孝松照片" --toc
pandoc /home/sonvhi/chenxiaosong/code/blog/src/articles/self-introduction/openharmony.md -o /var/www/html/self-introduction/openharmony.html --from markdown --to html --standalone --metadata encoding=gbk --metadata title="陈孝松OpenHarmony贡献" --toc
pandoc /home/sonvhi/chenxiaosong/code/blog/src/fs/nfs/nfs-null-ptr-in-nfs_updatepage.md -o /var/www/html/nfs/nfs-null-ptr-in-nfs_updatepage.html --from markdown --to html --standalone --metadata encoding=gbk --metadata title="4.19 nfs_updatepage空指针解引用问题" --toc

rm /var/www/html/pictures -rf
cp /home/sonvhi/chenxiaosong/code/pictures/pictures/ /var/www/html/ -rf
chown -R www-data:www-data /var/www/
find /home/sonvhi/chenxiaosong/www -type f -exec chmod 400 {} +
find /home/sonvhi/chenxiaosong/www -type d -exec chmod 500 {} +
