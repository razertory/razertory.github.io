---
title: 最大子数组和
date: 2019-06-02 07:59:54
tags: [algo]
---
给定一个数组，如 arr = [1,-3,4,2,-7,-1,8,10] 求最大子数组和。

### 累计法
对于任意一个子序列，如果他的前面数的和是正数，说明这个子序列的和可以继续变大。不断维护一个当前可以用来加给第 i 个元素的子序列最大值 max。当 max < 0 的时候就重置为 0。可以推导出 
`sum(i) = max(sum(i-1), max + arr[i])`

```java
public class Solution {
    // Time: O(n), Space: O(1)
    public int FindGreatestSumOfSubArray(int[] array) {
        if (array == null || array.length == 0) return 0;
        int max = 0;
        int sum = Integer.MIN_VALUE;
        for (int i = 1; i < array.length; i++) {
            max += array[i - 1];
            max = Math.max(max, 0);
            sum = Math.max(sum, max + array[i]);
        }
        return sum;
    }
}
```

### 动态规划
如果能找到状态转移方程，那也是极好的。当前子数组的最大值，其实就是前面子数组的最大值，加上当前元素和当前元素比较。

`sum(i) = max(sum(i-1) + arr[i], arr[i])`

```java
public class Solution1 {
    // Time: O(n), Space: O(n)
    public int FindGreatestSumOfSubArray(int[] array) {
        if (array == null || array.length == 0) return 0;
        int[] dp = new int[array.length];
        int result = array[0];
        dp[0] = result;
        for (int i = 1; i < array.length; i++) {
            dp[i] = Math.max(dp[i - 1] + array[i], array[i]);
            result = Math.max(dp[i], result);
        }
        return result;
    }
}
```