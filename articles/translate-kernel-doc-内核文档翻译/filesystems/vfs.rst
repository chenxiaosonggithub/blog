.. SPDX-License-Identifier: GPL-2.0

=========================================
Linux 虚拟文件系统概述
=========================================

本文是基于Documentation/filesystems/vfs.rst以下提交记录:

.. code-block:: shell

        commit 4c5b479975212065ef39786e115fde42847e95a9
        Author: Miklos Szeredi <mszeredi@redhat.com>
        Date:   Wed Apr 7 14:36:42 2021 +0200

        vfs: add fileattr ops

原作者: Richard Gooch <rgooch@atnf.csiro.au>

- Copyright (C) 1999 Richard Gooch
- Copyright (C) 2005 Pekka Enberg


Introduction
============

虚拟文件系统（也称为虚拟文件系统开关）是内核中的软件层，为用户空间程序提供文件系统接口。 它还在内核中提供了一个抽象，允许不同的文件系统实现共存。

VFS 系统调用 open(2)、stat(2)、read(2)、write(2)、chmod(2) 等是从进程上下文调用的。 文件系统锁定在文档 Documentation/filesystems/locking.rst 中有描述。


Directory Entry Cache (dcache)
------------------------------

VFS 实现了 open(2)、stat(2)、chmod(2) 和类似的系统调用。 VFS 使用传递给它们的路径名参数来搜索目录条目缓存（也称为 dentry 缓存或 dcache）。 这提供了一种非常快速的查找机制来将路径名（文件名）转换为特定的 dentry。 dentries 存在于 RAM 中，永远不会保存到磁盘：它们的存在只是为了性能。

dentry 缓存旨在成为整个文件空间的视图。 由于大多数计算机无法同时容纳 RAM 中的所有 dentry，因此缓存的某些位丢失了。 为了将您的路径名解析为一个 dentry，VFS 可能不得不沿途创建 dentry，然后加载 inode。 这是通过查找 inode 来完成的。


The Inode Object
----------------

单个 dentry 通常有一个指向 inode 的指针。 inode 是文件系统对象，例如常规文件、目录、FIFO 和其他beasts。 它们存在于磁盘上（对于块设备文件系统）或内存中（对于伪文件系统）。 需要时将位于磁盘上的 inode 复制到内存中，并将对 inode 的更改写回磁盘。 一个 inode 可以被多个 dentry 指向（例如，硬链接就是这样做的）。

查找inode 需要VFS 调用父目录inode 的lookup() 方法。 此方法由 inode 所在的特定文件系统实现安装。 一旦 VFS 拥有所需的 dentry（以及 inode），我们就可以执行所有这些无聊的事情，例如 open(2) 或 stat(2) 文件查看 inode 数据。 stat(2) 操作相当简单：一旦 VFS 有了 dentry，它就会查看 inode 数据并将其中的一些传回用户空间。


The File Object
---------------

打开文件需要另一个操作：文件结构的分配（这是文件描述符的内核端实现）。 新分配的文件结构用指向 dentry 的指针和一组文件操作成员函数进行初始化。 这些取自 inode 数据。 然后调用 open() 文件方法，以便特定的文件系统实现可以完成它的工作。 您可以看到这是 VFS 执行的另一个切换。 文件结构被放入进程的文件描述符表中。

读取、写入和关闭文件（以及其他各种 VFS 操作）是通过使用用户空间文件描述符获取适当的文件结构，然后调用所需的文件结构方法来完成所需的操作。 只要文件处于打开状态，它就会一直使用 dentry，这反过来意味着 VFS inode 仍在使用中。


Registering and Mounting a Filesystem
=====================================

要注册和取消注册文件系统，请使用以下 API 函数：

.. code-block:: c

	#include <linux/fs.h>

	extern int register_filesystem(struct file_system_type *);
	extern int unregister_filesystem(struct file_system_type *);

传递的 struct file_system_type 描述了您的文件系统。 当请求将文件系统挂载到命名空间中的目录时，VFS 将为特定文件系统调用适当的 mount() 方法。 引用 ->mount() 返回的树的新 vfsmount 将附加到挂载点，因此当路径名解析到达挂载点时，它将跳转到该 vfsmount 的根目录。

您可以在文件 /proc/filesystems 中看到所有注册到内核的文件系统。


struct file_system_type
-----------------------

这描述了文件系统。 从内核 2.6.39 开始，定义了以下成员：

.. code-block:: c

	struct file_system_type {
		const char *name;
		int fs_flags;
		struct dentry *(*mount) (struct file_system_type *, int,
					 const char *, void *);
		void (*kill_sb) (struct super_block *);
		struct module *owner;
		struct file_system_type * next;
		struct list_head fs_supers;
		struct lock_class_key s_lock_key;
		struct lock_class_key s_umount_key;
	};

``name``
	文件系统类型的名称，例如“ext2”、“iso9660”、“msdos”等

``fs_flags``
	各种标志（即 FS_REQUIRES_DEV、FS_NO_DCACHE 等）

``mount``
	应挂载此文件系统的新实例时调用的方法

``kill_sb``
	应关闭此文件系统的实例时调用的方法

``owner``
	对于内部 VFS 使用：在大多数情况下，您应该将其初始化为 THIS_MODULE。

``next``
	对于内部 VFS 使用：您应该将其初始化为 NULL

s_lock_key, s_umount_key: 特定于 lockdep

mount() 方法具有以下参数：

``struct file_system_type *fs_type``
	描述文件系统，部分由特定的文件系统代码初始化

``int flags``
	安装标志

``const char *dev_name``
	我们正在安装的设备名称。

``void *data``
	任意挂载选项，通常以 ASCII 字符串形式出现（参见“Mount Options”部分）

mount() 方法必须返回调用者请求的树的根目录项。必须获取对其超级块的活动引用，并且必须锁定超级块。失败时它应该返回 ERR_PTR(error)。

参数与 mount(2) 的参数匹配，它们的解释取决于文件系统类型。例如。对于块文件系统，dev_name 被解释为块设备名称，该设备被打开，如果它包含合适的文件系统映像，该方法会相应地创建和初始化 struct super_block，将其根目录返回给调用者。

->mount() 可以选择返回现有文件系统的子树——它不必创建一个新的。从调用者的角度来看，主要结果是对要附加的（子）树根部的 dentry 的引用；创建新的超级块是一种常见的副作用。

mount() 方法填充的超级块结构中最有趣的成员是“s_op”字段。这是一个指向“struct super_operations”的指针，它描述了文件系统实现的下一级。

通常，文件系统使用通用 mount() 实现之一并提供 fill_super() 回调。通用变体是：

``mount_bdev``
	挂载驻留在块设备上的文件系统

``mount_nodev``
	挂载不受设备支持的文件系统

``mount_single``
	挂载一个在所有挂载之间共享实例的文件系统

