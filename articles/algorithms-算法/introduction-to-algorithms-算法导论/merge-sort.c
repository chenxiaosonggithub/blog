/**  @file : merge-sort.c
  *  @note : 
  *  @brief : 归并排序
  *
  *  @author : 陈孝松
  *  @date : 2021.04.21 18:19
  *
  *  @note : 
  *  @record : 
  *	   2021.04.21 18:19 created
  *
  *  @warning : 
*/
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <limits.h>

/** @fn : merge
  * @brief : 合并数组
  * @param *array : 数组
  * @param start : 开始的下标
  * @param end : 结束的下标
  * @return : None
*/
static void merge(int *array, int start, int mid, int end)
{
	// 左边的数组包含下标mid
	int l_len = mid - start + 1;
	int r_len = end - mid;
	int *l_array = NULL;
	int *r_array = NULL;
	l_array = (int *)malloc(sizeof(int) * (l_len+1));
	r_array = (int *)malloc(sizeof(int) * (r_len+1));

	// 哨兵
	l_array[l_len] = INT_MAX;
	r_array[r_len] = INT_MAX;
	for(int i = 0; i < l_len; i++)
	{
		l_array[i] = array[start+i];
	}
	for(int i = 0; i < r_len; i++)
	{
		r_array[i] = array[mid+i+1];
	}

	int i = 0, j = 0;
	for(int k = start; k <= end; k++)
	{
		if(l_array[i] <= r_array[j])
		{
			array[k] = l_array[i];
			i++;
		}
		else
		{
			array[k] = r_array[j];
			j++;
		}
	}
	
	free(l_array);
	free(r_array);
}

/** @fn : mergesort
  * @brief : 归并排序
  * @param *array : 数组
  * @param start : 开始的下标
  * @param end : 结束的下标
  * @return : None
*/
static void mergesort(int *array, int start, int end)
{
	int mid = 0;
	if(start < end)
	{
		mid = (int)((start + end) / 2);
		mergesort(array, start, mid);// 包含mid下标
		mergesort(array, mid+1, end);
		merge(array, start, mid, end);
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
	mergesort(array, 0, len - 1);
	printf("\n\r");
	for(int i = 0; i < len; i++)
	{
		printf(" %d", array[i]);
	}
	printf("\n\r");
	return 0;
}
