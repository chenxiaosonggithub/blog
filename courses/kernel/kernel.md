<!-- public begin -->
准备出一个Linux内核相关的教程，最大的目的是为了整理自己以前学习到的知识点，当然也为了学习还没学到的知识点，查缺补漏，温故知新。

在这里郑重承诺一下，接下来的课程的每一个字，我都是用键盘一字一句的敲出来，绝对不会复制粘贴，引用其他朋友原话的内容我也会标明出处，欢迎各位朋友的监督。

[点击这里从百度网盘下载配套的视频教程](https://chenxiaosong.com/baidunetdisk)。

[点击这里在哔哩哔哩bilibili在线观看配套的教学视频](https://www.bilibili.com/video/BV1QC41157t7/)。

持续更新中。。。
<!-- public end -->

# Linux内核简介

在讲具体的技术点之前，我们先来讲一些Linux内核相关的小故事。我们都有过这种经历，如果我们对一件事很感兴趣，那我们就会很投入做这件事，做再久也就不会感觉到累；而如果我们对一件不感兴趣，那让我们多做一分钟估计都会感到难受。<!-- public begin -->比如对于喜欢玩游戏的朋友，你们可以玩几个小时，甚至通宵玩游戏；而我不喜欢玩游戏，让我多玩一分钟我都感觉难受；但我喜欢写博客，周末我可以把全部时间都花在写博客上。<!-- public end -->所以我们讲这些Linux内核的小故事，目的是让各位朋友对学习Linux内核产生兴趣，然后全身心的投入学习，接着能力就提升得很快，再涨很多工资，最后走上人生巅峰。当然Linux内核快速发展的30几年时间（截止到2024年），有趣的故事多到数不过来，这里只列出一小部分，感兴趣的朋友以后可以自己继续探索。

## 自由软件

高晓松有句话：这个世界不只有眼前的苟且，还有诗与远方。这在自由软件之父 理查德·马修·斯托曼 身上真正做到了，我们先来看看这位自由软件之父的光辉事迹。

### 自由软件之父

先上一段维基百科上对他的简介：

> 理查德·马修·斯托曼（英语：Richard Matthew Stallman，简称rms，有时也用大写的RMS，1953年3月16日—），美国程序员，自由软件活动家。他发起自由软件运动，倡导软件用户能够对软件自由进行使用、学习、共享和修改，确保了这些软件被称作自由软件。斯托曼发起了GNU项目，并成立了自由软件基金会。他开发了GCC、GDB、GNU Emacs，同时编写了GNU通用公共许可协议。

接触过编程的朋友应该都用过GCC和GDB这两大必不可少的工具，但也许会有朋友以前没了解过这是他开发的，当然他开发的软件数不胜数<!-- public begin -->，比如我使用的相对比较小众但功能极其强大的Emacs编辑器<!-- public end -->。

他写过很多伟大的软件，但相比他的软件开发能力，他最大的成就要数他发起的自由软件运动。可以不夸张的说，他发起的这项自由软件运动，是Linux能够这么成功的基础，当然也是今天很多流行软件成功的基础。

顺便要提一下的是，他虽然在计算机领域有突出贡献，学生时代还在数学、物理学、生物学领域非常有天赋。

他曾经说过一段话：

> 随着社区（软件分享社区）的终结，我面临着一个道德上的抉择。最简单的就是投身于专有软件世界之中，签署不公开协议，并承诺不帮助同行、同事。自己也很可能编写软件，并在不公开协议的前提下发布软件，去同流合污，迫使更多的人背叛自己的原则。显然，走这条路，可以挣大钱，而且使编写代码的工作增添一份金钱上的快乐。但是我知道，等到自己职业生涯终结时，我再回首这些年为分离人类而砌造的‘墙壁’。我会感受到，我将自己的一生都用在使这个世界变得更加糟糕。

1960年代的美国兴起的黑客文化起源于麻省理工学院，到1980年代时，黑客文化已经有所衰落，Unix开始收费和商业闭源（后面会细说），斯托曼于是开始致力于创建 Unix 的替代品，1985年成立了自由软件基金会，并发表GNU宣言。自由软件运动与开放源代码运动让黑客文化又开始流行了。

有意思的是，斯托曼用的一台电脑是中国龙芯芯片的江苏龙梦电脑，这台电脑甚至于在BIOS层级都完全是自由软件。

更多关于这位自由软件之父的有趣故事，可以看他的个人自传《Free as in Freedom: Richard Stallman's Crusade for Free Software》（中文翻译：[《若为自由故》](https://book.douban.com/subject/26314527/)）。

### GNU计划

GNU这个名字其实挺有意思的，GNU is Not Unix，是一个递归缩写，这是黑客文化中的一种幽默。1983年9月27日由理查德·斯托曼在麻省理工学院公开发起。这项计划的目标很崇高，就是创建一套完全自由的操作系统，称为GNU，从名字我们可以知道，就是要创建 Unix 的替代品。

我们再来看自由软件的定义：一类可以不受限制地自由使用、复制、研究、修改和分发的，尊重使用者自由的软件。这里要强调的一个词是“不受限制”，使用自由软件的人可以随便修改源代码，但要遵守一定的自由软件许可协议。自由软件许可协议有很多，比如BSD和MIT等宽松自由软件许可证，比如GPL这种Copyleft许可证。

这里我们重点说一下GPL协议，为什么呢，因为我们要学习的Linux内核就是采用的GPL协议，全称是GNU General Public License，中文名称是GNU通用公共许可协议。GPL是一个Copyleft许可证，什么是Copyleft呢，其实这个概念很有意思，就是针对copyright，copyright就是是著作权，俗称版权。维基百科上有一句话可以很好的解释Copyleft的概念：允许他人任意的修改散布作品，惟其散布及修改的行为和作法，亦限定以Copyleft的方式行之。翻译一下也就是你可以随便修改和传播我的代码，但你修改过的代码也要允许其他人修改和传播。

然后还要说一点，就是自由软件也是可以收费，可以商业化的，举个例子吧，比如红帽公司的Linux发行版就要收费，但他们的收费形式是通过提供技术服务，就是客户使用他们的发行版遇到问题了，红帽公司就有偿的帮助他们解决问题。

既然GNU计划是一项计划，可能有朋友会问这项计划成功了没，答案是这项计划基本完成。你可能会说，一项计划要么未完成，要么已经完成，为什么会是一个基本完成的状态呢，这就得说到GNU Hurd内核Linux内核了。到1989年时，GNU项目中的其他部分，如编辑器、编译器、Shell等都已经完成，就缺一个内核，GNU计划在1990年时是要开发一个内核的，名字叫Hurd，但这个Hurd也许一方面是设计得太复杂了吧，另一方面Linux内核的横空出世，让所有人都把目光从Hurd内核转移到Linux内核身上了，斯托曼坚持认为 Linux 应该被称作 GNU/Linux，因为 GNU 计划更早出现，且在 Linux 操作系统的早期，GNU 社区的软件源代码在其中起了关键的作用，例如 GCC 编译器。

### 开源软件

实际上吧，在今天，比起“自由软件”这个概念，“开源软件”被更多人提起。在自由软件之父看来，开源软件和自由软件是严格区分的。关于这两个概念的区别，社区争议很大，广为流传的一种说法是，我们可以这样理解，开源软件的范围更广，开源软件包含自由软件，也包含不自由软件，也就是有一些软件虽然开源了，但并不允许别人修改，你改了我的代码拿来商用，不管你有没把商业软件开源，我依然可以告你。

比如Minix早期的源代码虽然容易得到，但并没有采用自由软件许可协议，所以早期还不能称为自由软件。直到2000年4月，重新以BSD许可协议发布，才变成自由软件。

## Unix介绍

### Unix的历史

Linux的诞生和Unix密不可分，我们来看看关于Unix的一些有趣的故事。Unix这个操作系统的起源很有意思，它是起源于一个失败的操作系统MULTICS，这个MULTICS操作系统计划可厉害了，参与开发的公司和学校有贝尔实验室、麻省理工学院及美国通用电气公司，1964年开始开发。但是5年后1969年时因开发进度太慢，贝尔实验室决定退出这个计划。贝尔实验室里有两个很厉害的人，肯·汤普逊（老K）和丹尼斯·里奇（老R），也许你一时间想不起来他们是谁，但你肯定知道c语言吧，没错，他们就是c语言的作者。这两个厉害的人为什么要开发Unix呢，原因很有意思的，就是老K想玩一个他自己开发的叫“星际旅行”（Space Travel）游戏，之后老R也加入进来了，这系统的功能越来越完善，1970年时取名为Unix。

接下来的10年左右，Unix的拥有者AT&T公司（贝尔实验室就是这家公司的）以很便宜甚至不要钱将Unix源码给了学术机构用来研究或教学，这些学术机构经过扩展和改进，形成了所谓的“Unix变种”，其中最著名的是由加利福尼亚大学伯克利分校开发的伯克利软件套件(Berkeley Software Distribution，BSD)产品。后来AT&T公司发现Unix可以卖很多钱，就后悔了，不想把源码给学术机构了，还对Unix及其变种声明了著作权权利。但BSD已经被很多商业厂家采用了，AT&T就开始了一场持久的著作权官司。1984年时Unix的免费发行结束，斯托曼在1983年9月27日就发起的GNU计划着手使用免费分发给任何人的软件重新构建Unix，还将计划命名为GNU is Not Unix。

### Minix操作系统

Minix是一个迷你版本的类Unix操作系统，名字就是Mini Unix的简称，作者是安德鲁·斯图尔特·特南鲍姆，最初只用于他的教学，采用的是微内核的设计，没有使用任何的Unix代码，最初在1987年发布，最初只有约12,000行。2000年4月，重新以BSD许可协议发布，成为自由软件。在今天看来，这个Minix的最大价值在于启发了Linux内核的创作。

Linux内核刚发布时，使用的就是Minix文件系统，现在2024年的Linux内核源码中，还能看到Minix文件系统的代码，当然现在Minix文件系统并没有用于商业用途，仅仅只是用于学习的demo吧。还有Linux内核刚开发时，也是在Minix上编写代码和编译的。

### 宏内核和微内核

我们要学习的Linux内核是宏内核，也叫集成式内核、单体式内核，就是很多功能都放在内核中。除了Linux内核外，宏内核的操作系统还有：传统Unix内核（BSD、Solaris），类Unix系统的内核（FreeBSD、OpenBSD、NetBSD、LynxOS、Syllable Desktop），磁盘操作系统Disk Operating System（DR-DOS、MS-DOS、Microsoft Windows 9x系列（95、98、98SE、Me）、FreeDOS），Mac OS（从最初版到Mac OS 8.6版），OpenVMS，XTS-400。

刚刚说到的Minix和GNU计划的Hurd是微内核，提倡内核中的功能尽可能的少，只保留一些最核心的功能，其他的功能都放到用户空间中，是特殊的用户进程。其他的微内核的操作系统还有：QNX（在黑莓手机BlackBerry 10系统中被采用），L4微内核系列。

需要注意的是，微软Windows系统和苹果电脑的Mac OS X虽然说自己使用的是微内核架构，但为了追求性能，将很多功能放到了内核空间，实际上这已经违反了微内核的基本设计原则，更像是宏内核的设计方式，所以一般被称为混合内核。

### POSIX标准

POSIX的全称是Portable Operating System Interface，中文翻译为可移植操作系统接口，其中X的意思是对Unix API的传承。这个名称是自由软件之父斯托曼应IEEE的要求而提议的一个易于记忆的名称。

POSIX标准的目的是为了在各种Unix操作系统上定位API（应用程序接口）的标准，通俗的讲就是，你在BSD操作系统上写的源代码，拿到Solaris操作系统上也能编译运行。Linux虽然没有参加正式的POSIX认证，但基本上逐步实现了POSIX兼容。还有一个我们开始接触电脑就会用到的微软的Windows系统也部分实现了POSIX标准。所以现在你在Windows系统上编写的源代码，拿到Linux上也能编译运行通过了。

## Linux内核和GNU/Linux发行版

### Linux内核之父

先上维基百科的一段描述：

> 林纳斯·贝内迪克特·托瓦兹（瑞典语：Linus Benedict Torvalds，瑞典语：[ˈliːn.ɵs ˈtuːr.valds]，1969年12月28日—），生于芬兰赫尔辛基市，拥有美国国籍，Linux内核的最早作者，随后发起了这个开源项目，担任Linux内核的首要架构师与项目协调者，是当今世界最著名的电脑程序员、黑客之一。他还发起了开源项目Git，并为主要的开发者。

如果你在网上搜索“世上最厉害的程序员”，你绝对会发现林纳斯在其中。在他开发的众多软件之中，有两个软件最为著名，就是接下来我们要学习的Linux内核和git。其中git几乎现在的每一个程序员一定会用到的代码管理工具。他有句名言：Talk is cheap, show me the code，翻译过来就是，别逼逼那么多，有种给我看你的代码。从这句话可以看出，在他的带领下，Linux内核社区以技术说话，所以在Linux内核社区你可以和世上最顶尖的程序员交流技术，是不是有点小心动。

林纳斯在11岁时时就开始写程序，1989年进入大学的第二年去当兵，期间买了安德鲁·斯图尔特·塔能鲍姆所著的教科书《操作系统：设计与实现》（Operating Systems: Design and Implementation，ISBN 0-13-637331-3）及Minix源代码，开始研究操作系统。

接下来说几件关于他的有趣故事<!-- public begin -->。直接从维基百科上copy过来吧<!-- public end -->：

> 托瓦兹坚持开放源代码信念，并对微软等对手的FUD战略大为不满。例如，在一封回应微软资深副总裁克瑞格·蒙迪批评开放源代码运动破坏了知识产权的电子邮件中，托瓦兹写道：“我不知道蒙迪是否听说过艾萨克·牛顿爵士？他不仅因为创立了经典物理学而出名，也还因为说过这样一句话而闻名于世：‘我之所以能够看得更远，是因为我站在巨人肩膀上的缘故。’”托瓦兹又说道：“我宁愿听牛顿的也不愿听蒙迪的。他（牛顿）虽然死了快300年了，却也没有让房间这样地臭气熏天。”<!-- public begin -->陈孝松注：<!-- public end -->需要说明一下，微软现在已经拥抱Linux了，甚至有了自己的GNU/Linux发行版了。

> 林纳斯在网上邮件列表中也以火暴的脾气著称。例如，有一次与人争论Git为何不使用C++开发时与对方用“放屁”（原文为“bullshit”、“BS”）互骂。他更曾以“一群自慰的猴子”（原文为“OpenBSD crowd is a bunch of masturbating monkeys”）来称呼OpenBSD团队，因为林纳斯认为软件一般性的错误比安全漏洞来的要多，而信息安全人士因为找到漏洞而成为英雄，而忽略了一般性软件错误的修补，并认为OpenBSD团队过度重视安全性忽略其他部分。

> 2012年6月14日，托瓦兹在出席芬兰的阿尔托大学所主办的一次活动时称Nvidia是他所接触过的“最烂的公司”（the worst company）和 “最麻烦的公司”（the worst trouble spot），因为Nvidia一直没有针对Linux平台发布任何官方的Optimus支持，随后托瓦兹当众对着镜头竖起了中指，说“去你妈的NVIDIA！”（So, Nvidia, fuck you!）。<!-- public begin -->陈孝松注：<!-- public end -->这句话还真让这家公司做出改变了，现在英伟达开源了不少驱动，林纳斯对英伟达举大拇指了。

更多的林纳斯的有趣故事，可以查看他的个人自传：[《只是为了好玩》](https://book.douban.com/subject/25930025/)。

### Linux内核的历史

在林纳斯当兵期间，接触了Minix操作系统，Minix的源代码虽然容易得到，但作者只想把这个系统用于教学，对源代码的修改和发布是不允许的，这让林纳斯感到失望。另外，1989年时GNU项目中的其他部分，如编辑器、编译器、Shell等都已经完成，虽然在1990年自由软件基金会开始正式发展Hurd，但也许是设计得太过复杂了吧，开发进行得并不是很顺利。

这些原因综合在一起，使林纳斯决定要自己写一个内核，1991年，还是一名大学生的林纳斯在comp.os.minix新闻组里发了一封帖子，说自己出于兴趣爱好做了一个（自由的）操作系统，希望得到懂Minix系统的人的意见。之后，许多人为这个项目贡献了代码，其中Minix社区贡献了很多代码和想法。有趣的是，Linux内核最初不是取这个名字的，而是叫Freax，但林纳斯的同事觉得这个名字不好听，就把名字私自改成了Linux。

1991年9月，0.01版本时有1万多行代码。1994年3月14日，1.0.0版本有17万多行代码。1995年3月，1.2.0有31万行代码。2013年6月3.10版本有1580万行代码。再看2024年的今天，Linux的内核代码行数如今已经达到3000万行左右（约一亿的1/3）。一个由个人兴趣发展起来的软件，30几年发展到如今的规模，可以看出当初的设计是多么的优雅。

### 众多的GNU/Linux发行版

一个操作系统只有内核肯定是不够的，还需要配套很多GNU软件，这些软件与内核的集合称为Linux发行版，更准确的说，应该叫GNU/Linux发行版，因为其中包含了数量庞大的GNU软件，Linux内核虽然非常重要，但也只是占据很小的一部分。

按软件包管理系统划分，介绍使用人数最多的两个大类，当然还有其他发行版本使用别的软件包管理系统。

首先是Debian系，Debian及其派生发行版使用deb软件包格式，并使用dpkg及其前端作为软件包管理器。

- [Debian](https://www.debian.org/)：Debian计划是由伊恩·默多克在1993年发起的，在1993年9月15日发布Debian 0.01版，第一个稳定版本在1996年发布。<!-- public begin -->我内核测试验证的虚拟机用的就是Debian。<!-- public end -->
- [Ubuntu](https://cn.ubuntu.com/)：然后得说一下在桌面Linux发行版中使用人数比较多的Ubuntu发行版，是Canonical有限公司基于Debian开发的，但和Debian不同的地方是他的目的是开发更加友好的桌面。Ubuntu每6个月发布一个版本，每年的4月和10月，长期支持（LTS）版本每两年发布一次（如Ubuntu 22.04）。普通版本只支持9个月，LTS版本一般支持5年。<!-- public begin -->我编译代码的环境用的就是Ubuntu。<!-- public end -->
- [银河麒麟桌面系统](https://product.kylinos.cn/productCase/171/36)：银河麒麟为Ubuntu Kylin的商业版本，当前在国内使用人数比较多。

接着介绍一下Red Hat系，使用RPM格式软件包。

- [Red Hat Enterprise Linux](https://www.redhat.com/en/technologies/linux-platforms/enterprise-linux)：红帽公司发行，Red Hat 1.0版本在1995年5月发行，从Red Hat 9.0版本（2003-03-31）之后不再开发桌面版，开始专注服务器版本Red Hat Enterprise Linux（刚开始是基于 Red Hat Linux）。Red Hat Enterprise Linux 4 （2005-02-15）之后基于社区的Fedora，从 Red Hat Enterprise Linux 9 （2022-05-18）之后基于CentOS Stream和Fedora。
- [Fedora](https://fedoraproject.org/)：社群开发、红帽公司赞助，约6个月发布新版本。
- [CentOS](https://www.centos.org/)：来自于Red Hat Enterprise Linux（RHEL）依照开放源代码规定发布的源代码所编译而成，不包含闭源代码的软件，2014年与红帽公司合作，2020年红帽终止CentOS，采用CentOS Stream。
- [Rocky Linux](https://rockylinux.org/)：CentOS的创始人在CentOS终止后创建的，继续CentOS的目标。首个正式版本8.4在2021年6月21日发布。
- [openEuler](https://www.openeuler.org/zh/)：2019 年12月31日社区成立，版本发布周期和Ubuntu一样，只是换成了每年的3月和6月。参与度最高的有华为、麒麟软件等公司。

<!--
## Linux内核的就业

找工作时，我们会看招聘岗位的要求。其实，在学习时，我们也可以看招聘岗位要求，针对一些公司招聘要求去学习相应的知识点。

首先我们可以在[LWN上搜索贡献排名靠前的公司](https://lwn.net/Articles/948970/)，当然这是全世界的排名。或者看中国由华为发起的参与公司很多的[openEuler社区的商业发行版](https://www.openeuler.org/zh/download/commercial-release/)的公司。

下面我们列一下在中国的几类内核相关的岗位要求。

### 岗位职责

- 操作系统内核移植、适配以及定制
- 移动产品板卡和驱动开发
- 内核和驱动层问题分析和调试工作
- Linux内核性能的评估、设计、实现和验证
- 分析内核panic、死锁、内存踩踏/溢出，core hang和bus hang等疑难问题
- 内核CVE等补丁的回合和新特性移植
- 完成内核开发的技术文档设计和输出
- 内核驱动开发和单元测试
- 操作系统产品线版本定制和研发
- 

### 岗位要求

- 对Linux内核及底层有强烈兴趣，对技术有追求
- 熟悉ARM、MIPS、X86架构中的一种或者多种
- 阅读过内核中的主要模块（文件系统、TCP/IP、IO、内存管理、进程管理等）之一的源代码
- 具备Linux内核调试能力，灵活运用kexec、crash、kprobe、kdump、perf等调试工具
- 熟悉ebpf框架
- 熟悉Linux内核开源社区发展，参与过社区开发
- 熟悉汇编语言
- 熟悉KVM底层实现原理
- 熟悉RTOS系统底层实现原理
- 熟悉Linux系统性能调做及Linux服务管理
- 熟悉嵌入式设备Linux内核适配（体系结构适配）
- 熟悉Linux驱动开发流程和驱动框架
-->

# Linux内核开发环境

下面介绍Linux内核编译环境和测试环境的搭建过程，当然我也为各位朋友准备好了已经安装好的虚拟机镜像，只需下载运行即可。

<!-- public begin -->[点击这里从百度网盘下载对应平台的虚拟机镜像](https://chenxiaosong.com/baidunetdisk)，<!-- public end -->`x86_64`（也就是你平时用来安装windows系统的电脑，或者2020年前的苹果电脑）选择`ubuntu-x64_64.zip`，`arm64`（2020年末之后的苹果电脑）选择`ubuntu-aarch64.zip`。虚拟机运行后，登录界面的密码是`1`。

## 安装Linux发行版

安装Linux发行版，你可以选择以下几种方式：

- 在物理机上直接安装安装Linux发行版。这是工作时比较推荐的一种安装方法，可以最大程度的利用硬件资源。
- 在容器（如docker）中安装Linux发行版。这种方式也能最大程度的利用硬件资源，还能快速恢复开发环境。
- 在虚拟机上安装Linux发行版。在学习阶段推荐这种方式安装，因为一旦系统出现什么问题可以快速恢复。

### 虚拟机软件

接下来介绍几个常用的虚拟机软件。

- [VirtualBox](https://www.virtualbox.org/)。首先在[VirtualBox下载界面](https://www.virtualbox.org/wiki/Downloads)下载对应平台的安装包，比如如果要在Windows系统下安装VirtualBox，点击**Windows hosts**下载安装包。VirtualBox的安装过程很简单，只需根据安装提示操作即可。VirtualBox安装完成后，下载**VirtualBox 7.0.14 Oracle VM VirtualBox Extension Pack**安装插件。
- [VMware](https://www.vmware.com/)。在[VMware Workstation下载界面](https://www.vmware.com/products/workstation-pro/workstation-pro-evaluation.html)下载对应平台的安装包，注意非商业用途只能不使用Workstation Player。苹果电脑要下载[VMware Fusion](https://www.vmware.com/products/fusion/fusion-evaluation.html)，点击[Fusion 13 Player for macOS 12+](https://customerconnect.vmware.com/evalcenter?p=fusion-player-personal-13)注册登录账号，注册信息填写类似`Address 1: 1ONE, City: SACRAMENTO, Postal code: 94203-0001, Country/Territory: United States, State or province: California`，注册后会有个人使用的`LICENSE KEYS`。安装过程很简单，只需根据提示操作即可。<!-- public begin -->Linux下安装VMware时需要注意的是`/tmp`目录的挂载不能在`/etc/fstab`文件中指定`noexec`，还需要安装gcc较新的版本（如`VMware-Workstation-Full-17.5.1-23298084.x86_64.bundle`在ubuntu2204下安装时要安装gcc12，默认安装的是gcc11）。<!-- public end -->
- [Virtual Machine Manager](https://virt-manager.org/)。这个虚拟机软件只用在Linux平台上，如果你物理机上安装的操作系统是Linux，那么使用这个软件运行虚拟机就比较合适。比如在Ubuntu上使用命令`sudo apt-get install qemu qemu-kvm virt-manager qemu-system -y`安装（需要重启才能以非root用户启动）。
- [UTM](https://mac.getutm.app/)。只针对苹果电脑系统，从[github](https://docs.getutm.app/installation/macos/)上下载安装包。建议在配置比较高（尤其是内存）的苹果电脑上使用，如果配置比较低可能会遇到一些问题。

配置虚拟机时，Windows系统cpu核数查看方法：任务管理器->性能->CPU，苹果电脑cpu核数查看方法: `sysctl hw.ncpu`或`sysctl -n machdep.cpu.core_count`，Linux系统cpu核数查看方法`lscpu`。

### 安装Ubuntu发行版

Linux发行版很多，我们选择一个使用人数相对较多的[Ubuntu发行版](https://ubuntu.com/)。[x86_64的ubuntu22.04](https://releases.ubuntu.com/22.04/)，[arm64的ubuntu22.04](http://cdimage.ubuntu.com/jammy/daily-live/current/)下载。[x86_64的ubuntu20.04](https://releases.ubuntu.com/20.04/)，[arm64的ubuntu20.04](https://ftpmirror.your.org/pub/ubuntu/cdimage/focal/daily-live/current/)

安装内核编译和测试所需软件：
```sh
sudo apt install git -y # 代码管理工具
sudo apt install build-essential -y # 编译所需的常用软件，如gcc等
sudo apt-get install qemu qemu-kvm qemu-system -y # qemu虚拟机相关软件
sudo apt-get install virt-manager -y # docker中不需要安装，虚拟机图形界面，会安装iptables，可能需要重启才能以非root用户启动virt-manager，当然对于内核开发来说安装这个软件是为了生成自动生成virbr0网络接口
sudo apt install flex bison bc kmod pahole -y # 内核编译所需软件
sudo apt-get install libelf-dev libssl-dev libncurses-dev -y # 内核源码编译依赖的库
```

<!-- public begin -->
### docker环境

除了在vmware虚拟机中搭建开发环境，还可以在docker中搭建开发环境。注意qemu的权限配置请参考后面的“qemu配置”相关的章节。

#### NAT模式

参考[中文翻译QEMU Documentation/Networking/NAT](https://chenxiaosong.com/translations/qemu-networking-nat.html)。

qemu命令行的网络参数修改成（`model`和`macaddr`可以自己指定）：
```sh
-net tap \
-net nic,model=virtio,macaddr=00:11:22:33:44:01 \
```

注意在虚拟机中，不要手动配置ip，要运行`systemctl restart networking.service`自动获取ip地址。

#### 桥接模式（TODO）

宿主机中桥接模式配置：
```sh
apt install bridge-utils -y # brctl命令
brctl addbr br0
brctl stp br0 on
brctl addif br0 eth0
# brctl delif br0 eth0
ip addr del dev eth0 172.17.0.2/16 # 清除ip
ifconfig br0 172.17.0.2/16 up # 或 ifconfig virbr0 172.17.0.2 netmask 172.17.0.1 up
route add default gw 172.17.0.1
sysctl net.ipv4.ip_forward=1 # 或 echo 1 > /proc/sys/net/ipv4/ip_forward
```

虚拟机中：
```sh
ip addr add 172.17.0.3/16 dev ens2
# ip addr del dev ens2 172.17.0.3/16 # 删除ip
ip link set dev ens2 up
# ip link set dev ens2 down
# 网关可不配置
# route del default dev ens2
# route add default gw 172.17.0.1 # ip route add default via 172.17.0.1 dev ens2
```

手动配置ip没法访问外网，暂时还不知道要怎么弄，如果有知道的朋友可以指导我一下。
<!-- public end -->

## 代码管理和编辑工具

### 使用code-server浏览和编辑代码

为了尽可能的方便，推荐使用code-server在网页上浏览和编辑代码，当然你也可以使用自己习惯的代码浏览和编辑工具。

[code-server源码](https://github.com/coder/code-server)托管在GitHub，安装命令:
```sh
curl -fsSL https://code-server.dev/install.sh | sh
```

<!--
安装成功后，输出以下日志：
```sh
Ubuntu 22.04.2 LTS
Installing v4.11.0 of the amd64 deb package from GitHub.

+ mkdir -p ~/.cache/code-server
+ curl -#fL -o ~/.cache/code-server/code-server_4.11.0_amd64.deb.incomplete -C - https://github.com/coder/code-server/releases/download/v4.11.0/code-server_4.11.0_amd64.deb
######################################################################## 100.0%
+ mv ~/.cache/code-server/code-server_4.11.0_amd64.deb.incomplete ~/.cache/code-server/code-server_4.11.0_amd64.deb
+ sudo dpkg -i ~/.cache/code-server/code-server_4.11.0_amd64.deb
Selecting previously unselected package code-server.
(Reading database ... 226525 files and directories currently installed.)
Preparing to unpack .../code-server_4.11.0_amd64.deb ...
Unpacking code-server (4.11.0) ...
Setting up code-server (4.11.0) ...

deb package has been installed.

To have systemd start code-server now and restart on boot:
  sudo systemctl enable --now code-server@$USER
Or, if you don't want/need a background service you can run:
  code-server

Deploy code-server for your team with Coder: https://github.com/coder/coder
```
-->

或者下载[对应系统的安装包](https://github.com/coder/code-server/releases)。

设置开机启动：
```sh
sudo systemctl enable --now code-server@$USER
```

配置文件是`${HOME}/.config/code-server/config.yaml`，当不需要密码时修改成`auth: none`。

修改完配置后，需要再重启服务：
```sh
sudo systemctl restart code-server@$USER
```

然后打开浏览器输入`http://localhost:8888`（8888是`${HOME}/.config/code-server/config.yaml`配置文件中配置的端口）。

注意，和vscode客户端不一样，vscode server装插件时有些插件无法搜索到，这时就需要在[vscode网站](https://marketplace.visualstudio.com/vscode)上下载`.vsix`文件，手动安装。

<!-- public begin -->
常用插件：
<!-- public end -->

- C语言（尤其是内核代码）推荐使用插件[C/C++ GNU Global](https://marketplace.visualstudio.com/items?itemName=jaycetyle.vscode-gnu-global)。使用命令`sudo apt install global -y`安装gtags插件，Linux内核代码使用命令`make gtags`生成索引文件。

<!-- public begin -->
- C++语言推荐使用插件[C/C++](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools)或[clangd](https://marketplace.visualstudio.com/items?itemName=llvm-vs-code-extensions.vscode-clangd)。浏览C/C++代码时，建议这两个插件和[C/C++ GNU Global](https://marketplace.visualstudio.com/items?itemName=jaycetyle.vscode-gnu-global)选一个，不要安装多个。

- Vue.js推荐使用插件[Vetur](https://marketplace.visualstudio.com/items?itemName=octref.vetur)、[Vue Peek](https://marketplace.visualstudio.com/items?itemName=dariofuzinato.vue-peek)、[ESLint](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint)、[Bracket Pair Colorizer 2](https://marketplace.visualstudio.com/items?itemName=CoenraadS.bracket-pair-colorizer-2)、[VueHelper](https://marketplace.visualstudio.com/items?itemName=oysun.vuehelper)

当想在[vscode客户端](https://code.visualstudio.com/)打开远程的文件时, 可以使用 [remote-ssh](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh)插件.
<!-- public end -->

### git的一些特殊用法

这里我们不介绍git的一般用法，仅介绍一些特殊用法。

<!-- public begin -->
查看帮助文档`man 1 git log`：
```sh
       -L<start>,<end>:<file>, -L:<funcname>:<file>
           跟踪给定 <start>,<end> 或函数名正则表达式 <funcname> 所定义的行范围的演变，位于 <file> 内。您不可以提供任何路径规范限定符。目前此功能仅限于从单个修订版本开始的遍历，即您只能提供零个或一个正面修订参数，<start> 和 <end>（或 <funcname>）必须存在于起始修订版本中。您可以多次指定此选项。隐含--patch。可以使用 --no-patch 抑制补丁输出，但当前尚未实现其他差异格式（即 --raw、--numstat、--shortstat、--dirstat、--summary、--name-only、--name-status、--check）。

           <start> 和 <end> 可以采用以下形式之一：

           •   数字

               如果 <start> 或 <end> 是数字，则指定绝对行号（从 1 开始计数）。

           •   /正则表达式/

               此形式将使用与给定 POSIX 正则表达式匹配的第一行。如果 <start> 是正则表达式，则它将从前一个 -L 范围的末尾开始搜索，如果有的话，否则从文件开头开始搜索。如果 <start> 是 ^/正则表达式/，则它将从文件的开头开始搜索。如果 <end> 是正则表达式，则它将从由 <start> 给出的行开始搜索。

           •   +偏移量 或 -偏移量

               这仅对 <end> 有效，并将指定相对于由 <start> 给出的行之前或之后的行数。

           如果 :<funcname> 出现在 <start> 和 <end> 的位置，则它是一个正则表达式，表示从第一行与 <funcname> 匹配的 funcname 行开始，直到下一个 funcname 行。:<funcname> 从前一个 -L 范围的末尾开始搜索，如果有的话，否则从文件的开头开始搜索。^:<funcname> 从文件的开头开始搜索。函数名称的确定方式与 git diff 解析补丁块标题的方式相同（请参见 gitattributes(5) 中关于定义自定义块标题的说明）。
```
<!-- public end -->

以内核主线代码[fs/namespace.c](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/namespace.c?id=8f6f76a6a29f)文件为例，查看`do_new_mount`函数：
```sh
git log -L:do_new_mount:fs/namespace.c
```

我们发现列出的却是`do_new_mount_fc`的修改记录，因为`do_new_mount_fc`包含字符串`do_new_mount`，又在`do_new_mount()`函数前面，解决方法是在`do_new_mount`后面再加个`\(`：
```sh
git log -L:do_new_mount\(:fs/namespace.c
```

在内核开发过程中我们经常需要找某个commit提交记录是哪个版本引入的，使用以下命令
```sh
git name-rev <commit>
```

如果我们有两个github账号，两个账号不能在网站上添加同一个ssh key，这时我们就要再生成一个ssh key，还要将ssh私钥添加到ssh代理：
```sh
ssh-keygen -t ed25519-sk -C "YOUR_EMAIL" # 生成新的key
eval "$(ssh-agent -s)" # 启动 SSH 代理
ssh-add ~/.ssh/id_ed25519 # 将 SSH 私钥添加到 SSH 代理
```

`cherry-pick`多个`commit`:
```sh
git cherry-pick <commit1>..<commitN> # 不包含commit1
```

<!-- public begin -->
如果多个commit中包含有Merge的commit，直接cherry-pick多个会报错`error: 提交 xxxx 是一个合并提交但未提供 -m 选项`，可以把`git log --oneline`的输出放到文件`commits.txt`中，把Merge相关的commit删除，并删除掉每行的后面的commit信息，每行只保留commit号，然后用以下脚本`cherry-pick`（各位朋友如果有什么更好的方法请一定要联系告诉我）：
```sh
# tac 从最后一行开始 cherry-pick
tac commits.txt | while IFS= read -r commit; do
	git cherry-pick $commit
	if [ $? -eq 0 ]; then
		echo "合并成功"
	else
		echo "合并失败"
		return
	fi
done
echo "全部合并成功"
```
<!-- public end -->

`git cherry-pick`或`git am`合补丁时如果有冲突，在解决完冲突后，在`commit`信息中在`Conflicts:`后列出冲突文件，如：
```sh
Conflicts:
        include/linux/sunrpc/clnt.h
```

## 代码编译

### 获取代码

用git下载内核代码，仓库链接可以点击[内核网站](https://kernel.org/)上对应版本的`[browse] -> summary`查看，我们下载[mainline](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git)版本的代码：
```sh
git clone https://kernel.googlesource.com/pub/scm/linux/kernel/git/torvalds/linux.git # 国内使用googlesource仓库链接比较快
```

也可以在[/pub/linux/kernel/](https://mirrors.edge.kernel.org/pub/linux/kernel/)下载某个版本代码的压缩包。

### 编译步骤

建议新建一个`build`目录，把所有的编译输出存放在这个目录下，注意<!-- public begin -->[`.config`](https://gitee.com/chenxiaosonggitee/blog/blob/master/courses/kernel/x86_64/config)<!-- public end --><!-- private begin -->`.config`<!-- private end -->文件要放在`build`目录:
```sh
rm build -rf && mkdir build
```
<!-- public begin -->
```sh
cp ${HOME}/chenxiaosong/code/blog/courses/kernel/x86_64/config build/.config
```
<!-- public end -->

编译命令如下：
```sh
make O=build menuconfig # 交互式地配置内核的编译选项
KNLMKFLGS="-j64" # "-j64" 修改成你电脑上 lscpu 命令显示的cpu核数
make O=build olddefconfig ${KNLMKFLGS}
make O=build bzImage ${KNLMKFLGS} # x86_64
make O=build Image ${KNLMKFLGS} # aarch64，比如2020年末之后的arm芯片的苹果电脑上vmware fusion安装的ubuntu
make O=build modules ${KNLMKFLGS}
make O=build modules_install INSTALL_MOD_PATH=mod ${KNLMKFLGS}
```

在`x86_64`下，如果是交叉编译其他架构，`ARCH`的值为`arch/`目录下相应的架构，编译命令是：
```sh
make ARCH=i386 O=build bzImage # x86 32bit
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi-  O=build zImage # armel, arm eabi(embeded abi) little endian, 传参数用普通寄存器
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- O=build zImage # armhf, arm eabi(embeded abi) little endian hard float, 传参数用fpu的寄存器，浮点运算性能更高
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- O=build Image
make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- O=build Image
```

### 一些额外的补丁

如果你要更方便的使用一些调试的功能，就要加一些额外的补丁。

- 降低编译优化等级，默认的内核编译优化等级太高，用GDB调试时不太方便，有些函数语句被优化了，无法打断点，这时就要降低编译优化等级。做好的虚拟机中已经打上了降低编译优化等级的补丁。<!-- public begin -->比如`x86_64`架构下可以在[`x86_64`](https://gitee.com/chenxiaosonggitee/blog/tree/master/courses/kernel/x86_64)目录下选择对应版本的补丁，更多详细的内容请查看GDB调试相关的章节。<!-- public end -->
- `dump_stack()`输出的栈全是问号的解决办法。如果你使用`dump_stack()`输出的栈全是问号，可以 revert 补丁 `f1d9a2abff66 x86/unwind/orc: Don't skip the first frame for inactive tasks`。主线已经有补丁做了 revert： `230db82413c0 x86/unwind/orc: Fix unreliable stack dump with gcov`。
<!-- public begin -->
- 肯定还有一些其他有用的补丁，后面再补充哈。
<!-- public end -->

## 使用QEMU测试内核代码

前面介绍完了编译环境，编译出的代码我们不能直接在编译环境上运行，还要再启动qemu虚拟机运行我们编译好的内核。

### 模拟器与虚拟机

Bochs：x86硬件平台的开源模拟器，帮助文档少，只能模拟x86处理器。

QEMU：quick emulation，高速度、跨平台的开源模拟器，能模拟x86、arm等处理器，与Linux的KVM配合使用，能达到与真实机接近的速度。

第1类虚拟机监控程序：直接在主机硬件上运行，直接向硬件调度资源，速度快。如Linux的KVM（免费）、Windows的Hyper-V（收费）。

第2类虚拟机监控程序：在常规操作系统上以软件层或应用的形式运行，速度慢。如Vmware Workstation、Oracal VirtualBox。

本教程中，我们使用qemu来测试运行内核代码。

### 制作测试用的qcow2镜像的脚本

测试编译好的内核我们不直接用发行版的iso镜像安装的系统，而是使用脚本生成比较小的镜像（不含有图形界面）。<!-- public begin -->进入目录[`courses`](https://gitee.com/chenxiaosonggitee/blog/tree/master/courses)，<!-- public end -->选择相应的cpu架构，如<!-- public begin -->[`x86_64`](https://gitee.com/chenxiaosonggitee/blog/tree/master/courses/kernel/x86_64)<!-- public end --><!-- private begin -->`x86_64`<!-- private end -->目录。执行<!-- public begin -->[`create-raw.sh`](https://gitee.com/chenxiaosonggitee/blog/blob/master/courses/kernel/x86_64/create-raw.sh)<!-- public end --><!-- private begin -->`create-raw.sh`<!-- private end -->生成raw格式的镜像，这个脚本会调用到<!-- public begin -->[`create-debian.sh`](https://gitee.com/chenxiaosonggitee/blog/blob/master/courses/kernel/create-debian.sh)<!-- public end --><!-- private begin -->`create-debian.sh`<!-- private end -->，是从[syzkaller的脚本](https://github.com/google/syzkaller/blob/master/tools/create-image.sh)经过修改而来。

注意riscv64架构的镜像，可以直接下载[ubuntu2204](https://ubuntu.com/download/risc-v)（选择[QEMU emulator]）。

生成raw格式镜像后，再执行以下命令转换成占用空间更小的qcow2格式：
```sh
# -p 显示进度， -f 源镜像格式， -O 转换后的格式， 后面再紧接的是：源文件名称，转换后的文件名称
qemu-img convert -p -f raw -O qcow2 image.raw image.qcow2
```

再执行脚本<!-- public begin -->[`link-scripts.sh`](https://gitee.com/chenxiaosonggitee/blog/blob/master/courses/kernel/link-scripts.sh)<!-- public end --><!-- private begin -->`link-scripts.sh`<!-- private end -->把脚本链接到相应的目录，执行<!-- public begin -->[`update-base.sh`](https://gitee.com/chenxiaosonggitee/blog/blob/master/courses/kernel/x86_64/update-base.sh)<!-- public end --><!-- private begin -->`update-base.sh`<!-- private end -->启动虚拟机更新镜像（如再安装一些额外的软件），镜像更新完后关闭虚拟机，再执行<!-- public begin -->[`create-qcow2.sh`](https://gitee.com/chenxiaosonggitee/blog/blob/master/courses/kernel/x86_64/create-qcow2.sh)<!-- public end --><!-- private begin -->`create-qcow2.sh`<!-- private end -->生成指向基础镜像的qcow2镜像。

### 通过iso安装发行版

也可以在Virtual Machine Manager中通过iso文件安装发行版，安装完成后的qcow2镜像要用命令行启动，安装时不使用LVM，而是把磁盘的某个分区挂载到根路径`/`。

在 Virtual Machine Manager 中创建 qcow2 格式，会马上分配所有空间，所以需要在命令行中创建 qcow2:
```sh
qemu-img create -f qcow2 image.qcow2 512G
file image.qcow2 # 查看文件的格式
```

可以再生成一个qcow2文件`image2.qcow2`，指向安装好的镜像`image.qcow2`，`image.qcow2`作为备份文件， 注意<有些版本的qemu-img>要求源文件和目标文件都要指定绝对路径
```sh
qemu-img create -F qcow2 -b /path/image.qcow2 -f qcow2 /path/image2.qcow2 #  -F 源文件格式
```

iso安装发行版本后，默认是`/dev/vda1`（`-device virtio-scsi-pci`）挂载到根路径`/`，如果要重新制作成`/dev/vda`挂载到根分区`/`，可以把qcow2文件里的内容复制出来，qcow2格式镜像的挂载：
```sh
sudo apt-get install qemu-utils -y # 要先安装工具软件
sudo modprobe nbd max_part=8 # 加载nbd模块
sudo qemu-nbd --connect=/dev/nbd0 image.qcow2 # 连接镜像
sudo fdisk /dev/nbd0 -l # 查看分区
sudo mount /dev/nbd0p1 mnt/ # 挂载分区
sudo umount mnt # 操作完后，卸载分区
sudo qemu-nbd --disconnect /dev/nbd0 # 断开连接
sudo modprobe -r nbd # 移除模块
```

当然也可以把qcow2转换成raw格式，然后把raw格式文件里的内容复制出来：
```sh
qemu-img convert -p -f qcow2 -O raw image.qcow2 image.raw
```

### 源码安装qemu

关于各个Linux发行版怎么安装qemu，可以参考[qemu官网](https://www.qemu.org/download/#linux)的介绍，下面主要介绍一下源码的安装方式，源码安装方式可以使用qemu的最新特性。

先安装Ubuntu编译qemu所需的软件：
```sh
# ubuntu 22.04
sudo apt-get install libattr1-dev libcap-ng-dev -y
sudo apt install ninja-build -y
sudo apt-get install libglib2.0-dev -y
sudo apt-get install libpixman-1-dev -y
```

<!-- public begin -->
CentOS发行版安装编译qemu所需的软件：
```sh
sudo dnf install glib2-devel -y
sudo dnf install iasl -y
sudo dnf install pixman-devel -y
sudo dnf install libcap-ng-devel -y
sudo dnf install libattr-devel -y

# centos 9才需要， http://re2c.org/
git clone https://github.com/skvadrik/re2c.git
./autogen.sh
./configure  --prefix=${HOME}/chenxiaosong/sw/re2c
make && make install

# centos 要安装 ninja, https://ninja-build.org/
git clone https://github.com/ninja-build/ninja.git && cd ninja
./configure.py --bootstrap

# centos9, https://sparse.docs.kernel.org/en/latest/
git clone git://git.kernel.org/pub/scm/devel/sparse/sparse.git
make
```
<!-- public end -->

再下载编译qemu：
```sh
git clone https://gitlab.com/qemu-project/qemu.git
git submodule init
git submodule update --recursive
mkdir build
cd build/
../configure --enable-kvm --enable-virtfs --prefix=${HOME}/chenxiaosong/sw/qemu/
```

### qemu配置

非root用户没有权限的解决办法：
```sh
# 源码安装的
sudo chown root libexec/qemu-bridge-helper
sudo chmod u+s libexec/qemu-bridge-helper
# apt安装的
sudo chown root /usr/lib/qemu/qemu-bridge-helper
sudo chmod u+s /usr/lib/qemu/qemu-bridge-helper

groups | grep kvm
sudo usermod -aG kvm $USER
su - $USER # 或退出shell重新登录, 但在tmux中不起作用
```

允许使用`virbr0`网络接口：
```sh
# 源码安装的
mkdir -p etc/qemu
vim etc/qemu/bridge.conf # 添加 allow virbr0
# apt安装的
sudo mkdir -p /etc/qemu/
sudo vim /etc/qemu/bridge.conf # 添加 allow virbr0
```

修改`virbr0`网段：
```sh
virsh net-list # 查看网络情况
virsh net-edit default # 编辑
virsh net-destroy default
virsh net-start default
```

### qemu运行qcow2镜像

制作好的Ubuntu虚拟机镜像<!-- public begin -->（从百度网盘中下载的）<!-- public end -->中的`${HOME}/qemu-kernel/start.sh`脚本中每个选项的可选值可以使用以下命令查看：
```sh
qemu-system-aarch64 -cpu ?
qemu-system-x86_64 -machine ?
```

如果自己编译内核，启动时指定内核，需要指定`-kernel`和`-append`选项。

如果你的镜像是一个完整的镜像（比如通过iso安装），不想指定内核，就想用镜像本身自带的内核，可以把`-kernel`和`-append`选项删除。

qemu启动后，按快捷键`ctrl+a c`（先按`ctrl+a`松开后再按`c`）再输入`quit`强制退出qemu，但不建议强制退出。

在系统启动界面登录进去后（而不是以ssh登录），默认的窗口大小不会自动调整，需要手动调整：
```sh
stty size # 可以先在其他窗口查看大小
echo "stty rows 54 cols 229" > stty.sh
. stty.sh
```

当启用了9p文件系统，就可以把宿主机的modules目录（当然也可以是其他任何目录）共享给虚拟机，具体参考[Documentation/9psetup](https://wiki.qemu.org/Documentation/9psetup)。虚拟机中执行脚本<!-- public begin -->[`mod-cfg.sh`](https://gitee.com/chenxiaosonggitee/blog/blob/master/courses/kernel/mod-cfg.sh)<!-- public end --><!-- private begin -->`mod-cfg.sh`<!-- private end -->（直接运行`mod-cfg.sh`可以查看使用帮助）挂载和链接模块目录。

root免密登录，`/etc/ssh/sshd_config` 修改以下内容:
```
PermitRootLogin yes
PasswordAuthentication yes
PermitEmptyPasswords yes
```

<!-- public begin -->
曾经使用过fedora发行版，这里记录一下fedora的一些笔记。进入fedora虚拟机后：
```sh
# fedora 启动的时候等待： A start job is running for /dev/zram0，解决办法：删除 zram 的配置文件
mv /usr/lib/systemd/zram-generator.conf /usr/lib/systemd/zram-generator.conf.bak
# fedora26 安装 vim 前，先升级
sudo dnf update vim-common vim-minimal -y
```
<!-- public end -->

## 使用GDB调试内核代码

<!-- public begin -->
我刚开始是做用户态开发的，习惯了利用gdb调试来理解那些写得不好的用户态代码，尤其是公司内部一些不开源的比狗屎还难看的用户态代码（当然其中也包括我自己写的狗屎一样的代码）。

转方向做了Linux内核开发后，也尝试用qemu+gdb来调试内核代码。
<!-- public end -->

要特别说明的是，内核的大部分代码是很优美的，并不需要太依赖qemu+gdb这一调试手段，更建议通过阅读代码来理解。但某些写得不好的内核模块如果利用qemu+gdb将能使我们更快的熟悉代码。

这里只介绍`x86_64`下的qemu+gdb调试，其他cpu架构以此类推，只需要做些小改动。

### 编译选项和补丁

首先确保修改以下配置：
```sh
CONFIG_DEBUG_SECTION_MISMATCH=y # 防止内联
CONFIG_DEBUG_INFO=y # 调试信息
CONFIG_DEBUG_KERNEL=y # 调试信息
CONFIG_FRAME_POINTER=y # Makefile 中选择GCC编译选项
CONFIG_GDB_SCRIPTS=y # gdb python
CONFIG_RANDOMIZE_BASE = n # 关闭地址随机化
```

可以使用<!-- public begin -->我常用的[x86_64的内核配置文件](https://gitee.com/chenxiaosonggitee/blog/blob/master/courses/kernel/x86_64/config)。<!-- public end --><!-- private begin -->`kernel/x86_64/config`配置文件。<!-- private end -->

<!-- public begin -->gcc的编译选项`O1`优化等级不需要修改就可以编译通过。`O0`优化等级无法编译（尝试`CONFIG_JUMP_LABEL=n`还是不行），要修改汇编代码，有兴趣的朋友可以和我一直尝试。<!-- public end -->`Og`优化等级经过修改可以编译通过，`x86_64`合入目录<!-- public begin -->[`courses/kernel/x86_64`](https://gitee.com/chenxiaosonggitee/blog/tree/master/courses/kernel/x86_64)<!-- public end --><!-- private begin -->`kernel/x86_64`<!-- private end -->对应版本的补丁。建议使用`Og`优化等级编译，既能满足gdb调试需求，也能尽量少的修改代码。

### QEMU命令选项

qemu启动虚拟机时，要添加以下几个选项：
```sh
-append "nokaslr ..." # 防止地址随机化，编译内核时关闭配置 CONFIG_RANDOMIZE_BASE
-S # 挂起 gdbserver
-gdb tcp::5555 # 端口5555, 使用 -s 选项表示用默认的端口1234
-s # 相当于 -gdb tcp::1234 默认端口1234，不建议用，最好指定端口
```

完整的启动命令查看制作好的Ubuntu虚拟机镜像<!-- public begin -->（从百度网盘中下载的）<!-- public end -->中的`${HOME}/qemu-kernel/start.sh`脚本。

### GDB命令

启动GDB：
```sh
gdb build/vmlinux
```

进入GDB界面后：
```sh
(gdb) target remote:5555 # 对应qemu命令中的-gdb tcp::5555
(gdb) b func_name # 普通断点
(gdb) hb func_name # 硬件断点，有些函数普通断点不会停下, 如: nfs4_atomic_open，降低优化等级后没这个问题
```

gdb命令的用法和用户态程序的调试大同小异。

### GDB辅助调试功能

使用内核提供的[GDB辅助调试功能](https://www.kernel.org/doc/Documentation/dev-tools/gdb-kernel-debugging.rst)可以更方便的调试内核（如打印断点处的进程名和进程id等）。

内核最新版本（2024.04）使用以下命令开启GDB辅助调试功能，注意最新版本编译出的脚本无法调试4.19和5.10的代码：
```sh
echo "set auto-load safe-path /" > ~/.gdbinit # 设置自动加载共享库文件的安全路径
echo "source ${HOME}/.gdb-linux/vmlinux-gdb.py" >> ~/.gdbinit
make O=build scripts_gdb # 在内核仓库目录下执行
rm -rf ${HOME}/.gdb-linux/
mkdir ${HOME}/.gdb-linux/
cp build/scripts/gdb/* ${HOME}/.gdb-linux/ -rf # 在内核仓库目录下执行
cp scripts/gdb/vmlinux-gdb.py ${HOME}/.gdb-linux/ # 在内核仓库目录下执行
sed -i '/sys.path.insert/s/^/# /' ${HOME}/.gdb-linux/vmlinux-gdb.py # 将sys.path.insert所在的行注释掉
sed -i '/sys.path.insert/a\sys.path.insert(0, "'${HOME}'/.gdb-linux")' ${HOME}/.gdb-linux/vmlinux-gdb.py # 插入 sys.path.insert(0, "${HOME}/.gdb-linux")
```

内核5.10使用以下命令开启GDB辅助调试功能，也可以调试内核4.19代码，但无法调试内核最新的代码：
```sh
echo "set auto-load safe-path /" > ~/.gdbinit # 设置自动加载共享库文件的安全路径
echo "source ${HOME}/.gdb-linux-5.10/vmlinux-gdb.py" >> ~/.gdbinit
make O=build scripts_gdb # 在5.10内核仓库目录下执行
rm -rf ${HOME}/.gdb-linux-5.10/
mkdir ${HOME}/.gdb-linux-5.10/
cp build/scripts/gdb/* ${HOME}/.gdb-linux-5.10/ -rf # 在5.10内核仓库目录下执行
cp scripts/gdb/vmlinux-gdb.py ${HOME}/.gdb-linux-5.10/ # 在5.10内核仓库目录下执行
sed -i '/sys.path.insert/s/^/# /' ${HOME}/.gdb-linux-5.10/vmlinux-gdb.py # 将sys.path.insert所在的行注释掉
sed -i '/sys.path.insert/a\sys.path.insert(0, "'${HOME}'/.gdb-linux-5.10")' ${HOME}/.gdb-linux-5.10/vmlinux-gdb.py # 插入 sys.path.insert(0, "${HOME}/.gdb-linux-5.10")
```

重新启动GDB就可以使用GDB辅助调试功能：
```sh
(gdb) apropos lx # 查看有哪些命令
(gdb) p $lx_current().pid # 打印断点所在进程的进程id
(gdb) p $lx_current().comm # 打印断点所在进程的进程名
```

### GDB打印结构体偏移

结构体定义有时候加了很多宏判断，再考虑到内存对齐之类的因素，通过看代码很难确定结构体中某一个成员的偏移大小，使用gdb来打印就很直观。

如结构体`struct cifsFileInfo`:
```c
struct cifsFileInfo {
    struct list_head tlist;
    ...
    struct tcon_link *tlink;
    ...
    char *symlink_target;
};
```

想要确定`tlink`的偏移，可以使用以下命令：
```sh
gdb ./cifs.ko # ko文件或vmlinux
(gdb) p &((struct cifsFileInfo *)0)->tlink
```

`(struct cifsFileInfo *)0`：这是将整数值 0 强制类型转换为指向 struct cifsFileInfo 类型的指针。这实际上是创建一个指向虚拟内存地址 0 的指针，该地址通常是无效的。这是一个计算偏移量的技巧，因为偏移量的计算不依赖于结构体的实际实例。

`(0)->tlink`: 指向虚拟内存地址 0 的指针的成员`tlink`。

`&(0)->tlink`: tlink的地址，也就是偏移量。

### ko模块代码调试

使用`gdb vmlinux`启动gdb后，如果调用到ko模块里的代码，这时候就不能直接对ko模块的代码进行打断点之类的操作，因为找不到对应的符号。

这时就要把符号加入进来。首先，查看被调试的qemu虚拟机中的各个段地址：
```sh
cd /sys/module/ext4/sections/ # ext4 为模块名
cat .text .data .bss # 输出各个段地址
```

在gdb窗口中加载ko文件：
```sh
add-symbol-file <ko文件位置> <text段地址> -s .data <data段地址> -s .bss <bss段地址>
```

这时就能开心的对ko模块中的代码进行打断点之类的操作了。

<!-- public begin -->
# Linux内核书籍推荐

上面讲完了开发环境的准备，在讲具体内核模块知识点之前，我想先列一下曾经读过的几本书，其中有的书我看过很多遍，当然也有一些只看过一部分。总体来说，这些书是网上推荐比较多的。如果发现有其他好书，我还会继续补充，各位朋友如果有推荐的书也可以告诉我。

各位朋友可以[点击这里从百度网盘下载pdf电子书](https://chenxiaosong.com/baidunetdisk)。电子书请仅作为学习用途，有需要的话建议购买纸质书。

下面各小节列一下这些书的章节目录，方便自己和各位朋友的搜索。更详细的目录可以查看[《书籍目录》](https://chenxiaosong.com/courses/book-contents.html)。

点击小节标题可以看豆瓣上对这几本书的评价。

## 四库全书之一[《Linux内核设计与实现》](https://book.douban.com/subject/6097773/)-基于2.6.34内核

这本书我看过很多很多遍，是我的内核启蒙书，没那么厚，对内核知识概括得很好，看完可以对内核知识有一个总体的掌握，但讲得不那么细，也正是因为这样，第一遍我看的时候有点晕，但第二第三遍再看时很爽。

```
第1章 Linux内核简介
第2章 从内核出发
第3章 进程管理
第4章 进程调度
第5章 系统调用
第6章 内核数据结构
第7章 中断和中断处理
第8章 下半部和推后执行的工作
第9章 内核同步介绍
第10章 内核同步方法
第11章 定时器和时间管理
第12章 内存管理
第13章 虚拟文件系统
第14章 块I/O层
第15章 进程地址空间
第16章 页高速缓存和页回写
第17章 设备与模块
第18章 调试
第19章 可移植性
第20章 补丁、开发和社区参考资料
```

## 四库全书之二[《深入理解Linux内核》](https://book.douban.com/subject/2287506/)-基于2.6.11内核

这本书我看过一部分，内容很多很详细，建议作为工具书查阅，当然如果想全部看完也很棒，做这个课程我一定会把这本书看完的。

```
第一章 绪论
第二章 内存寻址
第三章 进程
第四章 中断和异常
第五章 内核同步
第六章 定时测量 
第七章 进程调度 
第八章 内存管理
第九章 进程地址空间
第十章 系统调用
第十一章 信号
第十二章 虚拟文件系统
第十三章 I/O体系结构和设备驱动程序
第十四章 块设备驱动程序
第十五章 页高速缓存
第十六章 访问文件 
第十七章 回收页框
第十八章 Ext2和Ext3文件系统
第十九章 进程通信
第二十章 程序的执行
附录一 系统启动
附录二 模块
参考文献
源代码索引
```

## 四库全书之三[《Linux设备驱动程序》](https://book.douban.com/subject/1723151/)-基于2.6.10内核

这本书只全部看过一次，讲驱动的，一般也只是用于查阅，做这个课程我也一定把这本书看完。

```
前言
第一章 设备驱动程序简介
第二章 构造和运行模块
第三章 字符设备驱动程序
第四章 调试技术
第五章 并发和竞态
第六章 高级字符驱动程序操作
第七章 时间、延迟及延缓操作
第八章 分配内存
第九章 与硬件通信
第十章 中断处理
第十一章 内核的数据类型
第十二章 PCI驱动程序
第十三章 USB驱动程序
第十四章 Linux设备模型
第十五章 内存映射和DMA
第十六章 块设备驱动程序
第十七章 网络驱动程序
第十八章 TTY驱动程序
参考书目
```

## 四库全书之四[《Linux内核源代码情景分析（上下）》](https://search.douban.com/book/subject_search?search_text=Linux%E5%86%85%E6%A0%B8%E6%BA%90%E4%BB%A3%E7%A0%81%E6%83%85%E6%99%AF%E5%88%86%E6%9E%90&cat=1001)-基于2.4.0内核

这本书用的内核比较老，我只看过部分，希望做完这个课程可以把这两本看完。

```
1. 预备知识
2. 存储管理
3. 中断、异常和系统调用
4. 进程与进程调度
5. 文件系统
6. 传统的unix进程间通信
7. 基于socket的进程间通信
8. 设备驱动
9. 多处理器SMP系统结构
10. 系统引导与初始化
```

## [《深入Linux内核架构》](https://book.douban.com/subject/4843567/)-基于2.6.24内核

我也只看过部分，讲得挺详细，值得看。

```
第1章 简介和概述
第2章 进程管理和调度
第3章 内存管理
第4章 进程虚拟内存
第5章 锁与进程间通信
第6章 设备驱动程序
第7章 模块
第8章 虚拟文件系统
第9章 Ext文件系统族
第10章 无持久存储的文件系统
第11章 扩展属性和访问控制表
第12章 网络
第13章 系统调用
第14章 内核活动
第15章 时间管理
第16章 页缓存和块缓存
第17章 数据同步
第18章 页面回收和页交换
第19章 审计
附录A 体系结构相关知识
附录B 使用源代码
附录C 有关C语言的注记
附录D 系统启动
附录E ELF二进制格式
附录F 内核开发过程参考文献
```

## [《LINUX内核完全剖析：基于0.12内核》](https://book.douban.com/subject/3229243/)

看早期的内核代码真的很棒，只看过一部分，想继续看完。

```
序
第1章 概述
第2章 微型计算机组成结构
第3章 内核编程语言和环境
第4章 80X86保护模式及其编程
第5章 Linux内核体系结构
第6章 引导启动程序
第7章 初始化程序
第8章 内核代码
第9章 块设备驱动程序
第10章 字符设备驱动程序
第11章 数学协处理器
第12章 文件系统
第13章 内存管理
第14章 头文件
第15章 库文件
第16章 建造工具
第17章 实验环境设置与使用方法
附录
参考文献
```

## [《Linux设备驱动开发详解：基于最新的Linux 4.0内核》](https://book.douban.com/subject/26600201/)

这本书我全部看完了，算是驱动开发的入门书吧，对初学者很友好。

```
第１章 Linux设备驱动概述及开发环境构建 1
第２章 驱动设计的硬件基础 20
第３章 Linux内核及内核编程 52
第４章 Linux内核模块 92
第５章 Linux文件系统与设备文件 104
第６章 字符设备驱动 134
第７章 Linux设备驱动中的并发控制 158
第８章 Linux设备驱动中的阻塞与非阻塞I/O 189
第９章 Linux设备驱动中的异步通知与异步I/O 206
第10章 中断与时钟 224
第11章 内存与I/O访问 251
第12章 Linux设备驱动的软件架构思想 286
第13章 Linux块设备驱动 331
第14章 Linux网络设备驱动 358
第15章 Linux I2C核心、总线与设备驱动 387
第16章 USB主机、设备与Gadget驱动 414
第17章 I2C、SPI、USB驱动架构类比 459
第18章 ARM Linux设备树 461
第19章 Linux电源管理的系统架构和驱动 494
第20章 Linux芯片级移植及底层驱动 535
第21章 Linux设备驱动的调试 581
```

## [《庖丁解牛Linux内核分析》](https://book.douban.com/subject/30350365/)-基于3.18.6内核

这本书我全看完了，讲得比较底层。

```
第1章 计算机工作原理 1
第2章 操作系统是如何工作的 29
第3章 MenuOS的构造 50
第4章 系统调用的三层机制（上） 67
第5章 系统调用的三层机制（下） 81
第6章 进程的描述和进程的创建 93
第7章 可执行程序工作原理 122
第8章 进程的切换和系统的一般执行过程 158
```
<!-- public end -->

# Linux内核源码

## 内核社区

<!-- public begin -->
说到Linux内核，很多人可能会认为只有Linus这样的神才懂。但事实是任何人都能参与，比如我这样能力差的也参与到Linux内核社区了。可能很多人早就想贡献Linux内核了，但就是不知道怎么开始。
<!-- public end -->

Linux内核有一个官方网站[The Linux Kernel Archives](https://kernel.org/)，在这个网站上可以获取Linux内核源码以及[其他相关源码](https://git.kernel.org/)。

Linux内核社区主要以邮件交流为主，以下是一些常用的网站：

- [邮件列表](https://lore.kernel.org/): 在这里获取社区的最新动态。
- [按模块划分的patchwork](https://patchwork.kernel.org/): 补丁的邮件都会在这里归档。
- [bugzilla](https://bugzilla.kernel.org/): 上面有很多未解决的bug，想在社区提补丁可以在这上面找问题。
- [syzbot](https://syzkaller.appspot.com/upstream): [谷歌的syzkaller](https://github.com/google/syzkaller)模糊测试跑出来的bug，想在社区提补丁也可以在这上面找问题。
- [kernelnewbies](https://kernelnewbies.org/): 适合内核初学者看的黑客。
- [LWN.net](https://lwn.net/): Linux新闻周刊。

## 内核源码树

我们以社区最近的一个LTS（longterm support，长期维护版本）v6.6的代码来讲接下来的课程。

内核源码树根目录每个文件夹的描述如下（按字母顺序）：

- `arch`: architecture的缩写，体系结构相关。我们着重介绍`arch/x86/`和`arch/arm64/`，在每个体系结构目录下，`boot/`是启动相关，`configs/`是配置相关，`include/`头文件相关，`mm/`内存管理相关，等等。
- `block`: 块设备IO层相关。
- `certs`: 认证相关。
- `crypto`: 加密API，加密、散列、压缩、校验等算法。
- `Documentation`: 文档，要多看，很有用。也可以看在线文档： https://www.kernel.org/doc/html/latest/
- `drivers`: 设备驱动程序相关。
- `fs`: 文件系统相关。我们主要介绍`fs/`目录下VFS（虚拟文件系统）相关的，还会介绍几个具体的文件系统，如`fs/ext2/`、`fs/xfs/`、`fs/proc/`、`fs/sysfs/`等，当然具体的文件系统不会介绍得很详细，只说一个大概，主要还是以VFS的讲解为主。
- `include`: 内核头文件相关。
- `init`: 内核引导和初始化相关。
- `io_uring`: 5.1版本引入的高性能异步IO框架，主要是为了加快IO密集型应用的性能。
- `ipc`: 进程间通信相关。
- `kernel`: 进程相关，包括进程管理和进程调度。
- `lib`: 可以看成是一个标准C库的子集，如`strlen`、`mmcpy`、`sprintf`等函数。
- `LICENSES`: 许可证。
- `mm`: 与体系结构无关的内存管理代码，注意与体系结构相关的代码在`arch/mm/`目录下。
- `net`: 网络子系统，如TCP/IP等网络协议的实现。
- `rust`: 内核除了C语言外采用的一门新开发语言，和C性能差不多，目前暂时主要用于驱动开发。
- `samples`: 示例代码，很好的学习资源，不要放过。
- `scripts`: 脚本文件，如`make menuconfig`、`make scripts_gdb`等都是调用这个目录下的脚本。
- `security`: 安全模块，比如复杂的`selinux`。
- `sound`: 语音子系统相关。
- `tools`: 开发工具相关。
- `usr`: 早期的用户空间代码（`initramfs`），比如有打包和压缩用的`cpio`等。注意，`usr`的全称是`Unix System Resources`，不是`user`，不是`user`，不是`user`。为什么要强调不是`user`呢，因为有太多太多的人读成了`user`，咱们专业点，读成`u, s, r`，一个单词一个单词的读。
- `virt`: 虚拟化相关，如`kvm`。

上面是文件夹，接下来介绍根目录下的文件：

- `COPYING`: 许可证。
- `CREDITS`: 贡献者。
- `Kbuild`: 内核顶层目录的`Kbuild`, 在进入子目录之前准备全局头文件并检查完整性。
- `Kconfig`: 内核配置。
- `MAINTAINERS`: 维护者名单。
- `Makefile`: 设置编译参数。
- `README`: 描述文档在哪里。

## 贡献Linux内核社区

### 准备补丁

你可以通过[bugzilla](https://bugzilla.kernel.org/)或[syzbot](https://syzkaller.appspot.com/upstream)发现内核bug，也可以通过阅读内核代码发现bug或进行重构。

可以参考内核仓库中的补丁<!-- public begin -->，比如[我提交的补丁](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/log/?qt=grep&q=chenxiaosong)<!-- public end -->。修改代码时要参考[Linux内核代码风格](https://www.kernel.org/doc/html/latest/translations/zh_CN/process/coding-style.html#cn-codingstyle)。

注意commit message每行长度不超过 72 个字符。

`git commit`命令之后，使用以下命令会生成补丁文件：
```shell
# -1 表示最后一次commit，
git format-patch -1

# 指定commit号
git format-patch --subject-prefix="PATCH next" -1 <commit号>

# 如果是第2个版本或第3个版本，需要指定v2或v3
git format-patch --subject-prefix="PATCH v2" -1

# 如果内容不变，重新发送（比如加一个抄送的人）
git format-patch --subject-prefix="PATCH resend,v2" -1

# 从指定的commit号数向前3个，共生成3个补丁
git format-patch --subject-prefix="PATCH resend,v2" -3 <commit号>

# 生成补丁集
git format-patch --subject-prefix="PATCH resend,v2" -3 commit号 --cover-letter
# 编辑0000-cover-letter.patch, 可参考patchwork上其他补丁的写法
vim 0000-cover-letter.patch
```

### 邮箱配置

- 163邮箱配置: 默认情况下，163邮箱只能在网页和网易邮箱大师登录。如果要用git通过163邮箱发送邮件则需要对163邮箱进行配置。在[pc端网页](mail.163.com)登录163邮箱，点击“设置 --> POP3/SMTP/IMAP”，开启SMTP服务，会弹出授权密码窗口，记下这个授权密码（也可以在下方新增授权密码或删除）。
- foxmail邮箱（qq邮箱）配置: 在[pc端网页](https://mail.qq.com/)登录foxmail邮箱，点击"Settings -> Third-party Services -> IMAP/SMTP", 点击"Generate Authorization Code"生成在`.gitconfig`和[thunderbird](https://www.thunderbird.net)中登录的密码。
- 腾讯企业邮箱配置: 登录[腾讯企业邮箱](https://exmail.qq.com/login)个人账号（不是管理员），左上角“设置”，然后“邮箱绑定 -> 客户端专用密码 -> 生成新密码“，注意要记住这个密码，只会显示一次，忘记了就要重新生成密码。thunderbird中登录时的配置：
  - 收件服务器：协议IMAP，主机名：imap.exmail.qq.com，端口：993（或不填），连接安全性：自动检测。
  - 发件服务器：主机名：smtp.exmail.qq.com，端口：465（或不填），连接安全性：自动检测。

### thunderbird邮件客户端

最新版本的[thunderbird](https://www.thunderbird.net/)默认使用html格式发送和显示，需要更改配置，参考[Plain text e-mail - Thunderbird](http://kb.mozillazine.org/Plain_text_e-mail_-_Thunderbird#Send_plain_text_messages)。

依次点击 `Account Settings -> Composition & Addressing -> Composition -> 取消勾选Compose messages in HTML format`。

还有，不建议订阅内核任何模块的邮件列表，因为太多了，一旦订阅邮箱基本就爆了，可以在[邮件列表网站](https://lore.kernel.org/)上选择对应的模块在线浏览，如果需要回复，可以把邮件下载下来保存成文件，然后用thunderbird打开文件，然后就可以回复了。如果实在要订阅，可以访问[vger.kernel.org](https://subspace.kernel.org/vger.kernel.org.html)和[linux-kernel mailing list FAQ](http://vger.kernel.org/lkml/)。

### git发送邮件

安装软件：
```sh
sudo apt install git-email -y
```

163邮箱`~/.gitconfig`：
```sh
[sendemail]
	from = your_name@163.com
	smtpserver = smtp.163.com
	smtpuser = your_name@163.com
	smtpencryption = ssl 
	smtppass = 此处填写163邮箱的授权密码
	smtpserverport = 994 
```

foxmail(qq)邮箱`~/.gitconfig`：
```sh
[sendemail]
        from = your_name@foxmail.com
        smtpserver = smtp.qq.com
        smtpuser = your_name@foxmail.com
        smtpencryption = ssl 
        smtppass = 此处填写qq邮箱的授权密码
```

腾讯企业邮箱`~/.gitconfig`：
```sh
[sendemail]
        from = your_name@your_name.com
        smtpserver = smtp.exmail.qq.com
        smtpuser = your_name@your_name.com
        smtpencryption = ssl 
        smtppass = 此处填写腾讯企业邮箱的授权密码
        smtpserverport = 465
```

获取maintainer邮箱：
```shell
./scripts/get_maintainer.pl file1.patch
```
发送邮件：
```shell
# --to是主送，--cc是抄送
git send-email --to=to1@example.com,to2@example.com --cc=cc1@example.com,cc2@example.com file1.patch file2.patch
```

# 文件系统

一般的Linux书籍都是先讲解进程和内存相关的知识，但我想先讲解文件系统。<!-- public begin -->第一，因为我就是做文件系统的，更擅长这一块，其他模块的内容我还要再去好好看看书，毕竟不能误人子弟嘛；第二，是<!-- public end -->因为文件系统模块更接近于用户态，是相对比较好理解的内容（当然想深入还是要下大功夫的），由文件系统入手比较适合初学者。

## 什么是文件系统

我们先来看一下什么是文件系统？我们买电脑时，肯定会配一块硬盘（现在一般是固态硬盘），硬盘是用来存储数据资料的。比如要存储一句话:"我爱操作系统"，一个汉字占用2个字节，存储这一句话要占用12个字节（不包括结束符），我们可以用2种方法来存储。第一种方法是从硬盘第一个字节开始存储，前两个字节存储"我"，第三四个字节存储"爱"，以此类推。第二种方法是先创建一个文件，在这个文件里存储这句话，我们打开硬盘时，只需要找到这个文件的位置，就能找到这句话。第一种方法数据管理起来很不方便，所以一般都用第二种方法，第二种方法管理数据的规则就称为文件系统。

我们来实际操作一下，虚拟机中的`${HOME}/qemu-kernel/start.sh`文件中增加以下内容（如果已有就不用增加）：
```sh
-drive file=1,if=none,format=raw,cache=writeback,file.locking=off,id=dd_1 \
-device scsi-hd,drive=dd_1,id=disk_1,logical_block_size=512,physical_block_size=512 \
```

然后在`${HOME}/qemu-kernel/`目录下创建一个1G的空文件：
```sh
fallocate -l 1G 1
```

进入虚拟机后，可以使用上面提到的第一种方法，直接从磁盘的第一个字节开始存：
```sh
echo "我爱操作系统" > /dev/sda
cat /dev/sda # 从磁盘的第一个字节开始输出
```

也可以用上面提到的第二种方法，也就是我们要学的文件系统：
```sh
mkfs.ext4 -F /dev/sda # 格式化文件系统
mount -t ext4 /dev/sda /mnt # 把磁盘挂载到某个目录
df /dev/sda # 查看是否已经挂载上
echo "我爱操作系统" > /mnt/file # 存到挂载点下的某个文件中
cat /mnt/file # 输出文件内容
umount /mnt # 卸载文件系统
```

## 虚拟文件系统

虚拟文件系统英文全称Virtual file system，缩写为VFS，又称为虚拟文件切换系统（virtual filesystem switch）。所有的文件系统都要先经过虚拟文件系统层，虚拟文件系统相当于制定了一套规则，如果你想写一个新的文件系统，只需要遵守这套规则就可以了。

VFS虽然是用C语言写的，但使用了面向对象的设计思路。

### 超级块对象

超级块英文全称是super block，存储特定文件系统的信息。如果是基于磁盘的文件系统，通常对应磁盘上特定扇区中的数据。如果不是基于磁盘的文件系统（如procfs或sysfs），会在使用时创建超级块，只保留在内存中。

超级块对象结构体定义在文件`include/linux/fs.h`中，比较长，不用背，用到时查一下就好，我会在这里加一些中文注释。
```c
struct super_block {
	struct list_head	s_list;		/* 放在最开头，指向 super_blocks，使用list_add_tail加到super_blocks链表中 */
	dev_t			s_dev;		/* 设备标识符 */
	unsigned char		s_blocksize_bits; // 块大小，单位：bit
	unsigned long		s_blocksize; // 块大小，单位：字节
	loff_t			s_maxbytes;	/* 文件大小上限 */
	struct file_system_type	*s_type; // 文件系统类型
	const struct super_operations	*s_op; // 超级块方法
	const struct dquot_operations	*dq_op; // 磁盘限额方法
	const struct quotactl_ops	*s_qcop; // 限额控制方法
	const struct export_operations *s_export_op; // 导出方法
	unsigned long		s_flags; // 挂载标志
	unsigned long		s_iflags;	/* internal SB_I_* flags */
	unsigned long		s_magic; // 文件系统幻数
	struct dentry		*s_root; // 目录挂载点
	struct rw_semaphore	s_umount; // 卸载信号量
	int			s_count; // 超级块引用计数
	atomic_t		s_active; // 活动引用计数
#ifdef CONFIG_SECURITY
	void                    *s_security; // 安全模块
#endif
	const struct xattr_handler **s_xattr; // 扩展的属性操作
#ifdef CONFIG_FS_ENCRYPTION
	const struct fscrypt_operations	*s_cop;
	struct fscrypt_keyring	*s_master_keys; /* master crypto keys in use */
#endif
#ifdef CONFIG_FS_VERITY
	const struct fsverity_operations *s_vop;
#endif
#if IS_ENABLED(CONFIG_UNICODE)
	struct unicode_map *s_encoding;
	__u16 s_encoding_flags;
#endif
	struct hlist_bl_head	s_roots;	/* alternate root dentries for NFS */
	struct list_head	s_mounts;	/* list of mounts; _not_ for fs use，struct mount的mnt_instance加到这个链表中 */
	struct block_device	*s_bdev; // 相关的块设备
	struct backing_dev_info *s_bdi;
	struct mtd_info		*s_mtd; // 存储磁盘信息
	struct hlist_node	s_instances; // 这种类型的所有文件系统
	unsigned int		s_quota_types;	/* Bitmask of supported quota types */
	struct quota_info	s_dquot;	/* 限额相关选项 */

	struct sb_writers	s_writers;

	/*
	 * Keep s_fs_info, s_time_gran, s_fsnotify_mask, and
	 * s_fsnotify_marks together for cache efficiency. They are frequently
	 * accessed and rarely modified.
	 */
	void			*s_fs_info;	/* Filesystem private info，文件系统特殊信息 */

	/* Granularity of c/m/atime in ns (cannot be worse than a second) */
	u32			s_time_gran; // 时间戳粒度
	/* Time limits for c/m/atime in seconds */
	time64_t		   s_time_min;
	time64_t		   s_time_max;
#ifdef CONFIG_FSNOTIFY
	__u32			s_fsnotify_mask;
	struct fsnotify_mark_connector __rcu	*s_fsnotify_marks;
#endif

	char			s_id[32];	/* Informational name，文本名字 */
	uuid_t			s_uuid;		/* UUID */

	unsigned int		s_max_links;

	/*
	 * The next field is for VFS *only*. No filesystems have any business
	 * even looking at it. You had been warned.
	 */
	struct mutex s_vfs_rename_mutex;	/* Kludge，重命名锁 */

	/*
	 * Filesystem subtype.  If non-empty the filesystem type field
	 * in /proc/mounts will be "type.subtype"
	 */
	const char *s_subtype; // 子类型名称

	const struct dentry_operations *s_d_op; /* default d_op for dentries */

	struct shrinker s_shrink;	/* per-sb shrinker handle */

	/* Number of inodes with nlink == 0 but still referenced */
	atomic_long_t s_remove_count;

	/*
	 * Number of inode/mount/sb objects that are being watched, note that
	 * inodes objects are currently double-accounted.
	 */
	atomic_long_t s_fsnotify_connectors;

	/* Read-only state of the superblock is being changed */
	int s_readonly_remount;

	/* per-sb errseq_t for reporting writeback errors via syncfs */
	errseq_t s_wb_err;

	/* AIO completions deferred from interrupt context */
	struct workqueue_struct *s_dio_done_wq;
	struct hlist_head s_pins;

	/*
	 * Owning user namespace and default context in which to
	 * interpret filesystem uids, gids, quotas, device nodes,
	 * xattrs and security labels.
	 */
	struct user_namespace *s_user_ns;

	/*
	 * The list_lru structure is essentially just a pointer to a table
	 * of per-node lru lists, each of which has its own spinlock.
	 * There is no need to put them into separate cachelines.
	 */
	struct list_lru		s_dentry_lru; // 未被使用目录项链表
	struct list_lru		s_inode_lru;
	struct rcu_head		rcu;
	struct work_struct	destroy_work;

	struct mutex		s_sync_lock;	/* sync serialisation lock */

	/*
	 * Indicates how deep in a filesystem stack this SB is
	 */
	int s_stack_depth;

	/* s_inode_list_lock protects s_inodes */
	spinlock_t		s_inode_list_lock ____cacheline_aligned_in_smp;
	struct list_head	s_inodes;	/* 索引节点链表 */

	spinlock_t		s_inode_wblist_lock;
	struct list_head	s_inodes_wb;	/* writeback inodes */
} __randomize_layout;
```

超级块对象通过`alloc_super()`函数创建和初始化，具体的文件系统如ext2文件系统的流程如下：
```c
mount // 系统调用
  do_mount
    path_mount
      do_new_mount
        vfs_get_tree
          legacy_get_tree
            ext2_mount // ext2_fs_type的.mount方法
              mount_bdev
                sget
                  alloc_super
```

### 超级块操作

超级块对象中最重要的一个成员是`s_op`，也是面向对象思想的一个体现，超级块操作函数表结构体也是定义在文件`include/linux/fs.h`中。也不需要背，用到时查一下就可以。

```c
struct super_operations {
 	struct inode *(*alloc_inode)(struct super_block *sb); // 创建和初始化一个新的索引节点对象
	void (*destroy_inode)(struct inode *); // 销毁索引节点
	void (*free_inode)(struct inode *); // 释放索引节点

  void (*dirty_inode) (struct inode *, int flags); // 索引节点脏（也就是数据被修改了）时调用，日志更新（如ext4的jbd2）
	int (*write_inode) (struct inode *, struct writeback_control *wbc); // 将索引节点写入磁盘
	int (*drop_inode) (struct inode *); // 最后一个索引节点的引用释放后调用，普通unix文件系统不会定义这个函数
	void (*evict_inode) (struct inode *); // 从磁盘删除索引节点
	void (*put_super) (struct super_block *); // 释放超级块，要持有超级块锁
	int (*sync_fs)(struct super_block *sb, int wait); // 文件系统的元数据与磁盘同步
	int (*freeze_super) (struct super_block *, enum freeze_holder who);
	int (*freeze_fs) (struct super_block *);
	int (*thaw_super) (struct super_block *, enum freeze_holder who);
	int (*unfreeze_fs) (struct super_block *);
	int (*statfs) (struct dentry *, struct kstatfs *); // 获取文件系统状态
	int (*remount_fs) (struct super_block *, int *, char *); // 指定新的选项重新安装文件系统
	void (*umount_begin) (struct super_block *); // 中断安装操作，目前只有网络相关的文件系统以及fuse实现了

	int (*show_options)(struct seq_file *, struct dentry *);
	int (*show_devname)(struct seq_file *, struct dentry *);
	int (*show_path)(struct seq_file *, struct dentry *);
	int (*show_stats)(struct seq_file *, struct dentry *);
#ifdef CONFIG_QUOTA
	ssize_t (*quota_read)(struct super_block *, int, char *, size_t, loff_t);
	ssize_t (*quota_write)(struct super_block *, int, const char *, size_t, loff_t);
	struct dquot **(*get_dquots)(struct inode *);
#endif
	long (*nr_cached_objects)(struct super_block *,
				  struct shrink_control *);
	long (*free_cached_objects)(struct super_block *,
				    struct shrink_control *);
	void (*shutdown)(struct super_block *sb);
};
```

注意在C语言的实现中，如果要获取`struct super_block *`父对象，必须要传入指针。

### 索引节点对象

索引节点包含了操作文件和目录时的全部信息，也定义在`include/linux/fs.h`。也不需要背，用到时查一下就可以。

```c
/*
 * 将“struct inode”中的大多数已读字段和经常访问的字段（特别是用于RCU路径查找和“stat”数据的字段）放在前面。
 */
struct inode {
	umode_t			i_mode; // 访问权限
	unsigned short		i_opflags;
	kuid_t			i_uid; // 使用者的id
	kgid_t			i_gid; // 使用组的id
	unsigned int		i_flags; // 文件系统标志

#ifdef CONFIG_FS_POSIX_ACL
	struct posix_acl	*i_acl;
	struct posix_acl	*i_default_acl;
#endif

	const struct inode_operations	*i_op; // 索引节点操作表
	struct super_block	*i_sb; // 相关的超级块
	struct address_space	*i_mapping; // 相关的地址映射

#ifdef CONFIG_SECURITY
	void			*i_security; // 安全模块
#endif

	/* Stat data, not accessed from path walking */
	unsigned long		i_ino; // 索引节点号
	/*
	 * Filesystems may only read i_nlink directly.  They shall use the
	 * following functions for modification:
	 *
	 *    (set|clear|inc|drop)_nlink
	 *    inode_(inc|dec)_link_count
	 */
	union {
		const unsigned int i_nlink; // 硬链接数
		unsigned int __i_nlink;
	};
	dev_t			i_rdev; // 实际设备标识符
	loff_t			i_size; // 大小，单位：字节
	struct timespec64	i_atime; // 最后访问时间
	struct timespec64	i_mtime; // 最后修改时间
	struct timespec64	__i_ctime; /* use inode_*_ctime accessors! 最后改变时间 */
	spinlock_t		i_lock;	/* i_blocks, i_bytes, maybe i_size，自旋锁 */
	unsigned short          i_bytes; // 使用的字节数
	u8			i_blkbits; // 以位为单位的块大小
	u8			i_write_hint;
	blkcnt_t		i_blocks; // 文件的块数

#ifdef __NEED_I_SIZE_ORDERED
	seqcount_t		i_size_seqcount; // 对 i_size 进行串行计数
#endif

	/* Misc */
	unsigned long		i_state; // 状态标志
	struct rw_semaphore	i_rwsem;

	unsigned long		dirtied_when;	/* jiffies of first dirtying，第一次弄脏数据的时间 */
	unsigned long		dirtied_time_when;

	struct hlist_node	i_hash; // 散列表
	struct list_head	i_io_list;	/* backing dev IO list */
#ifdef CONFIG_CGROUP_WRITEBACK
	struct bdi_writeback	*i_wb;		/* the associated cgroup wb */

	/* foreign inode detection, see wbc_detach_inode() */
	int			i_wb_frn_winner;
	u16			i_wb_frn_avg_time;
	u16			i_wb_frn_history;
#endif
	struct list_head	i_lru;		/* inode LRU list，Least Recently Used 最近最少使用链表 */
	struct list_head	i_sb_list; // 超级块链表
	struct list_head	i_wb_list;	/* backing dev writeback list */
	union {
		struct hlist_head	i_dentry; // 目录项链表
		struct rcu_head		i_rcu;
	};
	atomic64_t		i_version; // 版本号
	atomic64_t		i_sequence; /* see futex */
	atomic_t		i_count; // 引用计数
	atomic_t		i_dio_count;
	atomic_t		i_writecount; // 写者计数
#if defined(CONFIG_IMA) || defined(CONFIG_FILE_LOCKING)
	atomic_t		i_readcount; /* struct files open RO */
#endif
	union {
		const struct file_operations	*i_fop;	/* former ->i_op->default_file_ops，默认的索引节点操作 */
		void (*free_inode)(struct inode *);
	};
	struct file_lock_context	*i_flctx;
	struct address_space	i_data; // 设备地址映射
	struct list_head	i_devices; // 块设备链表
	union {
		struct pipe_inode_info	*i_pipe; // 管道信息
		struct cdev		*i_cdev; // 字符设备驱动
		char			*i_link;
		unsigned		i_dir_seq;
	};

	__u32			i_generation;

#ifdef CONFIG_FSNOTIFY
	__u32			i_fsnotify_mask; /* all events this inode cares about */
	struct fsnotify_mark_connector __rcu	*i_fsnotify_marks;
#endif

#ifdef CONFIG_FS_ENCRYPTION
	struct fscrypt_info	*i_crypt_info;
#endif

#ifdef CONFIG_FS_VERITY
	struct fsverity_info	*i_verity_info;
#endif

	void			*i_private; /* fs or device private pointer，私有指针 */
} __randomize_layout;
```

### 索引节点操作

索引节点对象中最重要的一个成员是`i_op`，也是面向对象思想的一个体现，索引节点操作函数表结构体也是定义在文件`include/linux/fs.h`中。还是不需要背，用到什么查什么就好。

```c
struct inode_operations {
	struct dentry * (*lookup) (struct inode *,struct dentry *, unsigned int); // 寻找索引节点，对应dentry中的文件名
	const char * (*get_link) (struct dentry *, struct inode *, struct delayed_call *);
	int (*permission) (struct mnt_idmap *, struct inode *, int); // 检查访问模式
	struct posix_acl * (*get_inode_acl)(struct inode *, int, bool);

	int (*readlink) (struct dentry *, char __user *,int); // 复制符号链接中的数据

	int (*create) (struct mnt_idmap *, struct inode *,struct dentry *, // 为dentry创建一个新的索引节点
		       umode_t, bool);
	int (*link) (struct dentry *,struct inode *,struct dentry *); // 创建硬链接
	int (*unlink) (struct inode *,struct dentry *); // 删除索引节点对象
	int (*symlink) (struct mnt_idmap *, struct inode *,struct dentry *, // 创建符号链接
			const char *);
	int (*mkdir) (struct mnt_idmap *, struct inode *,struct dentry *, // 创建新目录
		      umode_t);
	int (*rmdir) (struct inode *,struct dentry *); // 删除目录
	int (*mknod) (struct mnt_idmap *, struct inode *,struct dentry *, // 创建特殊文件（设备文件、命名管道、套接字）
		      umode_t,dev_t);
	int (*rename) (struct mnt_idmap *, struct inode *, struct dentry *, // 移动文件
			struct inode *, struct dentry *, unsigned int);
	int (*setattr) (struct mnt_idmap *, struct dentry *, struct iattr *); // 被notify_change()调用，修改索引节点后，通知
	int (*getattr) (struct mnt_idmap *, const struct path *, // 从磁盘更新时调用
			struct kstat *, u32, unsigned int);
	ssize_t (*listxattr) (struct dentry *, char *, size_t); // 将所有属性列表复制到缓冲列表中
	int (*fiemap)(struct inode *, struct fiemap_extent_info *, u64 start,
		      u64 len);
	int (*update_time)(struct inode *, int);
	int (*atomic_open)(struct inode *, struct dentry *,
			   struct file *, unsigned open_flag,
			   umode_t create_mode);
	int (*tmpfile) (struct mnt_idmap *, struct inode *,
			struct file *, umode_t);
	struct posix_acl *(*get_acl)(struct mnt_idmap *, struct dentry *,
				     int);
	int (*set_acl)(struct mnt_idmap *, struct dentry *,
		       struct posix_acl *, int);
	int (*fileattr_set)(struct mnt_idmap *idmap,
			    struct dentry *dentry, struct fileattr *fa);
	int (*fileattr_get)(struct dentry *dentry, struct fileattr *fa);
	struct offset_ctx *(*get_offset_ctx)(struct inode *inode);
} ____cacheline_aligned;
```

### 目录项对象

需要注意目录项表示路径中的一个部分，如`/home/linux/file`路径中，`/`、`home`、`linux`是目录，属于目录项对象，`file`属于文件，也属于目录项对象。也就是说，目录项也能表示文件。目录项对象结构体定义在`include/linux/dcache.h`中，成员不多。

```c
struct dentry {
	/* RCU lookup touched fields */
	unsigned int d_flags;		/* protected by d_lock，目录项标识 */
	seqcount_spinlock_t d_seq;	/* per dentry seqlock */
	struct hlist_bl_node d_hash;	/* lookup hash list, 散列表 */
	struct dentry *d_parent;	/* parent directory，父目录 */
	struct qstr d_name; // 目录项名，d_name.name是字符串数组
	struct inode *d_inode;		/* Where the name belongs to - NULL is negative， 关联的索引节点 */
	unsigned char d_iname[DNAME_INLINE_LEN];	/* small names，短文件名 */

	/* Ref lookup also touches following */
	struct lockref d_lockref;	/* per-dentry lock and refcount，使用计数，用d_count()函数获取 */
	const struct dentry_operations *d_op; // 目录项操作指针
	struct super_block *d_sb;	/* The root of the dentry tree，文件的超级块 */
	unsigned long d_time;		/* used by d_revalidate，重置时间 */
	void *d_fsdata;			/* fs-specific data，文件系统特有数据 */

	union {
		struct list_head d_lru;		/* LRU list，Least Recently Used 最近最少使用链表 */
		wait_queue_head_t *d_wait;	/* in-lookup ones only */
	};
	struct list_head d_child;	/* child of parent list，目录项内部形成的链表 */
	struct list_head d_subdirs;	/* our children，子目录链表 */
	/*
	 * d_alias and d_rcu can share memory
	 */
	union {
		struct hlist_node d_alias;	/* inode alias list，索引节点别名链表，当有多个硬链接时，就有多个dentry指向同一个inode，多个dentry都放到d_alias链表中 */
		struct hlist_bl_node d_in_lookup_hash;	/* only for in-lookup ones */
	 	struct rcu_head d_rcu; // RCU加锁
	} d_u;
} __randomize_layout;
```

目录项有3种状态：

- 被使用：`d_inode`不为空，`d_count()`大于等于`1`
- 未被使用：`d_inode`不为空，`d_count()`为`0`，注意曾经可能使用过
- 无效状态：`d_inode`为空

目录项缓存有3种：

- "被使用的"目录项链表：`inode->i_dentry`链表，一个`inode`可能有多个链接，一个`inode`可能有多个`dentry`
- "Least Recently Used 最近最少使用"链表：`d_lru`链表，包含未被使用和无效状态的`dentry`
- 散列表：`dentry_hashtable`链表，散列值由`d_hash()`计算，`d_lookup()`查找散列表

目录项让相应的索引节点的`i_count`为正，目录项被缓存了，索引节点肯定也被缓存了。

### 目录项操作

目录项对象中最重要的一个成员是`d_op`，目录项操作结构体定义在`include/linux/dcache.h`中，方法不多。

```c
struct dentry_operations {
	int (*d_revalidate)(struct dentry *, unsigned int); // 判断目录项对象是否有效，从缓存中使用目录项时会调用，一般文件系统不实现这个方法
	int (*d_weak_revalidate)(struct dentry *, unsigned int);
	int (*d_hash)(const struct dentry *, struct qstr *); // 生成散列值
	int (*d_compare)(const struct dentry *, // 比较两个文件名，微软的文件系统需要实现，因为不区分大小写
			unsigned int, const char *, const struct qstr *);
	int (*d_delete)(const struct dentry *); // d_count等于0时调用
	int (*d_init)(struct dentry *);
	void (*d_release)(struct dentry *); // 释放
	void (*d_prune)(struct dentry *);
	void (*d_iput)(struct dentry *, struct inode *); // dentry丢失相关的inode，也就是磁盘索引节点被删除了，调用此方法
	char *(*d_dname)(struct dentry *, char *, int);
	struct vfsmount *(*d_automount)(struct path *);
	int (*d_manage)(const struct path *, bool);
	struct dentry *(*d_real)(struct dentry *, const struct inode *);
} ____cacheline_aligned;
```

### 文件对象

站在用户角度，我们更关心的是文件对象。文件对象表示进程打开的文件，多个进程可能同时打开和操作同一个文件，同一个文件可能存在多个文件对象，最终指向同一个`dentry`。

```c
/*
 * f_{lock,count,pos_lock}成员可能存在高度争用，共享相同的缓存行。
 * 而f_{lock,mode}经常一起使用，因此也共享相同的缓存行。
 * 读取频率较高的f_{path,inode,op}被保存在单独的缓存行中。
 */
struct file {
	union {
		struct llist_node	f_llist; // 文件对象链表
		struct rcu_head 	f_rcuhead; // 释放之后的rcu链表
		unsigned int 		f_iocb_flags;
	};

	/*
	 * Protects f_ep, f_flags.
	 * Must not be taken from IRQ context.
	 */
	spinlock_t		f_lock; // 单个文件结构锁
	fmode_t			f_mode; // 访问模式
	atomic_long_t		f_count; // 引用计数
	struct mutex		f_pos_lock;
	loff_t			f_pos; // 当前位移量（文件指针）
	unsigned int		f_flags; // 打开时指定的标志
	struct fown_struct	f_owner; // 拥有者通过信号进行异步IO数据的传送
	const struct cred	*f_cred; // 文件的信任状
	struct file_ra_state	f_ra; // 预读状态
	struct path		f_path; // 包含dentry和vfsmount
	struct inode		*f_inode;	/* cached value */
	const struct file_operations	*f_op; // 文件操作表

	u64			f_version; // 版本号
#ifdef CONFIG_SECURITY
	void			*f_security; // 安全模块
#endif
	/* needed for tty driver, and maybe others */
	void			*private_data; // tty设备驱动的钩子

#ifdef CONFIG_EPOLL
	/* Used by fs/eventpoll.c to link all the hooks to this file */
	struct hlist_head	*f_ep; // 事件池链表
#endif /* #ifdef CONFIG_EPOLL */
	struct address_space	*f_mapping; // 页缓存映射
	errseq_t		f_wb_err;
	errseq_t		f_sb_err; /* for syncfs */
} __randomize_layout
  __attribute__((aligned(4)));	/* lest something weird decides that 2 is OK */
```

### 文件操作

文件对象中最重要的一个成员是`f_op`，你会发现，文件操作方法名和很多系统调用很像。

```c
struct file_operations {
	struct module *owner;
	loff_t (*llseek) (struct file *, loff_t, int); // 更新偏移量指针
	ssize_t (*read) (struct file *, char __user *, size_t, loff_t *); // 读取数据，并更新文件指针
	ssize_t (*write) (struct file *, const char __user *, size_t, loff_t *); // 写入数据并更新指针
	ssize_t (*read_iter) (struct kiocb *, struct iov_iter *);
	ssize_t (*write_iter) (struct kiocb *, struct iov_iter *);
	int (*iopoll)(struct kiocb *kiocb, struct io_comp_batch *,
			unsigned int flags);
	int (*iterate_shared) (struct file *, struct dir_context *); // v6.6在iterate_dir中加读锁，但在较早的版本（如v4.19）有些文件系统未实现此方法时加写锁
	__poll_t (*poll) (struct file *, struct poll_table_struct *); // 睡眠等待给定文件活动
	long (*unlocked_ioctl) (struct file *, unsigned int, unsigned long); // 不需要持有BKL，相比compat_ioctl，优先实现此方法
	long (*compat_ioctl) (struct file *, unsigned int, unsigned long); // 可移植变种，也不需要持有BKL
	int (*mmap) (struct file *, struct vm_area_struct *); // 将文件映射到地址空间上
	unsigned long mmap_supported_flags;
	int (*open) (struct inode *, struct file *); // 创建新的文件对象，与inode关联
	int (*flush) (struct file *, fl_owner_t id); // 已打开文件的引用计数减少时调用，作用取决于具体的文件系统
	int (*release) (struct inode *, struct file *); // 当引用计数为0时调用，作用取决于具体的文件系统
	int (*fsync) (struct file *, loff_t, loff_t, int datasync); // 所有文件的缓存数据写回磁盘
	int (*fasync) (int, struct file *, int); // 打开或关闭异步IO的通告信号
	int (*lock) (struct file *, int, struct file_lock *); // 给文件上锁
	unsigned long (*get_unmapped_area)(struct file *, unsigned long, unsigned long, unsigned long, unsigned long); // 获取未使用的地址空间来映射给定的文件
	int (*check_flags)(int); // 检查fcntl()系统调用的flags的有效性，只有nfs实现了
	int (*flock) (struct file *, int, struct file_lock *); // 提供忠告锁
	ssize_t (*splice_write)(struct pipe_inode_info *, struct file *, loff_t *, size_t, unsigned int);
	ssize_t (*splice_read)(struct file *, loff_t *, struct pipe_inode_info *, size_t, unsigned int);
	void (*splice_eof)(struct file *file);
	int (*setlease)(struct file *, int, struct file_lock **, void **);
	long (*fallocate)(struct file *file, int mode, loff_t offset,
			  loff_t len);
	void (*show_fdinfo)(struct seq_file *m, struct file *f);
#ifndef CONFIG_MMU
	unsigned (*mmap_capabilities)(struct file *);
#endif
	ssize_t (*copy_file_range)(struct file *, loff_t, struct file *,
			loff_t, size_t, unsigned int);
	loff_t (*remap_file_range)(struct file *file_in, loff_t pos_in,
				   struct file *file_out, loff_t pos_out,
				   loff_t len, unsigned int remap_flags);
	int (*fadvise)(struct file *, loff_t, loff_t, int);
	int (*uring_cmd)(struct io_uring_cmd *ioucmd, unsigned int issue_flags);
	int (*uring_cmd_iopoll)(struct io_uring_cmd *, struct io_comp_batch *,
				unsigned int poll_flags);
} __randomize_layout;
```

### 其他数据结构

`file_system_type`描述各种特定文件系统类型，每种文件系统只有一个`file_system_type`对象。
```c
struct file_system_type {
	const char *name; // 名字
	int fs_flags; // 类型标志
#define FS_REQUIRES_DEV		1 
#define FS_BINARY_MOUNTDATA	2
#define FS_HAS_SUBTYPE		4
#define FS_USERNS_MOUNT		8	/* Can be mounted by userns root */
#define FS_DISALLOW_NOTIFY_PERM	16	/* Disable fanotify permission events */
#define FS_ALLOW_IDMAP         32      /* FS has been updated to handle vfs idmappings. */
#define FS_RENAME_DOES_D_MOVE	32768	/* FS will handle d_move() during rename() internally. */
	int (*init_fs_context)(struct fs_context *);
	const struct fs_parameter_spec *parameters;
	struct dentry *(*mount) (struct file_system_type *, int, // 从磁盘中读取超级块
		       const char *, void *);
	void (*kill_sb) (struct super_block *); // 终止访问超级块
	struct module *owner; // 文件系统模块
	struct file_system_type * next; // 链表中下一个文件系统类型
	struct hlist_head fs_supers; // 超级块对象链表

	// 运行时使锁生效
	struct lock_class_key s_lock_key;
	struct lock_class_key s_umount_key;
	struct lock_class_key s_vfs_rename_key;
	struct lock_class_key s_writers_key[SB_FREEZE_LEVELS];

	struct lock_class_key i_lock_key;
	struct lock_class_key i_mutex_key;
	struct lock_class_key invalidate_lock_key;
	struct lock_class_key i_mutex_dir_key;
};
```

文件系统挂载时，有一个`mount`结构体在挂载点被创建，代表文件系统实例，也就是代表一个挂载点。

```c
struct mount {
	struct hlist_node mnt_hash; // 散列表
	struct mount *mnt_parent; // 父文件系统
	struct dentry *mnt_mountpoint; // 挂载点的目录项
	struct vfsmount mnt;
	union {
		struct rcu_head mnt_rcu;
		struct llist_node mnt_llist;
	};
#ifdef CONFIG_SMP
	struct mnt_pcp __percpu *mnt_pcp;
#else
	int mnt_count; // 引用计数
	int mnt_writers; // 写者引用计数
#endif
	struct list_head mnt_mounts;	/* list of children, anchored here，子文件系统链表 */
	struct list_head mnt_child;	/* and going through their mnt_child，子文件系统链表 */
	struct list_head mnt_instance;	/* mount instance on sb->s_mounts */
	const char *mnt_devname;	/* Name of device e.g. /dev/dsk/hda1，设备文件名 */
	struct list_head mnt_list; // 描述符链表
	struct list_head mnt_expire;	/* link in fs-specific expiry list，在到期链表的位置 */
	struct list_head mnt_share;	/* circular list of shared mounts，在共享安装链表的位置 */
	struct list_head mnt_slave_list;/* list of slave mounts，从安装链表 */
	struct list_head mnt_slave;	/* slave list entry，在从安装链表的位置 */
	struct mount *mnt_master;	/* slave is on master->mnt_slave_list，从安装链表的主人 */
	struct mnt_namespace *mnt_ns;	/* containing namespace，相关的命名空间 */
	struct mountpoint *mnt_mp;	/* where is it mounted */
	union {
		struct hlist_node mnt_mp_list;	/* list mounts with the same mountpoint */
		struct hlist_node mnt_umount;
	};
	struct list_head mnt_umounting; /* list entry for umount propagation */
#ifdef CONFIG_FSNOTIFY
	struct fsnotify_mark_connector __rcu *mnt_fsnotify_marks;
	__u32 mnt_fsnotify_mask;
#endif
	int mnt_id;			/* mount identifier，安装标识符 */
	int mnt_group_id;		/* peer group identifier，组标识符 */
	int mnt_expiry_mark;		/* true if marked for expiry，到期时为1 */
	struct hlist_head mnt_pins;
	struct hlist_head mnt_stuck_children;
} __randomize_layout;

struct vfsmount {
	struct dentry *mnt_root;	/* root of the mounted tree，该文件系统的根目录项 */
	struct super_block *mnt_sb;	/* pointer to superblock，超级块 */
	int mnt_flags; // 挂载标志, MNT_NOSUID 等
	struct mnt_idmap *mnt_idmap;
} __randomize_layout;
```

`files_struct`描述单个进程相关的信息，`struct task_struct`中的`files`成员指向它。
```c
/*
 * Open file table structure
 */
struct files_struct {
  /*
   * read mostly part
   */
	atomic_t count; // 引用计数
	bool resize_in_progress;
	wait_queue_head_t resize_wait;

	struct fdtable __rcu *fdt; // 如果打开的文件数大于NR_OPEN_DEFAULT，分配一个新数组
	struct fdtable fdtab; // 基fd表
  /*
   * written part on a separate cache line in SMP
   */
	spinlock_t file_lock ____cacheline_aligned_in_smp; // 单个文件的锁
	unsigned int next_fd; // 缓存下一个可用的fd
	unsigned long close_on_exec_init[1]; // exec()时关闭的fd链表
	unsigned long open_fds_init[1]; // 打开的fd链表
	unsigned long full_fds_bits_init[1];
	struct file __rcu * fd_array[NR_OPEN_DEFAULT]; // 默认的文件对象数组
};
```

`fs_struct`表示文件系统进程相关的信息，`struct task_struct`中的`fs`成员指向它。

```c
struct fs_struct {
	int users; // 用户数目
	spinlock_t lock; // 保护该结构体的锁
	seqcount_spinlock_t seq;
	int umask; // 掩码
	int in_exec; // 当前正在执行的文件
	struct path root; // 根目录路径
	struct path pwd; // 当前工作目录的路径
} __randomize_layout;
```

`mnt_namespace`表示单进程命名空间，`struct task_struct`中的`nsproxy->mnt_namespace`成员指向它。

```c
struct mnt_namespace {
	struct ns_common	ns;
	struct mount *	root; // 根目录的挂载点
	/*
	 * Traversal and modification of .list is protected by either
	 * - taking namespace_sem for write, OR
	 * - taking namespace_sem for read AND taking .ns_lock.
	 */
	struct list_head	list; // 挂载点链表
	spinlock_t		ns_lock;
	struct user_namespace	*user_ns;
	struct ucounts		*ucounts; // 用户计数
	u64			seq;	/* Sequence number to prevent loops */
	wait_queue_head_t poll; // 轮询的等待队列
	u64 event; // 事件计数
	unsigned int		mounts; /* # of mounts in the namespace */
	unsigned int		pending_mounts;
} __randomize_layout;

struct ucounts {
	struct hlist_node node;
	struct user_namespace *ns;
	kuid_t uid;
	atomic_t count; // 引用计数
	atomic_long_t ucount[UCOUNT_COUNTS];
	atomic_long_t rlimit[UCOUNT_RLIMIT_COUNTS];
};
```

## ext2文件系统

### 先做几个VFS的验证

#### 硬链接

#### 通过`inode`获取文件名

通过 inode 获取文件名，文件可能有多个硬链接对应多个dentry，文件夹没有多个硬链接只可能有一个dentry
```c
#include <linux/fs.h>
#include <linux/dcache.h>

void get_file_name(struct inode *inode)
{
    char buf[PATH_MAX];
    struct dentry *dentry = d_find_alias(inode);
    if (dentry) {
        d_path(dentry, buf, PATH_MAX);
        printk("File name: %s\n", buf);
        dput(dentry);
    }
}
```

### 通过`inode`得到完整路径

通过 inode 得到完整的路径