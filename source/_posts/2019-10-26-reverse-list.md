---
title: 反转链表
date: 2019-10-26 14:05:27
tags:
---
输入一个链表，反转链表后，输出新链表的表头。
Example:

```
Input: 1->2->3->4->5->NULL
Output: 5->4->3->2->1->NULL
```

[传送门](https://leetcode.com/problems/reverse-linked-list/submissions/)

---
反转的过程需要提前准备好下个节点的，用到两个指针，cur 和 pre 指向新节点和用于存放原本的下个节点

```java
ListNode reverseList(ListNode head) {
    ListNode cur = head, pre = null;
    while (cur != null) {
      ListNode next = cur.next; // 提前准备好指向下个节点
      cur.next = pre;
      pre = cur;
      cur = next;
    }
    return pre;
}
```