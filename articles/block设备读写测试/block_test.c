/**  @file : block_test.c
  *  @note : 
  *  @brief : 块设备测试
  *
  *  @author : 陈孝松
  *  @date : 2021.03.05 21:44
  *
  *  @note :
  *  @record :
  *       2021.03.05 21:44 created
  *       2021.03.17 18:45 增加多线程读写速度测试
  *
  *  @warning :
*/
#include <sys/time.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <getopt.h>
#include <pthread.h>

// 块设备名
#define BLK_DEV_NAME  "/dev/mmcblk0p7"
// 默认读写总大小，单位：字节（Byte）
#define TOTAL_SIZE_DEFALT (50 * 1024 * 1024)
// 是否打印时间
#define LOG_TIME 0

#define SUCCESS 0// 返回值成功
#define FAILURE -1// 返回值失败

#define PERFLOG(...) printf("%s:%s:%d:", __FILE__, __FUNCTION__, __LINE__); \
                     printf(__VA_ARGS__)
#define TEST_PRINT_TRC(...)		printf ("|TRACE LOG|"); \
					printf(__VA_ARGS__);\
					printf ("|\n");\
					usleep(100);
#define TEST_PRINT_ERR(...)		printf ("\n\n|ERROR|"); \
					printf("*ERROR* Line: %d, File: %s - ", \
						__LINE__, __FILE__); \
					printf(__VA_ARGS__); \
					printf("|\n"); \
					sleep(1);

// 用于计算时间差值
#define BASE_NUM_TRIALS 10

// 时间差值，暂时设置为0，单位：微秒
static int delta_time = 0;

/** @fn : start_timer
  * @brief : 启动计时器
  * @param *ptimer_handle : 时间结构体
  * @return : None
*/
static void start_timer(struct timeval *ptimer_handle)
{
	struct timeval *pstart_timeval = ptimer_handle;

	gettimeofday(pstart_timeval, NULL);

#if LOG_TIME
	PERFLOG("timeVal.sec %ld\n", pstart_timeval->tv_sec);
	PERFLOG("timeVal.usec %ld\n", pstart_timeval->tv_usec);
#endif
}

/** @fn : diff_time
  * @brief : 计算两个时间差值
  * @param *ptime_start : 开始时间
  * @param *ptime_end : 结束时间
  * @return : 时间差值, 单位：微秒
*/
static long diff_time(struct timeval *ptime_start,
		      struct timeval *ptime_end)
{
	return ((ptime_end->tv_sec - ptime_start->tv_sec) * 1000000u
		+ ptime_end->tv_usec - ptime_start->tv_usec);
}

/** @fn : elapsed_time
  * @brief : 计算经过的时间
  * @param *ptime_start : 开始时间
  * @param *ptime_end : 结束时间
  * @return : 经过的时间，单位：微秒
*/
static long elapsed_time(struct timeval *ptime_start,
			 struct timeval *ptime_end)
{
	return (diff_time(ptime_start, ptime_end) - delta_time);
}

/** @fn : stop_timer
  * @brief : 停止计时器
  * @param *ptimer_handle : 开始的时间
  * @return : 经过的时间, 单位：微秒
*/
static unsigned long stop_timer(struct timeval *ptimer_handle)
{
	struct timeval *pstart_timeval = ptimer_handle;
	struct timeval stop_time_val;
	gettimeofday(&stop_time_val, NULL);

#if LOG_TIME
	PERFLOG("timeVal.sec %ld\n", stop_time_val.tv_sec);
	PERFLOG("timeVal.usec %ld\n", stop_time_val.tv_usec);
#endif
	return ((unsigned long)elapsed_time(pstart_timeval, &stop_time_val));
}

