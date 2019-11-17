---
title: 汉明距离
date: 2019-11-17 10:46:03
tags: [algo]
---

两个整数之间的汉明距离指的是这两个数字对应二进制位不同的位置的数目。给出两个整数 x 和 y，计算它们之间的汉明距离。

```java
int hammingDistance(int x, int y)
```

对于 x, 和 y 先进行异或，然后再计算结果中的 1 的个数即可。（其中 count 算法来自 [二进制中 1 的个数](/2019/11/14/count-of-one/)）

```java
int hammingDistance(int x, int y) {
    int n = x ^ y;
    return count(n); 
}
```
