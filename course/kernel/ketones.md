# 环境

- [openeuler仓库](https://gitee.com/openeuler/ketones)
- [openkylin仓库](https://gitee.com/openkylin/ketones)

```sh
# Ubuntu/Debian/openKylin
sudo apt install clang llvm make gcc libelf-dev libbpf-dev
sudo apt install libncurses-dev libbfd-dev libssl-dev # 可选
# RHEL/CentOS/Fedora/openEuler
sudo yum install clang llvm make gcc elfutils-libelf-devel libbpf-devel
sudo yum install ncurses-devel binutils-devel openssl-devel # 可选

git clone https://gitee.com/openkylin/ketones.git
cd ketones
make -j$(nproc)
# Install to system
sudo make install
# Or install to custom directory
make install DESTDIR=/opt/ketones
# Build Specific Tools
# Build individual tools
make retsnoop tcpconnect fslatency
# Build with verbose output
make V=1 retsnoop
# Clean build
make clean
```

