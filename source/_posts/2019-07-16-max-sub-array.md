---
title: 最大子序列
date: 2018-12-16 22:14:05
tags: 
---

### 题目
给定一个整数数组 nums ，找到一个具有最大和的连续子数组（子数组最少包含一个元素），返回其最大和。示例：

```shell
输入：[-2,1,-3,4,-1,2,1,-5,4],
输出：6
解释：连续子数组 [4,-1,2,1] 的和最大，为 6。
```

### 暴力法
把所有子序列都找出来并求出最大和。利用两个循环，外循环记录开始下标，内循环记录结束下标。不断维护一个最大 sum。
``` Java
class Solution {
    // T:O(n^2) S:O(1)
    public int maxSubArray(int[] nums) {
        if (nums == null || nums.length == 0) return 0;
        int max = nums[0];
        for (int i = 0; i < nums.length; i++) {
            int cur = 0;
            for (int j = i; j < nums.length; j++) {
                cur += nums[j];
                max = Math.max(max, cur);
            }
        }
        return max;
    }
}
```

### 在线处理法
在线处理意味着在每次循环过程中都计算出一个当前最终值。遍历过程中维护一个 cur 用来表示当前的值左边的最大非负数的和。如果 cur 小于 0 意味着舍弃掉，反之就带上。在加上了当前值之后，由于当前值的正负，所以还需要维护一个 max 用来找到最大值。

```Java
class Solution {
    // T:O(n) S:O(1)
    public int maxSubArray(int[] nums) {
        int cur = 0, max = Integer.MIN_VALUE;
        for (int i = 0; i < nums.length; i++) {
            cur = cur <= 0 ? nums[i] : (cur + nums[i]);
            max = Math.max(max, cur);
        }
        return max;
    }
}
```

### 动态规划法
假设函数 f(i) 表示下标从 0 到 i 的子序列最大值。

假设数组为 [-2]，f(0) = -2 

假设数组为 [-2, 1]， f(1) = 1

假设数组为 [-2, 1, -3]， f(2) = 1

从上述可以发现。f(1) 可以看成 f(0) + nums[1] 与 nums[1] 比较的较大值；并且 f(2) 也满足这个条件。 那么可以容易得到状态转移方程：f(i) = max(f(i - 1) + nums[i], nums[i])。写出代码就是
```java
class Solution {
    // T:O(n) S:O(n)
    public int maxSubArray(int[] nums) {
        if (nums == null || nums.length == 0) return 0;
        int[] dp = new int[nums.length];
        int result = nums[0];
        dp[0] = result;
        for (int i = 1; i < nums.length; i++) {
            dp[i] = Math.max(dp[i - 1] + nums[i], nums[i]);
            result = Math.max(dp[i], result);
        }
        return result;
    }
}
```
