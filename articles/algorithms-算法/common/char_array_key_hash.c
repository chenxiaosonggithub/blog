#include <stdio.h>
#include <stdbool.h>
#include "uthash.h" // https://github.com/troydhanson/uthash.git

// 参考： https://troydhanson.github.io/uthash/

struct my_struct {
	char m_key[100];
	int val;
	UT_hash_handle hh;
};

struct my_struct *hash_table;

struct my_struct *find(char *key)
{
	struct my_struct *tmp;
	HASH_FIND_STR(hash_table, key, tmp);
	return tmp;
}

void insert(char *key, int val)
{
	struct my_struct *t = find(key);
	if (t == NULL) {
		struct my_struct *it = malloc(sizeof(struct my_struct));
		strcpy(it->m_key, key);
		it->val = val;
		HASH_ADD_STR(hash_table, m_key, it);
	} else {
		t->val = val;
	}
}

void delete(char *key)
{
	struct my_struct *t = find(key);
	if (t) {
		HASH_DEL(hash_table, t);
	}
}

int main()
{
	struct my_struct *t;
	struct my_struct *current, *tmp;
	hash_table = NULL;
	insert("hello", 10);
	t = find("hello");
	if (t)
		printf("find key:hello,val:%d\n", t->val);

	HASH_ITER(hh, hash_table, current, tmp) {
		HASH_DEL(hash_table, current);
		free(current);
	}

}
