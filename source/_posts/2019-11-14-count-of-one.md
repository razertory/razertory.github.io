---
title: 二进制中 1 的个数
date: 2019-11-14 09:42:44
tags: 
---

对于任意整数，求转换成二进制数之后，1 的个数。比如 5 转换成二进制是 101，其中 1 的个数是 2。

```java
int count (int num)
```

要判断一个二进制数的最低位是否是 1，只需要和 1 进行 `&` 运算即可。那么具体的做法就一边移位一边统计。

```java
int count (int num) {
    int count = 0;
    while(num != 0) {
        if (num & 1 == 1) count++;
        num >> 1;
    }
    return count;
}
```
