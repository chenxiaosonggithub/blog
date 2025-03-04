我买的nova13在2025年才支持升级HarmonyOS NEXT，且目前还只是beta版系统。

目前HarmonyOS NEXT的生态还在完善中，一些小众的程序还无法下载安装。所以需要在“卓易通”和“出境易”中安装，这两个说白了就是个虚拟机。

# “卓易通”和“出境易”

先在“应用商城”中搜索安装“卓易通”和“出境易”。

“卓易通”能安装下载好的apk文件，传到“卓易通”中的文件位置是“文件管理 -> 我的手机 -> ShareData -> ShareFile”。

“出境易”能搜索到google的一些应用（很多都需要连接外网才能正常用），我暂时没有找到办法安装下载好的apk文件，传到“出境易”中的文件位置是“文件管理 -> 我的手机 -> ShareData -> ShareHM”。

“卓易通”中无法安装的软件要用[“Apktool M”](https://maximoff.su/apktool/?lang=en)（在“卓易通”中安装）软件处理一下，点击apk文件名弹出的菜单选择“删除签名验证”，生成`_kill.apk`结尾的文件，
然后再点击apk文件弹出的菜单选择“快速编辑”，修改“包名”，可以在每个点号后加一些字符，生成`_kill_mod.apk`结尾的文件。

[“微信”apk文件](https://weixin.qq.com/)用[“Apktool M”](https://maximoff.su/apktool/?lang=en)处理后在“卓易通”中安装能正常使用，
有些软件如“蓝信”、[“VLC”](https://get.videolan.org/vlc-android/)等不需要用[“Apktool M”](https://maximoff.su/apktool/?lang=en)处理而是可以直接在“卓易通”中安装。
以下软件用[“Apktool M”](https://maximoff.su/apktool/?lang=en)处理后在“卓易通”中能安装但使用有问题:

- 美团企业版: 无法登录，且只能安装华为安卓机“应用市场”导出的apk。不过可以在“美团”app中找到“企业版”的入口（我的 -> 企业服务）
- 美团: 无法登录，登录过程中认证时找不到qq和微信
- qq: 无法联网，无法登录

