#include <linux/kernel.h>
#include <linux/module.h>

/* See MS-SMB2 2.2.31.1.1 */
struct srv_copychunk {
	__le64 SourceOffset;
	__le64 TargetOffset;
	__le32 Length;
	__le32 Reserved;
} __packed;

#define COPY_CHUNK_RES_KEY_SIZE	24
/* See MS-SMB2 2.2.31.1 */
/* this goes in the ioctl buffer when doing a copychunk request */
struct copychunk_ioctl_req {
	union {
		char SourceKey[COPY_CHUNK_RES_KEY_SIZE];
		__le64 SourceKeyU64[3];
	};
	__le32 ChunkCount;
	__le32 Reserved;
	struct srv_copychunk Chunks[] __counted_by_le(ChunkCount);
} __packed;

struct copychunk_ioctl_req *cc_req;

static int __init debug_init(void)
{
	int rc = 0;
	u32 chunk_count;
	size_t size;
	struct srv_copychunk *chunk;
	// struct srv_copychunk chunks_stack[4];
	// struct srv_copychunk chunk_stack;

	printk("sizeof(srv_copychunk):%zu, sizeof(copychunk_ioctl_req):%zu\n",
	       sizeof(struct srv_copychunk), sizeof(struct copychunk_ioctl_req));

	chunk_count = 4;
	size = struct_size(cc_req, Chunks, chunk_count);
	printk("size of cc_req:%zu\n", size);
	cc_req = kzalloc(size, GFP_KERNEL);
	if (!cc_req) {
		rc = -ENOMEM;
		goto out;
	}

	chunk = &cc_req->Chunks[1];
	chunk = &cc_req->Chunks[6];

	// memset(chunks_stack, 0, sizeof(chunks_stack));
	// chunk_stack = chunks_stack[5];

out:
	return rc;
}

static void __exit debug_exit(void)
{
	kfree(cc_req);
}

module_init(debug_init)
module_exit(debug_exit)
MODULE_LICENSE("GPL");
