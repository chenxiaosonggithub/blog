# SPDX-License-Identifier: GPL-2.0-only
# builds the kprobes example kernel modules;
# then to use one (as root):  insmod <module_name.ko>

obj-m += kprobe_blkwrite.o

KDIR := /home/sonvhi/chenxiaosong/code/aarch64-4.19

all:
	make -C ${KDIR} M=`pwd`

clean:
	rm -f *.ko *.o *.mod *.mod.o *.mod.c .*.cmd *.symvers  modul*
