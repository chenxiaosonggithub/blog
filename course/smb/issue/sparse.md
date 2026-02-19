
```sh
git clone https://git.kernel.org/pub/scm/devel/sparse/sparse.git /home/chenxiaosong/sparse
cd /home/chenxiaosong/sparse
make -j`nproc`

cd /home/chenxiaosong/smb-kernel
cat /etc/fedora-release # Fedora release 43 (Forty Three)
mkdir build_dir/
# wget -o build_dir/.config https://download.01.org/0day-ci/archive/20260216/202602162321.pMV2aDap-lkp@intel.com/config # 没有打开cifs配置
cp x86_64-build/.config build_dir/
git clone https://github.com/intel/lkp-tests.git ../lkp-tests
# dnf install install sparse -y # 版本太老
# CHECK选项指定sparse路径
COMPILER_INSTALL_PATH=$HOME/0day COMPILER=clang-20 ../lkp-tests/kbuild/make.cross W=1 C=1 CHECK=/home/chenxiaosong/code/sparse/sparse CF='-fdiagnostic-prefix -D__CHECK_ENDIAN__ -fmax-errors=unlimited -fmax-warnings=unlimited' O=build_dir ARCH=i386 olddefconfig
COMPILER_INSTALL_PATH=$HOME/0day COMPILER=clang-20 ../lkp-tests/kbuild/make.cross W=1 C=1 CHECK=/home/chenxiaosong/code/sparse/sparse CF='-fdiagnostic-prefix -D__CHECK_ENDIAN__ -fmax-errors=unlimited -fmax-warnings=unlimited' O=build_dir ARCH=i386 SHELL=/bin/bash fs/smb/client/
```

