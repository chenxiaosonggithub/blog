在大厂的笔试中，动态规划属于是常考的一类题，也是很多人比较害怕的题目，就从这种题型开始吧。

# 钢条切割

题目在《算法导论》书中的第204页。下面简单的描述一下题目。

有一根钢条，给出一个价格数组`price[] = {0, 1, 5, 8, 9, 10, 17, 17, 20, 24, 30}`，其中`price[1]`表示长度为`1`的钢条价格为`1`，`price[2]`表示长度为`2`的钢条价格为`5`，求最多能卖多少钱？

- [带备忘的自顶向下法钢条切割](https://gitee.com/chenxiaosonggitee/blog/blob/master/courses/algorithms/src/cut-rod-memoized.c)
- [自底向上法钢条切割](https://gitee.com/chenxiaosonggitee/blog/blob/master/courses/algorithms/src/cut-rod-bottom-up.c)