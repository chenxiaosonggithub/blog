# SPDX-License-Identifier: GPL-2.0-only

obj-m += dbg-wq.o

ARCH=x86_64
CROSS_COMPILE=

KDIR	:= /home/sonvhi/chenxiaosong/code/openeuler-kernel/x86_64-build
PWD	:= $(shell pwd)

all:
	$(MAKE) -C $(KDIR) M=$(PWD) ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} modules

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} clean

