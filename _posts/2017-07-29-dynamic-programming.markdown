---
layout: post
title:  "我所理解的动态规划"
date:   2017-07-29 +0800
categories: jekyll update
---

一直觉得，程序员分为两种，一种是懂动态规划的，另一种是不懂的。但是自从毕业参加工作以来，发现自己貌似游走在懂与不懂的边缘。所以写下这个博文记录理解动态规划的历程。

记得看过一篇文章说：“为什么很多顶级的团队会在意一个研发会不会动态规划。那么从动态规划的本质来说，就是加缓存”。绝大多数的系统，都会一定程度的使用缓存。对于动态规划来说，缓存就是将程序算过的东西存到一个地方，当下次再需要做一样的事情的时候，就从缓存区里面取值。从程序员的哲学来说，这也是DRY原则。

先从一个题目说起吧

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