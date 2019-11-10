---
title: 栈实现队列
date: 2019-11-10 09:45:31
tags: [algo]
---

维护一个 in，out 栈表示进出顺序，实现一个从 in 到 out 的转移方法。

```java
class MyQueue {

    private Stack<Integer> in, out;

    MyQueue() {
        in = new Stack<>();
        out = new Stack<>();
    }

    void push(int val) {
        in.push(val);
    }

    int pop() {
        transferIfEmpty();
        return out.pop();
    }

    int peek() {
        transferIfEmpty();
        return out.peek();
    }

    boolean isEmpty() {
        return in.isEmpty() && out.empty();
    }

    private void transferIfEmpty() {
        if(out.empty()) {
            while(!in.empty()) {
                out.push(in.pop());
            }
        }
    }
}
```
