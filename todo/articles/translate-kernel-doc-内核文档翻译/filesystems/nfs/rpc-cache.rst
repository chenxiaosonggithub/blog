=========
RPC Cache
=========

本文是基于Documentation/filesystems/nfs/rpc-cache.rst以下提交记录:

.. code-block:: shell

	commit f0bf8a988b26e75cc6fc28a44a745cb354a2b5a6
	Author: Daniel W. S. Almeida <dwlsalmeida@gmail.com>
	Date:   Wed Jan 29 01:49:14 2020 -0300

	Documentation: nfs: rpc-cache: convert to ReST

本文档简要介绍了 sunrpc 层中使用的缓存机制，特别是用于 NFS 身份验证。

Caches
======

缓存取代了旧的导出表，并允许缓存各种值。

有许多缓存在结构上相似，但在内容和用途上可能非常不同。 有一个用于管理这些缓存的通用代码库。

可能需要的缓存示例有：

  - 从 IP 地址到客户端名称的映射
  - 从客户端名称和文件系统映射到导出选项
  - 从 UID 映射到 GID 列表，以解决 NFS 的 16 个 gid 限制。
  - 对于没有统一 uid 分配的站点，本地 UID/GID 和远程 UID/GID 之间的映射
  - 从网络标识映射到用于加密身份验证的公钥。

公共代码处理以下事情：

   - 具有正确锁定的一般缓存查找
   - 支持“NEGATIVE”以及positive entries
   - 允许缓存项目的过期时间，并在它们过期后删除不再使用的项目。
   - 向用户空间发出请求以填充缓存条目
   - 允许用户空间直接在缓存中设置条目
   - 延迟依赖于尚未完成的缓存条目的 RPC 请求，并在缓存条目完成时重放这些请求。
   - 清除过期的旧条目。

Creating a Cache
----------------

-  缓存需要存储数据。 这是一个结构定义的形式，它必须包含一个 struct cache_head 作为元素，通常是第一个。 它还将包含一个密钥和一些内容。 每个缓存元素都进行引用计数，并包含用于缓存管理的到期和更新时间。

-  缓存需要一个描述缓存的“cache_detail”结构。 这存储了哈希表、一些缓存管理参数以及一些详细说明如何使用特定缓存项的操作。

   操作是：

    struct cache_head \*alloc(void)
      这只是分配适当的内存并返回指向嵌入在结构中的 cache_detail 的指针

    void cache_put(struct kref \*)
      当对项目的最后一个引用被删除时调用。传递的指针指向 cache_head 中的“ref”字段。 cache_put 应该释放由 'cache_init' 创建的任何引用，如果设置了 CACHE_VALID，则释放由 cache_update 创建的任何引用。然后它应该释放'alloc'分配的内存。

    int match(struct cache_head \*orig, struct cache_head \*new)
      测试两个结构中的键是否匹配。如果有则返回 1，否则返回 0。

    void init(struct cache_head \*orig, struct cache_head \*new)
      从“orig”设置“new”中的“key”字段。这可能包括引用共享对象。

    void update(struct cache_head \*orig, struct cache_head \*new)
      从“orig”设置“new”中的“content”文件。

    int cache_show(struct seq_file \*m, struct cache_detail \*cd, struct cache_head \*h)
      可选的。用于提供列出缓存内容的 /proc 文件。这应该显示一个项目，通常只在一行上。

    int cache_request(struct cache_detail \*cd, struct cache_head \*h, char \*\*bpp, int \*blen)
      格式化要发送到用户空间的请求，以便实例化一个项目。 \*bpp 是大小为 \*blen 的缓冲区。 bpp 应该在编码的消息上向前移动，并且 \*blen 应该减少以显示剩余的可用空间。成功返回 0, 或 <0 如果没有足够的空间或其他问题。

    int cache_parse(struct cache_detail \*cd, char \*buf, int len)
      来自用户空间的消息已到达以填充缓存条目。它在长度为“len”的“buf”中。 cache_parse 应该解析它，使用 sunrpc_cache_lookup_rcu 在缓存中找到该项目，并使用 sunrpc_cache_update 更新该项目。


