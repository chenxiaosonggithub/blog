src_path=/home/sonvhi/chenxiaosong/code # 替换为你的仓库路径
dst_path=/var/www
tmp_html_path=${dst_path}/html-tmp
html_path=${dst_path}/html
tmp_courses_path=/tmp/blog-courses

# 每一行代表： markdown或rst文件相对路径 html文件相对路径 网页标题
array=(
    # 自我介绍
    src/self-introduction/common.md common.html "公共的内容"
    src/self-introduction/index.md index.html '陈孝松个人主页'
    src/self-introduction/photos.md photos.html '陈孝松照片'
    src/self-introduction/openharmony.md openharmony.html "陈孝松OpenHarmony贡献"
    src/self-introduction/blog.md blog.html "陈孝松博客"
    src/self-introduction/contributions.md contributions.html "陈孝松自由软件贡献"
    # 课程
    ${tmp_courses_path}/kernel.md courses/kernel.html "Linux内核课程"
    ${tmp_courses_path}/kernel-introduction.md courses/kernel-introduction.html "Linux内核简介"
    ${tmp_courses_path}/kernel-dev-invironment.md courses/kernel-dev-invironment.html "Linux内核开发环境"
    ${tmp_courses_path}/kernel-book.md courses/kernel-book.html "Linux内核书籍推荐"
    ${tmp_courses_path}/kernel-source.md courses/kernel-source.html "Linux内核源码介绍"
    courses/book-contents.md courses/book-contents.html "书籍目录"
    # Linux内核
    src/kernel-environment/kernel-crash-vmcore.md kernel/kernel-crash-vmcore.html "crash解析vmcore"
    src/kernel-environment/kernel-qemu-kvm.md kernel/kernel-qemu-kvm.html "QEMU/KVM环境搭建与使用"
    src/strace-fault-inject/strace-fault-inject.md kernel/strace-fault-inject.html "strace内存分配失败故障注入"
    src/kernel/openeuler-sysmonitor.md kernel/openeuler-sysmonitor.html "openEuler的sysmonitor"
    src/kernel/kprobe-scsi-data.md kernel/kprobe-scsi-data.html "使用kprobe监控scsi的读写数据"
    src/mm/mm.md kernel/mm.html "Linux内存管理"
    src/process/process.md kernel/process.html "Linux进程调度"
    src/kernel/gio-to-mount.md kernel/gio-to-mount.html "gio执行慢的临时解决办法"
    # nfs
    src/nfs/nfs.md nfs/nfs.html "NFS网络文件系统介绍"
    src/nfs/nfs-debug.md nfs/nfs-debug.html "定位NFS问题的常用方法"
    src/nfs/CVE-2022-24448.md nfs/CVE-2022-24448.html "CVE-2022-24448"
    src/nfs/nfs-handle-writeback-errors-incorrectly.md nfs/nfs-handle-writeback-errors-incorrectly.html "NFS回写错误处理不正确的问题"
    src/nfs/4.19-null-ptr-deref-in-nfs_updatepage.md nfs/4.19-null-ptr-deref-in-nfs_updatepage.html '4.19 nfs_updatepage空指针解引用问题'
    src/nfs/4.19-null-ptr-deref-in-nfs_readpage_async.md nfs/4.19-null-ptr-deref-in-nfs_readpage_async.html '4.19 nfs_readpage_async空指针解引用问题'
    src/nfs/4.19-aarch64-null-ptr-deref-in-nfs_readpage_async.md nfs/4.19-aarch64-null-ptr-deref-in-nfs_readpage_async.html "aarch64架构 4.19 nfs_readpage_async空指针解引用问题"
    src/nfs/4.19-rdma-not-supported.md nfs/4.19-rdma-not-supported.html "4.19 rdma协议不支持的问题"
    src/nfs/4.19-nfs-mount-hung.md nfs/4.19-nfs-mount-hung.html "4.19 nfs lazy umount 后无法挂载的问题"
    src/nfs/4.19-warning-in-nfs4_put_stid-and-panic.md nfs/4.19-warning-in-nfs4_put_stid-and-panic.html "4.19 nfs4_put_stid报warning紧接着panic的问题"
    src/nfs/cthon-nfs-tests.md nfs/cthon-nfs-tests.html "Connectathon NFS tests"
    src/nfs/4.19-nfs-no-iterate_shared.md nfs/4.19-nfs-no-iterate_shared.html "nfs没实现iterate_shared导致的遍历目录无法并发问题"
    src/nfs/unable-to-initialize-client-recovery-tracking.md nfs/unable-to-initialize-client-recovery-tracking.html "重启nfs server后client打开文件卡顿很长时间的问题"
    src/nfs/4.19-ltp-nfs-fail.md nfs/4.19-ltp-nfs-fail.html "4.19 ltp nfs测试失败问题"
    # smb(cifs)
    src/smb/smb.md smb/smb.html "SMB文件系统介绍"
    src/smb/4.19-null-ptr-deref-in-cifs_reconnect.md smb/4.19-null-ptr-deref-in-cifs_reconnect.html "4.19 cifs_reconnect空指针解引用问题"
    src/smb/samba-server.md linux/samba-server.html "samba服务器搭建"
    # ext
    src/ext/null-ptr-deref-in-jbd2_journal_commit_transaction.md ext/null-ptr-deref-in-jbd2_journal_commit_transaction.html "jbd2_journal_commit_transaction空指针解引用问题"
    src/ext/bugon-in-ext4_writepages.md ext/bugon-in-ext4_writepages.html "ext4_writepages报BUG_ON的问题"
    src/ext/bugon-in-start_this_handle.md ext/bugon-in-start_this_handle.html "start_this_handle报BUG_ON的问题"
    src/ext/symlink-file-size-not-match.md ext/symlink-file-size-not-match.html "symlink file size 错误的问题"
    src/ext/uaf-in-ext4_search_dir.md ext/uaf-in-ext4_search_dir.html "ext4_search_dir空指针解引用问题"
    # 文件系统
    src/filesystem/configfs-race.md fs/configfs-race.html "configfs加载或卸载模块时的并发问题"
    src/xfs/xfs-null-ptr-deref-in-xfs_getbmap.md fs/xfs-null-ptr-deref-in-xfs_getbmap.html "xfs_getbmap发生空指针解引用问题"
    src/filesystem/microsoft-fs.md fs/microsoft-fs.html "微软文件系统"
    src/btrfs/4.19-btrfs-forced-readonly.md fs/4.19-btrfs-forced-readonly.html "4.19 btrfs文件系统变成只读的问题"
    src/filesystem/minix-fs.md fs/minix-fs.html "minix文件系统"
    # Linux环境
    src/qemu-vnc-install-desktop/qemu-vnc-install-desktop.md linux/qemu-vnc-install-desktop.html "QEMU+VNC安装桌面系统"
    src/chenxiaosong.com/chenxiaosong.com.md linux/chenxiaosong.com.html "如何拥有个人域名的网站和邮箱"
    src/userspace-environment/userspace-environment.md linux/userspace-environment.html "Linux环境安装与配置"
    src/linux-config/linux-config.md linux/linux-config.html "Linux配置文件"
    src/ssh-reverse/ssh-reverse.md linux/ssh-reverse.html "反向ssh和内网穿透"
    src/userspace-environment/docker.md linux/docker.html "Docker安装与使用"
    src/userspace-environment/qemu-kvm-install-macos.md linux/qemu-kvm-install-macos.html "QEMU/KVM安装macOS系统"
    src/userspace-environment/ghostwriter-makdown.md linux/ghostwriter-makdown.html "ghostwriter: 一款makdown编辑器"
    src/userspace-environment/mosquitto-mqtt.md linux/mosquitto-mqtt.html "使用mosquitto搭建MQTT服务器"
    src/editor/editor.md linux/editor.html "编辑器"
    src/windows/wine.md linux/wine.html "Linux使用wine运行Windows软件"
    # 其他
    src/windows/windows.md others/windows.html "Windows系统"
    src/wubi/wubi.md others/wubi.html "五笔输入法"
    src/keybord/keybord.md others/keyboard.html "键盘配置"
    src/openharmony/openharmony.md others/openharmony.html "OpenHarmony编译运行调试环境"
    src/free-software/free-software.md others/free-software.html "自由软件介绍"
    src/lorawan/stm32-linux.md others/stm32-linux.html "STM32 Linux开发环境"
    src/health/tooth-clean.md others/tooth-clean.html "牙齿护理"
    # 翻译
    src/translations/nfs/rfc8881-nfsv4.1.md translations/rfc8881-nfsv4.1.html "Network File System (NFS) Version 4 Minor Version 1 Protocol"
    src/translations/nfs/rfc7862-nfsv4.2.md translations/rfc7862-nfsv4.2.html "Network File System (NFS) Version 4 Minor Version 2 Protocol"
    src/translations/smb/ms-smb.md translations/ms-smb.html "[MS-SMB]: Server Message Block (SMB) Protocol"
    src/translations/smb/ms-smb2.md translations/ms-smb2.html "[MS-SMB2]: Server Message Block (SMB) Protocol Versions 2 and 3"
    src/translations/nfs/client-identifier.rst translations/client-identifier.html "NFSv4 client identifier"
    src/translations/nfs/cthon-nfs-tests-readme.md translations/cthon-nfs-tests-readme.html "Connectathon NFS tests README"
    src/translations/nfs/bugzilla-redhat-bug-2176575.md translations/bugzilla-redhat-bug-2176575.html "Red Hat Bugzilla - Bug 2176575 - intermittent severe NFS client performance drop via nfs_server_reap_expired_delegations looping?"
    src/translations/btrfs/btrfs-doc.rst translations/btrfs-doc.html "BTRFS documentation"
    src/translations/wine/building-wine-winehq-wiki.md translations/building-wine-winehq-wiki.html "Building Wine - WineHQ Wiki"
    src/translations/wine/box64-docs-X64WINE.md translations/box64-docs-X64WINE.html "box64 Installing Wine64"
    src/translations/wine/box86-docs-X86WINE.md translations/box86-docs-X86WINE.html "box86 Installing Wine (and winetricks)"
    src/translations/tests/ltp-readme.md translations/ltp-readme.html "Linux Test Project README"
    src/translations/tests/ltp-network-tests-readme.md translations/ltp-network-tests-readme.html "LTP Network Tests README"
    src/translations/qemu/qemu-networking-nat.md translations/qemu-networking-nat.html "QEMU Documentation/Networking/NAT"
    src/translations/tests/xfstests-readme.md translations/xfstests-readme.html "(x)fstests README"
    # private
    src/private/v2ray/v2ray.md private/v2ray.html "v2ray代理服务器"
    src/private/chatgpt/chatgpt.md private/chatgpt.html "注册ChatGPT"
)

