obj-m += kprobe-df-long-time.o
obj-m += kernel-open-file.o
obj-m += iterate-nfsv3-inodes.o

ARCH=x86_64
CROSS_COMPILE=

KDIR	:= /home/sonvhi/chenxiaosong/code/linux/x86_64-build
PWD     := $(shell pwd)

all:
	$(MAKE) -C $(KDIR) M=$(PWD) ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} modules

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} clean