fill_super() 回调实现具有以下参数：

``struct super_block *sb``
	超级块结构。 回调必须正确初始化它。

``void *data``
	任意挂载选项，通常以 ASCII 字符串形式出现（参见“Mount Options”部分）

``int silent``
	是否对错误保持沉默


The Superblock Object
=====================

超级块对象表示已安装的文件系统。


struct super_operations
-----------------------

这描述了VFS如何操作文件系统的超级块。 从内核2.6.22开始，定义了以下成员：

.. code-block:: c

	struct super_operations {
		struct inode *(*alloc_inode)(struct super_block *sb);
		void (*destroy_inode)(struct inode *);

		void (*dirty_inode) (struct inode *, int flags);
		int (*write_inode) (struct inode *, int);
		void (*drop_inode) (struct inode *);
		void (*delete_inode) (struct inode *);
		void (*put_super) (struct super_block *);
		int (*sync_fs)(struct super_block *sb, int wait);
		int (*freeze_fs) (struct super_block *);
		int (*unfreeze_fs) (struct super_block *);
		int (*statfs) (struct dentry *, struct kstatfs *);
		int (*remount_fs) (struct super_block *, int *, char *);
		void (*clear_inode) (struct inode *);
		void (*umount_begin) (struct super_block *);

		int (*show_options)(struct seq_file *, struct dentry *);

		ssize_t (*quota_read)(struct super_block *, int, char *, size_t, loff_t);
		ssize_t (*quota_write)(struct super_block *, int, const char *, size_t, loff_t);
		int (*nr_cached_objects)(struct super_block *);
		void (*free_cached_objects)(struct super_block *, int);
	};

除非另有说明，否则所有方法都会在不持有任何锁的情况下调用。 这意味着大多数方法都可以安全地阻塞。 所有方法仅从进程上下文调用（即不是从中断处理程序或下半部分）。

``alloc_inode``
        该方法由 alloc_inode() 调用，为 struct inode 分配内存并对其进行初始化。 如果未定义此函数，则会分配一个简单的“struct inode”。 通常 alloc_inode 将用于分配一个更大的结构，其中包含一个嵌入其中的“struct inode”。

``destroy_inode``
        该方法由 destroy_inode() 调用以释放为 struct inode 分配的资源。 只有在定义了 ->alloc_inode 并且简单地撤消了 ->alloc_inode 所做的任何事情时才需要它。

``dirty_inode``
        当 inode 被标记为脏时，VFS 会调用此方法。 这是专门针对被标记为脏的 inode 本身，而不是其数据。 如果更新需要由 fdatasync() 持久化，则 I_DIRTY_DATASYNC 将在 flags 参数中设置。

``write_inode``
        当 VFS 需要将 inode 写入磁盘时调用此方法。 第二个参数指示写入是否应该同步，并非所有文件系统都检查此标志。

``drop_inode``
        当对 inode 的最后一次访问被删除时调用，并持有 inode->i_lock 自旋锁。

        此方法应为 NULL（普通 UNIX 文件系统语义）或“generic_delete_inode”（对于不想缓存 inode 的文件系统 - 导致无论 i_nlink 的值如何，始终调用“delete_inode”）

        “generic_delete_inode()”行为相当于在 put_inode() 情况下使用“force_delete”的旧做法，但没有“force_delete()”方法所具有的竞争。

``delete_inode``
        当 VFS 想要删除一个 inode 时调用

``put_super``
        当 VFS 希望释放超级块（即卸载）时调用。 这是在持有超级块锁的情况下调用的

``sync_fs``
        当 VFS 写出与超级块相关的所有脏数据时调用。 第二个参数指示该方法是否应该等到写出完成。 可选的。

``freeze_fs``
        当 VFS 锁定文件系统并强制其进入一致状态时调用。 此方法当前由逻辑卷管理器 (LVM) 使用。

``unfreeze_fs``
        当 VFS 解锁文件系统并使其再次可写时调用。

``statfs``
        当 VFS 需要获取文件系统统计信息时调用。

``remount_fs``
        重新挂载文件系统时调用。 这是在持有内核锁的情况下调用的

``clear_inode``
        调用然后 VFS 清除 inode。 可选的

``umount_begin``
        当 VFS 卸载文件系统时调用。

``show_options``
        由 VFS 调用以显示 /proc/<pid>/mounts 的挂载选项。 （请参阅“Mount Options”部分）

``quota_read``
        由 VFS 调用以从文件系统配额文件中读取。

``quota_write``
        由 VFS 调用以写入文件系统配额文件。

``nr_cached_objects``
        由文件系统的 sb 缓存收缩函数调用，以返回它包含的可释放缓存对象的数量。 可选的。


``free_cache_objects``
        由文件系统的 sb 缓存收缩函数调用以扫描指示尝试释放它们的对象数量。 可选，但任何实现此方法的文件系统还需要实现 ->nr_cached_objects 才能正确调用它。

        我们不能对文件系统可能遇到的任何错误做任何事情，因此返回 void 类型。 如果 VM 在 GFP_NOFS 条件下尝试回收，则永远不会调用此方法，因此此方法不需要自己处理这种情况。

        实现必须在完成的任何扫描循环内包括条件重新调度调用。 这允许 VFS 确定适当的扫描批量大小，而不必担心实现是否会由于大扫描批量大小而导致延迟问题。

设置 inode 的人负责填写“i_op”字段。 这是一个指向“struct inode_operations”的指针，它描述了可以在单个 inode 上执行的方法。


struct xattr_handlers
---------------------

在支持扩展属性 (xattrs) 的文件系统上，s_xattr 超级块字段指向以 NULL 结尾的 xattr 处理程序数组。 扩展属性是name:value(名称：值)对。

``name``
        指示处理程序匹配具有指定名称的属性（例如“system.posix_acl_access”）； 前缀字段必须为 NULL。

``prefix``
        指示处理程序匹配具有指定名称前缀的所有属性（例如“user.”）； 名称字段必须为 NULL。

``list``
        确定是否应为特定 dentry 列出与此 xattr 处理程序匹配的属性。 由一些 listxattr 实现（如 generic_listxattr）使用。

``get``
        由 VFS 调用以获取特定扩展属性的值。 该方法由 getxattr(2) 系统调用调用。

``set``
        由 VFS 调用以设置特定扩展属性的值。 当新值为 NULL 时，调用以删除特定的扩展属性。 该方法由 setxattr(2) 和 removexattr(2) 系统调用调用。

当文件系统的 xattr 处理程序均不匹配指定的属性名称或文件系统不支持扩展属性时，各种 ``*xattr(2)`` 系统调用将返回 -EOPNOTSUPP。


The Inode Object
================

一个 inode 对象代表文件系统中的一个对象。


struct inode_operations
-----------------------

这描述了 VFS 如何操作文件系统中的 inode。 从内核 2.6.22 开始，定义了以下成员：

