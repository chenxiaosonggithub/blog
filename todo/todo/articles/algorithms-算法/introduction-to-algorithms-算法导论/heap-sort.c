/**  @file : heap-sort.c
  *  @note : 
  *  @brief : 堆排序
  *
  *  @author : 陈孝松
  *  @date : 2021.04.21 19:54
  *
  *  @note : 
  *  @record : 
  *       2021.04.21 19:54 created
  *
  *  @warning : 
*/
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <limits.h>

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

/** @fn : parent
  * @brief : 父结点
  * @param i : 下标
  * @return : 父结点的下标
*/
static int parent(int i)
{
	return (int)((i-1)/2);
}

/** @fn : left
  * @brief : 左孩子
  * @param i : 下标
  * @return : 左孩子的下标
*/
static int left(int i)
{
	return 2*i+1;
}

/** @fn : right
  * @brief : 右孩子
  * @param i : 下标
  * @return : 右孩子的下标
*/
static int right(int i)
{
	return 2*i+2;
}

/** @fn : max_heapify
  * @brief : 维护最大堆
  * @param *array : 数组
  * @param heap_size : 堆的大小
  * @param i : 根节点的下标
  * @return : None
*/
static void max_heapify(int *array, int heap_size, int i)
{
	int l = left(i);
	int r = right(i);
	int largest = i;
	if(l < heap_size && array[l] > array[i])
	{
		largest = l;
	}
	if(r < heap_size && array[r] > array[largest])
	{
		largest = r;
	}
	if(i != largest)
	{
		swap(&array[i], &array[largest]);
		max_heapify(array, heap_size, largest);
	}
}

/** @fn : build_max_heap
  * @brief : 建最大堆
  * @param *array : 数组
  * @param size : 数组大小
  * @return : None
*/
static void build_max_heap(int *array, int size)
{
	int heap_size = size;
	for(int i = parent(size); i >= 0; i--)
	{
		max_heapify(array, heap_size, i);
	}
}

/** @fn : heapsort
  * @brief : 堆排序
  * @param *array : 数组
  * @param size : 数组大小
  * @return : None
*/
static void heapsort(int *array, int size)
{
	int heap_size = size;
	build_max_heap(array, size);
	for(int i = size-1; i >= 1; i--)
	{
		swap(&array[0], &array[i]);
		heap_size--;
		max_heapify(array, heap_size, 0);
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
	heapsort(array, len);
	printf("\n\r");
	for(int i = 0; i < len; i++)
	{
		printf(" %d", array[i]);
	}
	printf("\n\r");
	return 0;
}
