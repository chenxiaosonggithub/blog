本文档翻译自[cifsd-team/ksmbd-tools/README.md](https://github.com/cifsd-team/ksmbd-tools/blob/1cbb9277cf48479036e5dee9f23e0ea6d47397c7/README.md)，翻译时文件的最新提交是`1cbb9277cf48479036e5dee9f23e0ea6d47397c7 ksmbd-tools: make share/user non-options and unify option naming`，大部分借助于ChatGPT翻译，仅作为我个人的参考，如果你想查阅，建议看英文文档，因为我不确定我记录的中文翻译是否完整和正确。

# ksmbd-tools

ksmbd-tools 是 ksmbd 内核服务器 的一组用户空间实用程序，ksmbd 已在 Linux 5.15 版本中合并到主线。

## Building and Installing

您应该首先检查您的发行版是否有 `ksmbd-tools` 的软件包，如果有的话，考虑通过包管理器安装它。否则，请按照以下说明自行构建它。可以使用 GNU Autotools 或 Meson 构建系统。

Debian 及其衍生版本的依赖项: `git` `gcc` `pkgconf` `autoconf`  
`automake` `libtool` `make` `meson` `ninja-build` `gawk` `libnl-3-dev`  
`libnl-genl-3-dev` `libglib2.0-dev`

RHEL 及其衍生版本的依赖项: `git` `gcc` `pkgconf` `autoconf`  
`automake` `libtool` `make` `meson` `ninja-build` `gawk` `libnl3-devel`  
`glib2-devel`

示例构建和安装:
```sh
git clone https://github.com/cifsd-team/ksmbd-tools.git
cd ksmbd-tools

# autotools build

./autogen.sh
./configure --with-rundir=/run

make
sudo make install

# meson build

mkdir build
cd build
meson -Drundir=/run ..

ninja
sudo ninja install
```

默认情况下，实用程序位于 `/usr/local/sbin`，它们默认使用的文件位于  
`/usr/local/etc` 下的 `ksmbd` 目录中。

如果您想将 ksmbd-tools 安装在 `/usr` 下，这可能会与使用包管理器安装的  
ksmbd-tools 冲突，请在 `configure` 或 `meson` 中添加 `--prefix=/usr` 和  
`--sysconfdir=/etc` 作为选项。在这种情况下，实用程序位于 `/usr/sbin`，它们  
默认使用的文件位于 `/etc` 下的 `ksmbd` 目录中。

很可能您应该将 `--with-rundir` 或 `-Drundir` 作为选项添加到 `configure` 或  
`meson` 中。这是因为您的系统可能没有在默认值给定的目录下挂载 tmpfs 文件系统。  
常见的选择是 `/run`、`/var/run` 或 `/tmp`。ksmbd-tools 使用该目录存放每个进程  
可修改的数据，即 `ksmbd.lock` 文件，该文件保存 `ksmbd.mountd` 管理进程的 PID。  
如果您的 autoconf 支持，您也可以选择将 `--runstatedir` 作为选项添加到 `configure` 中。

如果您有 systemd 并且它至少满足所需的最低版本，构建将安装 `ksmbd.service` 单元文件。  
该单元文件支持常见的单元命令，并处理加载内核模块。请注意，单元文件的位置可能与  
使用包管理器安装的 ksmbd-tools 冲突。您可以绕过版本检查并自己选择单元文件目录，  
通过将 `--with-systemdsystemunitdir=DIR` 或 `-Dsystemdsystemunitdir=DIR` 作为选项添加到  
`configure` 或 `meson` 中。

## Usage

帮助文档:
```sh
man 8 ksmbd.addshare
man 8 ksmbd.adduser
man 8 ksmbd.control
man 8 ksmbd.mountd
man 5 ksmbd.conf
man 5 ksmbdpwd.db
```

Example session:
```sh
# If you built and installed ksmbd-tools yourself using autoconf defaults,
# the utilities are in `/usr/local/sbin',
# the default user database is `/usr/local/etc/ksmbd/ksmbdpwd.db', and
# the default configuration file is `/usr/local/etc/ksmbd/ksmbd.conf'.

# Otherwise it is likely that,
# the utilities are in `/usr/sbin',
# the default user database is `/etc/ksmbd/ksmbdpwd.db', and
# the default configuration file is `/etc/ksmbd/ksmbd.conf'.

# Create the share path directory.
# The share stores files in this directory using its underlying filesystem.
mkdir -vp $HOME/MyShare

# Add a share to the default configuration file.
# Note that `ksmbd.addshare' does not do variable expansion.
# Without `--add', `ksmbd.addshare' will update `MyShare' if it exists.
sudo ksmbd.addshare --add \
                    --option "path = $HOME/MyShare" \
                    --option 'read only = no' \
                    MyShare

# The default configuration file now has a new section for `MyShare'.
#
# [MyShare]
#         ; share parameters
#         path = /home/tester/MyShare
#         read only = no
#
# Each share has its own section with share parameters that apply to it.
# A share parameter given in `[global]' changes its default value.
# `[global]' also has global parameters which are not share specific.

# You can interactively update a share by omitting `--option'.
# Without `--update', `ksmbd.addshare' will add `MyShare' if it does not exist.
sudo ksmbd.addshare --update MyShare

# Add a user to the default user database.
# You will be prompted for a password.
sudo ksmbd.adduser --add MyUser

# There is no system user called `MyUser' so it has to be mapped to one.
# We can force all users accessing the share to map to a system user and group.

# Update share parameters of a share in the default configuration file.
sudo ksmbd.addshare --update \
                    --option "force user = $USER" \
                    --option "force group = $USER" \
                    MyShare

# The default configuration file now has the updated share parameters.
#
# [MyShare]
#         ; share parameters
#         force group = tester
#         force user = tester
#         path = /home/tester/MyShare
#         read only = no
#

# Add the kernel module.
sudo modprobe ksmbd

# Start the user and kernel mode daemons.
# All interfaces are listened to by default.
sudo ksmbd.mountd

# Mount the new share with cifs-utils and authenticate as the new user.
# You will be prompted for the password given previously with `ksmbd.adduser'.
sudo mount -o user=MyUser //127.0.0.1/MyShare /mnt

# You can now access the share at `/mnt'.
sudo touch /mnt/new_file_from_cifs_utils

# Unmount the share.
sudo umount /mnt

# Update the password of a user in the default user database.
# `--password' can be used to give the password instead of prompting.
sudo ksmbd.adduser --update --password MyNewPassword MyUser

# Delete a user from the default user database.
sudo ksmbd.adduser --delete MyUser

# The utilities notify ksmbd.mountd of changes by sending it the SIGHUP signal.
# This can be done manually when changes are made without using the utilities.
sudo ksmbd.control --reload

# Toggle ksmbd debug printing of the `smb' component.
sudo ksmbd.control --debug smb

# Some changes require restarting the user and kernel mode daemons.
# Modifying any global parameter is one example of such a change.
# Restarting means starting `ksmbd.mountd' after shutting the daemons down.

# Shutdown the user and kernel mode daemons.
sudo ksmbd.control --shutdown

# Remove the kernel module.
sudo modprobe -r ksmbd
```

## Packages

The following packaging status tracker is provided by
[the Repology project](https://repology.org)
.

[![Packaging status](https://repology.org/badge/vertical-allrepos/ksmbd-tools.svg)](https://repology.org/project/ksmbd-tools/versions)