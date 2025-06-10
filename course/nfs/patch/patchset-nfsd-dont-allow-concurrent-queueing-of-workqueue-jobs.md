[[PATCH v2 0/5] nfsd: don't allow concurrent queueing of workqueue jobs](https://lore.kernel.org/all/20250220-nfsd-callback-v2-0-6a57f46e1c3a@kernel.org/):
```
在审视 Li Lingfeng 报告的 [1] 关于回调排队失败的问题时，我注意到可能存在这样的场景：回调工作队列（workqueue）中的任务会与某个 rpc_task 同时运行。由于它们会修改或读取相同的字段，这在最好的情况下也是不正确的，并且很可能带来危险。

该补丁集增加了一种新的机制，确保同一个 nfsd4_callback 在任何执行阶段都不会与自身并发运行。同时，它也为那些在回调运行期间需要获取并保持对象引用的场合提供了更可靠的处理手段。

这应当也能修复 Li Lingfeng 报告的问题，因为从 nfsd4_cb_release() 排队的工作将不再会失败。注意，在清洁地应用本补丁前，应当先从 nfsd-testing 中移除他们之前的补丁 (fdf5c9413ea)。
```

# [`1054e8ffc5c4 nfsd: prevent callback tasks running concurrently`](https://lore.kernel.org/all/20250220-nfsd-callback-v2-1-6a57f46e1c3a@kernel.org/)

```
nfsd4_callback 工作队列任务的作用是将背道通道（backchannel）的 RPC 排队给 rpciod。由于这些任务运行在不同的工作队列上下文中，一旦 rpc_task 被重新排入队列，就可能与工作队列任务本身并发执行。由于访问 nfsd4_callback 结构体中的字段时没有加锁，这种并发是有问题的。

为此，向 nfsd4_callback 结构体中添加了一个 unsigned long 类型的成员，并声明了一个新的标志位 NFSD4_CALLBACK_RUNNING。在尝试运行工作队列任务时，首先对该标志位执行 test_and_set_bit()，如果该函数返回 true（表示标志已被设置），则不再将任务排入队列；在 nfsd41_destroy_cb() 中清除 NFSD4_CALLBACK_RUNNING 标志。

这也为在必须在自旋锁（spinlock）下获取对象引用的代码路径中处理排队失败提供了更可靠的机制。现在我们可以先对 NFSD4_CALLBACK_RUNNING 执行 test_and_set_bit()，只有当其返回 false 时才对相关对象获取引用。

大多数 nfsd4_run_cb() 的调用方已改用该新标志或封装函数 nfsd4_try_run_cb()。唯一的主要例外是回调通道探测（callback channel probe），它使用自己的同步机制。
```

有些地方不是很理解，[已经发邮件咨询maintainer](https://lore.kernel.org/all/23651194C61FBB9C+e2ddd3f5-f51f-44c0-8800-d2abb08a2447@chenxiaosong.com/)。

# [`424dd3df1f99 nfsd: eliminate cl_ra_cblist and NFSD4_CLIENT_CB_RECALL_ANY`](https://lore.kernel.org/all/20250220-nfsd-callback-v2-2-6a57f46e1c3a@kernel.org/)

```
deleg_reaper() 会遍历 client_lru 列表，并使用 cl_ra_cblist 指针将任何合适的条目放入 “cblist”。然后它在自旋锁 (nn->client_lock) 之外对这些对象进行遍历，并为它们排队回调。

实际上，deleg_reaper() 在释放 nn->client_lock 之后所做的任何操作都不是阻塞操作。只需在持有 nn->client_lock 时将它们的工作队列任务入队即可。

此外，NFSD4_CLIENT_CB_RECALL_ANY 和 NFSD4_CALLBACK_RUNNING 这两个标志现在已完全等价。去掉 NFSD4_CLIENT_CB_RECALL_ANY，只保留回调结构体中的那个标志即可。
```

# [`49bdbdb11f70 nfsd: replace CB_GETATTR_BUSY with NFSD4_CALLBACK_RUNNING`](https://lore.kernel.org/all/20250220-nfsd-callback-v2-3-6a57f46e1c3a@kernel.org/)

```
这些标志本质上具有相同的用途，而且在同一时刻被设置和清除。去掉 CB_GETATTR_BUSY，只使用 NFSD4_CALLBACK_RUNNING 即可。

为了实现这一点，我们必须使用 clear_and_wake_up_bit()，但对其他类型的回调执行该操作则显得浪费。于是，在 cb_flags 中声明一个新的 NFSD4_CALLBACK_WAKE 标志，表示需要 wake_up，并且仅在处理 CB_GETATTR 时设置该标志。

此外，将等待改为使用 TASK_UNINTERRUPTIBLE 睡眠。此处是在 nfsd 线程的上下文中进行的，且永远不需要处理信号。
```

# [`32ce62c0f09c nfsd: move cb_need_restart flag into cb_flags`](https://lore.kernel.org/all/20250220-nfsd-callback-v2-4-6a57f46e1c3a@kernel.org/)

```
由于现在已有一个 cb_flags 字段，改用其中的新标志 NFSD4_CALLBACK_REQUEUE，而不再使用单独的布尔变量。
```

# [`ff383e8f9440 nfsd: handle errors from rpc_call_async()`](https://lore.kernel.org/all/20250220-nfsd-callback-v2-5-6a57f46e1c3a@kernel.org/)

```
rpc_call_async() 可能会失败（主要是由于内存分配失败）。如果发生这种情况，除了将回调重新排队并稍后重试之外，几乎别无他法。
```

