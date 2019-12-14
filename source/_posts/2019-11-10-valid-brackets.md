---
title: 括号的合法序列
date: 2019-11-10 09:55:10
tags: 
---

给你一个括号序列，里面包含小括号，中括号和大括号。你要判断这个括号序列是否有效。有效的括号序列要求，每个左括号都必须有一个同类的右括号与它正确配对。另外，空字符串认为是有效的括号序列。

```
比如说，给你的序列是：

()[]{}

小括号/中括号/大括号的左右括号都能正确配对，因此这是一个有效的括号序列。

再比如说给你的序列是：

([)]

这里面虽然正好有一对小括号和一对中括号，但它们的顺序不对，括号间无法正确配对，因此这不是一个有效的括号序列
```

```java
public boolean isValidBrackets(String s) {
```

维护一个 stack，存放 char。在遍历 s 的过程中，不断对遇到左括号进行 push，右括号进行 pop。当最后 stack 为空的时候说明是合法的括号序列.

```java
public boolean isValidBrackets(String s) {
    Stack<Character> stack = new Stack<>();

    for (int i = 0; i < s.length(); ++i) {
      if (s.charAt(i) == '(' || s.charAt(i) == '[' || s.charAt(i) == '{') {
        stack.push(s.charAt(i));
      } else if (stack.isEmpty()) {
        return false;
      } else {
        if (s.charAt(i) == ')' && stack.peek() != '(') return false;
        if (s.charAt(i) == ']' && stack.peek() != '[') return false;
        if (s.charAt(i) == '}' && stack.peek() != '{') return false;
        stack.pop();
      }
    }
    return stack.isEmpty();
  }
```
