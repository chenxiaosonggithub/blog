# 打怪

从左到右打怪，初始状态每只怪物1点血。怪物两种类型：1型和0型怪物。1型怪物被打时，右边的所有0型怪物都加1点血。一次攻击会使怪物少1点血。

请问杀死所有怪物要多少次攻击？

输入描述：

> 输入第一行包含一个正整数n，怪物的个数。（1 <= n <= 100000)
>
> 输入第二行包含n个数，怪物的种类，0或1.

输出描述：

> 一个整数，攻击次数。

示例：

> 输入：
>
> ​	4
>
> ​	0 1 0 1
>
> 输出：
>
> ​	5

```c
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv)
{
	int res = 0;
	int cnt = 0;
	int type_one_cnt = 0;
	int *array = NULL;
	int i;

	scanf("%d", &cnt);
	array = malloc(sizeof(*array) * cnt);
	for (i = 0; i < cnt; i++) {
		scanf("%d", &array[i]);
		if (1 == array[i]) {
			type_one_cnt++;
			res++;
		} else {
			res += (1+type_one_cnt);
		}
	}
	printf("%d", res);
	printf("\n\r");
	
	return 0;
}
```

# 递归洗牌

如果只有两张牌，交换位置。

如果有2^k张牌，分2堆，每堆2^(k-1)张，递归对两堆进行洗牌，然后将后一堆放在前一堆前面，则一轮洗牌完成。

现在桌子有2^n张牌，进行t轮洗牌后，这些牌的顺序？

输入描述：

> 第一行两个整数n和t。1 <= n <= 12，1 <= t <= 10^9
>
> 第二行包含2^n个整数a[i]，表示初始时牌的数字。1 <= a[i] <= 10^9

输出描述：

> t轮洗牌后，牌的顺序。

示例：

> 输入：
>
> ​	2 1
>
> ​	2 4 1 5
>
> 输出：
>
> ​	5 1 4 2

```c
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

static void swap(int *a, int *b)
{
	int tmp = *a;
	*a = *b;
	*b = tmp;
}

static void merge(int *array, int start, int mid, int end)
{
	for (int i = start; i <= mid; i++) {
		swap(&array[i], &array[i+mid+1]);
	}
}

static void swap_arr(int *array, int start, int mid, int end)
{
	if (1 == (end - start)) {
		swap(&array[start], &array[end]);
		return;
	}
	swap_arr(array, start, (mid-start)/2, mid);
	swap_arr(array, mid+1, (end-mid-1)/2, end);
	merge(array, start, mid, end);
}

static int core(int *array, int start, int mid, int end, int t)
{
	for (int i = 0; i < t; i++) {
		swap_arr(array, start, mid, end);
	}
}

int main()
{
	int order = 0;
	int t = 0;
	int cnt = 0;
	int *array = NULL;
	scanf("%d %d", &order, &t);
	cnt = pow(2, order);
	array = malloc(sizeof(*array)*cnt);
	for (int i = 0; i < cnt; i++) {
		scanf("%d", &array[i]);
	}
	//for (int i = 0; i < cnt; i++) {
	//	printf("%d ", array[i]);
	//}
	//printf("\n\r");
	core(array, 0, (cnt-1)/2, cnt-1, t);
	for (int i = 0; i < cnt; i++) {
		printf("%d ", array[i]);
	}
	printf("\n\r");
	
	return 0;
}
```

编译：

```shell
gcc main.c -lm
```

# 华为： 促销

```
价格： prices = {price_0, price_1, price_2, ...}, 数组大小 prices_size, id 为 0 的产品价格为 price_0
促销方案： promotions = {{promotion_00_id, promotion_00_count, promotion_01_id, promotion_01_count, ...}, ...}
           二维数组, 行数 promotions_size, 列数 为 数组 promotions_column_size = {promotion_0_size, promotion_1_size}
折扣： discounts = {discount_0, discount_1, ...}, 个数 promotions_size, 购买 promotion_00_count 个 编号为 promotion_00_id 的产品可减免 discount_0 的钱，折扣可重复
订单： orders = {id_0, count_0, id_1, count_1, ...}, 个数 orders_size, id 为 id_0 的产品购买 count_0 个
```

