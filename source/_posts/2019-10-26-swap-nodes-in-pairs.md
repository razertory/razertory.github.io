---
title: 链表中交换节点
date: 2019-10-26 14:47:13
tags: 
---
Given a linked list, swap every two adjacent nodes and return its head.
You may not modify the values in the list's nodes, only nodes itself may be changed.

```java
ListNode swapPairs(ListNode head) 
```
由于要交换前后两个链表节点，定义一个 dummy，cur。那么核心就是交换 cur.next 和 cur.next.next。
```java
ListNode swapPairs(ListNode head) {
    ListNode dummy = new ListNode(0);
    dummy.next = head;
    ListNode cur = dummy;
    while(cur.next != null && cur.next.next != null) {
        ListNode a = cur.next, b = cur.next.next;
        cur.next = b;
        a.next = b.next;
        b.next = a;
        cur = a;
    }
    return dummy.next;
```
