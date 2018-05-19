---
layout: post
title:  "我所理解的动态规划"
date:   2017-07-29 +0800
categories: jekyll update
---

一直觉得，程序员分为两种，一种是懂动态规划的，另一种是不懂的。但是自从毕业参加工作以来，发现自己貌似游走在懂与不懂的边缘。所以写下这个博文记录理解动态规划的历程。

记得看过一篇文章说：“为什么很多顶级的团队会在意一个研发会不会动态规划。那么从动态规划的本质来说，就是加缓存”。绝大多数的系统，都会一定程度的使用缓存。对于动态规划来说，缓存就是将程序算过的东西存到一个地方，当下次再需要做一样的事情的时候，就从缓存区里面取值。从程序员的哲学来说，这也是DRY原则。

先从一个题目说起吧

## 约翰的后花园

约翰想在他家后面的空地上建一个后花园，现在有两种砖，一种3 dm的高度，7 dm的高度。约翰想围成x dm的墙。如果约翰能做到，输出YES，否则输出NO。（https://www.lintcode.com/problem/johns-backyard-garden/description）

### 分析

很经典的一个问题。判断能不能被3 build，如果不能就回溯，直到判断被7build或者到栈顶。实现起来也比较容易：
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
本来以为这样的算法效率并不高，因为要反复执行 `||`运算。然而，然而，some times too naive |-_- 。事实是速度并不慢。在 `||`运算中，只要有一个`true`产生。那么这个表达式的值一定是true。对于布尔运算的递归程序同样适用。所以在debug阶段可以看到当helper里面一旦有`true`的时候。递归就会停止。这里不得不佩服前人做的努力。

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
这段代码简洁而又优美，但实际上性能真的很差。从实际的角度出发，在我自己的 MBP 2017，CPU 3.1 GHz Intel Core i5的电脑上。i = 40 ， 最终结果=102334155 的时候，跑到出结果花了869 ms。从分析的角度出发，这种递归程序有一个特质，就是大量重复的计算。举个例子：当 i = 5， 程序递归下去实际上执行了2个fib(3)和3个fib(2)。可以考虑的是，发生过的事情，真的需要让他再发生吗？是不是只需要记忆结果，那么下次再有同样的需求发生的时候，只需要去取得结果，而不再是计算相同的任务了。

所以，试着加上缓存。做法就是维护一个数据结构，将计算过的任务的结果保存在里面。
```java
int []cache = new int[10000]; //暂时用这么大，先不考虑极大情况。
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
好了，测试一发。嗯，结果正确。看看性能：不到5ms。

理解了动态规划的哲学，很大程度上，在做一些高性能的系统的时候一定会有更多的思路。