```c
#include <stdio.h>
#include <math.h>
#include "uthash.h"

struct hash_map {
	int product_id; // 产品 id
	int product_count; // 购买的数量
	UT_hash_handle hh;
};

// 应付的钱 = 原价 - 促销减免的钱
int cal_total_money(int *prices, int prices_size,
                    int **promotions, int promotions_size, int *promotions_column_size,
                    int *discounts,
                    int *orders, int orders_size)
{
	struct hash_map *order_map = NULL;
	struct hash_map *tmp;
	int origin_money = 0; // 原价
	int discount_money = 0; // 促销减免的钱

	for (int i = 0; i < orders_size; i += 2) {
		int product_id = orders[i];
		int product_count = orders[i+1];

		tmp = malloc(sizeof(struct hash_map));
		tmp->product_id = product_id;
		tmp->product_count = product_count;
		HASH_ADD_INT(order_map, product_id, tmp);

		origin_money += prices[product_id] * product_count;
		printf(" + %d*%d", product_count, prices[product_id]);
	}

	for (int i = 0; i < promotions_size; i++) {
		int *promotion = promotions[i];
		int promotion_times = 0; // 享受折扣次数
		for (int j = 0; j < promotions_column_size[i]; j += 2) {
			int promotion_id = promotion[j];
			int promotion_count = promotion[j+1];
			int tmp_times;
			HASH_FIND_INT(order_map, &promotion_id, tmp);
			if (!tmp) {
				// 没购买这个产品，不享受折扣
				promotion_times = 0;
				break;
			}
			tmp_times = tmp->product_count / promotion_count;
			if (promotion_times == 0)
				promotion_times = tmp_times;
			else
				promotion_times = fmin(tmp_times, promotion_times);
		}
		discount_money += discounts[i] * promotion_times;
		printf(" - %d*%d", promotion_times, discounts[i]);
	}
	return origin_money - discount_money;
}

int main(int argc, int **argv)
{
	int res;
	int prices[] = {1, 1, 1, 1};
	int prices_size = sizeof(prices)/sizeof(prices[0]);
	int promotion0[4] = {0, 100}; // 0
	int promotion1[4] = {2, 2, 1, 2}; // 2
	int promotion2[4] = {3, 2}; // 1
	int *promotions[3] = {promotion0, promotion1, promotion2};
	int promotions_size = 3;
	int promotions_column_size[] = {2, 4, 2};
	int discounts[] = {1, 2, 3};
	int orders[] = {2, 4, 1, 5, 3, 2};
	int orders_size = sizeof(orders)/sizeof(orders[0]);

	// 预期结果: + 4*1 + 5*1 + 2*1 - 0*1 - 2*2 - 1*3 = 4
	res = cal_total_money(prices, prices_size, promotions, promotions_size, promotions_column_size, discounts, orders, orders_size);
	printf(" = %d\n", res);
	return 0;
}
```

# 华为: 令牌

```
生成令牌对象： obj = create_system(capacity), 容量为 capacity, 超过容量就丢弃令牌
释放令牌对象： free_system(obj)
添加规则： bool = add_rule(obj, rule_id, start_time, interval, create_num), 在 start_time 时刻添加规则 rule_id, 每隔 interval 时间生成 create_num 个令牌, 返回成功或失败（已存在则添加失败）
删除规则： bool = remove_rule(obj, rule_id, time), 在 time 时刻删除规则 rule_id, 删除前先生成令牌, 返回成功或失败（不存在则删除失败）
传送数据消耗令牌： bool = transfer(obj, time, size), 在 time 时刻消耗 size 个令牌用于传送数据，传送前先生成令牌, 返回成功或失败(令牌数量不足传送失败)
获取令牌数量： token_number = get_token_num(obj, time), 获取 time 时刻的令牌数量

可能的操作为： add_rule, transfer, remove_rule, transfer, add_rule, transfer, get_token_num, 这些操作的时刻都是递增的
```