/** @fn : init_timer_module
  * @brief : 初始化定时器
  * @param : None
  * @return : None
*/
static void init_timer_module(void)
{
	struct timeval start_time;
	struct timeval end_time;
	int i = 0;

	// 已经检验过
	if (0 != delta_time)
		return;

	// 计算delta_time
	for (i = 0; i < BASE_NUM_TRIALS; i++) {
		start_timer(&start_time);
		start_timer(&end_time);

		delta_time += diff_time(&start_time, &end_time);
	}

	delta_time = delta_time / BASE_NUM_TRIALS;
}

/** @fn : read_test
  * @brief : 读测试
  * @param totalsize : 读写总大小，单位：字节（Byte）
  * @param buff_size : buff大小，单位：字节（Byte）
  * @param is_check : [0]: 不检查数据一致性，[1]: 检查数据一致性
  * @return : 测试结果
*/
static int read_test(int totalsize, int buff_size, int is_check)
{
	int fdes = 0;
	int result = SUCCESS;
	int res_close = SUCCESS;
	unsigned char *buff_ptr = NULL;
	char *file_ptr = NULL;
	unsigned int i = 0;
	int read_ret = 0;
	int loopcount = 0;
	int remainder = 0;
	int totbytread = 0;
	struct timeval start_time;
	unsigned long elapsed_usecs = 0;
        float throughput = 0;
	char file_name[] = BLK_DEV_NAME;

	file_ptr = file_name;

	loopcount = totalsize / buff_size;// 循环次数
	remainder = totalsize % buff_size;// 余数
	// 分配内存
	buff_ptr = (char *)malloc(buff_size * (sizeof(char)));
	if (NULL == buff_ptr) {
		perror("\n malloc");
		result = FAILURE;
		goto end;
	}

	// 打开块设备
	fdes = open((const char *)file_ptr, O_RDONLY);
	if (-1 == fdes) {
		perror("\n open");
		TEST_PRINT_ERR("file open failed ");
		result = FAILURE;
		goto free_mem;
	}

	// 开始记录时间
	start_timer(&start_time);

	for (i = 0; i < loopcount; i++) {
		read_ret = read(fdes, buff_ptr, buff_size);
		totbytread = totbytread + read_ret;
		if (buff_size != read_ret) {
			perror("\n read");
			TEST_PRINT_ERR("file read failed ");
			result = FAILURE;
			goto close_file;
		}
		// 检查数据一致性
		if(is_check)
		{
			for(i = 0; i < buff_size; i++)
			{
				// 数组第0个数据为0，第255个数据为255, 第256个数据为0，第257个数据为1
				if(buff_ptr[i] != (i & 0xff))
				{
					TEST_PRINT_ERR("data wrong,i=%d,data=%d", i, buff_ptr[i]);
					result = FAILURE;
					goto close_file;
				}
			}
		}
	}

	// 最后一次读取
	if (remainder) {
		read_ret = read(fdes, buff_ptr+buff_size-remainder, remainder);
		totbytread = totbytread + read_ret;
		if (remainder != read_ret) {
			perror("\n read");
			TEST_PRINT_ERR("file read failed ");
			result = FAILURE;
			goto close_file;
		}
		// 检查数据一致性
		if(is_check)
		{
			for(i = buff_size-remainder; i < buff_size; i++)
			{
				// 数组第0个数据为0，第255个数据为255, 第256个数据为0，第257个数据为1
				if(buff_ptr[i] != (i & 0xff))
				{
					TEST_PRINT_ERR("data wrong");
					result = FAILURE;
					goto close_file;
				}
			}
		}
	}
close_file:
	res_close = fsync(fdes);
	if (-1 == res_close) {
		perror("\n fsync");
		TEST_PRINT_ERR("file fsync failed ");
		result = FAILURE;
	}

	// 停止计时
	elapsed_usecs = stop_timer(&start_time);

	if (result == SUCCESS) 
	{
		// 计算速率
		throughput = (float)(((float)totalsize / (float)elapsed_usecs));
		//TEST_PRINT_TRC("fileread | Durartion in usecs | %ld, totalsize:%d", elapsed_usecs, totalsize);
		if(is_check)
		{
			TEST_PRINT_TRC("读写数据一致性测试通过");
		}
		else
		{
			TEST_PRINT_TRC("读数据速率 %lf Mega Bytes/Sec",throughput);
		}
	}
	res_close = close(fdes);
	if (-1 == res_close) {
		perror("\n close");
		TEST_PRINT_ERR("file close failed ");
		result = FAILURE;
	}

free_mem:
	// 释放数组
	if (NULL != buff_ptr) {
		free(buff_ptr);
	}

end:
	return result;
}

