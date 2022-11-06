[toc]

# 单队列 和 多队列

mq: q->mq_ops 不为空
sq: q->mq_ops 为空，make_request_fn = blk_queue_bio
bio_based: q->mq_ops 为空，自定义 make_request_fn（没有rq）

单队列当前主线已经不支持，4.19只有 DM 和 SCSI 支持单队列，需要修改配置 CONFIG_SCSI_MQ_DEFAULT 和 CONFIG_DM_MQ_DEFAULT

4.19 nvme:
```c
// modprobe nvme

kthread
  worker_thread
    process_one_work
      nvme_reset_work
        nvme_alloc_admin_tags
          blk_mq_init_queue
            blk_mq_init_allocated_queue
              blk_queue_make_request

kthread
  worker_thread
    process_scheduled_works
      process_one_work
        nvme_scan_work
          nvme_scan_ns_list
            nvme_validate_ns
              nvme_alloc_ns
                blk_mq_init_queue
                  blk_mq_init_allocated_queue
                    blk_queue_make_request
```

# max_sectors_kb

```shell
cat /sys/block/sda/queue/max_sectors_kb
```