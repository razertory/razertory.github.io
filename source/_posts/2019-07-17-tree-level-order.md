---
title: 各种层序遍历二叉树
date: 2019-06-17 12:48:27
tags: 
---
## BFS 
BFS 我觉得可以从两个方向理解。第一种，对某个树或者图的数据结构而言，就是某个节点相连接的节点都遍历，再不断对刚遍历的节点做同样的操作直到最后遍历完所有节点。第二种，当数据结构是树形的时候这个规律可以衍生为按照层来遍历。按照当前的理解，BFS 一般可以用一个队列来实现，这是因为按照 FIFO 的特性。对于节点相连接的节点都遍历的时候，遍历结束了之后需要从最第一个遍历的节点开始。

![](http://ww1.sinaimg.cn/large/a67b702fly1g52r53xyfvj205v07fwei.jpg)
输出：

1, 2, 3, 4, 5, 6, 7, 8

```Java
public class Tree {
    private ArrayList<Integer> order = new ArrayList<>();
   // T:O(n) T:O(n)
   ArrayList bfsSearch(TreeNode root) {
        Queue<TreeNode> queue = new LinkedList<>();
        queue.offer(root);
        while(!queue.isEmpty()) {
            TreeNode node = queue.poll();
            if (node != null) {
                order.add(node.value);
                queue.offer(node.left);
                queue.offer(node.right);
            }
        }
        return order;
    }
}
```

## 层序遍历二叉树
在 BFS 的基础上，期待上面的遍历结果能已分层的形式输出：
1
2 3
4 5 6
7 8
这个问题在《编程之美》和《剑指 Offer》上面都出现过。

其实只要模拟一下队列的出入过程就能发现，BFS 过程中维护的队列总是在不断的 offer 和 poll。当第 1 层的 #1 poll 的时候，第 2 层的 #2，#3 offer..., 第 2 层 #2 poll 的时候，第 3 层的 #4, #5 offer，第二层的 #3 poll 的时候。.. 也就是说，如果能知道第二层层结束了那么就有办法了。

回过头再看，第一层的 #1 两个子节点 offer 之后。队列的 size 变成了 2。如果维持一个计数器表示当计数器的值从在 [0, size] 之间的时候表示第二层正在 poll, 第三层正在 offer，那么就能表示层级的变化。

```java
public class Solution {

    // T:O(n) T:O(n)
    ArrayList<ArrayList<Integer>> Print(TreeNode pRoot) {
        ArrayList<ArrayList<Integer>> ret = new ArrayList<>();
        if (pRoot == null) return ret;
        Queue<TreeNode> queue = new LinkedList<>();
        queue.offer(pRoot);

        while(!queue.isEmpty()) {
            ArrayList<Integer> thisLevel = new ArrayList<>();
            int low = 0, high = queue.size();
            for (int i = low; i < high; i++) {
                TreeNode node = queue.poll();
                thisLevel.add(node.val);
                if (node.left != null) queue.offer(node.left);
                if (node.right != null) queue.offer(node.right);
            }
            ret.add(thisLevel);
        }
        return ret;
    }
}
```