```c
#include <stdio.h>
#include <math.h>
#include <stdbool.h>
#include "uthash.h"

struct hash_map {
	int rule_id;
	int start_time;
	int interval;
	int create_num;
	UT_hash_handle hh;
};

struct token_system {
	struct hash_map *rules;
	int capacity;
	int time; // 最后一次更新令牌数量的时刻
	int num; // time 时刻的令牌数量
};

struct token_system *create_system(int capacity)
{
	struct token_system *ret = malloc(sizeof(struct token_system));
	ret->rules = NULL;
	ret->capacity = capacity;
	ret->time = 0;
	ret->num = 0;
	return ret;
}

int calc_num(struct hash_map *rule, int time)
{
	if (rule->start_time > time)
		// 还未生成令牌
		return 0;

	return ((time - rule->start_time) / rule->interval + 1) * rule->create_num;
}

// 相对 obj->time 时刻新增的令牌
int get_diff_num(struct token_system *obj, struct hash_map *rule, int time)
{
	return calc_num(rule, time) - calc_num(rule, obj->time);
}

void update_token_num(struct token_system *obj, int time)
{
	struct hash_map *current;
	struct hash_map *tmp;

	if (obj->time == time)
		return;

	HASH_ITER(hh, obj->rules, current, tmp) {
		obj->num += get_diff_num(obj, current, time);
	}
	obj->time = time;
	if (obj->num > obj->capacity)
		obj->num = obj->capacity;
	// printf("\n******num:%d\n", obj->num);
}

bool add_rule(struct token_system *obj, int rule_id, int start_time, int interval, int create_num)
{
	struct hash_map *tmp;
	// printf("\n******add_rule,time:%d\n", start_time);
	HASH_FIND_INT(obj->rules, &rule_id, tmp);
	if (!tmp) {
		tmp = malloc(sizeof(struct hash_map));
		tmp->rule_id = rule_id;
		tmp->start_time = start_time;
		tmp->interval = interval;
		tmp->create_num = create_num;
		HASH_ADD_INT(obj->rules, rule_id, tmp);
		return true;
	}
	return false;
}

bool remove_rule(struct token_system *obj, int rule_id, int time)
{
	struct hash_map *tmp;
	// printf("\n******remove_rule,time:%d\n", time);
	HASH_FIND_INT(obj->rules, &rule_id, tmp);
	if (tmp) {
		update_token_num(obj, time); // 先生成令牌
		HASH_DEL(obj->rules, tmp);
		return true;
	}
	return false;
}

bool transfer(struct token_system *obj, int time, int size)
{
	// printf("\n******transfer %d,time:%d\n", size, time);
	update_token_num(obj, time);
	if (obj->num >= size) {
		obj->num -= size;
		return true;
	}
	return false;
}

int get_token_num(struct token_system *obj, int time)
{
	// printf("\n******get_token_num,time:%d\n", time);
	update_token_num(obj, time);
	return obj->num;
}

void free_system(struct token_system *obj)
{
	struct hash_map *current;
	struct hash_map *tmp;

	HASH_ITER(hh, obj->rules, current, tmp) {
		HASH_DEL(obj->rules, current);
		free(current);
	}
	free(obj);
}

void print_res(bool res)
{
	printf(" %s", res ? "true" : "false");
}

int main(int argc, int **argv)
{
	struct token_system *obj = create_system(8);
	bool res;
	int num;

	/* 预期结果
	time:      0  1  2  3  4  5  6  7  8  9  10
	rule0:        1  1  1  1  1  1  1  1  1  1
	rule1:           3  3  3  3           1  1
	num:       0  1  5  8  6  8  8  8  8  3  5
	transfer:           6              7
	num:                2              1
	print:        t  t  t  6  t  8  f  t  t  5
	*/
	res = add_rule(obj, 0, 1, 1, 1);
	print_res(res);
	res = add_rule(obj, 1, 2, 1, 3);
	print_res(res);
	res = transfer(obj, 3, 6);
	print_res(res);
	num = get_token_num(obj, 4);
	printf(" %d", num);
	res = remove_rule(obj, 1, 5);
	print_res(res);
	num = get_token_num(obj, 6);
	printf(" %d", num);
	res = add_rule(obj, 1, 7, 1, 1);
	print_res(res);
	res = transfer(obj, 8, 7);
	print_res(res);
	res = add_rule(obj, 1, 9, 1, 1);
	print_res(res);
	num = get_token_num(obj, 10);
	printf(" %d", num);
	printf("\n");
	return 0;
}
```
