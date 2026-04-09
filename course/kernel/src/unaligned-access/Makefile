obj-m += unalign_test.o

ARCH=arm64
CROSS_COMPILE='aarch64-linux-gnu-'
PWD := $(shell pwd)

KDIR := /home/chenxiaosong/code/smb-kernel/arm64-build

all:
	$(MAKE) -C $(KDIR) M=$(PWD) ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} modules

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} clean
