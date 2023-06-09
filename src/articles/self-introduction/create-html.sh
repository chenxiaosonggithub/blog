mkdir -p /home/sonvhi/chenxiaosong/www/html/self-introduction/
pandoc /home/sonvhi/chenxiaosong/code/blog/src/articles/self-introduction/index.md -o /home/sonvhi/chenxiaosong/www/html/index.html --from markdown --to html --standalone --metadata encoding=gbk --metadata title="陈孝松个人主页" --toc
pandoc /home/sonvhi/chenxiaosong/code/blog/src/articles/self-introduction/photos.md -o /home/sonvhi/chenxiaosong/www/html/self-introduction/photos.html --from markdown --to html --standalone --metadata encoding=gbk --metadata title="陈孝松照片" --toc
pandoc /home/sonvhi/chenxiaosong/code/blog/src/articles/self-introduction/openharmony.md -o /home/sonvhi/chenxiaosong/www/html/self-introduction/openharmony.html --from markdown --to html --standalone --metadata encoding=gbk --metadata title="陈孝松OpenHarmony贡献" --toc
rm /home/sonvhi/chenxiaosong/www/html/pictures -rf
cp /home/sonvhi/chenxiaosong/code/pictures/pictures/ /home/sonvhi/chenxiaosong/www/html/ -rf
chown -R www-data:www-data /home/sonvhi/chenxiaosong/www/
find /home/sonvhi/chenxiaosong/www -type f -exec chmod 400 {} +
find /home/sonvhi/chenxiaosong/www -type d -exec chmod 500 {} +
