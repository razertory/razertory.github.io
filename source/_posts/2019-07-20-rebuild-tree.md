---
title: 重建二叉树
date: 2019-07-20 20:29:49
tags: [algo]
---

### 用前序和中序遍历序列构建
输入
 ```
 pre: [1,2,4,7,3,5,6,8]
 in: [4,7,2,1,5,3,8,6]
 ```

 由 pre 得知 root 节点是 1，从而在 in 中找到 1，那么此时这棵树的 root 就是 1。并得出这个二叉树左子树由 [4, 7, 2] 构成，右子树由 [5, 3, 8, 6] 构成。从而确定左子树的 pre 是 [2, 4, 7], in 是 [4, 7, 2]。右子树 pre 是 [3, 5, 6, 8]，in 是 [5, 3, 8, 6]。对左右子树递归地用这个方法进行构建，最终当左右子树都为空的时候递归结束。

 找到 in 的 root 之后，根据 **root 到 开始节点中间的节点个数**可以对应地，确定 pre 的左子树和右子树。

 ```java
 // https://leetcode.com/problems/construct-binary-tree-from-preorder-and-inorder-traversal
 class Solution {
    public TreeNode buildTree(int[] preorder, int[] inorder) {
        if (preorder == null || inorder == null) return null;
        Map<Integer, Integer> map = new HashMap<>();
        for (int i = 0; i < inorder.length; i++) {
            map.put(inorder[i], i);
        }
        return build(preorder, 0, preorder.length - 1, 0, map);
    }

    private TreeNode build(int[] pre, int preStart, int preEnd, int inStart, Map<Integer, Integer> inPos) {
        if (preStart > preEnd) return null;
        int rootVal = pre[preStart];
        TreeNode root = new TreeNode(rootVal);
        int rootIndex = inPos.get(rootVal);
        int leftLen = rootIndex - inStart;
        root.left = build(pre, preStart + 1, preStart + leftLen, inStart, inPos);
        root.right = build(pre, preStart + leftLen + 1, preEnd, rootIndex + 1, inPos);
        return root;
    }
}
 ```


### 用中序和后序遍历序列构建
