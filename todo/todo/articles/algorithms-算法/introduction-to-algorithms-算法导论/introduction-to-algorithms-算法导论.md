[toc]

本文章是《算法导论 原书第3版 -- 机械工业出版社》算法的C语言实现。

本文所有的算法都未编写完整的测试用例，仅供参考，不能直接用于产品代码中。

注意：还未全部完成，更新中。。。

# 快速排序

第95页

时间复杂度O(nlgn)，空间复杂度O(lgn)。

完整代码：[quik-sort.c](./quick-sort.c)

核心函数：

```c
static int rand_range(int min, int max)
{
    return rand() % (max - min + 1) + min;
}

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
```

# 归并排序

第17页。

时间复杂度O(nlgn)，空间复杂度O(n)。

完整代码：[merge-sort.c](./merge-sort.c)。

核心函数：

```c
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
```

# 堆排序

第84页。

时间复杂度O(nlgn)，空间复杂度O(1)。

完整代码：[heap-sort.c](./heap-sort.c)。

核心函数：

```c
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
```

# 动态规划-钢条切割

第204页。

两种思路：

带备忘的自顶向下法（top-down with memoization）完整代码：[cut_rod_memoized.c](./cut_rod_memoized.c)。

核心函数：

```c
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
```

自底向上法（bottom-up method）完整代码：[cut_rod_bottom_up.c](./cut_rod_bottom_up.c)。

核心代码：

```c
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
```

