#define _GNU_SOURCE

#include <endian.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/syscall.h>
#include <sys/types.h>
#include <unistd.h>
#include <errno.h>

static long open_dev(void)
{
	char buf[] = "/dev/char/4:20";
	return open(buf, O_RDWR, 0);
}

int main()
{
	long fd;
	long res;
	int arg;

	fd = open_dev();
	printf("open fd:%ld, errno:%d\n", fd, errno);
	arg = 0x15;
	res = syscall(__NR_ioctl, fd, 0x5423, &arg);
	printf("ioctl res:%ld, errno:%d\n", res, errno);

	arg = 0;
	res = syscall(__NR_ioctl, fd, 0x5412, &arg);
	printf("ioctl res:%ld, errno:%d\n", res, errno);

	return 0;
}
