obj-m += debug_counted_by.o

ARCH=x86_64
CROSS_COMPILE=

KDIR	:= /home/sonvhi/chenxiaosong/code/smb-kernel/x86_64-build
PWD	:= $(shell pwd)

all:
	$(MAKE) -C $(KDIR) M=$(PWD) ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} modules

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} clean

