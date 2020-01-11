---
title: 二维数组中和最小路径
date: 2020-01-11 10:38:44
tags:
---
在一个 m * n 大的非负组整数组成的二维数组中，找到一条从 left-top 到 right-bottom 的和最小的路径。输出这个路径的值。[传送门](https://leetcode.com/problems/minimum-path-sum/)

---

```ruby
[
  [1,3,1],
  [1,5,1],
  [4,2,1]
]
```
在这样一个矩阵中，从 `m[0][0]` 到 `m[2][2]` 的最短路径，可以看作是 `m[0][0]` 到 `m[1][2]` 的最短路径 (1->3->1->1) 以及 `m[2][1]` 的最短路径中取到的最小值 (1->1->4->2) 加上 `m[2][2]` 取到的最小值 1->3->1->1->1。因此可以得到关系式 

`dp[m][n] = min(dp[m-1][n], dp[m][n-1]) + g[m][n]`

利用这个关系式，处理好 m，n 为 0 的边界情况即可得出最短路径

```java
class Solution {
    // dp[m][n] = min(dp[m-1][n], dp[m][n-1]) + g[m][n] 
    public int minPathSum(int[][] g) {
        if (g == null || g[0] == null)  return 0;
        int h = g.length, w = g[0].length;
        int[][] dp = new int[h][w];
        dp[0][0] = g[0][0];
        for (int i = 0; i < h; i++)
            for (int j = 0; j < w; j++) {
                if (i == 0 && j == 0)
                    continue;
                if (i == 0)
                    dp[i][j] = dp[i][j-1] + g[i][j];
                else if (j == 0)
                    dp[i][j] = dp[i-1][j] + g[i][j];
                else
                    dp[i][j] = Math.min(dp[i-1][j], dp[i][j-1]) + g[i][j];
            }
        return dp[h-1][w-1];
    }
}
```
