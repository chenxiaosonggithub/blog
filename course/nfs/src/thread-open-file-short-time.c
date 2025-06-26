#include <stdio.h>
#include <pthread.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/syscall.h> // 用于 SYS_gettid

// 线程函数：打开文件并进入无限循环
void* thread_function(void* arg) {
    const char* filename = "/mnt/file";
    pid_t tid = syscall(SYS_gettid);
    // 获取当前线程的 pthread ID
    pthread_t pthread_id = pthread_self();

    printf("Thread pthread ID=%lu, tid=%ld\n", (unsigned long)pthread_id, (long)tid);
    // 保持文件打开并不退出
    while (1) {
        // 打开文件（如果文件不存在则创建）
        FILE* file = fopen(filename, "w");
        if (file == NULL) {
            perror("fopen failed");
            pthread_exit(NULL);
        }
        fclose(file);
    }

    pthread_exit(NULL);
}

int main() {
    pthread_t thread1, thread2;
    // 获取主线程的 pthread ID
    pthread_t pthread_id = pthread_self();

    // 创建第一个线程
    if (pthread_create(&thread1, NULL, thread_function, NULL) != 0) {
        perror("Failed to create thread 1");
        exit(EXIT_FAILURE);
    }
    
    // 创建第二个线程
    if (pthread_create(&thread2, NULL, thread_function, NULL) != 0) {
        perror("Failed to create thread 2");
        exit(EXIT_FAILURE);
    }

    printf("Main thread pthread ID=%lu, pid=%d\n", (unsigned long)pthread_id, getpid());
    
    // 主线程等待子线程（实际上会永久阻塞）
    pthread_join(thread1, NULL);
    pthread_join(thread2, NULL);
    
    // 程序永远不会执行到这里
    return 0;
}