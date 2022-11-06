本文章是牛客网上的[华为机试](https://www.nowcoder.com/ta/huawei)编程题的答案，因为牛客网提交的答案数据会丢失（发生过很多次），所以还是自己保存一份。

注意：还未全部做完，更新中。。。

#  HJ5 	进制转换

```c
#include <math.h>
#include <stdio.h>
int main()
{
    char str[100];
    while(gets(str) != NULL)
    {
        int len = strlen(str);
        int dec = 0;
        for(int i = len-1; i > 1; i--)
        {
            if(str[i] >= '0' && str[i] <= '9')
            {
                dec += (str[i]-'0') * pow(16, len-i-1);
            }
            else if(str[i] >= 'A' && str[i] <= 'F')
            {
                dec += (str[i]-'A'+10) * pow(16, len-i-1);
            }
            else if(str[i] >= 'a' && str[i] <= 'f')
            {
                dec += (str[i]-'a'+10) * pow(16, len-i-1);
            }
        }
        printf("%d\n", dec);
    }
    return 0;
}
```

# HJ7 	取近似值

```c
int main()
{
    float fl;
    int a;
    scanf("%f", &fl);
    a = (int)(fl*10);
    a = a/10 + (a%10>=5);
    printf("%d", a);
    return 0;
}
```

#  HJ11 	数字颠倒

```c
int main()
{
    int a;
    scanf("%d", &a);
    while(a)
    {
        printf("%d", a%10);
        a = a/10;
    }
    return 0;
}
```

#  HJ12 	字符串反转

```c
int main()
{
    char str[1000+1];
    gets(str);
    for(int i = strlen(str); i > 0; i--)
    {
        printf("%c", str[i-1]);
    }
    return 0;
}
```

#  HJ15 	求int型数据在内存中存储时1的个数

```c
int main()
{
    int num, cnt = 0;
    scanf("%d", &num);
    while(num)
    {
        if(num%2 == 1)
        {
            cnt++;
        }
        num = num >> 1;
    }
    printf("%d", cnt);
    return 0;
}
```

# HJ22 	汽水瓶

```c
#include <stdio.h>
int getDrinkCnt(int empty)
{
    int drinkCnt;
    if(empty < 2)
    {
        return 0;
    }
    else if(empty == 2)
    {
        return 1;
    }
    drinkCnt = empty / 3;
    drinkCnt += getDrinkCnt(drinkCnt+empty%3);
    return drinkCnt;
}

void main()
{
    int empty;
    while((scanf("%d", &empty) != EOF) && (empty != 0))
    {
        printf("%d\n", getDrinkCnt(empty));
    }
}
```

#  HJ37 	统计每个月兔子的总数

```c
#include <stdio.h>
int main()
{
    int n;
    while(scanf("%d", &n) != EOF && n != 0)
    {
        int i, a = 0, b = 1, f = 1;
        for(i = 1; i < n; i++)
        {
            f = a+b;
            a = b;
            b = f;
        }
        printf("%d\n", f);
    }
    return 0;
}
```

#  HJ100 	等差数列

```c
#include <stdio.h>
int main()
{
    int n;
    while(scanf("%d", &n) != EOF)
    {
        printf("%d\n", ((3*n-1)+2)*n/2);
    }
}
```

#  HJ106 	字符逆序

```c
int main()
{
    char str[100];
    gets(str);
    int len = strlen(str);
    for(int i = len-1; i >= 0; i--)
    {
        printf("%c", str[i]);
    }
    return 0;
}
```

# HJ108 	求最小公倍数

```c
int gcd(int a, int b)
{
    if(a < b)
    {
        int tmp = a;
        a = b;
        b = tmp;
    }
    if(a % b == 0)
    {
        return b;
    }
    else
    {
        return gcd(b, a%b);
    }
}

int main()
{
    int ans, a, b;
    scanf("%d %d", &a, &b);
    int tmp = gcd(a, b);
    ans = a*b/tmp;
    printf("%d", ans);
}
```