.. code-block:: c

	struct inode_operations {
		int (*create) (struct user_namespace *, struct inode *,struct dentry *, umode_t, bool);
		struct dentry * (*lookup) (struct inode *,struct dentry *, unsigned int);
		int (*link) (struct dentry *,struct inode *,struct dentry *);
		int (*unlink) (struct inode *,struct dentry *);
		int (*symlink) (struct user_namespace *, struct inode *,struct dentry *,const char *);
		int (*mkdir) (struct user_namespace *, struct inode *,struct dentry *,umode_t);
		int (*rmdir) (struct inode *,struct dentry *);
		int (*mknod) (struct user_namespace *, struct inode *,struct dentry *,umode_t,dev_t);
		int (*rename) (struct user_namespace *, struct inode *, struct dentry *,
			       struct inode *, struct dentry *, unsigned int);
		int (*readlink) (struct dentry *, char __user *,int);
		const char *(*get_link) (struct dentry *, struct inode *,
					 struct delayed_call *);
		int (*permission) (struct user_namespace *, struct inode *, int);
		int (*get_acl)(struct inode *, int);
		int (*setattr) (struct user_namespace *, struct dentry *, struct iattr *);
		int (*getattr) (struct user_namespace *, const struct path *, struct kstat *, u32, unsigned int);
		ssize_t (*listxattr) (struct dentry *, char *, size_t);
		void (*update_time)(struct inode *, struct timespec *, int);
		int (*atomic_open)(struct inode *, struct dentry *, struct file *,
				   unsigned open_flag, umode_t create_mode);
		int (*tmpfile) (struct user_namespace *, struct inode *, struct dentry *, umode_t);
	        int (*set_acl)(struct user_namespace *, struct inode *, struct posix_acl *, int);
		int (*fileattr_set)(struct user_namespace *mnt_userns,
				    struct dentry *dentry, struct fileattr *fa);
		int (*fileattr_get)(struct dentry *dentry, struct fileattr *fa);
	};

同样，除非另有说明，否则所有方法都会在不持有任何锁的情况下调用。

``create``
        由 open(2) 和 creat(2) 系统调用调用。 仅当您想支持常规文件时才需要。 你得到的 dentry 不应该有一个 inode（即它应该是一个负 dentry）。 在这里，您可能会使用 dentry 和新创建的 inode 调用 d_instantiate()

``lookup``
        当 VFS 需要在父目录中查找 inode 时调用。 要查找的名称可在 dentry 中找到。 此方法必须调用 d_add() 将找到的 inode 插入到 dentry 中。 inode 结构中的“i_count”字段应该递增。 如果指定的 inode 不存在，则应将 NULL inode 插入到 dentry 中（这称为 negative dentry）。 从这个例程返回错误代码必须只在真正的错误时完成，否则创建具有系统调用的 inode 将失败，如 create(2)、mknod(2)、mkdir(2) 等。 如果您希望重载 dentry 方法，那么您应该初始化 dentry 中的“d_dop”字段； 这是一个指向结构“dentry_operations”的指针。 这个方法是用持有的目录 inode 信号量调用的

``link``
        由 link(2) 系统调用调用。 仅当您想支持硬链接时才需要。 您可能需要像在 create() 方法中一样调用 d_instantiate()

``unlink``
        由 unlink(2) 系统调用调用。 仅当您想支持删除 inode 时才需要

``symlink``
        由 symlink(2) 系统调用调用。 仅当您想支持符号链接时才需要。 您可能需要像在 create() 方法中一样调用 d_instantiate()

``mkdir``
        由 mkdir(2) 系统调用调用。 仅当您想支持创建子目录时才需要。 您可能需要像在 create() 方法中一样调用 d_instantiate()

``rmdir``
        由 rmdir(2) 系统调用调用。 仅当您想支持删除子目录时才需要

``mknod``
        由 mknod(2) 系统调用调用以创建设备（字符、块）inode 或命名管道 (FIFO) 或套接字。 仅当您希望支持创建这些类型的 inode 时才需要。 您可能需要像在 create() 方法中一样调用 d_instantiate()

``rename``
        由 rename(2) 系统调用调用以重命名对象，使其具有由第二个 inode 和 dentry 给出的父级和名称。

        对于任何不受支持或未知的标志，文件系统必须返回 -EINVAL。 目前实现了以下标志： (1) RENAME_NOREPLACE：这个标志表明如果重命名的目标存在，重命名应该失败并显示 -EEXIST 而不是替换目标。 VFS 已经检查是否存在，因此对于本地文件系统，RENAME_NOREPLACE 实现等效于普通重命名。 (2) RENAME_EXCHANGE：交换源和目标。 两者都必须存在； 这是由 VFS 检查的。 与普通重命名不同，源和目标可能是不同的类型。

``get_link``
        由 VFS 调用以遵循指向它所指向的 inode 的符号链接。仅当您想支持符号链接时才需要。此方法返回要遍历的符号链接体（并可能使用 nd_jump_link() 重置当前位置）。如果在 inode 消失之前 body 不会消失，则不需要其他任何东西；如果需要以其他方式固定，请通过让 get_link(..., ..., done) 执行 set_delayed_call(done, destructor, argument) 来安排释放。在这种情况下，一旦 VFS 处理完您返回的主体，就会调用destructor(argument)。可以在 RCU 模式下调用；这由 NULL dentry 参数指示。如果不离开 RCU 模式就不能处理请求，让它返回 ERR_PTR(-ECHILD)。

        如果文件系统将符号链接目标存储在 ->i_link 中，则 VFS 可以直接使用它而无需调用 ->get_link();但是，仍然必须提供 ->get_link()。 ->i_link 必须在 RCU 宽限期之后才能释放。写入 ->i_link post-iget() 时间需要“释放”内存屏障。

``readlink``
        这现在只是 readlink(2) 在 ->get_link 使用 nd_jump_link() 或 object 实际上不是符号链接的情况下使用的覆盖。 通常文件系统应该只为符号链接实现 ->get_link 并且 readlink(2) 将自动使用它。

``permission``
        由 VFS 调用以检查对 POSIX-like 的文件系统的访问权限。

        可以在 rcu-walk 模式下调用（掩码和 MAY_NOT_BLOCK）。 如果在 rcu-walk 模式下，文件系统必须检查权限而不阻塞或存储到 inode。

        如果遇到 rcu-walk 无法处理的情况，返回 -ECHILD，它将在 ref-walk 模式下再次调用。

``setattr``
        由 VFS 调用以设置文件的属性。 此方法由 chmod(2) 和相关系统调用调用。

``getattr``
        由 VFS 调用以获取文件的属性。 此方法由 stat(2) 和相关系统调用调用。

``listxattr``
        由 VFS 调用以列出给定文件的所有扩展属性。 此方法由 listxattr(2) 系统调用调用。

