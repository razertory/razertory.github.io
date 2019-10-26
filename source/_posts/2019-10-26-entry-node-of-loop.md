---
title: 链表环的入口
date: 2019-10-26 14:28:43
tags: [algo]
---
给一个链表，若其中包含环，请找出该链表的环的入口结点，否则，输出null。

```java
ListNode EntryNodeOfLoop(ListNode pHead) 
```
定义一个慢和一个快指针，当两个指针相遇的时候。快指针速度和慢指针一致，等再次相遇的时候这个点就是环入口。
```java
ListNode EntryNodeOfLoop(ListNode pHead) {
    if (pHead == null || pHead.next == null) return null;
    ListNode slow = pHead, fast = pHead;
    while(fast != null && fast.next != null){
        slow = slow.next;
        fast = fast.next.next;
        if (fast == slow) {
            slow = pHead;
            while(slow != fast){
                slow = slow.next;
                fast = fast.next;
            }
            return slow;
        }
    }
    return null;
}
```
