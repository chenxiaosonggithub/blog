/**  @file : cut_rod_memoized.c
  *  @note : 
  *  @brief : 带备忘的自顶向下法钢条切割
  *
  *  @author : 陈孝松
  *  @date : 2021.04.21 20:50
  *
  *  @note : 
  *  @record : 
  *       2021.04.21 20:50 created
  *
  *  @warning : 
*/
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <limits.h>

/** @fn : memoized_cut_rod_aux
  * @brief : 递归切割钢条
  * @param *p : 价格数组
  * @param n : 长度
  * @param *r : 备忘数组
  * @return : 最高能卖的钱
*/
static int memoized_cut_rod_aux(int *p, int n, int *r)
{
    int ret = r[n];
    if(r[n] >= 0)
    {
        return r[n];
    }
    if(0 == n)
    {
        ret = 0;
    }
    else
    {
        ret = INT_MIN;
        for(int i = 1; i <= n; i++)
        {
            int tmp = p[i] + memoized_cut_rod_aux(p, n-i, r);
            if(tmp > ret)
            {
                ret = tmp;
            }
        }
    }
    r[n] = ret;
    return ret;
}

/** @fn : memoized_cut_rod
  * @brief : 带备忘的切割钢条
  * @param *p : 价格数组
  * @param n : 长度
  * @return : 最高能卖的钱
*/
static int memoized_cut_rod(int *p, int n)
{
    int ret = 0;
    int *r = (int *)malloc(sizeof(int) * (n+1));
    for(int i = 0; i <= n; i++)
    {
        r[i] = INT_MIN;
    }
    ret = memoized_cut_rod_aux(p, n, r);
    free(r);
    return ret;
}

/** @fn : main
  * @brief : 程序入口
  * @param argc : 变量个数
  * @param **argv : 变量数组
  * @return : 程序执行结果
*/
int main(int argc, char **argv)
{
    // 长度为1价格1，长度为2价格5。。。
    int array[] = {0, 1, 5, 8, 9, 10, 17, 17, 20, 24, 30};
    int len = sizeof(array)/sizeof(array[0]);
    printf("\n\r");
    for(int i = 1; i < len; i++)
    {
        int res = memoized_cut_rod(array, i);
        printf("\n\r长度为%d的钢条切割后能卖的最多钱: %d\n\r", i, res);
    }
    printf("\n\r");
    return 0;
}

