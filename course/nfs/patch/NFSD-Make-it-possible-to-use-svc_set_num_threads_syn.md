# [`[PATCH 08/20] 3409e4f1e8f2 NFSD: Make it possible to use svc_set_num_threads_sync`](https://lore.kernel.org/all/163816148557.32298.11233238491435215789.stgit@noble.brown/)

```
NFSD: 使能使用 svc_set_num_threads_sync

当前 nfsd 无法使用 svc_set_num_threads_sync。它使用的是不会等待线程退出的 svc_set_num_threads，并通过一个单独机制（nfsd_shutdown_complete）来等待完成。

nfsd 与其他服务不同的原因在于 nfsd 线程可以在调用 svc_set_num_threads 后单独退出——它们在接收到 SIGKILL 时终止。此外，当最后一个线程退出时，服务必须关闭（套接字关闭）。

为此，需要获取 nfsd_mutex，并且由于在调用 svc_set_num_threads 时需要持有该互斥锁，这二者无法相互等待。

本补丁修改了 nfsd 线程，使其能够在不阻塞 nfsd_mutex 的情况下释放对服务的引用，以便可以使用 svc_set_num_threads_sync：
 - 如果它可以释放非最后一个引用，则直接释放。这不会触发关闭，也不需要互斥锁。这会发生在除最后一个被发信号的线程以及由 nfsd_shutdown_threads() 关闭的线程之外的所有线程上。
 - 如果它可以在不阻塞的情况下获取互斥锁（trylock），则获取后释放引用。这很可能发生在最后一个被 SIGKILL 杀死的线程上。
 - 否则，可能有其他不相关任务持有该互斥锁（可能在另一个网络命名空间中），或者 nfsd_shutdown_threads() 正准备获取对服务的引用，此时我们可以安全地释放我们的引用。我们无法方便地获取这些事件的唤醒通知，而且也不太可能需要，因此我们会短暂休眠，然后再次检查。

通过此方式，我们可以废弃 nfsd_shutdown_complete 和 nfsd_complete_shutdown()，并切换到 svc_set_num_threads_sync。
```

相关邮件:

