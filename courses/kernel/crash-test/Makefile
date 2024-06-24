obj-m += crash-test.o

KBUILD_CFLAGS += -g

# fedora
# KDIR := /usr/src/kernels/6.9.5-200.fc40.aarch64
# ubuntu
KDIR := /usr/src/linux-headers-6.8.0-35-generic

all:
	make -C ${KDIR} M=`pwd`

clean:
	rm -f *.ko *.o *.mod *.mod.o *.mod.c .*.cmd *.symvers  modul*
