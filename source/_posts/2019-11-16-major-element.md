---
title: 个数多于一半的数 
date: 2019-11-16 20:08:11
tags: 
---
给定一个大小为 n 的数组，找出其中在数组中出现次数大于 ⌊ n/2 ⌋ 的元素（众数）。

```java
int majorityElement(int[] nums)
```

理解这个问题，首先可以把数组分为两个部分：所有的众数和非众数。把众数和非众数进行两两抵消，那么最后一定还剩下众数。实际上这个也就是摩尔投票法。在遍历数组的时候不断确认当前的众数，如果没有，则认为下一个就是。维护一个计数器，在遇到相同的时候给众数 +1，不同的时候 -1。当计数器为 0 的时候认为没有众数。

```java
int majorityElement(int[] nums) {
    int count = 0;
    Integer candidate = null;

    for (int num : nums) {
        if (count == 0) {
            candidate = num;
        }
        count += (num == candidate) ? 1 : -1;
    }

    return candidate;
}
```