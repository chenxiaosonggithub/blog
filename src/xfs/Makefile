obj-m += debug-xfs-log.o

KDIR := /home/sonvhi/chenxiaosong/code/x86_64-linux/build

all:
	make -C ${KDIR} M=`pwd`

clean:
	rm -f *.ko *.o *.mod *.mod.o *.mod.c .*.cmd *.symvers  modul*