/** @fn : write_test
  * @brief : 写测试
  * @param totalsize : 读写总大小，单位：字节（Byte）
  * @param buff_size : buff大小，单位：字节（Byte）
  * @param is_check : [0]: 不检查数据一致性，[1]: 检查数据一致性
  * @return : 测试结果
*/
static int write_test(int totalsize, int buff_size, int is_check)
{
	int fdes = 0;
	int srcfdes = 0;
	unsigned char *buff_ptr = NULL;
        char *srcfile_ptr = NULL;
	char *file_ptr = NULL;
	int result = SUCCESS;
	int res_close = SUCCESS;
	int read_ret = 0;
	int write_ret = 0;
	unsigned int i = 0;
	int loopcount = 0;
	int remainder = 0;
	int totbytwrite = 0;
	struct timeval start_time;
	unsigned long elapsed_usecs = 0;
	float throughput = 0;
	char file_name[] = BLK_DEV_NAME;

	file_ptr = file_name;

	loopcount = totalsize / buff_size;
	remainder = totalsize % buff_size;
	// 分配内存
	buff_ptr = (char *)malloc(buff_size * (sizeof(char)));
	if (NULL == buff_ptr) {
		perror("\n malloc");
		result = FAILURE;
		goto end;
	}

	// 给数组赋值，0～255循环
	for(i = 0; i < buff_size * (sizeof(char)); i++)
	{
		buff_ptr[i] = i & 0xff;
	}

	// 打开块文件
	fdes = open((const char *)file_ptr, O_WRONLY);
	if (-1 == fdes) {
		perror("\n open");
		TEST_PRINT_ERR("file open failed ");
		result = FAILURE;
		goto free_mem;

	}

	// 开始计时
	start_timer(&start_time);

	//lseek(fdes, 2 * 1024 * 1024, SEEK_SET);
	for (i = 0; i < loopcount; i++) {
		write_ret = write(fdes, buff_ptr, buff_size);
		totbytwrite = totbytwrite + write_ret;
		if (buff_size != write_ret) {
			perror("\n write");
			TEST_PRINT_ERR("file write failed,write_ret:%d,seq:%d", write_ret, i);
			result = FAILURE;
			goto close_file;

		}
	}

	// 最后一次写
	if (remainder) {
		write_ret = write(fdes, buff_ptr+buff_size-remainder, remainder);
		totbytwrite = totbytwrite + write_ret;
		if (remainder != write_ret) {
			perror("\n write");
			TEST_PRINT_ERR("file write failed ");
			result = FAILURE;
			goto close_file;

		}
	}
close_file:
	res_close = fsync(fdes);
	if (-1 == res_close) {
		perror("\n fsynce");
		TEST_PRINT_ERR("file fsync failed ");
		result = FAILURE;

	}
	// 停止计时
	elapsed_usecs = stop_timer(&start_time);

	if (result == SUCCESS) {
		// 计算速率
		throughput = (float)(((float)totalsize / (float)elapsed_usecs));
		//TEST_PRINT_TRC("fileread | Durartion in usecs | %ld, totalsize:%d", elapsed_usecs, totalsize);
		if(!is_check)
		{
			TEST_PRINT_TRC("写数据速率 %lf Mega Bytes/Sec",throughput);
		}
	}

	res_close = close(fdes);
	if (-1 == res_close) {
		perror("\n close");
		TEST_PRINT_ERR("file close failed ");
		result = FAILURE;

	}

free_mem:
	// 释放数组
	if (NULL != buff_ptr) {
		free(buff_ptr);
	}

end:

	return result;
}

