---
title: 判断是否是子树
date: 2019-10-27 15:49:47
tags: [algo]
---

输入两棵二叉树A，B，判断B是不是A的子结构。（ps：我们约定空树不是任意一个树的子结构）

```java
boolean HasSubtree(TreeNode root1,TreeNode root2)
```
首先在 A 中找到一个节点，满足这个节点是 B 的 root 节点，在此基础上按照 B 的结构遍历 A，B。

```java
boolean HasSubtree(TreeNode root1,TreeNode root2) {
    boolean result =false;
    if(root1!=null&&root2!=null){
    if(root1.val==root2.val)
        result=isSubtree(root1,root2);
    if(!result)
        result= HasSubtree(root1.left,root2);
    if(!result)
        result= HasSubtree(root1.right,root2);
    }
    return result;
}

boolean isSubtree(TreeNode root1,TreeNode root2){
	if(root1==null&&root2!=null)
		return false;
	if(root2==null)
		return true;
	if (root1.val!=root2.val)
		return false;
	return isSubtree(root1.left, root2.left) && isSubtree(root1.right, root2.right);
}
```