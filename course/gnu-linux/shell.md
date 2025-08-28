# `ps` {#ps}

## `ps auxww` {#ps-auxww}

```sh
# a: 所有终端用户进程
# u: 用户详细格式
# x: 无终端进程
# ww: 两个w表示宽度不限制
# 要用aux（没有-号），不要用-aux，不要用-aux
# 输出列: USER PID %CPU %MEM VSZ RSS TTY STAT START TIME COMMAND
#   USER	进程所有者（用户名）
#   PID	进程 ID（唯一标识）
#   %CPU	CPU 使用率百分比（最近一次采样周期内）
#   %MEM	物理内存使用率百分比
#   VSZ	虚拟内存大小（Virtual Memory Size，单位 KB）
#   RSS	驻留集大小（Resident Set Size，实际占用的物理内存，单位 KB）
#   TTY	关联的终端设备：
#       ? = 无终端（守护进程）
#       pts/0 = 终端窗口
#   STAT	进程状态（关键字母组合）：
#       R = 运行中或可运行（在运行队列）
#       S = 可中断睡眠（等待事件）
#       D = 不可中断睡眠（通常等待 I/O）
#       Z = 僵尸进程（已终止但未回收）
#       T = 暂停状态（如 Ctrl+Z）
#       I = 空闲内核线程
#       s = 会话领导者
#       < = 高优先级
#       N = 低优先级
#       + = 前台进程组
#   START	进程启动时间（24小时制）：
#       当天启动：HH:MM
#       跨天：月 日（如 Jul15）
#   TIME	累计占用 CPU 时间（格式 [分:]秒）
#   COMMAND	启动命令（完整路径或名称）：
#       [kthreadd] = 内核线程
#       带参数的命令会被截断（可用 ps auxww 查看完整命令）
ps auxww
```

## `ps eLf` {#ps-eLf}

```sh
# -e: 显示 所有进程（等价于 -A）
# -L: 显示线程（Light Weight Process），新增两列：LWP（线程ID）和 NLWP（线程数量）
# -f: 使用 完整格式（Full-format） 显示信息
# 输出列:
#   UID	进程所有者的用户名
#   PID	进程ID（主线程的PID与进程ID相同）
#   PPID	父进程ID
#   LWP	线程ID（Light Weight Process ID），线程的唯一标识
#   C	CPU 利用率（百分比）
#   NLWP	进程中线程的数量（Number of Light Weight Processes）
#   STIME	进程启动时间
#   TTY	关联的终端（? 表示无终端，通常是守护进程）
#   TIME	累计占用CPU时间
#   CMD	启动进程的完整命令（参数可能被截断）
ps -eLf
```

# `export`

曾经遇到过一个坑，配置`http_proxy`和`https_proxy`时，前面没加`export`，proxy怎么都用不了。所以在这里记录一下`export`命令的笔记。

`http_proxy=http://10.42.20.221:7890`作用的是当前shell，子进程不可见，只是设置一个临时变量。

而`export https_proxy=http://10.42.20.221:7890`作用范围是当前shell+子进程，一般影响外部工具的环境配置就要在前面加`export`。

