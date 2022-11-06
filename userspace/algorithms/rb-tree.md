[toc]

[rb-tree.odg](http://47.97.36.184/pictures/rb-tree.odg)

# insert

```c
// z 一定是红
rb_insert_fixup(T, z)
{
	// 父结点是红
	while (z.parent.color == RED) {
		if (z.parent == z.parent.parent.left) {
			y = z.parent.parent.right // 叔结点
			// 情况1：叔结点y是红
			if (y.color == RED) {
				// 叔结点和父结点设成黑，祖父结点设成红
				z.parent.color = BLACK
				y.color = BLACK
				z.parent.parent.color = RED
				z = z.parent.parent // 新的z
			} else {
				// 情况2：叔结点y是黑，z是右孩子
				if (z = z.parent.right) {
					z = z.parent // 父结点作为新的z
					left_rotate(T, z) // 变成情况3
				}
				// 情况3：叔结点y是黑，z是左孩子
				// 交换 父结点 和 祖父结点 的颜色
				z.parent.color = BLACK
				z.parent.parent.color = RED
				right_rotate(T, z.parent.parent) // 祖父结点 右旋
			}
		} else {
			// left 和 right 交换
		}
	}
}
```

# delete

```c
rb_delete(T, z)
{
	y = z
	y_original_color = y.color
	if (z.left == T.nil) {
		x = z.right
		rb_transplant(T, z, x)
	} else if (z.right == T.nil) {
		x = z.left
		rb_transplant(T, z, x)
	} else {
		y = tree_minimum(z.right)
		y_original_color = y.color
		x = y.right
		if (y.parent == z) {
			x.parent = y // 好像不需要这一句
		} else {
			rb_transplant(T, y, x)
			y.right = z.right
			y.right.parent = y
		}
		rb_transplant(T, z, y)
		y.left = z.left
		y.left.parent = y
		y.color = z.color // 被删除的结点的颜色
	}

	if (y_original_color == BLACK)
		rb_delete_fixup(T, x)
}

rb_delete_fixup(T, x)
{
	while (x != T.root && x.color == BLACK) {
		if (x == x.parent.left) {
			w = x.parent.right // w为兄弟结点
			// 情况1：兄弟结点w为红色
			if (w.color == RED) {
				w.color = BLACK // 兄弟结点设成黑色
				x.parent.color = RED // 父结点设成红色
				left_rotate(T, x.parent) // 对父结点进行左旋
				w = x.parent.right // 新的兄弟结点
			}
			// 情况2：兄弟结点w为黑色(情况1处理过)，w的2个孩子都是黑色
			if (w.left.color == BLACK && w.right.color == BLACK) {
				w.color = RED // 兄弟结点设成红
				x = x.parent // 父结点为x
			} else {
				// 情况3：兄弟结点w为黑（情况1处理过），w左孩子红，w右孩子黑
				if (w.right.color == BLACK) {
					// 交换 w左孩子 和 兄弟结点 的颜色
					w.left.color = BLACK // w左孩子设成黑
					w.color = RED // 兄弟结点设成红
					right_rotate(T, w) // 对兄弟结点进行右旋
					w = x.parent.right // 新的兄弟结点
				}
				// 情况4：兄弟结点w为黑（情况1处理过），w右孩子红(情况3处理过)
				w.color = x.parent.color // 兄弟结点设成父结点的颜色
				x.parent.color = BLACK // 父结点设成黑
				w.right.color = BLACK // w右孩子设成黑
				left_rotate(T, x.parent) // 对父结点左旋
				x = T.root // 结束循环, 注意后面把root结点设成黑
			}
		} else {
			// left 和 right 交换
		}
	}
	x.color = BLACK
}
```
