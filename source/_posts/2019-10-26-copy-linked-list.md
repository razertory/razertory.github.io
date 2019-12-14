---
title: 复制复杂链表
date: 2019-10-26 14:14:46
tags: 
---
输入一个复杂链表（每个节点中有节点值，以及两个指针，一个指向下一个节点，另一个特殊指针指向任意一个节点），返回结果为复制后复杂链表的 head。

```java
public class RandomListNode {
    int label;
    RandomListNode next = null;
    RandomListNode random = null;
    RandomListNode(int label) {
        this.label = label;
    }
}
  public RandomListNode Clone(RandomListNode pHead) 
```
每个链表都有两个指针，这种情况下最简单的做法是用一个 k, v 的方式存放所有的节点以及新的只有 label，指针指向的节点为空的节点。然后用原来的节点指针指向的值复制到新节点。

```java
RandomListNode Clone(RandomListNode pHead) {
    HashMap<RandomListNode, RandomListNode> map = new HashMap<>();
    RandomListNode cur = pHead;
    while(cur != null) {
        map.put(cur, new RandomListNode(cur.label));
        cur = cur.next;
    }
    cur = pHead;
    while(cur != null) {
        map.get(cur).next = map.get(cur.next);
        map.get(cur).random = map.get(cur.random);
        cur = cur.next;
    }
    return map.get(pHead);
}
```