init_begin() {
    mkdir -p ${tmp_html_path}
    bash ${src_path}/blog/courses/remove-private.sh
}

init_end() {
    rm ${html_path}/ -rf
    mv ${tmp_html_path} ${html_path}
}

create_html() {
    # --standalone：此选项指示 pandoc 生成一个完全独立的输出文件，包括文档标题、样式表和其他元数据，使输出文件成为一个完整的文档。
    # --metadata encoding=gbk：这个选项允许您添加元数据。在这种情况下，您将 encoding 设置为 gbk，指定输出 HTML 文档的字符编码为 GBK。这对于确保生成的文档以正确的字符编码进行保存非常重要。
    # --toc：这个选项指示 pandoc 生成一个包含文档目录（Table of Contents，目录）的 HTML 输出。TOC 将包括文档中的章节和子章节的链接，以帮助读者导航文档。
    pandoc_common_options="--to html --standalone --metadata encoding=gbk --toc --number-sections --css https://chenxiaosong.com/stylesheet.css"

    element_count="${#array[@]}" # 总个数
    for ((index=0; index<${element_count}; index=$((index + 3)))); do
        src_file=${src_path}/blog/${array[${index}]}
        if [[ ${array[${index}]} == '/'* ]]; then
            src_file=${array[${index}]} # 绝对路径
        fi
        dst_file=${tmp_html_path}/${array[${index}+1]} # 生成的html文件名
        dst_dir="$(dirname "${dst_file}")" # html文件所在的文件夹
        if [ ! -d "${dst_dir}" ]; then
            mkdir -p "${dst_dir}" # 文件夹不存在就创建
        fi
        from_format="--from markdown"
        if [[ ${array[${index}]} == *.rst ]]; then
            from_format="--from rst" # rst格式
        fi
        pandoc ${src_file} -o ${dst_file} --metadata title="${array[${index}+2]}" ${from_format} ${pandoc_common_options}
    done
}

