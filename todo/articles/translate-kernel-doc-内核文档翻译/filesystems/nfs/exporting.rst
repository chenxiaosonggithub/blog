:orphan:

Making Filesystems Exportable
=============================

本文是基于Documentation/filesystems/nfs/exporting.rst以下提交记录:

.. code-block:: shell

	commit 7f84b488f9add1d5cca3e6197c95914c7bd3c1cf
	Author: Jeff Layton <jeff.layton@primarydata.com>
	Date:   Mon Nov 30 17:03:16 2020 -0500

	nfsd: close cached files prior to a REMOVE or RENAME that would replace target

Overview
--------

使文件系统可导出所有文件系统操作都需要一个（或两个）dentry 作为起点。本地应用程序通过打开的文件描述符或 cwd/root 对合适的 dentry 进行引用计数保留。然而，通过远程文件系统协议（如 NFS）访问文件系统的远程应用程序可能无法保存这样的引用，因此需要一种不同的方式来引用特定的 dentry。由于替代的引用形式需要在重命名、截断和服务器重启时保持稳定（除其他外，尽管这些往往是最有问题的），因此没有像“文件名”这样的简单答案。

此处讨论的机制允许每个文件系统实现指定如何为任何 dentry 生成不透明（文件系统之外）字节字符串，以及如何为任何给定的不透明字节字符串找到合适的 dentry。这个字节串将被称为“文件句柄片段”，因为它对应于 NFS 文件句柄的一部分。

支持文件句柄片段和 dentries 之间映射的文件系统将被称为“可导出”。


Dcache Issues
-------------

dcache 通常包含任何给定文件系统树的适当前缀。 这意味着如果任何文件系统对象在 dcache 中，那么该文件系统对象的所有祖先也在 dcache 中。 由于正常访问是通过文件名，这个前缀是自然创建的并且很容易维护（通过每个对象维护其父对象的引用计数）。

但是，当通过解释文件句柄片段将对象包含到 dcache 中时，不会自动为对象创建路径前缀。 这导致了正常文件系统访问不需要的 dcache 的两个相关但不同的功能。

1. dcache 有时必须包含不属于正确前缀的对象。 即没有连接到根。
2. dcache 必须为新发现的（通过 ->lookup）目录准备好已经有（未连接的）dentry，并且必须能够将该 dentry 移动到位（基于 ->lookup 中的父级和名称） . 这对于目录尤其需要，因为目录只有一个 dentry 是 dcache 不变的。

为了实现这些功能，dcache 具有：

a. 一个 dentry 标志 DCACHE_DISCONNECTED，它被设置在任何可能不是正确前缀的一部分的 dentry 上。 这在创建匿名 dentry 时设置，并在注意到 dentry 是正确前缀中的 dentry 的子项时清除。 如果设置了此标志的 dentry 上的 refcount 变为零，则立即丢弃该 dentry，而不是保留在 dcache 中。 如果文件句柄重复访问不在 dcache 中的 dentry（如 NFSD 可能会这样做），则将为每次访问分配一个新的 dentry，并在访问结束时丢弃。

   请注意，这样的 dentry 可以在不丢失 DCACHE_DISCONNECTED 的情况下获取子项、名称、祖先等 - 只有当子树成功重新连接到根时才会清除该标志。 在此之前，只有在存在引用时才会保留此类子树中的 dentry； refcount 达到零意味着立即驱逐，与未散列的 dentry 相同。 这保证了我们不需要在 umount 上追捕它们。

b. 用于创建次根的原语 - d_obtain_root(inode)。 那些_不_承担 DCACHE_DISCONNECTED。 它们被放置在 per-superblock 列表 (->s_roots) 中，因此它们可以在 umount 时定位以进行驱逐。

c. 帮助程序分配匿名目录，并在查找时帮助附加松散的目录dentry。 他们是：

    d_obtain_alias(inode) 将返回给定 inode 的 dentry。
      如果 inode 已经有一个 dentry，则返回其中一个。

       如果没有，则会分配并附加一个新的匿名（IS_ROOT 和 DCACHE_DISCONNECTED）dentry。

       在目录的情况下，注意只能附加一个 dentry。

    d_splice_alias(inode, dentry) 将在树中引入一个新的 dentry；
      如果合适，传入的 dentry 或给定 inode 的预先存在的别名（例如由 d_obtain_alias 创建的匿名别名）。 当使用传入的 dentry 时，它返回 NULL，遵循 ->lookup 的调用约定。

Filesystem Issues(文件系统问题)
-----------------

对于可导出的文件系统，它必须：

   1. 提供下面描述的文件句柄片段例程。
   2. 确保当 ->lookup 找到给定父节点和名称的 inode 时，使用 d_splice_alias 而不是 d_add。

      如果 inode 为 NULL，则 d_splice_alias(inode, dentry) 等效于：

		d_add(dentry, inode), NULL

      同理，d_splice_alias(ERR_PTR(err), dentry) = ERR_PTR(err)

      通常 ->lookup 例程将简单地以以下内容结束：

		return d_splice_alias(inode, dentry);
	}

