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

## 政治理论课

- 已选 中国马克思主义与当代

## 数学课

- 最优化方法
  - 核心问题: 怎样找到最优解？
  - 常见内容: 凸优化、梯度法、牛顿法、约束优化、对偶理论
  - 典型应用: 机器学习、运筹、控制、工程设计
- 计算机科学使用的数理逻辑
  - 核心问题: 怎样严格描述和验证推理？
  - 常见内容: 命题逻辑、一阶逻辑、可满足性、可判定性、证明系统
  - 典型应用: 程序验证、数据库、编译器、自动定理证明
- 矩阵论
  - 核心问题: 如何深入理解矩阵和线性变换？
  - 常见内容: 特征值、矩阵分解、范数、正定矩阵、广义逆
  - 典型应用: 数值计算、机器学习、图算法、信号处理
- 随机过程
  - 核心问题: 随机系统如何随时间变化？
  - 常见内容: 马尔可夫链、泊松过程、平稳过程、鞅、布朗运动
  - 典型应用: 排队系统、通信、金融、强化学习
- 泛函分析引论
  - 核心问题: 如何研究无限维空间中的函数与算子？
  - 常见内容: 赋范空间、Banach/Hilbert空间、有界算子、主要定理
  - 典型应用: 偏微分方程、量子力学、控制与优化理论

smb文件系统方向选课顺序:
- 随机过程
- 最优化方法
- 计算机科学使用的数理逻辑
- 矩阵论
- 泛函分析引论

## 专业课

- 嵌入式操作系统内核原理与分析
  - 核心问题： 如何在资源受限或具有实时要求的硬件上，实现可靠、高效、可预测的操作系统内核。
  - 常见内容： 任务调度、中断与异常、内存管理、进程间通信、锁与同步、实时性、设备驱动，以及FreeRTOS、RT-Thread或嵌入式Linux源码分析。
  - 典型应用： IoT设备、工业控制、汽车电子、机器人、智能终端、实时控制系统和嵌入式设备驱动开发。
- 计算复杂性理论
  - 核心问题： 哪些计算问题能够被高效求解，哪些问题本质上需要大量时间或空间资源。
  - 常见内容： 时间与空间复杂度、P与NP、NP完全性、多项式归约、SAT问题、随机算法、近似算法、计算下界及不可判定问题。
  - 典型应用： 算法可行性判断、密码学、安全协议、组合优化、调度问题和近似算法设计。
- 图像处理的数学基础
  - 核心问题： 如何用数学模型描述、变换、恢复和分析数字图像。
  - 常见内容： 傅里叶变换、卷积、采样、插值、数字滤波、矩阵分解、概率统计、小波变换、图像恢复和变分优化。
  - 典型应用： 图像去噪、增强、压缩、超分辨率、医学成像、遥感图像处理和计算机视觉预处理。
- 计算生物信息学（双语课）
  - 核心问题： 如何利用算法、统计模型和计算工具，从大规模生物数据中提取有意义的信息。
  - 常见内容： DNA与蛋白质序列、序列比对、动态规划、基因组组装、隐马尔可夫模型、系统发育树、基因表达和组学数据分析。
  - 典型应用： 基因识别、疾病诊断、药物研发、病毒变异分析、精准医疗和生物进化研究。
- 服务计算
  - 核心问题： 如何把分散的软件能力封装成服务，并完成服务的发现、组合、调用和质量管理。
  - 常见内容： SOA、Web Service、服务描述与发现、服务组合、工作流、QoS、微服务、云计算、服务安全和容错。
  - 典型应用： 企业信息系统、云服务平台、微服务架构、跨组织业务集成、分布式应用和开放API平台。
- 计算智能
  - 核心问题： 如何利用神经、生物进化或模糊推理等机制，解决难以建立精确数学模型的问题。
  - 常见内容： 神经网络、模糊逻辑、遗传算法、进化计算、粒子群优化、蚁群算法、群体智能及部分强化学习内容。
  - 典型应用： 模式识别、参数优化、智能控制、故障诊断、预测分析、路径规划和系统自动调优。
