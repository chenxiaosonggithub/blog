#include "stdio.h"
#include "string.h"

#define NAX_LEMGTH 10

static char visited[NAX_LEMGTH] ;
static int  result[NAX_LEMGTH];

int zuhe_cnt(int N, int M)
{
	if (M == 0)
		return 1;
	if (N == M)
		return 1;
	return zuhe_cnt(N - 1, M - 1) + zuhe_cnt(N - 1, M);
}

int pailie_cnt(int N,int M)
{
	if (M == 1)
		return N;
	return pailie_cnt(N - 1, M - 1) * N;
 
}

void pailie(int *array,int N,int M, int cnt)
{
	if (cnt >= M) {
		for (int i = 0; i < M; i++)
			printf("%d ", result[i]);
		printf("\n");
		return;
	}
	for (int i = 0; i < N; i++) {
		if (visited[i] == 0) {
			visited[i] = 1;
			result[cnt] = array[i];
			cnt++;
			pailie(array, N, M, cnt); // 从未标记过的数中继续选择
			cnt--; // 回溯
			visited[i] = 0;
		}
	}
}

void zuhe(int *array, int N, int M, int cnt, int next_idx)
{
	if (cnt >= M) {
		for (int i = 0; i < M; i++)
			printf("%d ", result[i]);
		printf("\n");
		return;
	}
	for (int i = next_idx; i < N; i++) {
		result[cnt] = array[i];
		cnt++;
		zuhe(array, N, M, cnt, i + 1);
		cnt--; // 回溯
	}
}
 
void main()
{
	int array[5] = {1, 2, 3, 4, 5};
	memset(visited, 0, sizeof(visited));

	printf("排列结果个数(5,3)：%d\n", pailie_cnt(5, 3));
	printf("排列结果(5,3)：\n");
	pailie(array, 5, 3, 0);
	printf("\n");
 
	printf("组合结果个数(5,3)：%d\n", zuhe_cnt(5, 3));
	printf("组合结果(5,3)：\n");
	zuhe(array, 5, 3, 0, 0);
	printf("\n");
	 
}