``update_time``
        由 VFS 调用以更新特定时间或 inode 的 i_version。 如果未定义，VFS 将更新 inode 本身并调用 mark_inode_dirty_sync。

``atomic_open``
        在打开的最后一个组件上调用。 使用这种可选方法，文件系统可以在一个原子操作中查找、可能创建和打开文件。 如果它想将实际打开留给调用者（例如，如果文件被证明是一个符号链接、设备，或者只是文件系统不会对其进行原子打开的东西），它可以通过返回finish_no_open(file, dentry)来表示这一点。 仅当最后一个组件为负数或需要查找时才调用此方法。 缓存的正项仍然由 f_op->open() 处理。 如果文件已创建，则应在 file->f_mode 中设置 FMODE_CREATED 标志。 在 O_EXCL 的情况下，该方法必须仅在文件不存在时成功，因此 FMODE_CREATED 应始终在成功时设置。

``tmpfile``
        在 O_TMPFILE open() 的末尾调用。 可选，相当于在给定目录中自动创建、打开和取消链接文件。

``fileattr_get``
	called on ioctl(FS_IOC_GETFLAGS) and ioctl(FS_IOC_FSGETXATTR) to
	retrieve miscellaneous file flags and attributes.  Also called
	before the relevant SET operation to check what is being changed
	(in this case with i_rwsem locked exclusive).  If unset, then
	fall back to f_op->ioctl().
        调用 ioctl(FS_IOC_GETFLAGS) 和 ioctl(FS_IOC_FSGETXATTR) 以检索其他文件标志和属性。 在相关 SET 操作之前也调用以检查正在更改的内容（在这种情况下与 i_rwsem 锁定独占）。 如果未设置，则回退到 f_op->ioctl()。

``fileattr_set``
        调用 ioctl(FS_IOC_SETFLAGS) 和 ioctl(FS_IOC_FSSETXATTR) 以更改其他文件标志和属性。 呼叫者持有 i_rwsem 独占。 如果未设置，则回退到 f_op->ioctl()。


The Address Space Object
========================

地址空间对象用于对页面缓存中的页面进行分组和管理。它可用于跟踪文件（或其他任何内容）中的页面，还可以跟踪文件部分到进程地址空间的映射。

地址空间可以提供许多不同但相关的服务。这些包括传达内存压力、按地址查找页面以及跟踪标记为“脏”或“写回”的页面。

第一个可以独立于其他人使用。 VM 可以尝试写入脏页以清除它们，或释放干净页以重用它们。为此，它可以在脏页面上调用 ->writepage 方法，在设置了 PagePrivate 的干净页面上调用 ->releasepage 方法。没有 PagePrivate 和没有外部引用的干净页面将被释放，而不会通知 address_space。

要实现此功能，需要使用 lru_cache_add 将页面放置在 LRU 上，并且在使用页面时需要调用 mark_page_active。

页面通常通过 ->index 保存在基数树索引中。该树维护有关每个页面的 PG_Dirty 和 PG_Writeback 状态的信息，以便可以快速找到具有这些标志之一的页面。

Dirty 标签主要由 mpage_writepages 使用 - 默认 ->writepages 方法。它使用标记来查找脏页以调用 ->writepage。如果未使用 mpage_writepages（即地址提供自己的 ->writepages），则 PAGECACHE_TAG_DIRTY 标签几乎未使用。 write_inode_now 和sync_inode 确实使用它（通过__sync_single_inode）来检查->writepages 是否已成功写出整个address_space。

Filemap*wait* 和sync_page* 函数使用Writeback 标记，通过filemap_fdatawait_range 等待所有写回完成。

address_space 处理程序可以将额外信息附加到页面，通常使用“struct page”中的“private”字段。如果附加了此类信息，则应设置 PG_Private 标志。这将导致各种 VM 例程对 address_space 处理程序进行额外调用以处理该数据。

地址空间充当存储和应用程序之间的中介。数据一次整页读入地址空间，并通过复制页面或通过内存映射页面提供给应用程序。数据由应用程序写入地址空间，然后通常以整页写回存储，但是 address_space 对写入大小有更好的控制。

读取过程基本上只需要“readpage”。写过程比较复杂，使用write_begin/write_end或set_page_dirty将数据写入address_space，writepage和writepages将数据写回存储。

在 address_space 中添加和删除页面受 inode 的 i_mutex 保护。

将数据写入页面时，应设置 PG_Dirty 标志。它通常保持设置，直到 writepage 要求写入它。这应该清除 PG_Dirty 并设置 PG_Writeback。实际上可以在 PG_Dirty 清除后的任何时候写入。一旦知道它是安全的，就会清除 PG_Writeback。

回写使用 writeback_control 结构来指导操作。这为 writepage 和 writepages 操作提供了一些关于写回请求的性质和原因的信息，以及执行它的约束条件。它还用于将有关 writepage 或 writepages 请求结果的信息返回给调用者。


Handling errors during writeback
--------------------------------

大多数执行缓冲 I/O 的应用程序将定期调用文件同步调用（fsync、fdatasync、msync 或 sync_file_range）以确保写入的数据已进入后备存储。当写回期间出现错误时，他们希望在发出文件同步请求时报告该错误。在对一个请求报告错误后，对同一文件描述符的后续请求应返回 0，除非自上次文件同步以来发生了进一步的写回错误。

理想情况下，内核只会报告已写入但随后无法回写的文件描述错误。但是，通用页面缓存基础结构不会跟踪弄脏每个单独页面的文件描述，因此无法确定哪些文件描述符应该返回错误。

相反，内核中的通用写回错误跟踪基础结构将错误发生时所有打开的文件描述的错误报告给 fsync。在有多个写入者的情况下，即使通过该特定文件描述符完成的所有写入都成功（或者即使该文件描述符上根本没有写入），所有写入者都会在后续 fsync 中返回错误。

希望使用此基础结构的文件系统应在发生错误时调用 mapping_set_error 将错误记录在 address_space 中。然后，在他们的 file->fsync 操作中从 pagecache 写回数据后，他们应该调用 file_check_and_advance_wb_err 以确保结构文件的错误游标已经前进到后备设备发出的错误流中的正确点。


struct address_space_operations
-------------------------------

这描述了 VFS 如何操作文件到文件系统中页面缓存的映射。 定义了以下成员：

