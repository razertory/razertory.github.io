---
title: 链表相加
date: 2019-10-26 14:38:48
tags: [algo]
---
You are given two non-empty linked lists representing two non-negative integers. The digits are stored in reverse order and each of their nodes contain a single digit. Add the two numbers and return it as a linked list.You may assume the two numbers do not contain any leading zero, except the number 0 itself.

```java
ListNode addTwoNumbers(ListNode l1, ListNode l2) 
```

这道题本质上就是在模拟加法运算中进位的过程。

```java
ListNode addTwoNumbers(ListNode l1, ListNode l2) {
    ListNode dummy = new ListNode(0), p = dummy;
    int carry = 0;
    while (l1 != null || l2 != null || carry != 0) {
        int cur = carry;
        if (l1 != null) {
            cur += l1.val;
            l1 = l1.next;
        }
        if (l2 != null) {
            cur += l2.val;
            l2 = l2.next;
        }
        p.next = new ListNode(cur % 10);
        p = p.next;
        carry = cur / 10;
    }
    return dummy.next;
}
```