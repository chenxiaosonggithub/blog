/**  @file : quick-sort.c
  *  @note : 
  *  @brief : 快速排序
  *
  *  @author : 陈孝松
  *  @date : 2021.04.21 18:07
  *
  *  @note : 
  *  @record : 
  *       2021.04.21 18:07 created
  *
  *  @warning : 
*/
#include <stdio.h>
#include <stdlib.h>

/** @fn : swap
  * @brief : 交换两个数
  * @param *a : 第一个数指针
  * @param *b : 第二个数指针
  * @return : None
*/
static void swap(int *a, int *b)
{
    int tmp = *a;
    *a = *b;
    *b = tmp;
}

/** @fn : rand_range
  * @brief : 获取随机值
  * @param min : 最小值
  * @param max : 最大值
  * @return : 随机值
*/
static int rand_range(int min, int max)
{
    return rand() % (max - min + 1) + min;
}

/** @fn : partition
  * @brief : 把数组划分为两个部分
  * @param *array : 数组
  * @param start : 开始的下标
  * @param end : 结束的下标
  * @return : 中间的下标
*/
static int partition(int *array, int start, int end)
{
    int rand_idx = rand_range(start, end);
    swap(&array[rand_idx], &array[end]);
    int left = start;
    for(int right = start; right < end; right++)
    {
        if(array[right] < array[end])
        {
            swap(&array[left], &array[right]);
            left++;
        }
    }
    swap(&array[end], &array[left]);
    return left;
}

/** @fn : quiksort
  * @brief : 快速排序
  * @param *array : 数组
  * @param start : 开始的下标
  * @param end : 结束的下标
  * @return : None
*/
static void quiksort(int *array, int start, int end)
{
    int mid = 0;
    if(start < end)
    {
        mid = partition(array, start, end);
        quiksort(array, start, mid);
        quiksort(array, mid+1, end);
    }
}

/** @fn : main
  * @brief : 程序入口
  * @param argc : 变量个数
  * @param **argv : 变量数组
  * @return : 程序执行结果
*/
int main(int argc, char **argv)
{
    int array[] = {5, 8, 6, 7, 3, 4, 2, 1};
    int len = sizeof(array)/sizeof(array[0]);
    quiksort(array, 0, len - 1);
    printf("\n\r");
    for(int i = 0; i < len; i++)
    {
        printf(" %d", array[i]);
    }
    printf("\n\r");
    return 0;
}
