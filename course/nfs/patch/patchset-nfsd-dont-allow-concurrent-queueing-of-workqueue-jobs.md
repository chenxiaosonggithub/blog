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


## 4.19合补丁

前置补丁:

```sh
12357f1b2c8e nfsd: minor 4.1 callback cleanup
2bbfed98a4d8 nfsd: Fix races between nfsd4_cb_release() and nfsd4_shutdown_callback()
b95239ca4954 nfsd: make nfsd4_run_cb a bool return function: 把nfsd4_run_cb函数改成有返回值
```

4.19可不合的前置补丁:
```sh
# 引入 nfs4_cb_getattr
c5967721e106 NFSD: handle GETATTR conflict with write delegation
# 引入 deleg_reaper
44df6f439a17 NFSD: add delegation reaper to react to low memory condition
# 引入 nfsd4_send_cb_offload
e72f9bc006c0 NFSD: Add nfsd4_send_cb_offload()
# 引入 nfsd4_do_async_copy （其中的部分代码独立成nfsd4_send_cb_offload）
e0639dc5805a NFSD introduce async copy feature
```

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

# Li Lingfeng <lilingfeng3@huawei.com> 未合入的补丁[`nfsd: decrease cl_cb_inflight if fail to queue cb_work`](https://lore.kernel.org/linux-nfs/20250218135423.1487309-1-lilingfeng3@huawei.com/)

```
在 nfsd4_run_cb 中，cl_cb_inflight 会在尝试将 cb_work 入队到 callback_wq 之前就被递增。这个计数可以在以下三种情况下递减：

- 如果在 nfsd4_run_cb 中排队失败，则会相应地将该计数减一；
- 当 cb_work 正在运行时，在 nfsd4_run_cb_work 的异常分支中通过调用 nfsd41_destroy_cb 将计数减一；
- 在 rpc_task 的释放回调中减小计数——要么在 nfsd4_cb_probe_release 中直接调用 nfsd41_cb_inflight_end，要么在 nfsd4_cb_release 中调用 nfsd41_destroy_cb。

然而，在 nfsd4_cb_release 中，如果当前的 cb_work 需要重启，该计数并不会被减小，而是期望在 cb_work 真正运行时再做减少处理。如果此时排队失败，就会造成计数泄漏，最终导致 nfsd 服务无法退出，表现如下：

[root@nfs_test2 ~]# cat /proc/2271/stack
[<0>] nfsd4_shutdown_callback+0x22b/0x290
[<0>] __destroy_client+0x3cd/0x5c0
[<0>] nfs4_state_destroy_net+0xd2/0x330
[<0>] nfs4_state_shutdown_net+0x2ad/0x410
[<0>] nfsd_shutdown_net+0xb7/0x250
[<0>] nfsd_last_thread+0x15f/0x2a0
[<0>] nfsd_svc+0x388/0x3f0
[<0>] write_threads+0x17e/0x2b0
[<0>] nfsctl_transaction_write+0x91/0xf0
[<0>] vfs_write+0x1c4/0x750
[<0>] ksys_write+0xcb/0x170
[<0>] do_syscall_64+0x70/0x120
[<0>] entry_SYSCALL_64_after_hwframe+0x78/0xe2

通过在重启失败时也将 cl_cb_inflight 计数减一即可修复此问题。
```

[Jeff Layton](https://lore.kernel.org/linux-nfs/04ed0c70b85a1e8b66c25b9ad4d0aa4c2fb91198.camel@kernel.org/):
```
实际上，我认为情况并非如此简单。问题的微妙之处在于，回调的工作队列任务与 RPC 的工作队列任务运行在不同的线程上，因此它们之间可能会发生竞争。

当回调首次被排队时，cl_cb_inflight 会被递增，并且只有在 nfsd41_destroy_cb() 中才会释放。如果排队失败，那一定是因为在此期间，另一个地方已经通过 nfsd4_run_cb() 将该工作队列任务排队了。

这种情况可能发生在两个地方：nfsd4_cb_release() 和 nfsd4_run_cb()。既然问题出现在 nfsd4_cb_release() 中，那么唯一的可能就是有竞争发生，并且该回调已经被 nfsd4_run_cb() 排队了。这也会多次递增 cl_cb_inflight，那么你的补丁在这种情况下就说得通了。

不幸的是，如果之前没有其他地方释放该计数，插槽仍然可能会泄漏。我认为在无法排队时，或许需要调用 nfsd41_destroy_cb()，但这可能又会与实际运行的回调工作队列任务发生竞争。

我觉得我们可能需要考虑添加一个“此回调正在运行”的原子标志：在 nfsd4_run_cb() 中对该标志执行 test_and_set，并且只有当它返回 false 时才将工作队列任务排队。然后，在 nfsd41_destroy_cb() 中清除该标志。

这样就能确保在 nfsd4_cb_release() 中不会因为该标志已设置而无法排队回调任务。

你怎么看？
```

```c
nfsd4_run_cb
  nfsd41_cb_inflight_begin
    atomic_inc(&clp->cl_cb_inflight)
  nfsd41_cb_inflight_end // 失败时执行
    atomic_dec_and_wake_up(&clp->cl_cb_inflight)

nfsd4_run_cb_work
  if (!clnt || clp->cl_state == NFSD4_COURTESY) { // 异常
  if (!cb->cb_ops && clp->cl_minorversion) { // 或者nfsv4.1之后的版本不需要发送probe
  nfsd41_destroy_cb
    nfsd41_cb_inflight_end

nfsd4_cb_release
  nfsd4_queue_cb // 这里可能失败
  nfsd41_destroy_cb
    nfsd41_cb_inflight_end

nfsd4_cb_probe_release
  nfsd41_cb_inflight_end
```

