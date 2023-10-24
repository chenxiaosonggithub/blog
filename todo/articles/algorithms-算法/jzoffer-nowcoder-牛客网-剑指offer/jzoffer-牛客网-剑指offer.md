本文章是牛客网上的[剑指offer](https://www.nowcoder.com/ta/coding-interviews)编程题的答案，因为牛客网提交的答案数据会丢失（发生过很多次），所以还是自己保存一份。

67道题已经全部做完。

# JZ1    二维数组中的查找 	

```c
class Solution {
public:
    bool Find(int target, vector<vector<int> > array) {
        int row_size = array.size();
        int col_size = array[0].size();
        for(int i = 0, j = col_size - 1; i < row_size && j >= 0;)
        {
            if(array[i][j] == target)
            {
                return true;
            }
            else if(array[i][j] > target)
            {
                j--;
                continue;
            }
            else
            {
                i++;
                continue;
            }
        }
        return false;
    }
};
```



#  JZ2 	替换空格

```c
class Solution {
public:
    /**
     * 代码中的类名、方法名、参数名已经指定，请勿修改，直接返回方法规定的值即可
     *
     * 
     * @param s string字符串 
     * @return string字符串
     */
    string replaceSpace(string s) {
        // write code here
        if(s.size() == 0)
            return s;
        int old_len = s.size();
        int new_len = old_len;
        for(int i = 0; i < old_len; i++)
        {
            if(s[i] == ' ')
                new_len += 2;
        }
        s.resize(new_len);
        int old_idx = old_len - 1;
        int new_idx = new_len - 1;
        while(old_idx >= 0 && new_idx > old_idx)
        {
            if(s[old_idx] == ' ')
            {
                s[new_idx--] = '0';
                s[new_idx--] = '2';
                s[new_idx--] = '%';
            }
            else
            {
                s[new_idx--] = s[old_idx];
            }
            old_idx--;
        }
        return s;
    }
};
```

#  JZ3 	从尾到头打印链表

```c
/**
*  struct ListNode {
*        int val;
*        struct ListNode *next;
*        ListNode(int x) :
*              val(x), next(NULL) {
*        }
*  };
*/
class Solution {
public:
    vector<int> printListFromTailToHead(ListNode* head) {
        vector<int> ret;
        stack<int> node_stack;
        while(head)
        {
            node_stack.push(head->val);
            head = head->next;
        }
        while(!node_stack.empty())
        {
            ret.push_back(node_stack.top());
            node_stack.pop();
        }
        return ret;
    }
};
```

#  JZ4 	重建二叉树

```c
/**
 * Definition for binary tree
 * struct TreeNode {
 *     int val;
 *     TreeNode *left;
 *     TreeNode *right;
 *     TreeNode(int x) : val(x), left(NULL), right(NULL) {}
 * };
 */
class Solution {
public:
    TreeNode *constr_core(int *start_pre, int *end_pre, 
                          int *start_mid, int *end_mid)
    {
        int total_len = end_pre - start_pre + 1;
        TreeNode *ret = new TreeNode(start_pre[0]);
        int *mid_root_ptr = start_mid;
        while(mid_root_ptr != end_mid)
        {
            if(mid_root_ptr[0] == start_pre[0])
                break;
            mid_root_ptr++;
        }
        int left_len = mid_root_ptr - start_mid;
        if(left_len > 0)
            ret->left = constr_core(start_pre + 1, start_pre + left_len, 
                                    start_mid, mid_root_ptr - 1);
        int right_idx = left_len + 1;
        if(right_idx < total_len)
            ret->right = constr_core(start_pre + right_idx, 
                                     end_pre, start_mid + right_idx, end_mid);
        return ret;
    }

    TreeNode* reConstructBinaryTree(vector<int> pre,vector<int> mid) {
        int size = pre.size();
        int mid_size = mid.size();
        if(0 == size || 0 == mid_size)
            return NULL;
        if(size != mid_size)
            return NULL;
        int *pre_arr = new int[size];
        int *mid_arr = new int[size];
        for(int i = 0; i < size; i++)
        {
            pre_arr[i] = pre[i];
            mid_arr[i] = mid[i];
        }
        TreeNode *ret = constr_core(pre_arr, pre_arr + size - 1, 
                                    mid_arr, mid_arr + size - 1);
        delete[] pre_arr;
        delete[] mid_arr;
        return ret;
    }
};
```

# JZ5 	用两个栈实现队列

```c
class Solution
{
public:
    void push(int node) {
        stack1.push(node);
    }

    int pop() {
        int ret;
        int data;
        if(stack2.empty() == true)
        {
            while(stack1.empty() == false)
            {
                data = stack1.top();
                stack2.push(data);
                stack1.pop();
            }
        }
        ret = stack2.top();
        stack2.pop();
        return ret;
    }

private:
    stack<int> stack1;
    stack<int> stack2;
};
```

#  JZ6 	旋转数组的最小数字

```c
class Solution {
public:
    int minNumberInRotateArray(vector<int> array) {
        int length = array.size();
        if(1 == length)
            return array[0];
        int head = 0;
        int tail = length - 1;
        while(tail - head > 1)
        {
            if(array[head] <= array[head + 1])
            {
                head++;
            }
            else
            {
                tail--;
            }
        }
        return array[tail];
    }
};
```

# JZ7 	斐波那契数列

```c
class Solution {
public:
    int Fibonacci(int n) {
        if(n == 0) return 0;
        if(n == 1) return 1;
        if(n == 2) return 1;
        int a = 1;
        int b = 1;
        int fb = a + b;
        for(int i = 3; i <= n; i++)
        {
            fb = a + b;
            a = b;
            b = fb;
        }
        return fb;
    }
};
```

# JZ8 	跳台阶

```c
class Solution {
public:
    int jumpFloor(int number) {
        if(1 == number)
            return 1;
        if(2 == number)
            return 2;
        return jumpFloor(number - 1) + jumpFloor(number - 2);
    }
};
```

#  JZ9 	变态跳台阶

```c
class Solution {
public:
    int jumpFloorII(int num) {
        if(num <= 0)
        {
            return 0;
        }
        if(1 == num)
        {
            return 1;
        }
        return (2 * jumpFloorII(num - 1));
    }
};
```

# JZ10 	矩形覆盖

```c
class Solution {
public:
    int rectCover(int number) {
        if(number < 3)
            return number;
        else
            return rectCover(number - 1) + rectCover(number - 2);
    }
};
```

#  JZ11 	二进制中1的个数

```c
class Solution {
public:
     int  NumberOf1(int n) {
         int ret = 0;
         while(n)
         {
             ret++;
             n = (n - 1) & n;
         }
         return ret;
     }
};
```

# JZ12 	数值的整数次方

```c
class Solution {
public:
    double Power(double base, int expo) {
        if(0 == expo)
            return 1;
        if(1 == expo)
            return base;
        if(-1 == expo)
            return 1.0f / base;
        double result = Power(base, expo / 2);
        result *= result;
        if(expo & 0x01 == 1)
        {
            if(expo < 0)
                base = 1.0f / base;
            result *= base;
        }
        return result;
    }
};
```

#  JZ13 	调整数组顺序使奇数位于偶数前面

```c
/**
 * 代码中的类名、方法名、参数名已经指定，请勿修改，直接返回方法规定的值即可
 *
 * 
 * @param array int整型一维数组 
 * @param arrayLen int array数组长度
 * @return int整型一维数组
 * @return int* returnSize 返回数组行数
 */
int* reOrderArray(int* array, int arrayLen, int* returnSize ) {
    // write code here
    for(int i = 0; i < arrayLen; i++)
    {
        if(array[i]%2 == 1)
        {
            for(int j = i-1; j >= 0 && array[j]%2 == 0; j--)
            {
                int tmp = array[j];
                array[j] = array[j+1];
                array[j+1] = tmp;
            }
        }
    }
    *returnSize = arrayLen;
    return array;
}
```

#  JZ14 	链表中倒数第k个结点

```c
/**
 * struct ListNode {
 *	int val;
 *	struct ListNode *next;
 *	ListNode(int x) : val(x), next(nullptr) {}
 * };
 */
class Solution {
public:
    /**
     * 代码中的类名、方法名、参数名已经指定，请勿修改，直接返回方法规定的值即可
     *
     * 
     * @param pHead ListNode类 
     * @param k int整型 
     * @return ListNode类
     */
    ListNode* FindKthToTail(ListNode* pHead, int k) {
        // write code here
        if(NULL == pHead || 0 == k)
            return NULL;
        ListNode *second = pHead;
        for(int i = 0; i < k-1; i++)
        {
            if(second->next)
                second = second->next;
            else
                return NULL;
        }
        while(second->next)
        {
            pHead = pHead->next;
            second = second->next;
        }
        return pHead;
    }
};
```

#  JZ15 	反转链表

```c
/*
struct ListNode {
	int val;
	struct ListNode *next;
	ListNode(int x) :
			val(x), next(NULL) {
	}
};*/
class Solution {
public:
    ListNode* ReverseList(ListNode* head) {
        if(head == NULL)
        {
            return NULL;
        }
        ListNode *pre = NULL;
        ListNode *next;
        while(head != NULL)
        {
            next = head->next;
            head->next = pre;
            pre = head;
            head = next;
        }
        return pre;
    }
};
```

# JZ16 	合并两个排序的链表

```c
/*
struct ListNode {
	int val;
	struct ListNode *next;
	ListNode(int x) :
			val(x), next(NULL) {
	}
};*/
class Solution {
public:
    ListNode* Merge(ListNode* head1, ListNode* head2)
    {
        if(NULL == head1)
            return head2;
        if(NULL == head2)
            return head1;
        ListNode *ret = NULL;
        if(head1->val < head2->val)
        {
            ret = head1;
            ret->next = Merge(head1->next, head2);
        }
        else
        {
            ret = head2;
            ret->next = Merge(head1, head2->next);
        }
        return ret;
    }
};
```

# JZ17 	树的子结构

```c
/*
struct TreeNode {
	int val;
	struct TreeNode *left;
	struct TreeNode *right;
	TreeNode(int x) :
			val(x), left(NULL), right(NULL) {
	}
};*/
class Solution {
public:
    bool core(TreeNode* root1, TreeNode* root2)
    {
        if(NULL == root2)
            return true;
        if(NULL == root1)
            return false;
        if(root1->val != root2->val)
            return false;
        return core(root1->left, root2->left) && core(root1->right, root2->right);
    }
    bool HasSubtree(TreeNode* root1, TreeNode* root2)
    {
        bool ret = false;
        if(NULL == root1 || NULL == root2)
            return false;
        if(root1->val == root2->val)
            ret = core(root1, root2);
        if(false == ret)
            ret = HasSubtree(root1->left, root2);
        if(false == ret)
            ret = HasSubtree(root1->right, root2);
        return ret;
    }
};
```

#  JZ18 	二叉树的镜像

```c
/**
 * struct TreeNode {
 *	int val;
 *	struct TreeNode *left;
 *	struct TreeNode *right;
 *	TreeNode(int x) : val(x), left(nullptr), right(nullptr) {}
 * };
 */
class Solution {
public:
    /**
     * 代码中的类名、方法名、参数名已经指定，请勿修改，直接返回方法规定的值即可
     *
     * 
     * @param pRoot TreeNode类 
     * @return TreeNode类
     */
    TreeNode* Mirror(TreeNode* pRoot) {
        // write code here
        if(pRoot == NULL)
            return NULL;
        TreeNode *tmp = pRoot->left;
        pRoot->left = Mirror(pRoot->right);
        pRoot->right = Mirror(tmp);
        return pRoot;
    }
};
```

# JZ19 	顺时针打印矩阵

```c
class Solution {
public:
    vector<int> printMatrix(vector<vector<int> > matrix) {
        vector<int> ret;
        int row_cnt = matrix.size();
        int col_cnt = matrix[0].size();
        int circle = ((row_cnt > col_cnt ? col_cnt : row_cnt) - 1) / 2 + 1;
        for(int i = 0; i < circle; i++)
        {
            for(int j = i; j < col_cnt - i; j++)
            {
                ret.push_back(matrix[i][j]);
            }
            for(int k = i + 1; k < row_cnt - i; k++)
            {
                ret.push_back(matrix[k][col_cnt - i - 1]);
            }
            for(int m = col_cnt - 2 - i; (row_cnt-i-1 > i) && (m >= i); m--)
                ret.push_back(matrix[row_cnt - i - 1][m]);
            for(int n = row_cnt - i - 2; (i < col_cnt - i - 1) && (n >= i + 1); n--)
                ret.push_back(matrix[n][i]);
        }
        return ret;
    }
};
```

#  JZ20 	包含min函数的栈

```c
class Solution {
public:
    void push(int value) {
        sta_vec.push_back(value);
        int min = this->min();
        if(value < min)
            min = value;
        min_vec.push_back(min);
    }
    void pop() {
        if(sta_vec.size())
            sta_vec.erase(sta_vec.end() - 1);
        if(min_vec.size())
            min_vec.erase(min_vec.end() - 1);
    }
    int top() {
        int ret = 0;
        if(sta_vec.size())
            ret = sta_vec[sta_vec.size() - 1];
        return ret;
    }
    int min() {
        int ret = 0xffff;
        if(min_vec.size())
            ret = min_vec[min_vec.size() - 1];
        return ret;
    }
private:
    vector<int> sta_vec;
    vector<int> min_vec;
};
```

# JZ21 	栈的压入、弹出序列

```c
class Solution {
public:
    bool IsPopOrder(vector<int> pushV,vector<int> popV) {
        int size = pushV.size();
        stack<int> sta;
        int pop_idx = 0;
        for(int i = 0; i < size; i++)
        {
            int push_val = pushV[i];
            int pop_val = popV[pop_idx];
            sta.push(push_val);
            if(sta.top() == pop_val)
            {
                sta.pop();
                pop_idx++;
            }
        }
        int sta_size = sta.size();
        for(int i = 0; i < sta_size; i++)
        //while(sta.empty() == false)
        {
            if(sta.top() == popV[pop_idx])
            {
                pop_idx++;
            }
            sta.pop();
        }
        if(size == pop_idx)
            return true;
        return false;
    }
};
```

# JZ22 	从上往下打印二叉树

```c
/*
struct TreeNode {
	int val;
	struct TreeNode *left;
	struct TreeNode *right;
	TreeNode(int x) :
			val(x), left(NULL), right(NULL) {
	}
};*/
class Solution {
public:
    vector<int> PrintFromTopToBottom(TreeNode* root) {
        vector<int> ret;
        deque<TreeNode *> deque_node;
        if(!root)
            return ret;
        deque_node.push_back(root);
        while(deque_node.size())
        {
            TreeNode *node = deque_node.front();
            deque_node.pop_front();
            ret.push_back(node->val);
            if(node->left)
            {
                deque_node.push_back(node->left);
            }
            if(node->right)
            {
                deque_node.push_back(node->right);
            }
        }
        return ret;
    }
};
```

#  JZ23 	二叉搜索树的后序遍历序列

```c
class Solution {
public:
    bool core(int *sequence, int length)
    {
        int root_val = sequence[length - 1];
        int idx;
        for(idx = 0; idx < length - 1; idx++)
        {
            if(sequence[idx] > root_val)
            {
                break;
            }
        }
        for(int j = idx; j < length - 1; j++)
        {
            if(sequence[j] < root_val)
            {
                return false;
            }
        }
        bool left_res = true;
        if(idx > 0)
        {
            int left_len = idx;
            left_res = core(sequence, left_len);
        }
        bool right_res = true;
        if(idx < length - 1)
        {
            int right_len = length - idx - 2;
            right_res = core(sequence + idx + 1, right_len);
        }
        return (left_res && right_res);
    }
    
    bool VerifySquenceOfBST(vector<int> sequence) {
        int length = sequence.size();
        if(length <= 0)
            return false;
        int *arr = new int[length];
        for(int i = 0; i < length; i++)
        {
            arr[i] = sequence[i];
        }
        bool ret = core(arr, length);
        delete[] arr;
        return ret;
    }
};
```

 JZ24 	二叉树中和为某一值的路径

```c
/*
struct TreeNode {
	int val;
	struct TreeNode *left;
	struct TreeNode *right;
	TreeNode(int x) :
			val(x), left(NULL), right(NULL) {
	}
};*/
class Solution {
public:
    void core(TreeNode* root, vector<vector<int>> &out, int sum, 
              int exp_sum, vector<int> vec)
    {
        sum += root->val;
        vec.push_back(root->val);
        if(NULL == root->left && NULL == root->right && sum == exp_sum)
        {
            out.push_back(vec);
            return;
        }
        if(root->left)
            core(root->left, out, sum, exp_sum, vec);
        if(root->right)
            core(root->right, out, sum, exp_sum, vec);
    }
    vector<vector<int> > FindPath(TreeNode* root,int expectNumber) {
        vector<vector<int>> ret;
        if(NULL == root)
            return ret;
        vector<int> vec;
        core(root, ret, 0, expectNumber, vec);
        return ret;
    }
};
```

# JZ25 	复杂链表的复制

```c
/*
struct RandomListNode {
    int label;
    struct RandomListNode *next, *random;
    RandomListNode(int x) :
            label(x), next(NULL), random(NULL) {
    }
};
*/
class Solution {
public:
    void clone_nodes(RandomListNode *head)
    {
        RandomListNode *node = head;
        while(NULL != node)
        {
            RandomListNode *cloned = new RandomListNode(node->label);
            cloned->next = node->next;
            cloned->random = NULL;
            node->next = cloned;
            node = cloned->next;
        }
    }
    
    void connect_random(RandomListNode *head)
    {
        RandomListNode *node = head;
        while(NULL != node)
        {
            RandomListNode *cloned = node->next;
            if(NULL != node->random)
            {
                cloned->random = node->random->next;
            }
            node = cloned->next;
        }
    }
    
    RandomListNode *reconnect_nodes(RandomListNode *head)
    {
        RandomListNode *node = head;
        RandomListNode *cloned = NULL;
        RandomListNode *ret = NULL;
        if(NULL != node)
        {
            ret = node->next;
        }
        while(NULL != node)
        {
            cloned = node->next;
            node->next = cloned->next;
            if(NULL != node->next)
            {
                cloned->next = node->next->next;
            }
            else
            {
                cloned->next = NULL;
            }
            node = node->next;
        }
        return ret;
    }
    
    RandomListNode* Clone(RandomListNode* head)
    {
        clone_nodes(head);
        connect_random(head);
        return reconnect_nodes(head);
    }
};
```

#  JZ26 	二叉搜索树与双向链表

```c
/*
struct TreeNode {
	int val;
	struct TreeNode *left;
	struct TreeNode *right;
	TreeNode(int x) :
			val(x), left(NULL), right(NULL) {
	}
};*/
class Solution {
public:
    void convert_node(TreeNode *root, TreeNode *&head, TreeNode *&tail)
    {
        if(NULL == root->left && NULL == root->right)
        {
            head = root;
            tail = root;
            return;
        }
        
        TreeNode *left_head = NULL;
        TreeNode *left_tail = NULL;
        if(root->left)
        {
            convert_node(root->left, left_head, left_tail);
        }
        
        TreeNode *right_head = NULL;
        TreeNode *right_tail = NULL;
        if(root->right)
        {
            convert_node(root->right, right_head, right_tail);
        }
        
        if(left_tail)
        {
            left_tail->right = root;
            root->left = left_tail;
            head = left_head;
        }
        else
        {
            head = root;
        }
        
        if(right_head)
        {
            right_head->left = root;
            root->right = right_head;
            tail = right_tail;
        }
        else
        {
            tail = root;
        }
        
    }
    
    TreeNode* Convert(TreeNode* root)
    {
        if(NULL == root)
            return NULL;
        TreeNode *head = NULL;
        TreeNode *tail = NULL;
        convert_node(root, head, tail);
        return head;
    }
};
```

#  JZ27 	字符串的排列

```c
class Solution {
public:
    
	void exchange_char(string &str, int idx)
	{
		char tmp_char = str[0];
		str[0] = str[idx];
		str[idx] = tmp_char;
	}
	
    void core(string str_head, string str_tail, vector<string> &out)
    {
        int tail_size = str_tail.size();
        if(1 == tail_size)
        {
            out.push_back(str_head + str_tail);
            return;
        }
        if(tail_size == 0)
        {
            return;
        }
        exec_sub_str(str_head, str_tail, out);
        for(int i = 1; i < tail_size; i++)
        {
            if(str_tail[i] != str_tail[0])
            {
				exchange_char(str_tail, i);
                exec_sub_str(str_head, str_tail, out);
            }
        }
    }
    
    void exec_sub_str(string &str_head, string &str_tail, vector<string> &out)
    {
        int tail_size = str_tail.size();
        sort(str_tail.begin() + 1, str_tail.end());//assure that the sub string is sorted
        string new_head = str_head + str_tail[0];
        string new_tail = str_tail.substr(1, tail_size - 1);
        core(new_head, new_tail, out);
    }

    vector<string> Permutation(string str) {
        vector<string> ret;
        if(str.size() > 9)
            return ret;
        string tmp = "";
        core(tmp, str, ret);
        return ret;
    }
};
```

#  JZ28 	数组中出现次数超过一半的数字

```c
class Solution {
public:
    bool CheckMoreThanHalf(vector<int> nums, int num)
    {
        int length = nums.size();
        int cnt = 0;
        for(int i = 0; i < length; i++)
        {
            if(nums[i] == num)
                cnt++;
        }
        if(cnt * 2 > length)
            return true;
        return false;
    }

        void swap(int &num1, int &num2)
        {
            int tmp = num1;
            num1 = num2;
            num2 = tmp;
        }

        int rand_range(int min, int max)
        {
            int ret = rand() % (max - min + 1) + min;
            return ret;
        }

        int partition(vector<int> &nums, int start, int end)
        {
            int rand_idx = rand_range(start, end);
            swap(nums[rand_idx], nums[end]);
            int left = start;
            for(int right = start; right < end; right++)
            {
                if(nums[right] < nums[end])
                {
                    //if(right != left)
                        swap(nums[left], nums[right]);
                    left++;
                }
            }
            swap(nums[end], nums[left]);
            return left;
        }
    
    int MoreThanHalfNum_Solution(vector<int> nums) {
        int length = nums.size();
        if(length <= 0)
            return 0;
        int mid = length / 2;
        int start = 0;
        int end = length - 1;
        int idx = partition(nums, start, end);
        while(idx != mid)
        {
            if(idx > mid)
            {
                end = idx - 1;
                idx = partition(nums, start, end);
            }
            else
            {
                start = idx + 1;
                idx = partition(nums, start, end);
            }
        }
        int ret = nums[idx];
        if(false == CheckMoreThanHalf(nums, ret))
            ret = 0;
        return ret;
    }
};
```

# JZ29 	最小的K个数

```c
class Solution {
public:
    void swap(int &num1, int &num2)
    {
        int tmp = num1;
        num1 = num2;
        num2 = tmp;
    }

    int rand_range(int min, int max)
    {
        int ret = rand() % (max - min + 1) + min;
        return ret;
    }

    int partition(vector<int> &nums, int start, int end)
    {
        int rand_idx = rand_range(start, end);
        swap(nums[rand_idx], nums[end]);
        int left = start;
        for(int right = start; right < end; right++)
        {
            if(nums[right] < nums[end])
            {
                //if(right != left)
                    swap(nums[left], nums[right]);
                left++;
            }
        }
        swap(nums[end], nums[left]);
        return left;
    }
    vector<int> GetLeastNumbers_Solution(vector<int> nums, int k) {
        vector<int> ret;
        int length = nums.size();
        if(k <= 0)
            return ret;
        if(length < k)
        {
            //ret = nums;
            //for(int i = length; i < k; i++)
            //    ret.push_back(0);
            return ret;
        }
        int mid = k - 1;
        int start = 0;
        int end = length - 1;
        int idx = partition(nums, start, end);
        while(idx != mid)
        {
            if(idx > mid)
            {
                end = idx - 1;
                idx = partition(nums, start, end);
            }
            else
            {
                start = idx + 1;
                idx = partition(nums, start, end);
            }
        }
        for(int i = 0; i < k; i++)
        {
            ret.push_back(nums[i]);
        }
        return ret;
    }
};
```

#  JZ30 	连续子数组的最大和

```c
#define MIN_INT  (-0xffffff)
class Solution {
public:
    int FindGreatestSumOfSubArray(vector<int> array) {
        int ret = MIN_INT;
        int length = array.size();
        if(length <= 1)
            return 0;
        int *dyna_arr = (int *)malloc(sizeof(int) *length);
        dyna_arr[0] = array[0];
        ret = dyna_arr[0];
        for(int i = 1; i < length; i++)
        {
            //dyna_arr[i] = MIN_INT;
            if(dyna_arr[i-1] > 0)
            {
                dyna_arr[i] = dyna_arr[i-1] + array[i];
            }
            else
            {
                dyna_arr[i] = array[i];
            }
            if(ret < dyna_arr[i])
                ret = dyna_arr[i];
        }
        free(dyna_arr);
        return ret;
    }
};
```

#  JZ31 	整数中1出现的次数（从1到n整数中1出现的次数）

```c
class Solution {
public:
    int num_of_1(int n)
    {
        int ret = 0;
        while(n)
        {
            if(1 == n % 10)
                ret++;
            n /= 10;
        }
        return ret;
    }
    
    int NumberOf1Between1AndN_Solution(int n)
    {
        int ret = 0;
        for(int i = 1; i <= n; i++)
        {
            ret += num_of_1(i);
        }
        return ret;
    }
};
```

# JZ32 	把数组排成最小的数

```c
#include <vector>
#include <algorithm>
#include <cstdlib>
#include <stdio.h>
#include <iostream>
#include <string.h>
#include <algorithm>

#define STR_LEN     10

char str_combine1[2 * STR_LEN + 1];
char str_combine2[2 * STR_LEN + 1];
class Solution {
public:
    static int comparestr(const void *arg1, const void *arg2)
    {
        strcpy(str_combine1, *(const char **)arg1);
        strcat(str_combine1, *(const char **)arg2);
        
        strcpy(str_combine2, *(const char **)arg2);
        strcat(str_combine2, *(const char **)arg1);
        
        return strcmp(str_combine1, str_combine2);
    }
    
    string PrintMinNumber(vector<int> num) {
        string ret = "";
        if(num.size() < 1)
            return ret;
        char **num_str = new char*[num.size()];
        for(int i = 0; i < num.size(); i++)
        {
            num_str[i] = new char[STR_LEN + 1];
            sprintf(num_str[i], "%d", num[i]);
        }
        //comparestr 必须是static
        qsort(num_str, num.size(), sizeof(char *), comparestr);
        
        for(int i = 0; i < num.size(); i++)
        {
            ret += num_str[i];
        }
        return ret;
    }
    
private:
};
```

#  JZ33 	丑数

```c
class Solution {
public:
    int min3(int a, int b, int c)
    {
        int ret = (a < b) ? a : b;
        ret = (ret < c) ? ret : c;
        return ret;
    }
    
    int GetUglyNumber_Solution(int index) {
        if(index <= 0)
            return 0;
        int *ugly_arr = new int[index];
        ugly_arr[0] = 1;
        int next_idx = 1;
        int *mul_2 = ugly_arr;
        int *mul_3 = ugly_arr;
        int *mul_5 = ugly_arr;
        while(next_idx < index)
        {
            int min = min3(mul_2[0] * 2, mul_3[0] * 3, mul_5[0] * 5);
            ugly_arr[next_idx] = min;
            while(mul_2[0] * 2 <= ugly_arr[next_idx])
                mul_2++;
            while(mul_3[0] * 3 <= ugly_arr[next_idx])
                mul_3++;
            while(mul_5[0] * 5 <= ugly_arr[next_idx])
                mul_5++;
            next_idx++;
        }
        int ret = ugly_arr[next_idx - 1];
        delete[] ugly_arr;
        return ret;
    }
};
```

# JZ34 	第一个只出现一次的字符位置

```c
class Solution {
public:
    int FirstNotRepeatingChar(string str) {
        int length = str.size();
        const int hash_size = 256;
        //int hash_table[hash_size];
        int idx_table[hash_size];
        for(int i = 0; i < hash_size; i++)
        {
            //hash_table[i] = 0;
            idx_table[i] = -1;
        }
        for(int i = 0; i < length; i++)
        {
            //hash_table[str[i]]++;
            if(idx_table[str[i]] == -1)
                idx_table[str[i]] = i;
            else
                idx_table[str[i]] = -2;
        }
        for(int i = 0; i < length; i++)
        {
            if(idx_table[str[i]] != -1 && idx_table[str[i]] != -2)
                return idx_table[str[i]];
        }
        return -1;
    }
};
```

#  JZ35 	数组中的逆序对

```c
class Solution {
public:
    long core(vector<int> &data, vector<int> &copy, int start, int end)
    {
        if(start == end)
        {
            copy[start] = data[start];
            return 0;
        }
        int mid = (end - start) / 2;
        long left = core(copy, data, start, start + mid);
        long right = core(copy, data, start + mid + 1, end);
        int head = start + mid;// 前半段数组最后一个下标
        int tail = end;// 后半段数组最后一个下标
        int idx_cp = end;
        long cnt = 0;
        while(head >= start && tail >= start + mid + 1)
        {
            if(data[head] > data[tail])
            {
                copy[idx_cp--] = data[head--];
                cnt += tail - (start + mid);
            }
            else
            {
                copy[idx_cp--] = data[tail--];
            }
        }
        for(; head >= start;)
            copy[idx_cp--] = data[head--];
        for(; tail >= start + mid + 1;)
            copy[idx_cp--] = data[tail--];
        return left + right + cnt;
    }
    
    int InversePairs(vector<int> data) {
        int length = data.size();
        if(length <= 0)
            return 0;
        vector<int> copy = data;
        return core(data, copy, 0, length - 1) % 1000000007;
    }
};
```

#  JZ36 	两个链表的第一个公共结点

```c
/*
struct ListNode {
	int val;
	struct ListNode *next;
	ListNode(int x) :
			val(x), next(NULL) {
	}
};*/
class Solution {
public:
    int get_length(ListNode *head)
    {
        int ret = 0;
        while(head)
        {
            head = head->next;
            ret++;
        }
        return ret;
    }
    
    ListNode* FindFirstCommonNode( ListNode* head1, ListNode* head2) {
        int length1 = get_length(head1);
        int length2 = get_length(head2);
        
        int len_diff = length1 - length2;
        ListNode *head_long = head1;
        ListNode *head_short = head2;
        if(length2 > length1)
        {
            len_diff = length2 - length1;
            head_long = head2;
            head_short = head1;
        }
        for(int i = 0; i < len_diff; i++)
        {
            head_long = head_long->next;
        }
        while((head_long != NULL) && (NULL != head_short) && 
              (head_long != head_short))
        {
            head_long = head_long->next;
            head_short = head_short->next;
        }
        return head_long;
    }
};
```

#  JZ37 	数字在排序数组中出现的次数

```c
class Solution {
public:
    int bi_search(const vector<int> &data, double num)
    {
        int start = 0;
        int end = data.size() - 1;
        while(start <= end)
        {
            int mid = (end - start) / 2 + start;
            if(data[mid] > num)
                end = mid - 1;
            else
                start = mid + 1;
        }
        return start;
    }
    int GetNumberOfK(vector<int> data ,int k) {
        return bi_search(data, k + 0.5) - bi_search(data, k - 0.5);
    }
};
```

#  JZ38 	二叉树的深度

```c
/*
struct TreeNode {
	int val;
	struct TreeNode *left;
	struct TreeNode *right;
	TreeNode(int x) :
			val(x), left(NULL), right(NULL) {
	}
};*/
class Solution {
public:
    int TreeDepth(TreeNode* root)
    {
        if(NULL == root)
            return 0;
        int left = TreeDepth(root->left);
        int right = TreeDepth(root->right);
        return ((left > right) ? left : right) + 1;
    }
};
```

#  JZ39 	平衡二叉树

```c

//第二版55题
#include <math.h>
#define MAX_TWO(x, y)  (x > y ? x : y)
class Solution {
public:
    int get_depth(TreeNode *root)
    {
        if(NULL == root)
            return 0;
        int left = get_depth(root->left);
        if(-1 == left)
            return -1;
        int right = get_depth(root->right);
        if(-1 == right)
            return -1;
        return (abs(left - right) > 1 ? -1 : (1 + MAX_TWO(left, right)));
    }
    
    bool IsBalanced_Solution(TreeNode* root) {
        return (get_depth(root) != -1);
    }
};
```

#  JZ40 	数组中只出现一次的数字

```c
class Solution {
public:
    int find_idx(int num)
    {
        int ret = 0;
        while((num & 1) == 0)
        {
            num = num >> 1;
            ret++;
        }
        return ret;
    }
    /**
     * 代码中的类名、方法名、参数名已经指定，请勿修改，直接返回方法规定的值即可
     *
     * 
     * @param array int整型vector 
     * @return int整型vector
     */
    vector<int> FindNumsAppearOnce(vector<int>& array) {
        // write code here
        vector<int> ret;
        int len = array.size();
        if(len < 2)
            return ret;
        int res = 0;
        for(int i = 0; i < len; i++)
            res ^= array[i];
        int idx = find_idx(res);
        int num1 = 0, num2 = 0;
        for(int i = 0; i < len; i++)
        {
            if((array[i] >> idx) & 1)
                num2 ^= array[i];
            else
                num1 ^= array[i];
        }
        ret.push_back(num1);
        ret.push_back(num2);
        sort(ret.begin(), ret.end());
        return ret;
    }
};
```

#  JZ41 	和为S的连续正数序列

```c
//第二版57题
class Solution {
public:
    vector<vector<int> > FindContinuousSequence(int sum) {
        vector<vector<int>> ret;
        vector<int> tmp_vec;
        int small = 1;
        int big = 2;
        int tmp_sum = small + big;
        while(small < big)
        {
            if(tmp_sum == sum)
            {
                for(int i = small; i <= big; i++)
                {
                    tmp_vec.push_back(i);
                }
                ret.push_back(tmp_vec);
                tmp_vec.clear();
                big++;
                tmp_sum += big;
            }
            else if(tmp_sum < sum)
            {
                big++;
                tmp_sum += big;
            }
            else
            {
                tmp_sum -= small;
                small++;
            }
        }
        return ret;
    }
};
```

# JZ42 	和为S的两个数字

```c
class Solution {
public:
    vector<int> FindNumbersWithSum(vector<int> array,int sum) {
        vector<int> ret;
        int length = array.size();
        int head = 0;
        int tail = length - 1;
        int product = 0xffffff;
        while(head < tail)
        {
            if((array[head] + array[tail] == sum) && 
               (array[head] * array[tail] < product))
            {
                product = array[head] * array[tail];
                ret.clear();
                ret.push_back(array[head]);
                ret.push_back(array[tail]);
                tail--;
                head++;
            }
            else if(array[head] + array[tail] > sum)
            {
                tail--;
            }
            else
            {
                head++;
            }
        }
        return ret;
    }
};
```

# JZ43 	左旋转字符串

```c
//第二版58题
class Solution {
public:
    void reverse(string &str, int begin, int end)
    {
        int length = str.size();
        if(end <= 0 || end > length - 1)
            return;
        int head_idx = begin;
        int tail_idx = end;
        while(head_idx < tail_idx)
        {
            char tmp = str[head_idx];
            str[head_idx] = str[tail_idx];
            str[tail_idx] = tmp;
            head_idx++;
            tail_idx--;
        }
    }
    string LeftRotateString(string str, int n) {
        int length = str.size();
        reverse(str, 0, n - 1);
        reverse(str, n, length - 1);
        reverse(str, 0, length - 1);
        return str;
    }
};
```

 JZ44 	翻转单词顺序列

```c
class Solution {
public:
    void reverse(string &str, int begin, int end)
    {
        int length = str.size();
        if(end <= 0 || end > length - 1)
            return;
        int head_idx = begin;
        int tail_idx = end;
        while(head_idx < tail_idx)
        {
            char tmp = str[head_idx];
            str[head_idx] = str[tail_idx];
            str[tail_idx] = tmp;
            head_idx++;
            tail_idx--;
        }
    }
    string ReverseSentence(string str) {
        int length = str.size();
        reverse(str, 0, length - 1);
        int begin = 0;
        int end = 0;
        bool space_flag = false;
        for(int i = 0; i < length + 1; i++)
        {
            if(i >= length || ' ' == str[i])
            {
                reverse(str, begin, end - 1);
                begin = i + 1;
            }
            end++;
        }
        return str;
    }
};
```

#  JZ45 	扑克牌顺子

```c
class Solution {
public:
    bool IsContinuous( vector<int> numbers ) {
        int length = numbers.size();
        if(length < 1)
            return false;
        sort(numbers.begin(), numbers.end());
        int zero_num = 0;
        int gap_num = 0;
        for(int i = 0; i < length && numbers[i] == 0; i++)//统计0的个数
        {
            zero_num++;
        }
        int small_idx = zero_num;
        int big_idx = zero_num + 1;
        while(big_idx < length)
        {
            if(numbers[small_idx] == numbers[big_idx])
                return false;
            gap_num += numbers[big_idx] - numbers[small_idx] - 1;
            small_idx++;
            big_idx++;
        }
        return (gap_num > zero_num) ? false : true;
    }
};
```

#  JZ46 	孩子们的游戏(圆圈中最后剩下的数)

```c
class Solution {
public:
    int LastRemaining_Solution(int n, int m)
    {
        if(n < 1 || m < 1)
            return -1;
        int i;
        list<int> nums;
        for(i = 0; i < n; i++)
            nums.push_back(i);
        list<int>::iterator cur = nums.begin();
        while(nums.size() > 1)
        {
            for(i = 1; i < m; i++)
            {
                cur++;
                if(cur == nums.end())
                    cur = nums.begin();
            }
            list<int>::iterator next = ++cur;
            if(next == nums.end())
                next = nums.begin();
            cur--;
            nums.erase(cur);
            cur = next;
        }
        return *(cur);
    }
};
```

#  JZ47 	求1+2+3+...+n

```c
typedef int (*func)(int);
int final_func(int n)
{
    return 0;
}

int sum_solution(int n)
{
    func fun[2] = {final_func, sum_solution};
    return n + fun[!!n](n - 1);
}

class Solution {
public:
    int Sum_Solution(int n) {
        return sum_solution(n);
    }
};
```

#  JZ48 	不用加减乘除做加法

```c
class Solution {
public:
    int Add(int num1, int num2)
    {
        int sum, carry;
        do
        {
            sum = num1 ^ num2;
            carry = (num1 & num2) << 1;
            num1 = sum;
            num2 = carry;
        }
        while(num2 != 0);
        return num1;
    }
};
```

#  JZ49 	把字符串转换成整数

```c
class Solution {
public:
    int core(string &str, int idx, bool minus)
    {
        long long ret = 0;
        int length = str.size();
        while(idx < length)
        {
            if(str[idx] >= '0' && str[idx] <= '9')
            {
                int flag = (true == minus) ? -1 : 1;
                ret = ret * 10 + flag * (str[idx] - '0');
            }
            else
            {
                ret = 0;
                break;
            }
            idx++;
        }
        return ret;
    }
    int StrToInt(string str) {
        long long ret = 0;
        int length = str.size();
        if(length <= 0)
            return 0;
        bool minus = false;
        int idx = 0;
        if('+' == str[idx])
        {
            idx++;
        }
        else if('-' == str[idx])
        {
            idx++;
            minus = true;
        }
        if(idx < length)
            ret = core(str, idx, minus);
        return ret;
    }
};
```

#  JZ50 	数组中重复的数字

```c
class Solution {
public:
    /**
     * 代码中的类名、方法名、参数名已经指定，请勿修改，直接返回方法规定的值即可
     *
     * 
     * @param numbers int整型vector 
     * @return int整型
     */
    int duplicate(vector<int>& numbers) {
        // write code here
        if(numbers.size() == 0)
            return -1;
        for(int i = 0; i < numbers.size(); i++)
        {
            if(numbers[i] != i)
            {
                if(numbers[i] == numbers[numbers[i]])
                {
                    return numbers[i];
                }
                int tmp = numbers[numbers[i]];
                numbers[numbers[i]] = numbers[i];
                numbers[i] = tmp;
                i--;//再判断一次
            }
        }
        return -1;
    }
};
```

#   JZ51 	构建乘积数组

```c
class Solution {
public:
    vector<int> multiply(const vector<int>& in) {
        vector<int> ret;
        int length = in.size();
        if(length <= 0)
            return ret;
        int left = 1;
        ret.push_back(left);
        for(int i = 1; i < length; i++)
        {
            left = left * in[i - 1];
            ret.push_back(left);
        }
        int right = 1;
        for(int i = length - 2; i >= 0; i--)
        {
            right *= in[i + 1];
            ret[i] *= right;
        }
        return ret;
    }
};
```

#  JZ52 	正则表达式匹配

```c
#include <stdbool.h>
bool core(char* str, char* pattern)
{
    if(str[0] == 0 && pattern[0] == 0)
        return true;
    if(str[0] != 0 && pattern[0] == 0)
        return false;
    if(pattern[1] == '*')
    {
        if(pattern[0] == str[0] || (pattern[0] == '.' && str[0] != 0))
        {
            return core(str+1, pattern+2) ||
                   core(str+1, pattern) ||
                   core(str, pattern+2);
        }
        else
            return core(str, pattern+2);
    }
    if(pattern[0] == str[0] || (pattern[0] == '.' && str[0] != 0))
        return core(str+1, pattern+1);
    return false;
}
/**
 * 代码中的类名、方法名、参数名已经指定，请勿修改，直接返回方法规定的值即可
 *
 * 
 * @param str string字符串 
 * @param pattern string字符串 
 * @return bool布尔型
 */
bool match(char* str, char* pattern ) {
    // write code here
    if(str == NULL || pattern == NULL)
        return false;
    return core(str, pattern);
}
```

# JZ53 	表示数值的字符串

```c
class Solution {
public:
    bool scan_uint(string& str)
    {
        bool ret = false;
        while(str[0] != 0 && str[0] >= '0' && str[0] <= '9')
        {
            ret = true;
            str = str.substr(1, str.size()-1);
        }
        return ret;
    }
    bool scan_int(string& str)
    {
        if(str[0] == '+' || str[0] == '-')
        {
            str = str.substr(1, str.size()-1);
        }
        return scan_uint(str);
    }
    /**
     * 代码中的类名、方法名、参数名已经指定，请勿修改，直接返回方法规定的值即可
     *
     * 
     * @param str string字符串 
     * @return bool布尔型
     */
    bool isNumeric(string str) {
        // write code here
        bool numeric = false;
        if(str.size() == 0)
            return false;
        numeric = scan_int(str);
        if(str[0] == '.')
        {
            str = str.substr(1, str.size()-1);
            numeric = scan_uint(str) || numeric;
        }
        if(str[0] == 'e' || str[0] == 'E')
        {
            str = str.substr(1, str.size()-1);
            numeric = scan_int(str) && numeric;
        }
        return numeric && str[0] == 0;
    }
};
```

#  JZ54 	字符流中第一个不重复的字符

```c
class Solution
{
public:
    Solution()
    {
        idx = 0;
        for(int i = 0; i < 256; i++)
        {
            char_arr[i] = -1;
        }
    }
    
  //Insert one char from stringstream
    void Insert(char ch)
    {
        if(char_arr[ch] == -1)
            char_arr[ch] = idx;
        else if(char_arr[ch] > -1)
            char_arr[ch] = -2;
        idx++;
    }
  //return the first appearence once char in current stringstream
    char FirstAppearingOnce()
    {
        char ret = '#';
        int min_idx = idx + 2;//设置一个临时值，idx+2比目前所有的idx都大
        for(int i = 0; i < 256; i++)
        {
            if(char_arr[i] > -1 && char_arr[i] < min_idx)
            {
                ret = (char)i;
                min_idx = char_arr[i];
            }
        }
        return ret;
    }

private:
    int char_arr[256];
    int idx;
};
```

#  JZ55 	链表中环的入口结点

```c
/*
struct ListNode {
    int val;
    struct ListNode *next;
    ListNode(int x) :
        val(x), next(NULL) {
    }
};
*/
class Solution {
public:
    //返回环中任意一个节点
    ListNode *get_loop_node(ListNode *head)
    {
        if(NULL == head)
            return NULL;
        ListNode *slow = head;
        ListNode *fast = head->next;
        while(NULL != fast)
        {
            if(fast == slow)
            {
                return fast;
            }
            slow = slow->next;
            fast = fast->next;
            if(fast)
            {
                fast = fast->next;
            }
        }
        return NULL;
    }
    ListNode* EntryNodeOfLoop(ListNode* head)
    {
        ListNode *loop_node = get_loop_node(head);
        if(NULL == loop_node)
            return NULL;
        ListNode *tmp = loop_node->next;
        int loop_cnt = 1;
        while(tmp != loop_node)
        {
            loop_cnt++;
            tmp = tmp->next;
        }
        ListNode *early = head;
        for(int i = 0; i < loop_cnt; i++)
        {
            early = early->next;
        }
        ListNode *late = head;
        while(late != early)
        {
            early = early->next;
            late = late->next;
        }
        return early;
    }
};
```

#  JZ56 	删除链表中重复的结点

```c
/*
struct ListNode {
    int val;
    struct ListNode *next;
    ListNode(int x) :
        val(x), next(NULL) {
    }
};
*/
class Solution {
public:
    ListNode* deleteDuplication(ListNode* head)
    {
        if(NULL == head)
            return NULL;
        ListNode *tmp = head->next;
        ListNode *first = head;
        ListNode *pre = NULL;
        bool repeat = false;
        while(NULL != tmp || true == repeat)
        {
            if(tmp && tmp->val == first->val)
            {
                repeat = true;
                ListNode *del = tmp;
                tmp = tmp->next;
                first->next = tmp;
                delete del;
            }
            else
            {
                if(true == repeat)
                {
                    repeat = false;
                    delete first;
                    first = tmp;
                    if(pre)
                        pre->next = tmp;
                    else
                        head = tmp;
                }
                else
                    pre = first;
                first = tmp;
                if(tmp)
                    tmp = tmp->next;
            }
        }
        return head;
    }
};
```

# JZ57 	二叉树的下一个结点

```c
/*
struct TreeLinkNode {
    int val;
    struct TreeLinkNode *left;
    struct TreeLinkNode *right;
    struct TreeLinkNode *next;
    TreeLinkNode(int x) :val(x), left(NULL), right(NULL), next(NULL) {
        
    }
};
*/
class Solution {
public:
    TreeLinkNode* GetNext(TreeLinkNode* node)
    {
        if(NULL == node)
            return node;
        TreeLinkNode *ret = NULL;
        if(NULL != node->right)
        {
            TreeLinkNode *next = node->right;
            while(next->left != NULL)
            {
                next = next->left;
            }
            ret = next;
        }
        else if(NULL != node->next)
        {
            TreeLinkNode *parent = node->next;
            if(parent->left == node)
                ret = parent;
            else
            {
                TreeLinkNode *current = node;
                while(parent->right == current && NULL != parent)
                {
                    current = parent;
                    parent = parent->next;
                }
                ret = parent;
            }
        }
        return ret;
    }
};
```

# JZ58 	对称的二叉树

```c
/*
struct TreeNode {
    int val;
    struct TreeNode *left;
    struct TreeNode *right;
    TreeNode(int x) :
            val(x), left(NULL), right(NULL) {
    }
};
*/
class Solution {
public:
    bool core(TreeNode *root1, TreeNode *root2)
    {
        if(root1 == NULL && root2 == NULL)
            return true;
        if(root1 == NULL || root2 == NULL)
            return false;
        if(root1->val != root2->val)
            return false;
        return (core(root1->left, root2->right) && core(root1->right, root2->left));
    }
    bool isSymmetrical(TreeNode* pRoot) {
        return core(pRoot, pRoot);
    }

};
```

#  JZ59 	按之字形顺序打印二叉树

```c
/*
struct TreeNode {
    int val;
    struct TreeNode *left;
    struct TreeNode *right;
    TreeNode(int x) :
            val(x), left(NULL), right(NULL) {
    }
};
*/
class Solution {
public:
    vector<vector<int> > Print(TreeNode* root) {
        vector<vector<int>> ret;
        if(NULL == root)
            return ret;
        stack<TreeNode *> sta_node[2];
        int sta_idx = 0;
        sta_node[sta_idx].push(root);
        vector<int> tmp_vec;
        bool reverse = true;
        while(sta_node[0].size() || sta_node[1].size())
        {
            TreeNode *node = sta_node[sta_idx].top();
            sta_node[sta_idx].pop();
            tmp_vec.push_back(node->val);
            if(1 == sta_idx)
            {
                if(node->right)
                    sta_node[!sta_idx].push(node->right);
                if(node->left)
                    sta_node[!sta_idx].push(node->left);
            }
            else
            {
                if(node->left)
                    sta_node[!sta_idx].push(node->left);
                if(node->right)
                    sta_node[!sta_idx].push(node->right);
            }
            if(sta_node[sta_idx].empty())
            {
                ret.push_back(tmp_vec);
                tmp_vec.clear();
                sta_idx = !sta_idx;
            }
        }
        return ret;
    }
};
```

#  JZ60 	把二叉树打印成多行

```c
/*
struct TreeNode {
    int val;
    struct TreeNode *left;
    struct TreeNode *right;
    TreeNode(int x) :
            val(x), left(NULL), right(NULL) {
    }
};
*/
class Solution {
public:
        vector<vector<int> > Print(TreeNode* root) {
			vector<vector<int>> ret;
			if(NULL == root)
				return ret;
			deque<TreeNode *> deque_node;
			deque_node.push_back(root);
			TreeNode *last = root;
			vector<int> tmp_vec;
			while(deque_node.size())
			{
				TreeNode *node = deque_node.front();
				deque_node.pop_front();
				tmp_vec.push_back(node->val);
				if(node->left)
				{
					deque_node.push_back(node->left);
				}
				if(node->right)
				{
					deque_node.push_back(node->right);
				}
				if(last == node)
				{
					ret.push_back(tmp_vec);
					tmp_vec.clear();
					last = deque_node.back();
				}
			}
			return ret;
        }
    
};
```

#  JZ61 	序列化二叉树

```c
#include <stdlib.h>
#include<string>
/*
struct TreeNode {
    int val;
    struct TreeNode *left;
    struct TreeNode *right;
    TreeNode(int x) :
            val(x), left(NULL), right(NULL) {
    }
};
*/
#include <cstdlib>
class Solution {
public:
    char* Serialize(TreeNode *root) {   
         if (root == nullptr) {
			return "#";
		}
	  
		string res = to_string(root->val);
		res.push_back(',');
	  
		char* left = Serialize(root->left);
		char* right = Serialize(root->right);
	  
		char* ret = new char[strlen(left)+strlen(right)+res.size()];
		// 如果是string类型，直接用operator += ,这里char* 需要用函数
		strcpy(ret,res.c_str());
		strcat(ret,left);
		strcat(ret,right);
	  
		return ret;
    }
     
    TreeNode* deserialize(char* &s)
    {
        if (*s == '#')
        {
			++s;
			return nullptr;
        }
  
		// 构造根节点值
		int num = 0;
		while (*s != ',')
        {
			num = num * 10 + (*s - '0');
			++s;
        }
		++s;
		// 递归构造树
		TreeNode *root = new TreeNode(num);
		root->left = deserialize(s);
		root->right = deserialize(s);
	  
		return root;
    }
    TreeNode* Deserialize(char *str) {
        return deserialize(str);
    }
};
```

# JZ62 	二叉搜索树的第k个结点

```c
/*
struct TreeNode {
    int val;
    struct TreeNode *left;
    struct TreeNode *right;
    TreeNode(int x) :
            val(x), left(NULL), right(NULL) {
    }
};
*/
class Solution {
public:
    void kth_core(TreeNode *root, int &k, TreeNode *&out)
    {
        if(root == NULL || NULL != out)
            return;
        kth_core(root->left, k, out);
        k--;
        if(k == 0)
        {
            out = root;
            return;
        }
        kth_core(root->right, k, out);
    }

    TreeNode* KthNode(TreeNode* root, int k)
    {
        if(root == NULL)
            return NULL;
        TreeNode *ret = NULL;
        kth_core(root, k, ret);
        return ret;
    }

    
};
```

#  JZ63 	数据流中的中位数

```c
#include<algorithm>
class Solution {
public:
    void Insert(int num)
    {
        int size = min.size() + max.size();
        if(0 == (size & 1))
        {
            if(max.size() > 0 && num < max[0])
            {
                max.push_back(num);
                //首先数组push_back插入元素，然后再调用push_heap，
                //它会使最后一个元素插到合适位置
                push_heap(max.begin(), max.end(), less<int>());//大顶堆
                num = max[0];
                //会将堆顶元素（即为数组第一个位置）和数组最后一个位置对调，
                //然后你可以调用数组pop_back，删除这个元素
                pop_heap(max.begin(), max.end(), less<int>());//大顶堆
                max.pop_back();
            }
            min.push_back(num);
            push_heap(min.begin(), min.end(), greater<int>());
        }
        else
        {
            if(min.size() > 0 && num > min[0])
            {
                min.push_back(num);
                push_heap(min.begin(), min.end(), greater<int>());//小顶堆
                num = min[0];
                pop_heap(min.begin(), min.end(), greater<int>());//小顶堆
                min.pop_back();
            }
            max.push_back(num);
            push_heap(max.begin(), max.end(), less<int>());
        }
    }

    double GetMedian()
    { 
        int size = min.size() + max.size();
        if(0 == size)
            return 0;
        double mid = 0;
        if((size & 1) == 1)
            mid = min[0];
        else
            mid = 1.0f * (min[0] + max[0]) / 2;
        return mid;
    }
private:
    vector<int> min;//最小堆，第一个元素最小
    vector<int> max;//最大堆，第一个元素最大
};
```

#  JZ64 	滑动窗口的最大值

```c
class Solution {
public:
    vector<int> maxInWindows(const vector<int>& num, unsigned int size)
    {
        deque<int> q;//put index
        int length = num.size();
        vector<int> ret;
        if(size <= 0 || length < size)
            return ret;
        for(int i = 0; i < size - 1; i++)
        {
            while(false == q.empty() && num[q.front()] < num[i])
            {
                q.pop_front();
            }
            q.push_front(i);
        }
        for(int i = size - 1; i < length; i++)
        {
            while(false == q.empty() && num[q.front()] < num[i])
            {
                q.pop_front();
            }
            q.push_front(i);
            int back_idx = q.back();
            int out_idx = i - size;// 滑动窗口的开始idx-1
            if(back_idx <= out_idx)
            {
                int tmp = q.back();
                tmp = i - size;
                q.pop_back();
            }
            ret.push_back(num[q.back()]);
        }
        return ret;
    }

};
```

#  JZ65 	矩阵中的路径

```c
class Solution {
public:
    bool core(vector<vector<char> >& matrix, int rows, int cols, int r, int c, string word, int& len, bool *visited)
    {
        if(word.size() == len)
            return true;
        bool ret = false;
        if(r >= 0 && r < rows && c >= 0 && c < cols &&
           matrix[r][c] == word[len] && !visited[r*cols+c])
        {
            len++;
            visited[r*cols+c] = true;
            ret = core(matrix, rows, cols, r-1, c, word, len, visited) ||
                  core(matrix, rows, cols, r+1, c, word, len, visited) ||
                  core(matrix, rows, cols, r, c-1, word, len, visited) ||
                  core(matrix, rows, cols, r, c+1, word, len, visited);
            if(!ret)
            {
                len--;
                visited[r*cols+c] = false;
            }
        }
        return ret;
    }
    /**
     * 代码中的类名、方法名、参数名已经指定，请勿修改，直接返回方法规定的值即可
     *
     * 
     * @param matrix char字符型vector<vector<>> 
     * @param word string字符串 
     * @return bool布尔型
     */
    bool hasPath(vector<vector<char> >& matrix, string word) {
        // write code here
        int rows = matrix.size();
        int cols = matrix[0].size();
        if(rows < 1 || cols < 1)
            return false;
        bool *visited = new bool[rows * cols];
        memset(visited, 0, rows*cols);
        
        int len = 0;
        for(int r = 0; r < rows; r++)
        {
            for(int c = 0; c < cols; c++)
            {
                if(core(matrix, rows, cols, r, c, word, len, visited))
                {
                    return true;
                }
            }
        }
        
        delete[] visited;
        return false;
    }
};
```

#  JZ66 	机器人的运动范围

```c
class Solution {
public:
    int get_digit_sum(int num)
    {
        int ret = 0;
        while(num > 0)
        {
            ret += num % 10;
            num /= 10;
        }
        return ret;
    }
    
    int core(int threshold, int rows, int cols, int r, int c, bool *visited)
    {
        int ret = 0;
        if(r >= 0 && r < rows && c >= 0 && c < cols
          && get_digit_sum(r) + get_digit_sum(c) <= threshold
          && false == visited[r * cols + c])
        {
            visited[r * cols + c] = true;
            ret = 1 + core(threshold, rows, cols, r - 1, c, visited)
                + core(threshold, rows, cols, r + 1, c, visited)
                + core(threshold, rows, cols, r, c - 1, visited)
                + core(threshold, rows, cols, r, c + 1, visited);
        }
        return ret;
    }
    
    int movingCount(int threshold, int rows, int cols)
    {
        if(threshold < 0 || rows <= 0 || cols <= 0)
            return 0;
        bool *visited = new bool[rows * cols];
        for(int i = 0; i < rows * cols; i++)
            visited[i] = false;
        int ret = core(threshold, rows, cols, 0, 0, visited);
        delete[] visited;
        return ret;
    }
};
```

# JZ67 	剪绳子

```c
class Solution {
public:
    int cutRope(int number) {
        int res[60] = {0};
        res[0] = 1;
        res[1] = 1;
        res[2] = 2;
        res[3] = 3;
        for(int i = 4; i <= number; i++)
        {
            int tmp = 0;
            for(int j = 0; j <= i; j++)
            {
                tmp = res[j] * res[i-j];
                if(tmp > res[i])
                {
                    res[i] = tmp;
                }
            }
        }
        return res[number];
    }
};
```