-  需要使用 cache_register() 注册缓存。 这将其包含在将定期清理以丢弃旧数据的缓存列表中。

Using a cache
-------------

要在缓存中查找值，请调用 sunrpc_cache_lookup_rcu 将指针传递到填充了“key”字段的示例项中的 cache_head。这将传递给 ->match 以标识目标条目。如果没有找到条目，将创建一个新条目，将其添加到缓存中，并标记为不包含有效数据。

返回的项目通常传递给 cache_check，它会检查数据是否有效，并可能发起向上调用以获取新数据。 cache_check 将在条目中返回 -ENOENT 为负数或者如果需要向上调用但不可能，如果向上调用未决，则返回 -EAGAIN，如果数据有效则返回 0；

cache_check 可以传递一个“struct cache_req\*”。此结构通常嵌入在实际请求中，可用于创建请求的延迟副本 (struct cache_deferred_req)。这是在找到的缓存项不是最新的时候完成的，但有理由相信用户空间可能很快就会提供信息。当缓存项变为有效时，请求的延迟副本将被重新访问（->revisit）。预计此方法将重新安排处理请求。

sunrpc_cache_lookup_rcu 返回的值也可以传递给 sunrpc_cache_update 以设置项目的内容。传递了第二个项目，它应该包含内容。如果 _lookup 找到的项目具有有效数据，则将其丢弃并创建新项目。这可以避免项目的任何用户在检查项目时担心内容更改。如果 _lookup 找到的项目不包含有效数据，则复制内容并设置 CACHE_VALID。

Populating a cache(填充缓存)
------------------

每个缓存都有一个名称，当缓存被注册时，会在 /proc/net/rpc 中创建一个具有该名称的目录

该目录包含一个名为“channel”的文件，该文件是内核和用户之间进行通信以填充缓存的通道。 此目录稍后可能包含与缓存交互的其他文件。

“channel”的工作方式有点像数据报套接字。 每个“写入”都作为一个整体传递给缓存以进行解析和解释。 每个缓存可以不同地处理写入请求，但预计写入的消息将包含：

  - a key
  - an expiry time
  - a content.

目的是应该创建或更新缓存中具有给定键的项目以具有给定的内容，并且应该在该项目上设置到期时间。

从频道阅读更有趣。 当缓存查找失败时，或者当它成功但发现一个可能很快过期的条目时，就会请求用户空间更新该缓存项。 这些请求出现在通道文件中。

连续读取将返回连续请求。 如果没有更多的请求返回，read 将返回 EOF，但 read 的 select 或 poll 将阻塞等待添加另一个请求。

因此，用户空间助手可能会::

  open the channel.
    select for readable
    read a request
    write a response
  loop.

如果它死掉并需要重新启动，则任何尚未得到答复的请求仍将出现在文件中，并将被帮助程序的新实例读取。

每个缓存都应该定义一个“cache_parse”方法，该方法接收从用户空间写入的消息并对其进行处理。 它应该返回一个错误（传播回写系统调用）或 0。

每个缓存还应定义一个“cache_request”方法，该方法获取缓存项并将请求编码到提供的缓冲区中。

.. note::
  如果缓存在通道上没有活动阅读器，并且没有活动阅读器的时间超过 60 秒，则不会向通道添加更多请求，而是所有未找到有效条目的查找都将失败。 这部分是为了向后兼容：以前的 nfs 导出表被认为是权威的，失败的查找意味着明确的“no”。

request/response format
-----------------------

虽然每个缓存都可以自由地使用自己的格式来处理通道上的请求和响应，但建议采用以下适当的格式，并且支持例程可以提供帮助： 每个请求或响应记录都应该是可打印的 ASCII，并且精确地有一个换行符，该换行符应该位于 结尾。 记录中的字段应该用空格分隔，通常是一个。 如果字段中需要空格、换行符或空字符，则需要引用它们。 有两种机制可用：

-  如果字段以'\x'开头，则它必须包含偶数个十六进制数字，这些数字对提供字段中的字节。
-  否则字段中的 a \ 必须后跟 3 个八进制数字，它们给出了一个字节的代码。 其他角色被视为他们自己。 至少，空格、换行符、nul 和 '\' 必须以这种方式引用。
