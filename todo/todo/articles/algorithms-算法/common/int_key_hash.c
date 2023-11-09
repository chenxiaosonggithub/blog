#include <stdio.h>
#include <stdbool.h>
#include "uthash.h" // https://github.com/troydhanson/uthash.git

// 参考： https://troydhanson.github.io/uthash/

struct my_struct {
	int m_key; // 元素的值
	int val; // idx
	UT_hash_handle hh;
};

struct my_struct *hash_table;

struct my_struct *find(int key)
{
	struct my_struct *tmp;
	HASH_FIND_INT(hash_table, &key, tmp);
	return tmp;
}

void insert(int key, int val)
{
	struct my_struct *t = find(key);
	if (t == NULL) {
		struct my_struct *it = malloc(sizeof(struct my_struct));
		it->m_key = key;
		it->val = val;
		HASH_ADD_INT(hash_table, m_key, it);
	} else {
		t->val = val;
	}
}

void delete(int key)
{
	struct my_struct *t = find(key);
	if (t) {
		HASH_DEL(hash_table, t);
	}
}

int main()
{
	struct my_struct *t;
	hash_table = NULL;
	insert(5, 10);
	t = find(5);
	if (t)
		printf("find key:5,val:%d\n", t->val);
}

// 两数之和题目： https://leetcode-cn.com/problems/two-sum/
int *twoSum(int *nums, int numSize, int target, int *returnSize)
{
	hash_table = NULL; // 一定要初始化为 NULL
	for (int i = 0; i < numSize; i++) {
		struct my_struct *t = find(target-nums[i]);
		if (t) {
			int *ret = malloc(sizeof(int) * 2);
			ret[0] = t->val;
			ret[1] = i;
			*returnSize = 2;
			return ret;
		}
		insert(nums[i], i);
	}
	*returnSize = 0;
	return NULL;
}

// https://leetcode-cn.com/problems/contains-duplicate-ii/
bool containsNearbyDuplicate(int* nums, int numsSize, int k)
{
	hash_table = NULL;
	for (int i = 0; i < numsSize; i++) {
		struct my_struct *t = find(nums[i]);
		if (t)
			return true;
		insert(nums[i], i);
		if (i >= k)
			delete(nums[i-k]);
	}
	return false;
}
