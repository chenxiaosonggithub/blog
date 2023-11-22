[点击这里跳转到陈孝松个人主页:chenxiaosong.com](http://chenxiaosong.com/)。

本文档翻译自[dkruchinin/cthon-nfs-tests 的 README 文件](https://github.com/dkruchinin/cthon-nfs-tests/blob/master/README)，大部分借助于ChatGPT，当然有一丢丢是经过了我的修改。

# 1. Connectathon NFS Testsuites 简介

这些目录包含可用于测试 NFS 协议实现的程序。测试在 UNIX 客户端和测试服务器上运行，并测试服务器和客户端功能（有关在 DOS 和 Windows 上运行的信息，请参见 READWIN.txt）。测试分为四组：

- **basic**：基本文件系统操作测试
- **general**：一般文件系统测试
- **special**：测试针对某些常见问题领域
- **lock**：测试网络锁定功能

此 README 分为五个部分。第一部分是介绍，您正在阅读它。然后是在在您的计算机上运行测试套件之前需要做的事情的描述。接下来是测试套件的一般运行方式的描述，然后是它们在 Connectathon 中的使用描述。最后一部分详细描述了每个测试的作用。

这个测试套件应该在基于 BSD 和 System V 的系统上都能运行。Connectathon Testsuite 的 System V Release 3 移植由 Lachman Technology, Incorporated 提供，地址为 1901 N. Naper Blvd., Naperville, IL. 60563。

# 2. 准备运行测试套件

为了在您的计算机上准备运行测试套件，切换到最高级别的测试套件目录（应该是包含此 README 文件的目录），根据您所在的平台编辑 tests.init，并键入 "make" 编译测试程序。如果您不确定是否在正确的目录中，请键入 "ls -CF"，您应该看到以下文件和目录：
```sh
Makefile    basic/      lock/       tests.h
README      domount.c   runtests    tests.init
READWIN.txt general/    server      tools/
Testitems   getopt.c    special/    unixdos.h
```

"server" 脚本使用 "getopt"。包含公共领域版本 "getopt" 的源文件已包含在该目录中。Makefile 将为您编译它。

测试根据 tests.init 脚本中的参数进行配置。它包含各种由各种 Makefiles 和 shell 脚本使用的命令和参数的定义。应该检查并可能修改此文件以正确匹配您的系统。特别是，应检查并正确设置 "MOUNTCMD"、"UMOUNTCMD"、"PATH"、"CFLAGS" 和 "LIBS" 的值。有几组建议的值，可作为可能的起点。

Makefiles 中包含两个特殊的目标：copy 和 dist。命令 "make copy DESTDIR="path""，其中 "path" 是目录的绝对名称，将导致已编译的测试被复制到 "path"。命令 "make dist DESTDIR="path""，其中 "path" 是目录的绝对名称，将测试源复制到 "path"。在制作这两个目标时，必须在 make 命令行上指定 DESTDIR。

可能需要修改以使程序在您的计算机上编译。如果是这样，请告诉我们，以便我们可以将其合并到我们的分发中。

当使用默认值时，测试程序期望在服务器上存在目录 /server。测试驱动程序将在客户端上使用目录 /mnt/'server_name'，如果需要的话会首先创建它（其中 'server_name' 是您正在测试的服务器的名称）。可以在运行时覆盖这些默认值。如何执行此操作的说明包含在下一部分中。

# 3. 如何运行测试套件

有两种运行测试的方法：使用服务器 shell 脚本或挂载、自行运行测试，然后卸载。我们建议您使用服务器脚本运行测试。

## 3.1. server脚本

server脚本根据给定的选项执行一个或多个测试集（见下文）。它被设置为挂载，使用 runtests 程序运行测试，然后卸载。在尝试挂载服务器文件系统之前，它将尝试卸载挂载点上的任何内容。如果测试失败，运行将中止，文件系统将保持挂载状态以帮助排除故障。

服务器脚本使用 domount 程序来挂载和卸载测试文件系统。由于挂载只能由 root 执行，domount 必须具有 root 权限。Makefile 将尝试将 domount 程序的 setuid 设置为 root。服务器脚本可以作为非特权用户运行。或者，您可以在运行 server 之前以 root 身份登录。

```sh
server [-a|-b|-g|-s|-l] [-f|-t] [-n] [-o mnt_options] [-p server_path] [-m mntpoint] [-N numpasses] server_name

- `-a|-b|-g|-s|-l`: 将传递给 runtests 脚本。该参数是可选的，默认从初始化文件 tests.init 中读取。变量 TEST 包含此参数。该参数选择要运行哪些测试：
  - `-a`: 运行基本、常规、特殊和锁测试
  - `-b`: 仅运行基本测试
  - `-g`: 仅运行常规测试
  - `-s`: 仅运行特殊测试
  - `-l`: 仅运行锁测试
- `-f|-t`: 将传递给 runtests 脚本。该参数是可选的，默认从初始化文件 tests.init 中读取。变量 TESTARG 包含此参数。该参数选择如何运行基本测试：
  - `-f`: 快速功能测试
  - `-t`: 带有定时的扩展测试模式
- `-n`: 不执行创建和销毁测试目录的 mkdir 和 rmdir 操作。
- `-o mnt_options`: 将传递给 mount 命令。该参数是可选的，默认从初始化文件 tests.init 中读取。变量 MNTOPTIONS 包含此参数。
- `-p server_path`: 指定要挂载的服务器上的目录。该参数是可选的，默认从初始化文件 tests.init 中读取。变量 SERVPATH 包含此参数。
- `-m mntpoint`: 指定客户端上的挂载点。该参数是可选的，默认从初始化文件 tests.init 中读取。变量 MNTPOINT 包含此参数。
- `-N numpasses`: 将传递给 runtests 脚本。该参数是可选的。它指定运行测试的次数。
- `server_name`: 要测试的服务器。这是唯一必须的参数。
```

测试程序将在 mntpoint 目录中创建一个名为 'hostname'.test 的子目录（其中 'hostname' 是运行测试的机器的名称）。如果使用 server 脚本，该名称无法被覆盖，但如果直接使用 runtests，则可以覆盖。

示例：（客户端机器为 eddie）
```sh
eddie% server -o hard,intr,rw slartibartfarst
Start tests on path /mnt.slartibartfast/eddie.test [y/n]? y
<output from tests>
         :
         :
All tests completed
eddie%
```

可以查看 server 脚本获取更多信息。

## 3.2. 自行运行测试

在最高级目录（主 runtests 目录）中有一个 runtest 脚本，它使用 tests.init 来设置测试环境，然后执行 basic、general 和/或 special 子目录中的 runtest 脚本。

```sh
runtests [-a|-b|-g|-s|-l] [-f|-n|-t] [-N numpasses] [test-directory]

-a             - 运行基本、常规、特殊和锁定测试。这是默认设置。
-b             - 运行基本测试。
-g             - 运行常规测试。
-s             - 运行特殊测试。
-l             - 运行锁定测试。
-f             - 为快速功能测试设置参数。它仅适用于基本测试。
-n             - 抑制对测试目录进行的目录操作（mkdir 和 rmdir）。有关基本测试的详细信息，请参见描述。
-t             - 运行带有运行时间统计的全长测试。它仅适用于基本测试。这是基本测试的默认模式。
-N numpasses   - 运行测试 "numpasses" 次。
test-directory - 测试程序在客户端上创建的测试目录的名称。runtests 在原地执行基本测试，并且它们在测试目录上运行。通用测试被复制到测试目录并在那里执行。使用 -n 标志时，假定测试目录已经存在。

默认的测试目录是 /mnt.'servername'/'hostname'.test（其中 'servername' 是要测试的服务器的名称，'hostname' 是您运行测试的计算机的名称）。有三种方法可以覆盖默认的测试目录名称。其中一种方法是将 test_directory 放在命令行上。另一种方法是将环境变量 NFSTESTDIR 设置为目录名称。命令行方法会覆盖设置环境变量。第三种方法只能用于 basic 子目录中的测试。在那里，您可以在 tests.h 中设置 TESTDIR 变量。命令行和环境变量都会覆盖此方法。
```

在不将 NFS 服务器挂载到 /mnt 上的情况下运行测试将在本地运行测试（如果 /mnt 是本地磁盘）。我们建议您在使用测试套件测试 NFS 之前至少运行一次此操作，以确保测试套件正常运行。

如果希望单独运行每个测试套件，可以使用与主 runtests 相同的参数调用子目录中的 basic、general 和 special 中的 runtests。

# 4. 如何在 Connectathon 上运行测试套件

应按以下顺序运行测试：basic、general 和 special。在尝试其他测试之前，应完全通过基本测试。

NFS 测试套件应分为三个阶段运行：

阶段 1 - 在本地运行测试程序。

阶段 2 - 对接 Sun 运行测试。使用 Sun 作为服务器在您的机器上运行它们，然后使用您的机器作为服务器在 Sun 上运行它们。

阶段 3 - NxN 测试。在您的机器上运行测试，每次使用其他机器作为服务器。在使用特定服务器成功完成测试后，请使用提供的电子板软件记录下来。检查电子板，确保测试在将您的机器作为服务器的每台其他机器上都成功运行。

# 5. 测试描述

测试套件使用的系统调用和库调用已包含在括号中。如果您想了解如何记录时间统计信息，请查看源代码，因为这些信息在本描述中未包含。

## 5.1. BASIC TESTS

下面列出的许多程序都有可选的调用参数，可用于覆盖现有参数。目前未使用这些参数，因此不会进行描述。

test1: 文件和目录创建测试

该程序在客户端上创建测试目录（mkdir），并更改目录（chdir）到该目录，除非使用 -n 标志，在这种情况下，它只是更改到测试目录。然后，它构建一个 N 层深的目录树，其中每个目录（包括测试目录）都有 M 个文件和 P 个目录（creat、close、chdir 和 mkdir）。对于 -f 选项，N = 2，M = 2，P = 2，因此总共创建了六个文件和六个目录。对于其他选项，N = 5，M = 5，P = 2。创建的文件以 "file." 开头，目录以 "dir." 开头。

test2: 文件和目录删除测试

该程序更改目录到测试目录（chdir 和/或 mkdir），并删除由 test1 刚刚创建的目录树（unlink、chdir 和 rmdir）。层次、文件和目录的数量，以及名称前缀与 test1 相同。

此例程不会删除未由 test1 创建的文件或目录，如果找到一个，则会失败。它通过查看要删除对象的名称前缀来确定这一点。

test3: 跨挂载点的查找

该程序更改到测试目录（chdir 和/或 mkdir），并获取工作目录的文件状态（getwd 或 getcwd 和 stat）。对于 -f 选项，执行 getwd 或 getcwd 一次。对于其他选项，执行 250 次 getcwd 或 getcwd。

test4: setattr、getattr 和查找

该程序更改到测试目录（chdir 和/或 mkdir），并创建十个文件（creat）。然后更改权限（chmod）并为每个文件检索文件状态（stat）。对于 -f 选项，对每个文件执行一次 chmod 和 stat。对于其他选项，对每个文件执行 50 次 getcwd 或 getcwd 和 stat。

test4a: getattr 和查找

此测试存在，但不作为测试套件的一部分调用。您可以编辑基本目录中的 runtests，以便调用此测试。

该程序更改到测试目录（chdir 和/或 mkdir），并创建十个文件（creat）。然后为每个文件检索文件状态（stat）。对于 -f 选项，对每个文件执行一次 stat。对于其他选项，对每个文件执行 50 次 stat。

test5: 读取和写入

该程序更改到测试目录（chdir 和/或 mkdir），然后：

```sh
1) 创建一个文件（creat）
2) 获取文件的状态（fstat）
3) 检查文件的大小
4) 将 1048576 字节写入文件（write）以 8192 字节缓冲区的形式。
5) 关闭文件（close）
6) 获取文件的状态（stat）
7) 检查文件的大小
```

对于 -f 选项，创建并写入文件一次。对于其他选项，创建并写入文件 10 次。

然后打开文件（open）并以 8192 字节缓冲区的形式读取文件（read）。将其内容与写入的内容进行比较。然后关闭文件（close）。

然后重新打开文件（open）并重新读取文件（read），然后将其删除（unlink）。对于 -f 选项，执行此序列一次。对于其他选项，执行此序列 10 次。

test5a: 写入

此测试存在，但不作为测试套件的一部分调用。您可以编辑基本目录中的 runtests，以便调用此测试。

该程序更改到测试目录（chdir 和/或 mkdir），然后：
```sh
1) 创建一个文件（creat）
2) 获取文件的状态（fstat）
3) 检查文件的大小
4) 将 1048576 字节写入文件（write）以 8192 字节缓冲区的形式。
5) 关闭文件（close）
6) 获取文件的状态（stat）
7) 检查文件的大小
```

对于 -f 选项，创建并写入文件一次。对于其他选项，创建并写入文件 10 次。

test5b: 读取

此测试存在，但不作为测试套件的一部分调用。您可以编辑基本目录中的 runtests，以便调用此测试。

在 test5a 中创建的文件会以 8192 字节缓冲区的形式打开（open）和读取（read）。将其内容与写入的内容进行比较。然后关闭文件（close）并删除文件（unlink）。

对于 -f 选项，打开并读取文件一次。对于其他选项，创建并写入文件 10 次。

test6: readdir

该程序更改到测试目录（chdir 和/或 mkdir），并创建 200 个文件（creat）。然后打开当前目录（opendir），找到开始位置（rewinddir），并在循环中读取目录（readdir），直到找到结束位置。标记的错误有：

```sh
1) 没有 "."
2) 没有 ".."
3) 重复的条目
4) 文件名不以 "file." 开头
5) 文件名的后缀超出范围
6) 为已取消链接的文件返回一个条目（此错误仅在使用 -f 以外的选项运行测试时才能找到。对于其他选项，rewinddir/readdir 循环执行 200 次，每次取消链接一个文件）。
```

然后关闭目录（closedir）并删除创建的文件（unlink）。

test7: link 和 rename

该程序更改到测试目录（chdir 和/或 mkdir），并创建十个文件。对于这些文件的每一个，将文件重命名（rename），并为新旧名称分别检索文件统计信息（stat）。标记的错误有：
```sh
1) 旧文件仍然存在
2) 新文件不存在（无法 stat）
3) 新文件的链接数不等于一
```

然后尝试将新文件链接到其旧名称（link），然后再次检索文件统计信息（stat）。如果出现错误：
```sh
1) 无法链接
2) 无法在链接后检索新文件的统计信息
3) 新文件的链接数不等于两
4) 无法在链接后检索旧文件的统计信息
5) 旧文件的链接数不等于两
```

然后删除新文件（unlink）并检索旧文件的文件统计信息（stat）。如果出现错误：
```sh
1) 无法在取消链接后检索旧文件的统计信息
2) 旧文件的链接数不等于一
```

对于 -f 选项，对每个文件执行一次重命名/链接/取消链接循环。对于其他选项，对每个文件执行 10 次重命名/链接/取消链接循环。

在测试结束时删除任何剩余的文件（unlink）。

test7a: 重命名

此测试存在，但不作为测试套件的一部分调用。您可以编辑基本目录中的 runtests，以便调用此测试。

该程序更改到测试目录（chdir 和/或 mkdir），并创建十个文件。对于这些文件的每一个，将文件重命名（rename），并为新旧名称分别检索文件统计信息（stat）。标记的错误有：
```sh
1) 旧文件仍然存在
2) 新文件不存在（无法 stat）
3) 新文件的链接数不等于一
```

然后将文件重命名回其原始名称，并应用相同的测试。

对于 -f 选项，对每个文件执行一次重命名/重命名循环。对于其他选项，对每个文件执行 10 次重命名/重命名循环。

在测试结束时删除任何剩余的文件（unlink）。

test7b: 链接

此测试存在，但不作为测试套件的一部分调用。您可以编辑基本目录中的 runtests，以便调用此测试。

该程序更改到测试目录（chdir 和/或 mkdir），并创建十个文件。对于这些文件的每一个，都会进行一次链接（link），并为旧文件和新文件分别检索文件统计信息（stat）。如果出现错误：
```sh
1) 无法链接
2) 无法在链接后检索两个文件的统计信息
3) 两个文件的链接数不等于两
```

然后执行新文件的取消链接（unlink）。如果出现错误：
```sh
1) 无法在取消链接后检索旧文件的统计信息
2) 旧文件的链接数不等于一
```

对于 -f 选项，对每个文件执行一次链接/取消链接循环。对于其他选项，对每个文件执行 10 次链接/取消链接循环。

在测试结束时删除任何剩余的文件（unlink）。

test8: symlink 和 readlink

注意：并非所有操作系统都支持 symlink 和 readlink。如果在 test8 中返回 errno，EOPNOTSUPP，则将测试计为通过。对于不支持 S_IFLNK 的客户端，将不尝试进行此测试。

该程序更改到测试目录（chdir 和/或 mkdir），并创建 10 个符号链接（symlink）。它读取（readlink）并获取每个的统计信息（lstat），然后删除它们（unlink）。标记的错误有：
```sh
1) 不支持的功能
2) 无法获取统计信息（lstat 失败）
3) 统计信息中的模式不是符号链接
4) 符号链接的值不正确（从 readlink 返回）
5) 链接名称错误
6) 取消链接失败
```

对于 -f 选项，对每个符号链接执行一次符号链接/readlink/取消链接循环。对于其他选项，对每个符号链接执行 20 次符号链接/readlink/取消链接循环。

test9: statfs

该程序更改到测试目录（chdir 和/或 mkdir），并获取当前目录的文件系统状态（statfs）。对于 -f 选项，执行一次 statfs。对于其他选项，执行 1500 次 statfs。


## 5.2. GENERAL: 用于查看服务器负载的通用测试

运行小型编译、tbl、nroff、大型编译、四个同时运行的大型编译和 make。

## 5.3. SPECIAL:  有关特殊测试的特定信息

特殊目录设置为测试过去出现的特殊问题。这些测试旨在提供建议，以便注意。并不要求您“通过”这些测试，但我们强烈建议您这样做。

这些测试尝试：

- 检查正确的打开/取消链接操作
- 检查正确的打开/重命名操作
- 检查正确的打开/chmod 0 操作
- 检查非幂等请求的丢失回复
- 测试独占创建
- 测试负偏移查找
- 测试重命名


## 5.4. LOCK

锁目录包含一个测试程序，可用于测试内核文件和记录锁定设施。这是为了测试网络锁定管理器。

测试程序包含 13 组锁定测试。它们测试基本的锁定功能。

默认情况下，不测试强制锁定。一般情况下，NFS 文件通常不支持强制锁定。


## 5.5. MISC

“Testitems”是可以用作参考的 NFS 功能列表。

“tools”中提供的程序可根据您的需要使用。请随时向其中（或任何其他）目录添加内容！如果这样做，请确保将副本发送给 Mike Kupfer <mike.kupfer@sun.com>，以便我们可以将其添加到主测试分发中。

此树中的代码在 1998 年 8 月进行了 Y2000 问题检查。未发现问题。

有关在 DOS 或 Windows 下运行测试的信息，请参见 READWIN.txt。


2004 年的更改包括以下内容：

1. 修复 lock/tlock.c，使其在何时使用 stdarg 和何时使用 varargs 方面保持一致；由Samuel Sha <sam@austin.ibm.com>报告。

2. 更改“make all”，以便各种“runtests”脚本具有执行权限；由Erik Deumens <deumens@qtp.ufl.edu>报告。

3. 删除了一些 lint；由James Peach <jpeach@sgi.com>提供。

4. Irix 6.5.19 支持，由James Peach <jpeach@sgi.com>提供。

5. “server”脚本现在导出 MNTOPTIONS，以便“server”添加的选项可以被测试套件的其余部分检测到。由Chuck Lever <Charles.Lever@netapp.com>提供。

6. 测试现在正确检查从 mmap() 返回的错误。由David Robinson <david.robinson@sun.com>提供。

7. MacOS X 支持，由Mike Mackovitch <macko@apple.com>提供。

8. tests.init 现在包含一个 Linux 的 CC= 行，以防您的发行版不包含“cc”。由Rodney Brown <rodney@lehman.com>报告。

9. 针对 AIX 的更改，由Erik Deumens <deumens@qtp.ufl.edu>提供。

10. 针对最新的 Tru64 Unix 的更改，由Eric Werme <werme@hp.com>提供。

11. 一般测试在面对 make(1) 的错误时应更为健壮。基于来自Chuck Lever <Charles.Lever@netapp.com>的评论和来自Mike Mackovitch <macko@apple.com>的补丁。

12. 基本测试的“make lint”目标现在包括 subr.c。

13. 对 special/bigfile2 的改进：
    - 错误消息现在打印完整的低阶字（来自Mike Mackovitch <macko@apple.com>）。
    - 测试文件以 O_SYNC 打开，以便立即检测到问题。

14. 修复了 special/op_chmod，使其使用 CHMOD_NONE 而不是 0。来自Pascal Schmidt <der.eremit@email.de>。


2003 年的更改包括以下内容：

1. 来自Brian Love <blove@rlmsoftware.com>和Brian McEntire <brianm@fsg1.nws.noaa.gov>的 HPUX 修复。

2. AIX 支持，基于<saul@exanet.com>的补丁。

3. 用于构建 64 位二进制文件的 gcc 命令行选项，来自Sergey Klyushin <sergey.klyushin@hummingbird.com>。

4. 有关服务器脚本的消息现在更清晰，关于在测试失败后保留服务器的挂载。感谢Vincent McIntyre <Vince.McIntyre@atnf.csiro.au>提出的建议。

5. 锁定测试现在应该适用于 NFS 版本 4 和强制执行强制锁定的服务器。感谢Bill Baker <bill.baker@sun.com>提供 test12 修复。

6. 通用测试已修复为使用测试套件提供的“stat”程序，而不是任何系统“stat”程序。


2002 年的更改包括以下内容：

1. special 测试更好地识别了何时指定了 NFS 版本 2（基于Jay Weber <jweber@mail.thatnet.net>的补丁）。

2. 基于来自Marty Johnson <martyj@traakan.com>的补丁，对 *BSD 系统进行了编译和运行修复。

3. 默认的本地挂载点已从 /mnt.'server_name' 更改为 /mnt/'server_name'。这是为了如果服务器死机或挂起，不太可能在客户端引起操作问题。

4. 如果可用，“server”脚本将尝试使用“mkdir -p”。

5. 一般测试和特殊测试在初始化期间检查错误的能力更强了。

6. 由于运行时间可能很长，特殊测试的 bigfile 测试已移到最后。

7. 修复了 Tru64 UNIX 信号处理程序的定义。

8. 从Jay Weber <jweber@mail.thatnet.net>获取的 Linux 配置信息进行了更新。


2001 年的更改包括以下内容：

1. 添加了“-N numpasses”选项，用于顶级“server”和“runtests”脚本。

2. 为了使 special/bigfile2 测试更稳定，更新了 HPUX 编译标志（来自Anand Paladugu <paladugu_anand@emc.com>）。

3. 对 special/bigfile2.c 进行了轻微的可移植性修复。

4. 基本测试不再假定“.”在 $PATH 中。

5. 基本测试和 special 测试在 Windows 下构建应更加容易（来自Rick Hopkins <rhopkins@ssc-corp.com>）。
