---
layout: post
title:  "动态规划"
date:   2017-07-29 +0800
categories: dp
---

一直觉得，程序员分为两种，一种是懂动态规划的，另一种是不懂的。但是自从毕业参加工作以来，发现自己貌似游走在懂与不懂的边缘。所以写下这个博文记录理解动态规划的历程。

记得看过一篇文章说：“为什么很多顶级的团队会在意一个研发会不会动态规划。那么从动态规划的本质来说，就是加缓存”。绝大多数的系统，都会一定程度的使用缓存。对于动态规划来说，缓存就是将程序算过的东西存到一个地方，当下次再需要做一样的事情的时候，就从缓存区里面取值。从程序员的哲学来说，这也是 DRY 原则。

先从一个题目说起吧

## 约翰的后花园

约翰想在他家后面的空地上建一个后花园，现在有两种砖，一种 3 dm 的高度，7 dm 的高度。约翰想围成 x dm 的墙。如果约翰能做到，输出 YES，否则输出 NO。（https://www.lintcode.com/problem/johns-backyard-garden/description）

### 分析

很经典的一个问题。判断能不能被 3 build，如果不能就回溯，直到判断被 7build 或者到栈顶。实现起来也比较容易：
```java
public class Solution {
    /**
     * @param x: the wall's height
     * @return: YES or NO
     */
    public String isBuild(int x) {
        // write you code here
        if (helper(x) == true)
            return "YES";
        else
            return "NO";
    }

    private boolean helper(int x){
        if (x == 0){
            return true;
        }
        if (x < 3){
            return false;
        }
        return helper(x - 3) || helper(x - 7);
    }
}
```
本来以为这样的算法效率并不高，因为要反复执行 `||`运算。然而，然而，some times too naive |-_- 。事实是速度并不慢。在 `||`运算中，只要有一个`true`产生。那么这个表达式的值一定是 true。对于布尔运算的递归程序同样适用。所以在 debug 阶段可以看到当 helper 里面一旦有`true`的时候。递归就会停止。这里不得不佩服前人做的努力。

## 斐波那契
先来一把传统的递归写法
```java
public int fib(int i){
    if (i == 0){
        return 0;
    }
    if ( i == 1) {
        return 1;
    }
    return fib(i - 1) + fib(i - 2);
}
```
这段代码简洁而又优美，但实际上性能真的很差。从实际的角度出发，在我自己的 MBP 2017，CPU 3.1 GHz Intel Core i5 的电脑上。i = 40 ， 最终结果 =102334155 的时候，跑到出结果花了 869 ms。从分析的角度出发，这种递归程序有一个特质，就是大量重复的计算。举个例子：当 i = 5， 程序递归下去实际上执行了 2 个 fib(3) 和 3 个 fib(2)。可以考虑的是，发生过的事情，真的需要让他再发生吗？是不是只需要记忆结果，那么下次再有同样的需求发生的时候，只需要去取得结果，而不再是计算相同的任务了。

所以，试着加上缓存。做法就是维护一个数据结构，将计算过的任务的结果保存在里面。
```java
int []cache = new int[10000]; // 暂时用这么大，先不考虑极大情况。
cache[1] = 1;

public int fib(int i) {
    if (cache[i] != 0) {
        return cache[i];
    }

    if (i <= 0) {
        return 0;
    }

    int result = fib(i - 1) + fib(i - 2);
    cache[i] = result;
    return result;

}
```
好了，测试一发。嗯，结果正确。看看性能：不到 5ms。

## 子数组问题
给一个非负整数集合 set，一个目标值元素 sum，求判断该集合中，是否包含一个子集合，使得子集合的元素和等于目标值 sum？

easy

子集合如果大小确定为 2，那么直接就可以用 k-v 映射来判断。（嵌套 for 循环解决的的就过掉～）
```java
public boolean isSubsetSum(int[]set, int sum) {
    HashMap map = new HashMap();
    for (int i : set) {
        map.put(sum - i, i);
    }
    for (int i: set) {
        if (map.containsKey(i)) {
            return true;
        }
    }
    return false;
}
```

hard

`状态转移方程`

子集合的大小 0 < size <= set.length。这种情况下，需要进一步把大问题拆分成小问题，推导出状态转移方程。
```java
isSubsetSum(set, n, sum) = isSubsetSum(set, n-1, sum) ||
                           isSubsetSum(set, n-1, sum-set[n-1])
Base Cases:
isSubsetSum(set, n, sum) = false, if sum > 0 and n == 0
isSubsetSum(set, n, sum) = true, if sum == 0
```
紧接着，coding
```java
boolean isSubsetSum(int set[], int n, int sum){
    // 基本条件
    if (sum == 0)
        return true;
    if (n == 0 && sum != 0)
        return false;

    // 如果最后一个元素大于 sum，忽略掉
    if (set[n-1] > sum)
        return isSubsetSum(set, n-1, sum);

    /* 否则，检查 sum 是否能够被组合。分为下面两种情况
        (a) 包含最后一个元素
        (b) 不包含最后一个元素 */
    return isSubsetSum(set, n-1, sum) ||
        isSubsetSum(set, n-1, sum-set[n-1]);
}
```
这个做法的复杂度为指数级别

`动态规划矩阵`
其实，在《算法导论》一书中，其实有一点可以很明确“应用于子问题重叠的情况”。分析上述的算法，可以发现有很多重叠的子问题。所以，有必要回到文章最开始的一点`加缓存`。这里考虑用一个矩阵来缓存结果集。
```java
boolean isSubsetSum(int set[], int n, int sum) {
    boolean subset[][] = new boolean[sum+1][n+1];

    // sum 为 0 的情况，结果始终为 true
    for (int i = 0; i <= n; i++)
        subset[0][i] = true;

    // sum 不为 0，但集合为空，始终为 false
   for (int i = 1; i <= sum; i++)
        subset[i][0] = false;

    // 自底向上填充矩阵
    for (int i = 1; i <= sum; i++)
    {
        for (int j = 1; j <= n; j++)
        {
            subset[i][j] = subset[i][j-1];
            if (i >= set[j-1])
            subset[i][j] = subset[i][j] ||
                    subset[i - set[j-1]][j-1];
        }
    }

    return subset[sum][n];
}
```
可以分析出，只需要矩阵级别的复杂度就可以解决这个问题。

笔者用了大量的案例来说明解决某些问题，用动态规划的方式。后续将加上一些最短路径算法和经典背包问题的解法。

理解了动态规划的哲学，很大程度上，在做一些高性能的系统的时候一定会有更多的思路。
