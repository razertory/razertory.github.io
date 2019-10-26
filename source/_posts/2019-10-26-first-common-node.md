---
title: 链表的公共节点
date: 2019-10-26 14:23:52
tags: [algo]
---
输入两个链表，找出它们的第一个公共结点。
```java
ListNode FindFirstCommonNode(ListNode pHead1, ListNode pHead2) 
```
首先计算出两个链表的各自长度，然后计算出一个差值 delta。然后基于 delta 的值走对应的节点，当 delta 变为 0 的时候停止。并判断是否有公共节点

```java
ListNode FindFirstCommonNode(ListNode pHead1, ListNode pHead2) {
    if (pHead1 == null || pHead2 == null ) return null;
    ListNode node1 = pHead1, node2 = pHead2;
    int len1 = 0, len2 = 0;

    for (; node1 !=null; node1 = node1.next, len1++);
    for (; node2 !=null; node2 = node2.next, len2++);

    int delta = len1 - len2;

    node1 = pHead1; node2 = pHead2;
    while (delta > 0) {
        node1 = node1.next;
        delta--;
    }
    while (delta < 0) {
        node2 = node2.next;
        delta++;
    }
    while (node1 != node2) {
        node1 = node1.next;
        node2 = node2.next;
    }
    return node1;
}
```
