#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>

// 设置文件锁的函数
int set_lock(int fd, int type, off_t offset, off_t len) {
    struct flock lock;
    
    // 设置锁结构
    lock.l_type = type;       // 锁类型: F_RDLCK, F_WRLCK, F_UNLCK
    lock.l_whence = SEEK_SET; // 相对文件开始处
    lock.l_start = offset;    // 锁区偏移量
    lock.l_len = len;         // 锁区长度
    lock.l_pid = getpid();    // 进程ID
    
    // 尝试设置锁 (F_SETLKW 会阻塞等待)
    if (fcntl(fd, F_SETLKW, &lock) == -1) {
        perror("fcntl(F_SETLKW) failed");
        return -1;
    }
    printf("加锁: 区域 [%ld, %ld] 已被 PID=%d 的 %s 锁锁定\n",
            offset, offset + len - 1, lock.l_pid,
            (lock.l_type == F_WRLCK) ? "写锁" : "读锁");
    return 0;
}

// 测试锁状态的函数
void test_lock(int fd, int type, off_t offset, off_t len) {
    struct flock lock;
    
    lock.l_type = type;
    lock.l_whence = SEEK_SET; // 相对文件开始处
    lock.l_start = offset;
    lock.l_len = len;
    lock.l_pid = getpid();
    
    if (fcntl(fd, F_GETLK, &lock) == -1) {
        perror("fcntl(F_GETLK) failed");
        return;
    }
    
    if (lock.l_type == F_UNLCK) {
        printf("锁测试: 区域 [%ld, %ld] 可以加锁\n", offset, offset + len - 1);
    } else {
        printf("锁测试: 区域 [%ld, %ld] 已被 PID=%d 的 %s 锁锁定\n",
               offset, offset + len - 1, lock.l_pid,
               (lock.l_type == F_WRLCK) ? "写锁" : "读锁");
    }
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "用法: %s <文件名>\n", argv[0]);
        exit(EXIT_FAILURE);
    }
    
    const char *filename = argv[1];
    int fd;
    
    // 打开文件 (读写模式)
    if ((fd = open(filename, O_RDWR | O_CREAT, 0644)) == -1) {
        perror("打开文件失败");
        exit(EXIT_FAILURE);
    }
    
    printf("进程 PID=%d 操作文件: %s\n\n", getpid(), filename);
    
    // 测试初始锁状态
    printf("测试初始锁状态:\n");
    test_lock(fd, F_WRLCK, 0, 100);
    
    // 设置写锁 (锁定前100字节)
    printf("\n==> 设置写锁 (0-99字节)\n");
    if (set_lock(fd, F_WRLCK, 0, 100) == -1) {
        close(fd);
        exit(EXIT_FAILURE);
    }
    
    // 测试自己的锁
    printf("\n测试自己的锁:\n");
    test_lock(fd, F_RDLCK, 0, 50);  // 尝试读锁
    test_lock(fd, F_WRLCK, 50, 50); // 尝试写锁
    
    // 测试重叠区域
    printf("\n测试重叠区域:\n");
    test_lock(fd, F_WRLCK, 90, 20); // 重叠区域 (90-109)
    
    // 测试非重叠区域
    printf("\n测试非重叠区域:\n");
    test_lock(fd, F_WRLCK, 100, 50); // 非重叠区域 (100-149)
    
    // 持有锁一段时间
    printf("\n==> 持有锁 10 秒...\n");
    sleep(10);
    
    // 释放锁
    printf("\n==> 释放锁\n");
    set_lock(fd, F_UNLCK, 0, 100);
    
    // 设置读锁 (锁定50-149字节)
    printf("\n==> 设置读锁 (50-149字节)\n");
    if (set_lock(fd, F_RDLCK, 50, 100) == -1) {
        close(fd);
        exit(EXIT_FAILURE);
    }
    
    // 测试读锁
    printf("\n测试读锁:\n");
    test_lock(fd, F_RDLCK, 50, 50);  // 测试读锁区域
    test_lock(fd, F_WRLCK, 50, 50);  // 尝试写锁会失败
    
    printf("\n==> 持有读锁 5 秒...\n");
    sleep(5);
    
    // 释放所有锁
    set_lock(fd, F_UNLCK, 50, 100);
    
    close(fd);
    return 0;
}
