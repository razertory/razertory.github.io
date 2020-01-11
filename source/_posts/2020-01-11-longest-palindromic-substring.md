---
title: 最长回文子串
date: 2020-01-11 10:00:36
---
给一个字符串 s，找到其中最长的回文串。[传送门](https://leetcode.com/problems/longest-palindromic-substring/)

---

回文串有两种模式，一种是 aabb 类型，另一种是 aacbb 类型。当我们对一个字符串做是否是回文的时候可以实现一个 expand 函数用作判断`int expand(String s, int lelf, int right)` 当 s[left] == s[right] 且 left 和 right 没有到达字符串边界的时候计算长度即 `right - left + 1`。

实现了 expand 之后，对于任意字符串可以确认：

1. 字符串长度为 1 的时候，本身就是回文串
2. 字符串长度为 2 的时候，判断两个字符是否相等，相等说明本身是，否则和 1 一致
3. 字符串长度为 n 的时候，在对字符串进行从左到右扫描找到最大值 `max (expand(s, i, i), expand(s, i, i + 1))`

```java
class Solution {
    public String longestPalindrome(String s) {
        int start = 0, max = 0;
        for (int i = 0; i < s.length(); i++) {
            int len1 = expand(s, i, i);
            int len2 = expand(s, i, i + 1);
            int len = Math.max(len1, len2);
            if (len > max) {
                start = i - (len-1)/2;
                max = len;
            }
        }
        return s.substring(start, start + max);
    }
    
    int expand(String s, int left, int right) {
        while(left >= 0 && right < s.length() && s.charAt(left) == s.charAt(right)){
            left--;
            right++;
        }
        return right - left - 1;
    }
}
```