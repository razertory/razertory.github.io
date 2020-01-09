---
title: 买卖股票的最大利润
date: 2020-01-09 13:02:03
tags:
---
假设把某股票的价格按照时间先后顺序存储在数组中，请问买卖 一次 该股票可能获得的利润是多少？

例如一只股票在某些时间节点的价格为 [9, 11, 8, 5, 7, 12, 16, 14]。

如果我们能在价格为 5 的时候买入并在价格为 16 时卖出，则能收获最大的利润 11。
[传送门](https://leetcode.com/problems/best-time-to-buy-and-sell-stock/)


---

股票最大利润，其实就是个从头到尾一直更新最大利润。最大利润 = Math.max(前面的最大利润，当前股票价格 - 前面最低价格)
 
```java
  public int maxProfit(int[] nums) {
      if (nums == null || nums.length == 0) return 0;
      int min = nums[0], maxProfit = 0;
      for (int i = 1; i < nums.length; i++) {
          min = Math.min(min, nums[i]);
          maxProfit = Math.max(maxProfit, nums[i] - min);
      }
      return maxProfit;
  } 
```

