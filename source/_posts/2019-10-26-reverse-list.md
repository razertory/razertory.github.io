---
title: 反转链表
date: 2019-10-26 14:05:27
tags: 
---
输入一个链表，反转链表后，输出新链表的表头。
```java
ListNode reverseList(ListNode head) 
```
反转的过程需要用到两个指针，cur 和 pre 指向新节点和用于存放原本的下个节点

```java
ListNode reverseList(ListNode head) {
    ListNode cur = head, pre = null;
    while (cur != null) {
      ListNode next = cur.next;
      cur.next = pre;
      pre = cur;
      cur = next;
    }
    return pre;
}
```