.. code-block:: c

	struct address_space_operations {
		int (*writepage)(struct page *page, struct writeback_control *wbc);
		int (*readpage)(struct file *, struct page *);
		int (*writepages)(struct address_space *, struct writeback_control *);
		int (*set_page_dirty)(struct page *page);
		void (*readahead)(struct readahead_control *);
		int (*readpages)(struct file *filp, struct address_space *mapping,
				 struct list_head *pages, unsigned nr_pages);
		int (*write_begin)(struct file *, struct address_space *mapping,
				   loff_t pos, unsigned len, unsigned flags,
				struct page **pagep, void **fsdata);
		int (*write_end)(struct file *, struct address_space *mapping,
				 loff_t pos, unsigned len, unsigned copied,
				 struct page *page, void *fsdata);
		sector_t (*bmap)(struct address_space *, sector_t);
		void (*invalidatepage) (struct page *, unsigned int, unsigned int);
		int (*releasepage) (struct page *, int);
		void (*freepage)(struct page *);
		ssize_t (*direct_IO)(struct kiocb *, struct iov_iter *iter);
		/* isolate a page for migration */
		bool (*isolate_page) (struct page *, isolate_mode_t);
		/* migrate the contents of a page to the specified target */
		int (*migratepage) (struct page *, struct page *);
		/* put migration-failed page back to right list */
		void (*putback_page) (struct page *);
		int (*launder_page) (struct page *);

		int (*is_partially_uptodate) (struct page *, unsigned long,
					      unsigned long);
		void (*is_dirty_writeback) (struct page *, bool *, bool *);
		int (*error_remove_page) (struct mapping *mapping, struct page *page);
		int (*swap_activate)(struct file *);
		int (*swap_deactivate)(struct file *);
	};

``writepage``
        由 VM 调用以将脏页写入后备存储。这可能出于数据完整性原因（即“同步”）或释放内存（刷新）而发生。区别可以在 wbc->sync_mode 中看到。 PG_Dirty 标志已被清除并且 PageLocked 为真。 writepage 应该开始写出，应该设置 PG_Writeback，并且应该确保在写操作完成时同步或异步地解锁页面。

        如果 wbc->sync_mode 是 WB_SYNC_NONE，->writepage 如果有问题就不必太努力，如果更容易（例如由于内部依赖），可以选择从映射中写出其他页面。如果它选择不开始写出，它应该返回 AOP_WRITEPAGE_ACTIVATE 以便虚拟机不会继续在该页面上调用 ->writepage。

        有关更多详细信息，请参阅文件“Locking”。

``readpage``
        由 VM 调用以从后备存储读取页面。调用 readpage 时该页面将被锁定，一旦读取完成，应解锁并标记为更新。如果 ->readpage 发现由于某种原因需要对页面进行解锁，则可以这样做，然后返回 AOP_TRUNCATED_PAGE。在这种情况下，页面将被重新定位、重新锁定，如果一切成功，->readpage 将再次被调用。

``writepages``
        由 VM 调用以写出与 address_space 对象关联的页面。如果 wbc->sync_mode 是 WB_SYNC_ALL，则 writeback_control 将指定必须写出的页面范围。如果它是 WB_SYNC_NONE，则给出 nr_to_write 并且如果可能的话应该写入许多页面。如果没有给出 ->writepages，则使用 mpage_writepages 代替。这将从地址空间中选择标记为 DIRTY 的页面并将它们传递给 ->writepage。

``set_page_dirty``
        由 VM 调用以设置页面脏。如果地址空间将私有数据附加到页面，并且在页面变脏时需要更新该数据，则这尤其需要。例如，当内存映射页面被修改时，就会调用它。如果定义，它应该在基数树中设置 PageDirty 标志和 PAGECACHE_TAG_DIRTY 标记。

``readahead``
        由 VM 调用以读取与 address_space 对象关联的页面。页在页缓存中是连续的并且被锁定。在每个页面上启动 I/O 后，实现应该减少页面引用计数。通常页面将被 I/O 完成处理程序解锁。如果文件系统决定在到达预读窗口的末尾之前停止尝试 I/O，它可以简单地返回。调用者将减少页面引用计数并为您解锁剩余的页面。如果 I/O 成功完成，则设置 PageUptodate。在任何页面上设置 PageError 都将被忽略；如果发生 I/O 错误，只需解锁页面即可。

``readpages``
        由 VM 调用以读取与 address_space 对象关联的页面。这本质上只是 readpage 的矢量版本。请求的不是一页，而是多页。 readpages 仅用于预读，因此忽略读取错误。如果出现任何问题，请随时放弃。此接口已弃用，将于 2020 年底移除；改为 readahead。

``write_begin``
        由通用缓冲写入代码调用，以要求文件系统准备在文件中的给定偏移量处写入 len 个字节。 address_space 应该检查写入是否能够完成，必要时通过分配空间并执行任何其他内部管理。如果写入将更新存储上任何基本块的部分，那么这些块应该被预读（如果它们还没有被读取），以便可以正确地写出更新的块。

        文件系统必须返回指定偏移量的锁定页面缓存页面，在 ``*pagep`` 中，供调用者写入。

        它必须能够处理短写入（其中传递给 write_begin 的长度大于复制到页面中的字节数）。

        flags 是 AOP_FLAG_xxx 标志的字段，在 include/linux/fs.h 中有描述。

        一个 void * 可能会在 fsdata 中返回，然后被传递到 write_end。

        成功返回 0； < 0 失败（这是错误代码），在这种情况下不调用 write_end。

``write_end``
        在成功的 write_begin 和数据复制之后，必须调用 write_end。 len 是传递给 write_begin 的原始 len，而被复制的是能够被复制的数量。

        文件系统必须负责解锁页面并释放它的引用计数，以及更新 i_size。

        失败时返回 < 0，否则返回能够复制到页面缓存中的字节数 (<= 'copied')。

``bmap``
        由 VFS 调用以将对象内的逻辑块偏移量映射到物理块号。此方法由 FIBMAP ioctl 使用并用于处理交换文件。为了能够交换到文件，该文件必须具有到块设备的稳定映射。交换系统不通过文件系统，而是使用 bmap 找出文件中的块所在的位置并直接使用这些地址。

``invalidatepage``
        如果页面设置了 PagePrivate，则在要从地址空间中删除部分或全部页面时将调用 invalidatepage。这通常对应于地址空间的截断、打孔或完全无效（在后一种情况下，'offset' 将始终为 0，'length' 将为 PAGE_SIZE）。应更新与页面关联的任何私人数据以反映此截断。如果offset为0，length为PAGE_SIZE，那么私有数据应该被释放，因为页面必须能够被完全丢弃。这可以通过调用 ->releasepage 函数来完成，但在这种情况下，释放必须成功。

``releasepage``
        在 PagePrivate 页面上调用 releasepage 以指示应尽可能释放该页面。 ->releasepage 应该从页面中删除任何私有数据并清除 PagePrivate 标志。如果 releasepage() 由于某种原因失败，它必须用 0 返回值指示失败。 releasepage() 用于两种不同但相关的情况。第一种是当 VM 找到一个没有活动用户的干净页面并希望将其设为free页面时。如果 ->releasepage 成功，该页面将从 address_space 中删除并变为空闲。

        第二种情况是当请求使 address_space 中的某些或所有页面无效时。这可以通过 fadvise(POSIX_FADV_DONTNEED) 系统调用或文件系统通过调用 invalidate_inode_pages2() 像 nfs 和 9fs 那样显式请求它（当他们认为缓存可能已过期）发生。如果文件系统进行了这样的调用，并且需要确定所有页面都无效，那么它的 releasepage 将需要确保这一点。如果它还不能释放私有数据，它可能可以清除 PageUptodate 位。

