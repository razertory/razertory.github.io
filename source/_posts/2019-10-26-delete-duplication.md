---
title: 有序链表去重
date: 2019-10-26 14:32:58
tags:
---
在一个排序的链表中，存在重复的结点，请删除该链表中重复的结点，重复的结点不保留，返回链表头指针。 例如，链表1->2->3->3->4->4->5 处理后为 1->2->5

[传送门](https://www.nowcoder.com/practice/fc533c45b73a41b0b44ccba763f866ef)

---
定义一个 dummy 节点，pre，cur 节点。比较 pre.next 和 cur。如果相同让 pre = pre.next 做删除操作

```java
ListNode deleteDuplication(ListNode pHead) {
    if (pHead == null) return null;
    ListNode dummy = new ListNode(0);
    dummy.next = pHead;
    ListNode prev= dummy, cur = pHead;
    while (cur != null) {
        while(cur.next != null && cur.val == cur.next.val) cur = cur.next;
        if (prev.next != cur)
            prev.next = cur.next;
        else
            prev = prev.next;
        cur = prev.next;
    }
    return dummy.next;
}
```