- 高级计算机网络
  - 核心问题： 如何构建高性能、高可靠、可扩展和安全的现代计算机网络。
  - 常见内容： TCP与拥塞控制、可靠传输、网络测量、数据中心网络、RDMA、多路径传输、SDN、网络虚拟化、无线网络和网络安全。
  - 典型应用： 云计算网络、数据中心、分布式存储、网络文件系统、高性能计算、内容分发和网络性能优化。
- 具身智能
  - 核心问题： 如何让智能体通过感知和行动与物理环境交互，并在交互过程中学习和完成任务。
  - 常见内容： 多模态感知、计算机视觉、机器人控制、路径规划、强化学习、仿真环境、视觉语言模型和机器人基础模型。
  - 典型应用： 人形机器人、自动驾驶、无人机、工业机器人、家庭服务机器人和智能制造。
- 形式语言与自动机
  - 核心问题： 如何用数学模型描述计算机能够识别的语言，以及不同计算模型具有什么表达能力。
  - 常见内容： 正则语言、正则表达式、有限自动机、上下文无关文法、下推自动机、图灵机、可计算性和可判定性。
  - 典型应用： 编译器、词法和语法分析、协议解析、文本处理、输入校验、状态机设计和计算理论研究。
- 网络多媒体
  - 核心问题： 如何在带宽、时延和丢包受限的网络中，高质量地传输音频、视频和交互式媒体。
  - 常见内容： 音视频编码、流媒体协议、实时传输、QoS与QoE、抖动缓冲、自适应码率、CDN、缓存及丢包恢复。
  - 典型应用： 视频会议、直播、短视频、网络电视、云游戏、远程教育和实时音视频通信。
- 计算机视觉与异构计算
  - 核心问题： 如何让计算机理解图像和视频，并利用CPU、GPU、FPGA等不同计算单元高效执行视觉算法。
  - 常见内容： 图像特征、目标检测、图像分割、深度学习视觉模型、GPU编程、CUDA/OpenCL、并行计算、内存优化和任务卸载。
  - 典型应用： 自动驾驶、视频监控、工业检测、医学影像、边缘AI、视觉推理加速和高性能图像处理。
- 并行算法与程序设计
  - 核心问题： 如何把一个计算任务拆分到多个处理单元上执行，并保证正确性、负载均衡和良好的扩展性。
  - 常见内容： 数据并行、任务并行、线程与进程、同步与通信、锁与原子操作、OpenMP、MPI、CUDA、Amdahl定律和并行性能分析。
  - 典型应用： 多核程序、高性能计算、科学计算、数据库、分布式系统、机器学习训练和内核并发性能优化。

smb文件系统选课顺序:
- 高级计算机网络：与SMB协议、性能和论文研究最直接  
- 嵌入式操作系统内核原理与分析：与内核机制相关，但课程可能主要讲RTOS，且部分内容你工作中已经掌握  
- 并行算法与程序设计：适合研究并发I/O、多通道、多核扩展和锁竞争  
- 形式语言与自动机：适合协议状态机、报文解析和正确性研究  
- 服务计算：适合云文件服务和分布式服务架构，但偏上层

## 必修环节

- 工程专业实践
- 学术（技术）交流

## 专业核心课

- 软件体系结构
  - 核心问题: 
  - 常见内容: 
  - 典型应用: 
- 信号检测与估值理论
  - 核心问题: 
  - 常见内容: 
  - 典型应用: 
- 机器学习（全英文课程）
  - 核心问题: 
  - 常见内容: 
  - 典型应用: 
- 先进数据库技术
  - 核心问题: 
  - 常见内容: 
  - 典型应用: 
- 算法分析与设计（双语）
  - 核心问题: 
  - 常见内容: 
  - 典型应用: 
- 网络空间安全高级技术
  - 核心问题: 
  - 常见内容: 
  - 典型应用: 
- 智能软件工程
  - 核心问题: 
  - 常见内容: 
  - 典型应用: 
- 网络信息论
  - 核心问题: 
  - 常见内容: 
  - 典型应用: 

## 公共限选课

- 已选 工程伦理学
- 已选 研究生心理健康教育
- 已选 科技文档写作
- 已选 项目管理