``freepage``
        一旦页面在页面缓存中不再可见，就会调用 freepage 以允许清理任何私有数据。由于可能被内存回收者调用，所以不应该假设原来的address_space映射仍然存在，也不应该阻塞。

``direct_IO``
        由通用读/写例程调用以执行 direct_IO - 即绕过页面缓存并直接在存储和应用程序地址空间之间传输数据的 IO 请求。

``isolate_page``
        在隔离可移动的非 lru 页面时由 VM 调用。如果页面被成功隔离，VM 通过 __SetPageIsolated 将该页面标记为 PG_isolated。

``migrate_page``
        这用于压缩物理内存使用。如果 VM 想要重新定位页面（可能是从发出即将发生故障的存储卡上移出），它将向此函数传递一个新页面和一个旧页面。 migrate_page 应该传输任何私有数据并更新它对页面的任何引用。

``putback_page``
        当隔离页迁移失败时由 VM 调用。

``launder_page``
        在释放页面之前调用 - 它写回脏页面。为了防止重新脏页面，在整个操作过程中保持锁定。

``is_partially_uptodate``
        当底层块大小 != 页面大小(underlying blocksize != pagesize)时，VM 在通过页面缓存读取文件时调用。如果所需的块是最新的，那么读取就可以完成，而无需 IO 来更新整个页面。

``is_dirty_writeback``
        尝试回收页面时由 VM 调用。 VM 使用脏信息和写回信息来确定它是否需要暂停以允许刷新程序有机会完成某些 IO。通常它可以使用 PageDirty 和 PageWriteback 但是一些文件系统有更复杂的状态（NFS 中不稳定的页面阻止回收）或者由于锁定问题不设置这些标志。此回调允许文件系统向 VM 指示是否应将页面视为脏页或回写以便停止。

``error_remove_page``
        如果此地址空间可以截断，则通常设置为 generic_error_remove_page。用于内存故障处理。设置此选项意味着您处理在您身下消失的页面，除非您将它们锁定或引用计数增加。

``swap_activate``
        在文件上使用 swapon 时调用以在必要时分配空间并将块查找信息固定在内存中。返回值为零表示成功，在这种情况下，此文件可用于备份交换空间。

``swap_deactivate``
        在swap_activate 成功的文件的swapoff 期间调用。


The File Object
===============

文件对象代表进程打开的文件。 这在 POSIX 用语中也称为“打开文件描述”。


struct file_operations
----------------------

这描述了 VFS 如何操作打开的文件。 从内核 4.18 开始，定义了以下成员：

