sudo pandoc index.md -o /var/www/html/index.html --from markdown --to html --standalone --metadata encoding=gbk --metadata title="陈孝松个人主页" --toc
sudo pandoc photos.md -o /var/www/html/self-introduction/photos.html --from markdown --to html --standalone --metadata encoding=gbk --metadata title="陈孝松照片" --toc
sudo pandoc openharmony.md -o /var/www/html/self-introduction/openharmony.html --from markdown --to html --standalone --metadata encoding=gbk --metadata title="陈孝松OpenHarmony贡献" --toc
sudo chown -R www-data:www-data /var/www/
sudo find /var/www -type f -exec chmod 400 {} +
sudo find /var/www -type d -exec chmod 500 {} +