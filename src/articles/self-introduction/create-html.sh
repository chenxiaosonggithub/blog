pandoc index.md -o /var/www/html/index.html --from markdown --to html --standalone --metadata encoding=gbk --metadata title="陈孝松个人主页" --toc
pandoc photos.md -o /var/www/html/self-introduction/photos.html --from markdown --to html --standalone --metadata encoding=gbk --metadata title="陈孝松照片" --toc
pandoc openharmony.md -o /var/www/html/self-introduction/openharmony.html --from markdown --to html --standalone --metadata encoding=gbk --metadata title="陈孝松OpenHarmony贡献" --toc
rm /var/www/html/pictures -rf
cp /home/sonvhi/chenxiaosong/code/pictures/pictures/ /var/www/html/ -rf
chown -R www-data:www-data /var/www/
find /var/www -type f -exec chmod 400 {} +
find /var/www -type d -exec chmod 500 {} +
