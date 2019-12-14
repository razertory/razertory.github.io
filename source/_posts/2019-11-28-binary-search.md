---
title: 完美的二分搜索
date: 2019-11-28 22:45:06
tags: 
---

> 假设给一个有序的 int 类型的数组 arr，和一个目标值 target，找到这个目标值在数组中的下标。如果数组中没有
target 返回 -1。

```java
int search(int[] arr, int target) {
    int start = 0, end = arr.length - 1;
    while (start <= end) {
        int mid = start + (end - start) / 2; // 需要注意用 (start + end) / 2 在数学上没有问题。但是考虑到 start + end 可能会溢出。
        if (target == arr[mid]) 
            return mid;
        else if (target < arr[mid])
            end = mid - 1;
        else
            start + mid + 1;
    }
    return -1;
}
```