文件系统实现通过在 struct super_block 中设置 s_export_op 字段来声明文件系统的实例是可导出的。 此字段必须指向具有以下成员的“struct export_operations”结构：

  encode_fh  (optional)
    获取一个 dentry 并创建一个文件句柄片段，稍后可用于为同一对象查找或创建一个 dentry。默认实现会创建一个文件句柄片段，该片段对 32 位 inode 和已编码的 inode 的生成编号进行编码，并在必要时为父级提供相同的信息。

  fh_to_dentry (mandatory)
    给定一个文件句柄片段，这应该找到隐含的对象并为其创建一个 dentry（可能使用 d_obtain_alias）。

  fh_to_parent (optional but strongly recommended)
    给定一个文件句柄片段，这应该找到隐含对象的父对象并为其创建一个 dentry（可能使用 d_obtain_alias）。如果文件句柄片段太小，可能会失败。

  get_parent (optional but strongly recommended)
    当给定目录的 dentry 时，这应该返回父目录的 dentry。很可能父 dentry 已由 d_alloc_anon 分配。默认的 get_parent 函数只返回一个错误，因此任何需要查找父级的文件句柄查找都将失败。 ->lookup("..") *不用作*默认值，因为它可能会在 dcache 中留下“..”entries，这些entries太乱而无法使用。

  get_name (optional)
    当给定一个父 dentry 和一个子 dentry 时，这应该在由父 dentry 标识的目录中找到一个名称，这会导致由子 dentry 标识的对象。如果未提供 get_name 函数，则提供默认实现，该实现使用 vfs_readdir 查找潜在名称，并匹配 inode 编号以查找正确匹配项。

  flags
    某些文件系统可能需要以与其他文件系统不同的方式进行处理。 export_operations 结构还包括一个标志字段，允许文件系统将此类信息传达给 nfsd。有关更多说明，请参阅下面的Export Operations Flags(导出操作标志)部分。

文件句柄片段由 1 个或多个 4byte words 的数组以及一个 1 字节的“类型”组成。 decode_fh 例程不应依赖于传递给它的规定大小。这个大小可能比encode_fh 生成的原始文件句柄大，在这种情况下，它将用空值填充。相反，encode_fh 例程应该选择一个“类型”，它指示 decode_fh 文件句柄有多少是有效的，以及应该如何解释它。

Export Operations Flags
-----------------------
除了操作向量指针之外，struct export_operations 还包含一个“flags”字段，允许文件系统与 nfsd 通信，在处理它时它可能希望以不同的方式做事。定义了以下标志：

  EXPORT_OP_NOWCC - 在此文件系统上禁用 NFSv3 WCC 属性
    RFC 1813 建议服务器在每次操作后始终向客户端发送弱缓存一致性 (WCC) 数据。服务器应该自动收集有关 inode 的属性，对其进行操作，然后再收集这些属性。这允许客户端在某些情况下跳过发出 GETATTR，但这意味着服务器正在为几乎所有 RPC 调用 vfs_getattr。在某些文件系统上（特别是那些集群或网络的文件系统），这是昂贵的并且难以保证原子性。此标志向 nfsd 指示，在此文件系统上执行操作时，它应跳过在 NFSv3 回复中向客户端提供 WCC 属性。考虑在具有昂贵的 ->getattr inode 操作的文件系统上启用此功能，或者在无法保证操作前后属性集合之间的原子性时。

  EXPORT_OP_NOSUBTREECHK - 禁止对此 fs 进行子树检查
    许多 NFS 操作处理文件句柄，然后服务器必须对其进行审查以确保它们存在于导出的树中。当导出包含整个文件系统时，这是微不足道的。 nfsd 可以确保文件句柄存在于文件系统上。但是，当仅导出文件系统的一部分时，nfsd 必须遍历 inode 的祖先以确保它位于导出的子树中。这是一项昂贵的操作，并非所有文件系统都能正确支持它。此标志免除文件系统的子树检查，如果它尝试启用子树检查，则会导致 exportfs 返回错误。

  EXPORT_OP_CLOSE_BEFORE_UNLINK - 在取消链接之前始终关闭缓存文件
    在某些可导出的文件系统（例如 NFS）上，取消链接仍然打开的文件可能会导致大量额外的工作。例如，NFS 客户端将执行“sillyrename”以确保文件在它仍然打开时仍然存在。重新导出时，该打开的文件由 nfsd 保存，因此我们通常会执行一个"sillyrename"，然后在链接计数实际上为零时立即删除"sillyrename"的文件。有时，此删除操作会与其他操作（例如父目录的 rmdir）竞争。此标志会导致 nfsd 关闭此 inode _before_ 调用到 vfs 以执行取消链接或重命名以替换现有文件的所有打开文件。
