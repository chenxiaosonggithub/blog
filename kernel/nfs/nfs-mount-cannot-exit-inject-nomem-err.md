[toc]

```c
mount
  path_mount
    do_new_mount
      vfs_get_tree
        nfs_get_tree
          nfs4_try_get_tree
            nfs4_create_server
              nfs4_init_server
                nfs4_set_client
                  nfs_get_client
                    nfs4_init_client
                      nfs4_discover_server_trunking
                        nfs41_discover_server_trunking
                          nfs4_schedule_state_manager
                            kthread_run
                              kthread_create
                                kthread_create_on_node
                                  __kthread_create_on_node
                                    create = kmalloc() = NULL
                                    return ERR_PTR(-ENOMEM)
                          nfs_wait_client_init_complete
```
