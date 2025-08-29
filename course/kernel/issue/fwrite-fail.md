# 问题描述

不只nfs，本地文件系统也一样，不调用`fflush()`数据不会落盘，有时间可以调试看看为什么。

```c
#include <stdio.h>
#include <unistd.h> // 用于sleep函数
#include <string.h>

int main() {
    FILE *file = fopen("/mnt/file", "wb");

    if (file == NULL) {
        perror("无法打开文件");
        return 1;
    }

    // 准备要写入的数据
    const char *data = "这是一个使用fwrite写入的示例数据\n";

    // 使用fwrite写入数据
    size_t written = fwrite(data, 1, strlen(data), file);

    if (written != strlen(data)) {
        perror("写入文件时发生错误");
        fclose(file);
        return 1;
    }
    // 不调用fflush，数据不会落盘，while循环时使用sync命令也无法落盘
    // fflush(file);

    printf("%d字节数据已写入文件，文件保持打开状态...\n", written);

    // 无限循环，保持程序运行且不关闭文件
    while (1) {
        sleep(1); // 每秒休眠一次，减少CPU占用
    }

    // 注意：这里的fclose永远不会执行
    fclose(file);
    return 0;
}
```