- [NeilBrown <neilb@suse.de> `Re: [RFC PATCH] nfsd: convert the nfsd_users to atomic_t`](https://lore.kernel.org/all/175042051171.608730.8613669948428192921@noble.neil.brown.name/):
```sh
我能找到的此崩溃的唯一可能原因是，在调用 nfsd_shutdown_net() 和随后调用 nfsd_shutdown_generic() 时，nfsd 线程仍在运行，从而导致工作队列被销毁。
这些线程都会收到 SIGKILL 信号，但没有任何机制去等待它们执行完毕。
这一点在提交
Commit: 3409e4f1e8f2 ("NFSD: Make it possible to use svc_set_num_threads_sync")
中得到了修正：在同步模式下，线程会被同步地停止，因此可以确保在移除工作队列之前，所有线程都已经停止运行。
```

前置补丁:

- [`c6c7f2a84da4 nfsd: Ensure knfsd shuts down when the "nfsd" pseudofs is unmounted`](https://lore.kernel.org/all/20210313210847.569041-1-trondmy@kernel.org/): `/proc/fs/nfsd`卸载时确保所有`nfsd`线程全部停止
  - 前置补丁, 4.19可不合: `[PATCH 07/10] 97ad4031e295 nfsd4: add a client info file`](https://lore.kernel.org/all/1556201060-7947-8-git-send-email-bfields@redhat.com/)
- [`[PATCH 01/20] 89b24336f03a NFSD: handle error better in write_ports_addfd()`](https://lore.kernel.org/all/163816148551.32298.1997321981162233125.stgit@noble.brown/): 确保`nfsd_serv`刚创建时才销毁
- [`[PATCH 02/20] df5e49c880ea SUNRPC: change svc_get() to return the svc.`](https://lore.kernel.org/all/163816148552.32298.18413679797079617436.stgit@noble.brown/): 让`svc_get()`有返回值
- [`[PATCH 03/20] 8c62d12740a1 SUNRPC/NFSD: clean up get/put functions.`](https://lore.kernel.org/all/163816148553.32298.12054000235093970423.stgit@noble.brown/): 重构`svc_destroy()`和`nfsd_destroy()`
  - 前置补丁: [`[PATCH v2] c20106944eb6 NFSD: Keep existing listeners on portlist error`](https://lore.kernel.org/all/547ee3794ac9678bc20ccb6ec35ba0fca5fe92f2.1633540771.git.bcodding@redhat.com/): 如果已经存在sockets就只是减少计数，不调用`nfsd_destroy()`
- [`[PATCH 04/20] ec52361df99b SUNRPC: stop using ->sv_nrthreads as a refcount`](https://lore.kernel.org/all/163816148554.32298.8307258870002897708.stgit@noble.brown/): `sv_nrthreads`只作为线程计数，新增`sv_refcnt`作为引用计数
  - 后续修复补丁: [`[PATCH 1/5] 2a501f55cd64 nfsd: call nfsd_last_thread() before final nfsd_put()`](https://lore.kernel.org/all/20231215010030.7580-2-neilb@suse.de/): 失败时调用`nfsd_last_thread()`
    - 前置补丁: [`[PATCH 05/12] 9f28a971ee9f nfsd: separate nfsd_last_thread() from nfsd_put()`](https://lore.kernel.org/all/20230731064839.7729-6-neilb@suse.de/): 从`nfsd_put()`中分离出函数`nfsd_last_thread()`
      - 前置补丁: [`[PATCH v2 3/8] 87cdd8641c8a SUNRPC: Remove svo_shutdown method`](https://lore.kernel.org/all/164511393711.1361.3789898013043466921.stgit@klimt.1015granger.net/): 删除结构体的`.svo_shutdown()`，在使用的地方直接调用函数
      - 前置补丁: [`[PATCH v2 4/8] 352ad31448fe SUNRPC: Rename svc_create_xprt()`](https://lore.kernel.org/all/164511394380.1361.15753264922295129414.stgit@klimt.1015granger.net/): 函数重命名成`svc_xprt_create()`
      - 前置补丁: [`[PATCH v2 6/8] c7d7ec8f043e SUNRPC: Remove svc_shutdown_net()`](https://lore.kernel.org/all/164511395701.1361.2321498517172060697.stgit@klimt.1015granger.net/): `svc_shutdown_net()`换成`svc_xprt_destroy_all()`
      - 前置补丁（头文件`nfsd.h`）, 4.19可不合: `73598a0cfb21 nfsd: don't allocate the versions array.`
      - 后续修复补丁: [`[PATCH] 88956eabfdea NFSD: fix possible oops when nfsd/pool_stats is closed.`](https://lore.kernel.org/all/169448190063.19905.9707641304438290692@noble.neil.brown.name/): 修复可能的空指针解引用
    - 后续修复补丁: [`[PATCH] 64e6304169f1 nfsd: drop the nfsd_put helper`](https://lore.kernel.org/all/20240103-nfsd-fixes-v1-1-4f4f9d7edd0d@kernel.org/)
- [`[PATCH 05/20] 9b6c8c9bebcc nfsd: make nfsd_stats.th_cnt atomic_t`](https://lore.kernel.org/all/163816148555.32298.5422275287728622222.stgit@noble.brown/): 把`nfsd_stats.th_cnt`变成原子变量
  - 前置补丁, 4.19可不合: [`[PATCH v2 2/3] e567b98ce9a4 nfsd: protect concurrent access to nfsd stats counters`](https://lore.kernel.org/all/20210106075236.4184-3-amir73il@gmail.com/)
- [`[PATCH 06/20] 2a36395fac3b SUNRPC: use sv_lock to protect updates to sv_nrthreads.`](https://lore.kernel.org/all/163816148556.32298.17419698380488869158.stgit@noble.brown/): 对`sv_nrthreads`加锁
- [`[PATCH 07/20] 9d3792aefdcd NFSD: narrow nfsd_mutex protection in nfsd thread`](https://lore.kernel.org/all/163816148556.32298.7308512506129152207.stgit@noble.brown/): 缩小`nfsd_mutex`加锁的范围
- [`[PATCH 09/20] 3ebdbe5203a8 SUNRPC: discard svo_setup and rename svc_set_num_threads_sync()`](https://lore.kernel.org/all/163816148558.32298.2182168040527421256.stgit@noble.brown/): 函数改名为`svc_set_num_threads()`
- [`[PATCH 10/20] d057cfec4940 NFSD: simplify locking for network notifier.`](https://lore.kernel.org/all/163816148559.32298.4434140851292696444.stgit@noble.brown/): 使用自旋锁`nfsd_notifier_lock`
  - 前置补丁（修改`nfsd_reset_versions()`），4.19可不合: `e333f3bbefe3 nfsd: Allow containers to set supported nfs versions`

