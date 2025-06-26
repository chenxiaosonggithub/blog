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

- [NeilBrown <neilb@suse.de> `Re: [RFC PATCH] nfsd: convert the nfsd_users to atomic_t`](https://lore.kernel.org/all/175042051171.608730.8613669948428192921@noble.neil.brown.name/)

前置补丁:

- 4.19可不合: `[PATCH 07/10] 97ad4031e295 nfsd4: add a client info file`](https://lore.kernel.org/all/1556201060-7947-8-git-send-email-bfields@redhat.com/)
- [`c6c7f2a84da4 nfsd: Ensure knfsd shuts down when the "nfsd" pseudofs is unmounted`](https://lore.kernel.org/all/20210313210847.569041-1-trondmy@kernel.org/)
- [`[PATCH 01/20] 89b24336f03a NFSD: handle error better in write_ports_addfd()`](https://lore.kernel.org/all/163816148551.32298.1997321981162233125.stgit@noble.brown/)
- [`[PATCH 02/20] df5e49c880ea SUNRPC: change svc_get() to return the svc.`](https://lore.kernel.org/all/163816148552.32298.18413679797079617436.stgit@noble.brown/)
- [`[PATCH v2] c20106944eb6 NFSD: Keep existing listeners on portlist error`](https://lore.kernel.org/all/547ee3794ac9678bc20ccb6ec35ba0fca5fe92f2.1633540771.git.bcodding@redhat.com/)
- [`[PATCH 03/20] 8c62d12740a1 SUNRPC/NFSD: clean up get/put functions.`](https://lore.kernel.org/all/163816148553.32298.12054000235093970423.stgit@noble.brown/)
- [`[PATCH 04/20] ec52361df99b SUNRPC: stop using ->sv_nrthreads as a refcount`](https://lore.kernel.org/all/163816148554.32298.8307258870002897708.stgit@noble.brown/)
- 4.19可不合: [`[PATCH v2 2/3] e567b98ce9a4 nfsd: protect concurrent access to nfsd stats counters`](https://lore.kernel.org/all/20210106075236.4184-3-amir73il@gmail.com/)
- [`[PATCH 05/20] 9b6c8c9bebcc nfsd: make nfsd_stats.th_cnt atomic_t`](https://lore.kernel.org/all/163816148555.32298.5422275287728622222.stgit@noble.brown/)
- [`[PATCH 06/20] 2a36395fac3b SUNRPC: use sv_lock to protect updates to sv_nrthreads.`](https://lore.kernel.org/all/163816148556.32298.17419698380488869158.stgit@noble.brown/)
- [`[PATCH 07/20] 9d3792aefdcd NFSD: narrow nfsd_mutex protection in nfsd thread`](https://lore.kernel.org/all/163816148556.32298.7308512506129152207.stgit@noble.brown/)

