- [陕西省网络与系统安全重点实验室](https://web.xidian.edu.cn/ylshen/team.html)
- [我的博导张志为老师](https://faculty.xidian.edu.cn/zwzhang/zh_CN/index.htm)
- [2025中国最好学科排名（网络空间安全）](https://www.shanghairanking.cn/rankings/bcsr/2025/0839)
- [2025中国大学专业排名(网络空间安全)](https://www.shanghairanking.cn/rankings/bcmr/2025/080911TK)

# smb特性

和smb client maintainer的交流:
```
SMB3.1.1 supports so many advanced security features.

Have you looked at the recent series:

      [PATCH v2 0/4] smb: client: Use AES-CMAC library

which improves performance but also uses new libraries for this very
important security tasks.

Another thought - SMB3.1.1 allows negotiating stronger/faster packet
signing not just
("military grade") strong encryption.   Would be good to implement
that?  See below AI summary:

For signing, SMB 3.1.1 supports:
AES-CMAC (baseline)
AES-GMAC (much faster, hardware-accelerated)

Why AES-GMAC is faster
Uses AES-GCM primitives without encryption
Benefits from CPU instructions like AES-NI
Much lower CPU overhead than HMAC-SHA256

So when people say “faster signing,” they usually mean:
Negotiating AES-GMAC instead of older signing methods

Making sure crypto is offloaded well for perf (gmac support on the
processor) and how does this work fastest when with RDMA (smbdirect).
With Enzo's recent SMB3.1.1 compression improvements it would be
interesting to
make sure that the combination of compression and encryption offloads
efficiently.

I also think that there are multiple other cool security features
(improving id mapping
options as an example, improving upcall to get ids mapped, improving upcalls for
credentials, especially in container environments)

The move away from NTLMv2/NTLMSSP to Kerberos especially the newer peer to
peer Kerberos models ("IAKERB" which is soon to be default for WIndows, and is
a default for Mac) is exciting but may need minor changes to
cifs-utils to make sure
tickets are acquired correctly and refreshed.  At SambaXP this week,
it looks like there
are at least 8 good security talks that you should download when available.

Of course fixing broken chown with the SMB3.1.1 Linux Extensions would
be HUGE help
to security.

Could also be fun to do at least a read only emulated view of the
SMB3.1.1 ACL as a POSIX ACL over SMB3.1.1
```

翻译如下:
```
SMB 3.1.1 支持许多高级安全特性。

你看过最近这个补丁系列吗：

[PATCH v2 0/4] smb: client: Use AES-CMAC library

它提升了性能，同时也在这些非常重要的安全任务中使用了新的库。

另一个想法是——SMB 3.1.1 允许协商更强/更快的数据包签名，而不仅仅是（“军用级”）强加密。实现这一点会很好？见下面的 AI 总结：

对于签名，SMB 3.1.1 支持：

* AES-CMAC（基线）
* AES-GMAC（更快，支持硬件加速）

为什么 AES-GMAC 更快：

* 使用 AES-GCM 原语但不进行加密
* 受益于 CPU 指令（例如 AES-NI）
* 相比 HMAC-SHA256，CPU 开销更低

所以当人们说“更快的签名”时，通常指的是：

协商使用 AES-GMAC 而不是旧的签名方法

确保加密能够很好地 offload 以提升性能（处理器上的 GMAC 支持），以及在 RDMA（smbdirect）场景下如何实现最快性能。随着 Enzo 最近对 SMB3.1.1 压缩的改进，确保压缩和加密 offload 的组合高效运行将会很有意思。

我也认为还有很多其他很酷的安全特性（例如改进 id 映射选项、改进用于获取 id 映射的 upcall、改进凭证的 upcall，尤其是在容器环境中）。

从 NTLMv2/NTLMSSP 迁移到 Kerberos，特别是新的点对点 Kerberos 模型（“IAKERB”，很快将成为 Windows 的默认，并且在 Mac 上已经是默认），令人兴奋，但可能需要对 cifs-utils 做一些小改动，以确保票据能够正确获取并刷新。在本周的 SambaXP 上，看起来至少有 8 个不错的安全相关演讲，等可用时你应该下载来看。

当然，修复 SMB3.1.1 Linux 扩展中损坏的 chown 将对安全性有巨大帮助。

另外，实现一个至少只读的 SMB3.1.1 ACL 到 POSIX ACL 的模拟视图也可能很有趣。
```

# 选课

- [选课网站](https://yjsxk.xidian.edu.cn/yjsxkapp/sys/xsxkapp/index.html)
- [一张图看懂该怎么选课](https://res.xidian.edu.cn/products/yjs/xsxkapp/images/index/ydt.jpg)
- 咨询方式:
  - 81891044
  - pyb@mail.xidian.edu.cn
  - 如有意见和建议电话和QQ无法解决的请联系研究生院培养办公室南校区办公楼711
- 【常见问题 】 登录账号问题
  - 用户名（学号）：登录账号即本人学号。 密码 ：学生的初始密码为二代身份证后六位，末位如果是字母，字母应大写。 如果登录不成，请访问 https://ids.xidian.edu.cn/authserver/login 在登录页操作激活；
- 【常见问题 】 学生培养计划维护的上课学期问题
  - 培养方案开课学期是秋季的培养计划选课学期只能选择对应学期秋季； 培养方案开课学期是春季的培养计划选课学期只能维护对应学期春季； 培养方案是全年的，对应学期春秋季都可以维护。 培养计划的维护的选课学期与当前学期一致才可以在选课进行成功选课，目前培养计划选课学期是当前学期的才能在选课进行成功选课。
- 【常见问题 】 选课提示“校验不成功，与培养计划学期不一致问题”与教学班选课人数已满 问题
  - 当前学期选课的能选课成功的课程，必须培养计划中维护的选课学期是当前学期，例如：“2021秋”；
- 【常见问题 】 硕士外语加强班和基础班与英语能力认定关联问题
  - 申请硕士A级的学生，模块课程培养计划选择对应“加强班”，不满足A级条件的，不需要申请，培养计划默认对应的“基础班”

