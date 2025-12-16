#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>
#include <stdbool.h>
#include <fcntl.h>
#include <string.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>


void dumpmem(FILE *out, const void *ptr, const size_t size)
{
    const size_t BYTES_PER_LINE = 16;
    size_t offset, read;

    uint8_t *p = (uint8_t *)ptr;
    const uint8_t *maxp = (p + size);

    if (out == NULL || ptr == NULL || size == 0)
    {
        return;
    }

    for (offset = read = 0; offset != size; offset += read)
    {
        uint8_t buf[BYTES_PER_LINE];

        for (read = 0; read != BYTES_PER_LINE && (&p[offset + read]) < maxp; read++)
        {
            buf[read] = p[offset + read];
        }

        if (read == 0)
            return;

        fprintf(out, "%.8x: ", (unsigned int)offset);

        /* raw data */
        for (size_t i = 0; i < read; i++)
        {
            fprintf(out, " %.2x", buf[i]);
            if (BYTES_PER_LINE > 8 && BYTES_PER_LINE % 2 == 0 && i == (BYTES_PER_LINE / 2 - 1))
                fprintf(out, " ");
        }

        /* ASCII */
        if (read < BYTES_PER_LINE)
        {
            for (size_t i = read; i < BYTES_PER_LINE; i++)
            {
                fprintf(out, "  ");
                fprintf(out, " ");
                if (BYTES_PER_LINE > 8 && BYTES_PER_LINE % 2 == 0 && i == (BYTES_PER_LINE / 2 - 1))
                    fprintf(out, " ");
            }
        }
        fprintf(out, " ");
        for (size_t i = 0; i < read; i++)
        {
            if (buf[i] <= 31 || buf[i] >= 127) /* ignore control and non-ASCII characters */
                fprintf(out, ".");
            else
                fprintf(out, "%c", buf[i]);
        }

        fprintf(out, "\n");
    }
}


/* See MS-SMB2 2.2.35 for a definition of the individual filter flags */
struct __attribute__((__packed__)) smb3_notify {
       uint32_t completion_filter;
       bool	watch_tree;
       uint32_t data_len;
       uint8_t	data[];
} __packed;

#define CIFS_IOC_NOTIFY  0x4005cf09 /* previous ioctl which simply returns when changes occur */
#define CIFS_IOC_NOTIFY_INFO 0xc009cf0b /* new ioctl for change notification */
int main(int argc, char **argv)
{
	struct smb3_notify *pnotify;
	int f, g;

	if ((f = open(argv[1], O_RDONLY)) < 0) {
		fprintf(stderr, "Failed to open %s\n", argv[1]);
		exit(1);
	}

	pnotify = malloc(sizeof(struct smb3_notify) + 200);
	memset(pnotify, 0, sizeof(struct smb3_notify) + 200);

	pnotify->watch_tree = false;
	pnotify->completion_filter = 0xFFF;
	pnotify->data_len = 200;

	if (ioctl(f, CIFS_IOC_NOTIFY_INFO, pnotify) < 0)
		printf("Error %d returned from ioctl\n", errno);
	else {
		printf("notify completed. returned data size is %d\n", pnotify->data_len);
		dumpmem(stdout, pnotify->data, pnotify->data_len);
	}
}