copy_secret_repository() {
    # pictures是我的私有仓库
    cp ${src_path}/pictures/public/ ${tmp_html_path}/pictures -rf
}

copy_public_files() {
    # css样式
    cp ${src_path}/blog/src/chenxiaosong.com/stylesheet.css ${tmp_html_path}/
}

change_perm() {
    chown -R www-data:www-data ${tmp_html_path}/

    # -type f：这个选项告诉 find 只搜索普通文件（不包括目录和特殊文件）。
    # -exec chmod 400 {} +：这个部分告诉 find 对每个找到的文件执行 chmod 400 操作。{} 表示找到的文件的占位符，+ 表示一次处理多个文件以提高效率。
    find ${tmp_html_path}/ -type f -exec chmod 400 {} +

    # -type d：这个选项告诉find只搜索目录（不包括普通文件）。
    find ${tmp_html_path}/ -type d -exec chmod 500 {} +
}

add_common() {
    # 先去除common.html文件中其他内容
    sed -i '/<\/header>/,/<\/body>/!d' ${tmp_html_path}/common.html # 只保留</header>到</body>的内容
    sed -i '1d;$d' ${tmp_html_path}/common.html # 删除第一行和最后一行
    # 在<header之后插入common.html整个文件
    # find ${tmp_html_path}/ -type f -name '*.html' -exec sed -i -e '/<header/r ${tmp_html_path}/common.html' {} + # 所有文件
    find ${tmp_html_path}/ -type f -name '*.html' | grep -v ${tmp_html_path}/index.html \
        | xargs sed -i -e '/<header/r '${tmp_html_path}'/common.html' # index文件除外
}

init_begin
create_html
copy_secret_repository
copy_public_files
change_perm
add_common
init_end