.. code-block:: c

	struct file_operations {
		struct module *owner;
		loff_t (*llseek) (struct file *, loff_t, int);
		ssize_t (*read) (struct file *, char __user *, size_t, loff_t *);
		ssize_t (*write) (struct file *, const char __user *, size_t, loff_t *);
		ssize_t (*read_iter) (struct kiocb *, struct iov_iter *);
		ssize_t (*write_iter) (struct kiocb *, struct iov_iter *);
		int (*iopoll)(struct kiocb *kiocb, bool spin);
		int (*iterate) (struct file *, struct dir_context *);
		int (*iterate_shared) (struct file *, struct dir_context *);
		__poll_t (*poll) (struct file *, struct poll_table_struct *);
		long (*unlocked_ioctl) (struct file *, unsigned int, unsigned long);
		long (*compat_ioctl) (struct file *, unsigned int, unsigned long);
		int (*mmap) (struct file *, struct vm_area_struct *);
		int (*open) (struct inode *, struct file *);
		int (*flush) (struct file *, fl_owner_t id);
		int (*release) (struct inode *, struct file *);
		int (*fsync) (struct file *, loff_t, loff_t, int datasync);
		int (*fasync) (int, struct file *, int);
		int (*lock) (struct file *, int, struct file_lock *);
		ssize_t (*sendpage) (struct file *, struct page *, int, size_t, loff_t *, int);
		unsigned long (*get_unmapped_area)(struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
		int (*check_flags)(int);
		int (*flock) (struct file *, int, struct file_lock *);
		ssize_t (*splice_write)(struct pipe_inode_info *, struct file *, loff_t *, size_t, unsigned int);
		ssize_t (*splice_read)(struct file *, loff_t *, struct pipe_inode_info *, size_t, unsigned int);
		int (*setlease)(struct file *, long, struct file_lock **, void **);
		long (*fallocate)(struct file *file, int mode, loff_t offset,
				  loff_t len);
		void (*show_fdinfo)(struct seq_file *m, struct file *f);
	#ifndef CONFIG_MMU
		unsigned (*mmap_capabilities)(struct file *);
	#endif
		ssize_t (*copy_file_range)(struct file *, loff_t, struct file *, loff_t, size_t, unsigned int);
		loff_t (*remap_file_range)(struct file *file_in, loff_t pos_in,
					   struct file *file_out, loff_t pos_out,
					   loff_t len, unsigned int remap_flags);
		int (*fadvise)(struct file *, loff_t, loff_t, int);
	};

同样，除非另有说明，否则所有方法都会在不持有任何锁的情况下调用。

``llseek``
        当 VFS 需要移动文件位置索引时调用

``read``
        由 read(2) 和相关系统调用调用

``read_iter``
        可能以 iov_iter 作为目标异步读取

``write``
        由 write(2) 和相关系统调用调用

``write_iter``
        可能以 iov_iter 作为源的异步写入

``iopoll``
        当 aio 想要轮询 HIPRI iocbs 上的完成情况时调用

``iterate``
        当 VFS 需要读取目录内容时调用

``iterate_shared``
        当文件系统支持并发目录迭代器时，当 VFS 需要读取目录内容时调用

``poll``
        当进程想要检查此文件上是否有活动并且（可选）进入睡眠状态直到有活动时，由 VFS 调用。由 select(2) 和 poll(2) 系统调用调用

``unlocked_ioctl``
        由 ioctl(2) 系统调用调用。

``compat_ioctl``
        在 64 位内核上使用 32 位系统调用时由 ioctl(2) 系统调用调用。

``mmap``
        由 mmap(2) 系统调用调用

``open``
        当应该打开一个 inode 时由 VFS 调用。当 VFS 打开一个文件时，它会创建一个新的“结构文件”。然后它为新分配的文件结构调用 open 方法。您可能认为 open 方法确实属于“struct inode_operations”，您可能是对的。我认为这样做是因为它使文件系统更易于实现。如果要指向设备结构，open() 方法是初始化文件结构中的“private_data”成员的好地方

``flush``
        由 close(2) 系统调用调用以刷新文件

``release``
        当对打开的文件的最后一个引用关闭时调用

``fsync``
        由 fsync(2) 系统调用调用。另请参阅上面标题为"Handling errors during writeback"(“在写回期间处理错误”)的部分。

``fasync``
        当为文件启用异步（非阻塞）模式时由 fcntl(2) 系统调用调用

``lock``
        由 fcntl(2) 系统调用调用 F_GETLK、F_SETLK 和 F_SETLKW 命令

``get_unmapped_area``
        由 mmap(2) 系统调用调用

``check_flags``
        由 fcntl(2) 系统调用调用 F_SETFL 命令

``flock``
        由 flock(2) 系统调用调用

``splice_write``
        由 VFS 调用以将数据从管道拼接到文件。该方法由 splice(2) 系统调用使用

``splice_read``
        由 VFS 调用以将数据从文件拼接到管道。该方法由 splice(2) 系统调用使用

``setlease``
        由 VFS 调用以设置或释放文件锁租用。 setlease 实现应该调用 generic_setlease 来记录或删除 inode 中的租约。

``fallocate``
        由 VFS 调用以预分配块或打孔。

``copy_file_range``
        由 copy_file_range(2) 系统调用调用。

``remap_file_range``
        由 ioctl(2) 系统调用调用 FICLONERANGE 和 FICLONE 和 FIDEDUPERANGE 命令以重新映射文件范围。 实现应将源文件 pos_in 处的 len 字节重新映射到 pos_out 处的 dest 文件中。 实现必须处理传入 len == 0 的调用者； 这意味着“重新映射到源文件的末尾”。 返回值应该是重新映射的字节数，如果在重新映射任何字节之前发生错误，则返回通常的负错误代码。 remap_flags 参数接受 REMAP_FILE_* 标志。 如果设置了 REMAP_FILE_DEDUP，则实现必须仅在请求的文件范围具有相同内容时重新映射。 如果设置了 REMAP_FILE_CAN_SHORTEN，调用者就可以缩短请求长度以满足对齐或 EOF 要求（或任何其他原因）的实现。

``fadvise``
        可能由 fadvise64() 系统调用调用。

请注意，文件操作由 inode 所在的特定文件系统实现。 当打开设备节点（字符或块特殊）时，大多数文件系统将调用 VFS 中的特殊支持例程，它将定位所需的设备驱动程序信息。 这些支持例程将文件系统文件操作替换为设备驱动程序的操作，然后继续为文件调用新的 open() 方法。 这就是在文件系统中打开设备文件最终调用设备驱动程序 open() 方法的方式。


Directory Entry Cache (dcache)
==============================


struct dentry_operations
------------------------

这描述了文件系统如何重载标准 dentry 操作。 dentries 和 dcache 是 VFS 和单个文件系统实现的域。 设备驱动程序在这里没有业务。 这些方法可以设置为 NULL，因为它们要么是可选的，要么 VFS 使用默认值。 从内核 2.6.22 开始，定义了以下成员：

.. code-block:: c

	struct dentry_operations {
		int (*d_revalidate)(struct dentry *, unsigned int);
		int (*d_weak_revalidate)(struct dentry *, unsigned int);
		int (*d_hash)(const struct dentry *, struct qstr *);
		int (*d_compare)(const struct dentry *,
				 unsigned int, const char *, const struct qstr *);
		int (*d_delete)(const struct dentry *);
		int (*d_init)(struct dentry *);
		void (*d_release)(struct dentry *);
		void (*d_iput)(struct dentry *, struct inode *);
		char *(*d_dname)(struct dentry *, char *, int);
		struct vfsmount *(*d_automount)(struct path *);
		int (*d_manage)(const struct path *, bool);
		struct dentry *(*d_real)(struct dentry *, const struct inode *);
	};

``d_revalidate``
        当 VFS 需要重新验证 dentry 时调用。每当名称查找在 dcache 中找到一个 dentry 时就会调用它。大多数本地文件系统将其保留为 NULL，因为它们在 dcache 中的所有 dentry 都是有效的。网络文件系统是不同的，因为服务器上的事情可能会发生变化，而客户端不一定会意识到这一点。

        如果 dentry 仍然有效，这个函数应该返回一个正值，如果不是，则返回零或负错误代码。

        d_revalidate 可以在 rcu-walk 模式下调用（flags & LOOKUP_RCU）。如果在 rcu-walk 模式下，文件系统必须在不阻塞或存储到 dentry 的情况下重新验证 dentry， d_parent 和 d_inode 不应随意使用（因为它们可以更改，在 d_inode 的情况下，甚至在我们的情况下变为 NULL）。

        如果遇到 rcu-walk 无法处理的情况，返回 -ECHILD，它将在 ref-walk 模式下再次调用。

``d_weak_revalidate``
        当 VFS 需要重新验证“jumped”(“跳跃”)的 dentry 时调用。当路径遍历在 dentry 处结束时调用，该 dentry 不是通过在父目录中查找而获得的。这包括 ”/”， ”.”和“..”，以及 procfs-style 的符号链接和挂载点遍历。

        在这种情况下，我们不太关心 dentry 是否仍然完全正确，而是关心 inode 仍然有效。与 d_revalidate 一样，大多数本地文件系统会将其设置为 NULL，因为它们的 dcache 条目始终有效。

        此函数具有与 d_revalidate 相同的返回码语义。

        d_weak_revalidate 只有在离开 rcu-walk 模式后才会被调用。

``d_hash``
        当 VFS 向哈希表添加一个 dentry 时调用。传递给 d_hash 的第一个 dentry 是名称要散列到的父目录。

        与 d_compare 相同的锁定和同步规则关于什么是安全的解除引用等。

``d_compare``
        调用以将 dentry 名称与给定名称进行比较。第一个 dentry 是要比较的 dentry 的父级，第二个是子 dentry。 len 和 name string 是要比较的 dentry 的属性。 qstr 是要与之进行比较的名称。

        必须是常量和幂等的，如果可能的话不应该拿锁，也不应该或存储到 dentry 中。不应该在没有很多注意的情况下取消引用 dentry 之外的指针（例如，不应使用 d_parent、d_inode、d_name）。

        然而，我们的 vfsmount 是固定的，并且 RCU 被保持，所以 dentries 和 inode 不会消失，我们的 sb 或文件系统模块也不会消失。 ->d_sb 可以使用。

        这是一个棘手的调用约定，因为它需要在“rcu-walk”下调用，即,没有任何锁定或对事物的引用。

``d_delete``
        当对 dentry 的最后一个引用被删除并且 dcache 决定是否缓存它时调用。返回 1 以立即删除，或返回 0 以缓存 dentry。默认值为 NULL，这意味着始终缓存可访问的 dentry。 d_delete 必须是常数和幂等的。

``d_init``
        在分配 dentry 时调用

``d_release``
        当 dentry 真正被释放时调用

``d_iput``
        当 dentry 丢失其 inode 时调用（就在其被释放之前）。 NULL 时的默认值是 VFS 调用 iput()。如果你定义了这个方法，你必须自己调用 iput()

``d_dname``
        在应生成 dentry 的路径名时调用。对某些伪文件系统（sockfs、pipefs 等）有用以延迟路径名生成。 （而不是在创建 dentry 时执行它，它仅在需要路径时执行。）。真正的文件系统可能不想使用它，因为它们的 dentry 存在于全局 dcache 散列中，所以它们的散列应该是一个不变的。由于没有持有锁，d_dname() 不应尝试修改 dentry 本身，除非使用适当的 SMP 安全。注意：d_path() 逻辑非常棘手。返回例如“Hello”的正确方法是将其放在缓冲区的末尾，并返回指向第一个字符的指针。提供了 dynamic_dname() 帮助函数来解决这个问题。

	例子 :

.. code-block:: c

	static char *pipefs_dname(struct dentry *dent, char *buffer, int buflen)
	{
		return dynamic_dname(dentry, buffer, buflen, "pipe:[%lu]",
				dentry->d_inode->i_ino);
	}

``d_automount``
        当要遍历自动挂载 dentry 时调用（可选）。这应该创建一个新的 VFS 挂载记录并将记录返回给调用者。调用者被提供一个路径参数，给出自动挂载目录来描述自动挂载目标和父 VFS 挂载记录以提供可继承的挂载参数。如果其他人设法首先进行自动挂载，则应返回 NULL。如果 vfsmount 创建失败，则应返回错误代码。如果返回-EISDIR，则该目录将被视为普通目录并返回pathwalk继续行走。

        如果返回了 vfsmount，调用者将尝试将其挂载到挂载点，并在失败时从其过期列表中删除 vfsmount。 vfsmount 应该返回 2 个引用以防止自动过期 - 调用者将清理额外的引用。

        仅当在 dentry 上设置 DCACHE_NEED_AUTOMOUNT 时才使用此函数。如果在添加的 inode 上设置了 S_AUTOMOUNT，则由 __d_instantiate() 设置。

``d_manage``
        调用以允许文件系统管理从 dentry 的转换（可选）。例如，这允许 autofs 阻止客户端等待在“挂载点”后面探索，同时让守护程序经过并在那里构建子树。应该返回 0 以让调用过程继续。可以返回 -EISDIR 以告诉 pathwalk 将此目录用作普通目录并忽略安装在其上的任何内容并且不检查自动挂载标志。任何其他错误代码都将完全中止 pathwalk。

        如果 'rcu_walk' 参数为真，则调用者正在 RCU-walk 模式下进行路径漫游。在这种模式下不允许休眠，并且可以通过返回 -ECHILD 要求调用者离开它并再次调用。 -EISDIR 也可以返回以告诉 pathwalk 忽略 d_automount 或任何挂载。

        此函数仅在 DCACHE_MANAGE_TRANSIT 设置在被传输的 dentry 上时使用。

``d_real``
        覆盖/联合类型文件系统实现此方法以返回被覆盖隐藏的底层 dentry 之一。它用于两种不同的模式：

        从 file_dentry() 调用它返回与 inode 参数匹配的真实 dentry。真正的 dentry 可能来自已经复制的较低层，但仍从文件中引用。使用非 NULL inode 参数选择此模式。

        使用 NULL inode 返回最顶层真实的底层 dentry。

每个 dentry 都有一个指向其父 dentry 的指针，以及一个子 dentry 的哈希列表。子目录基本上就像目录中的文件。


Directory Entry Cache API
--------------------------

定义了许多允许文件系统操作 dentry 的函数：

``dget``
        为现有的 dentry 打开一个新句柄（这只会增加使用计数）

``dput``
        关闭 dentry 的句柄（减少使用计数）。如果使用计数下降到 0，并且 dentry 仍在其父项的哈希中，则调用“d_delete”方法来检查它是否应该被缓存。如果它不应该被缓存，或者如果 dentry 没有被散列，它就会被删除。否则，缓存的 dentry 会被放入 LRU 列表中，以便在内存不足时回收。

``d_drop``
        这会从其父哈希列表中对 dentry 进行哈希处理。如果 dentry 的使用计数下降到 0，则对 dput() 的后续调用将取消分配该 dentry

``d_delete``
        删除一个dentry。如果没有其他对 dentry 的开放引用，则该 dentry 将变成负 dentry（调用 d_iput() 方法）。如果有其他引用，则调用 d_drop() 代替

``d_add``
        将 dentry 添加到其父哈希列表中，然后调用 d_instantiate()

``d_instantiate``
        向 inode 的别名哈希列表添加一个 dentry 并更新“d_inode”成员。 inode 结构中的“i_count”成员应该被设置/递增。如果 inode 指针为 NULL，则该 dentry 被称为“负 dentry”。当为现有的负 dentry 创建 inode 时，通常会调用此函数

``d_lookup``
        在给定其父项和路径名组件的情况下查找 dentry 它从 dcache 哈希表中查找该给定名称的子项。如果找到，则增加引用计数并返回 dentry。调用者必须使用 dput() 在完成使用后释放 dentry。


Mount Options
=============


Parsing options
---------------

在挂载和重新挂载时，文件系统会传递一个字符串，其中包含以逗号分隔的挂载选项列表。 选项可以具有以下任一形式：

        option
        option=value

<linux/parser.h> 头文件定义了一个 API 来帮助解析这些选项。 有很多关于如何在现有文件系统中使用它的示例。


Showing options
---------------

如果文件系统接受挂载选项，它必须定义 show_options() 以显示所有当前活动的选项。 规则是：

  - 必须显示非默认选项或它们的值与默认值不同
  - 可以显示默认启用或具有默认值的选项

仅在挂载助手和内核之间内部使用的选项（例如文件描述符），或仅在挂载期间有效的选项（例如控制日志创建的选项）不受上述规则的约束。

上述规则的根本原因是确保可以根据 /proc/mounts 中的信息准确复制挂载（例如卸载和再次挂载）。


Resources
=========

(请注意，其中一些资源不是最新的内核版本。)

Creating Linux virtual filesystems. 2002
    <https://lwn.net/Articles/13325/>

The Linux Virtual File-system Layer by Neil Brown. 1999
    <http://www.cse.unsw.edu.au/~neilb/oss/linux-commentary/vfs.html>

A tour of the Linux VFS by Michael K. Johnson. 1996
    <https://www.tldp.org/LDP/khg/HyperNews/get/fs/vfstour.html>

A small trail through the Linux kernel by Andries Brouwer. 2001
    <https://www.win.tue.nl/~aeb/linux/vfs/trail.html>

