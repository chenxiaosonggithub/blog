[toc]

```shell
[   90.544769][  T913]  gsmld_receive_buf+0x113/0x2ca
[   90.546000][  T913]  tiocsti+0x1ef/0x2d7
[   90.549441][  T913]  tty_ioctl+0x449/0xc66
[   90.550558][  T913]  vfs_ioctl+0x6e/0xb6
[   90.551081][  T913]  __se_sys_ioctl+0xe6/0x105
[   90.551669][  T913]  __x64_sys_ioctl+0x79/0x97
[   90.552248][  T913]  do_syscall_64+0x43/0xc7
[   90.552794][  T913]  entry_SYSCALL_64_after_hwframe+0x63/0xcd
```

```c
ioctl
  vfs_ioctl
    tty_ioctl
      tiocsetd
        tty_set_ldisc
          tty_ldisc_open
            gsmld_open
              gsm_alloc_mux
                gsm = kzalloc(sizeof(struct gsm_mux), GFP_KERNEL)
                  kmalloc(size, flags | __GFP_ZERO)
                gsm->receive == NULL
                gsm->dead = true

ioctl
  vfs_ioctl
    tty_ioctl
      tiocsti
        gsmld_receive_buf
          gsm->receive == NULL

gsmld_ioctl
  gsm_config
    gsm_activate_mux
      gsm->receive != NULL
      gsm->dead = false

EPERM    
```