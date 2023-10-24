/**  @file : cut_rod_bottom_up.c
  *  @note : 
  *  @brief : 自底向上法钢条切割
  *
  *  @author : 陈孝松
  *  @date : 2021.04.21 21:33
  *
  *  @note : 
  *  @record : 
  *       2021.04.21 21:33 created
  *
  *  @warning : 
*/
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <limits.h>

/** @fn : bottom_up_cut_rod
  * @brief : 自底向上切割钢条
  * @param *p : 价格数组
  * @param n : 长度
  * @return : 最高能卖的钱
*/
static int bottom_up_cut_rod(int *p, int n)
{
    int ret = 0;
    int *r = (int *)malloc(sizeof(int) * (n+1));
    r[0] = 0;
    for(int i = 1; i <= n; i++)
    {
        int res = INT_MIN;
        for(int j = 1; j <= i; j++)
        {
            int tmp = p[j] + r[i-j];
            if(tmp > res)
            {
                res = tmp;
            }
        }
        r[i] = res;
    }
    ret = r[n];
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
        int res = bottom_up_cut_rod(array, i);
        printf("\n\r长度为%d的钢条切割后能卖的最多钱: %d\n\r", i, res);
    }
    printf("\n\r");
    return 0;
}

