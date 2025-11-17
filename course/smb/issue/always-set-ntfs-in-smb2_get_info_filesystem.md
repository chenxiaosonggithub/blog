# 问题描述

在`smb2_get_info_filesystem()`函数中`FileSystemName`总是设置为`NTFS`，[maintainer说是为了解决Windows作为client的一些问题](https://github.com/namjaejeon/ksmbd/commit/84392651b0b740d2f59bcacd3b4cfff8ae0051a0)。