/** @fn : *thread_read
  * @brief : 读数据线程
  * @param *arg : 参数
  * @return : None
*/
static void *thread_read(void *arg)
{
	if(SUCCESS != read_test(TOTAL_SIZE_DEFALT, TOTAL_SIZE_DEFALT, 0))// 不检查数据一致性
	{
		TEST_PRINT_ERR("thread read error");
		exit(FAILURE);
	}
}

/** @fn : *thread_write
  * @brief : 写数据线程
  * @param *arg : 参数
  * @return : None
*/
static void *thread_write(void *arg)
{
	if(SUCCESS != write_test(TOTAL_SIZE_DEFALT, TOTAL_SIZE_DEFALT, 0))// 不检查数据一致性
	{
		TEST_PRINT_ERR("thread write error");
		exit(FAILURE);
	}
}

/** @fn : speed_test
  * @brief : 速度测试
  * @param thread_num : 线程个数
  * @return : 测试结果 
*/
static int speed_test(int thread_num)
{
	int res, i;
	pthread_t *thread_arr = (pthread_t *)malloc(thread_num * sizeof(pthread_t));
	TEST_PRINT_TRC("%d个线程同时读速度测试：", thread_num);
	// 多个线程同时读
	for(i = 0; i < thread_num; i++)
	{
		res = pthread_create(&thread_arr[i], NULL, thread_read, NULL);
		if(0 != res)
		{
			TEST_PRINT_ERR("create thread %d error", i);
			exit(FAILURE);
		}
	}
	// 等待所有线程执行完
	for(i = 0; i < thread_num; i++)
	{
		res = pthread_join(thread_arr[i], NULL);
		if(0 != res)
		{
			TEST_PRINT_ERR("join thread %d error", i);
			exit(FAILURE);
		}
	}
	// 多个线程同时写
	TEST_PRINT_TRC("%d个线程同时写速度测试：", thread_num);
	for(i = 0; i < thread_num; i++)
	{
		res = pthread_create(&thread_arr[i], NULL, thread_write, NULL);
		if(0 != res)
		{
			TEST_PRINT_ERR("create thread %d error", i);
			exit(FAILURE);
		}
	}
	// 等待所有线程执行完
	for(i = 0; i < thread_num; i++)
	{
		res = pthread_join(thread_arr[i], NULL);
		if(0 != res)
		{
			TEST_PRINT_ERR("join thread %d error", i);
			exit(FAILURE);
		}
	}
	free(thread_arr);
	return SUCCESS;
}

/** @fn : check_test
  * @brief : 数据一致性测试 
  * @param : None
  * @return : 测试结果
*/
static int check_test(void)
{
	if(SUCCESS != write_test(TOTAL_SIZE_DEFALT, TOTAL_SIZE_DEFALT, 1))// 检查数据一致性
	{
		return FAILURE;
	}
	if(SUCCESS != read_test(TOTAL_SIZE_DEFALT, TOTAL_SIZE_DEFALT, 1))// 检查数据一致性
	{
		return FAILURE;
	}
	return SUCCESS;
}

/** @fn : main
  * @brief : 程序入口
  * @param argc : 变量个数
  * @param **argv : 变量数组
  * @return : 程序执行结果
*/
int main(int argc, char **argv)
{
	int i;
	init_timer_module();
	// 多个线程读写速率测试
	for(i = 1; i <= 10; i++)
	{
		if(SUCCESS != speed_test(i))
		{
			return FAILURE;
		}
	}
	// 读写数据一致性测试
	if(SUCCESS != check_test())
	{
		return FAILURE;
	}
	return SUCCESS;
}
