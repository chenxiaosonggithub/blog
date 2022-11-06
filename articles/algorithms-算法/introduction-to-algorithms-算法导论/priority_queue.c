/**  @file : heap-sort.c
  *  @note : 
  *  @brief : 优先队列
  *
  *  @author : 陈孝松
  *  @date : 2021.11.17 22:47
  *
  *  @note : 
  *  @record : 
  *       2021.11.17 22:47 created
  *
  *  @warning : 
*/
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <limits.h>

#define ARRAY_MAX_LENGTH	100

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

static int top(int *array)
{
	return array[0];
}

static void push(int *array, int *size, int x)
{
	int i;
	array[*size] = x;
	(*size)++;
	i = (*size) - 1;
	while (i > 0 && array[parent(i)] < array[i]) {
		swap(&array[parent(i)], &array[i]);
		i = parent(i);
	}
}

static void pop(int *array, int *size)
{
	array[0] = array[(*size)-1]; // 把最后一个数 放到第一个
	*size = (*size)-1;
	max_heapify(array, *size, 0);
}

static void print(int *array, int size)
{
	printf("\n\r");
	for(int i = 0; i < size; i++)
	{
		printf(" %d", array[i]);
	}
	printf("\n\r");
}

/** @fn : main
  * @brief : 程序入口
  * @param argc : 变量个数
  * @param **argv : 变量数组
  * @return : 程序执行结果
*/
int main(int argc, char **argv)
{
	int array[ARRAY_MAX_LENGTH] = {4, 7, 8, 6};
	int size = 4;

	max_heapify(array, size, 0);
	print(array, size);

	push(array, &size, 9);
	print(array, size);

	push(array, &size, 3);
	print(array, size);

	pop(array, &size);
	print(array, size);

	pop(array, &size);
	print(array, size);

	return 0;
}
