---
title: 有序数组转化为平衡二叉搜索树树（BST）
date: 2019-12-12 21:41:57
tags: [algo]
---
给定一个有序数组，数组元素升序排列，试将该数组转换为一棵平衡二叉搜索树（Balanced Binary Search Tree）。

```java
TreeNode convertToBST(ArrayList<Integer> arr) 
```

根据 BST 的定义 *二叉排序树的查找过程和次优二叉树类似，通常采取二叉链表作为二叉排序树的存储结构。中序遍历二叉排序树可得到一个关键字的有序序列，一个无序序列可以通过构造一棵二叉排序树变成一个有序序列，构造树的过程即为对无序序列进行排序的过程。每次插入的新的结点都是二叉排序树上新的叶子结点，在进行插入操作时，不必移动其它结点，只需改动某个结点的指针，由空变为非空即可。搜索,插入,删除的复杂度等于树高，O(log(n)).* 可以对其进行反中序的遍历。也就是 中-左-右 的一个逆向过程

```java
TreeNode convertToBST(ArrayList<Integer> arr) {
    if (arr == null || arr.length == 0)
    return null;
    return convert(arr, 0, arr.length - 1);
}
TreeNode convert(ArrayList<Integer> arr, int start, int end) {
    if (start > end) return null;
    int mid = start + (end - start) / 2;
    TreeNode node = new TreeNode(arr[mid]);
    node.left = convert(arr, start, mid - 1);
    node.right = convert(arr, mid + 1, end);
    return node;
}
```