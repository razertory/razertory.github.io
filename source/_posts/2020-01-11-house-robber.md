---
title: 抢劫房子
date: 2020-01-11 09:33:19
---

你是一个专业的小偷，计划偷窃沿街的房屋。每间房内都藏有一定的现金，影响你偷窃的唯一制约因素就是相邻的房屋装有相互连通的防盗系统，如果两间相邻的房屋在同一晚上被小偷闯入，系统会自动报警。
给定一个代表每个房屋存放金额的非负整数数组，计算你在不触动警报装置的情况下，能够偷窃到的最高金额。

[传送门](https://leetcode.com/problems/house-robber/)

---
假设房子定义为 `house[i]`

房屋数量是 1 的时候，小偷只能偷这一家 `house[0]`。

房屋数量是 2 的时候，小偷从现有的选一个多的，也就是 `max(house[0], house[1])`

房屋数量是 3 的时候，小偷的选择为 `max(house[0] + house[2], house[1])`

如果我们知道房屋数量为 i - 1 的时候，小偷的最佳选择是 `d[i-1]`，那么当再增加一个房屋，即房屋数量为 i 的时候。依据题意可以推导出

```ruby
d[i] = max(house[i] + d[i-2], d[i-1])
```
翻译成代码就是 

```java
class Solution {
    public int rob(int[] nums) {
        if (nums == null || nums.length == 0) return 0;
        int[] d = new int[nums.length];
        for (int i = 0; i < nums.length; i++) {
            if (i == 0) d[i] = nums[i];
            else if (i == 1) d[i] = Math.max(nums[i], nums[i-1]);
            else d[i] = Math.max(d[i-2] + nums[i], d[i-1]);
        }
        return d[nums.length - 1];
    }
} 
```


