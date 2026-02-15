if [ $# -ne 4 ]; then
	echo "用法: $0 <gcc/llvm> <lld/no-lld> <test/no-test> <all/menuconfig/modules/modules_install/bzImage>"
	exit 1
fi
compiler=$1
linker=$2
dir=$3
part=$4

COMPILER_OPT=""
case "$compiler" in
gcc)
	COMPILER_OPT=""
	;;
llvm)
	COMPILER_OPT="LLVM=1"
	;;
*)
	echo "Invalid compiler argument"
	exit
	;;
esac

LINKER_OPT=""
case "$linker" in
lld)
	LINKER_OPT="LD=ld.lld"
	;;
no-lld)
	LINKER_OPT=""
	;;
*)
	echo "Invalid linker argument"
	exit
	;;
esac

BUILD_DIR=""
case "$dir" in
test)
	BUILD_DIR="test-build"
	;;
no-test)
	BUILD_DIR="x86_64-build"
	;;
*)
	echo "Invalid build-dir argument"
	exit
	;;
esac

show_args() {
	echo
	echo "COMPILER_OPT: $COMPILER_OPT"
	echo "LINKER_OPT: $LINKER_OPT"
	echo "BUILD_DIR: $BUILD_DIR"
	echo "build part: $part"
	echo
}

olddefconfig() {
	make $COMPILER_OPT $LINKER_OPT O=$BUILD_DIR olddefconfig -j`nproc`
	return $?
}

menuconfig() {
	make $COMPILER_OPT $LINKER_OPT O=$BUILD_DIR menuconfig -j`nproc`
	return $?
}

bzImage() {
	make $COMPILER_OPT $LINKER_OPT O=$BUILD_DIR bzImage -j`nproc`
	return $?
}

modules() {
	make $COMPILER_OPT $LINKER_OPT O=$BUILD_DIR modules -j`nproc`
	return $?
}

modules_install() {
	make $COMPILER_OPT $LINKER_OPT O=$BUILD_DIR modules_install INSTALL_MOD_PATH=mod -j`nproc`
	return $?
}

show_args
sleep 2

case "$part" in
all)
	time olddefconfig && bzImage && modules && modules_install
	;;
menuconfig)
	time menuconfig
	;;
modules)
	time modules
	;;
modules_install)
	time modules && modules_install
	;;
bzImage)
	time bzImage
	;;
*)
	echo "Invalid part argument"
	exit
	;;
esac

show_args

