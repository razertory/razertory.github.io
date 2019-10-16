---
title: 顺序打印
date: 2019-10-16 08:03:29
published: false
tags: [os, oj]
---
截止到目前，Leetcode 上已经出了 6 道并发编程相关的题。对于并发编程，如果光是看文档和资料没有实践总是不够的。接下来打算把这 6 道题都做完（Java）并且尽量分析多种方法。

#### print-in-order
[原题](https://leetcode.com/problems/print-in-order/) 说的是：给一个类

```java
public class Foo {
  public void first() { print("first"); }
  public void second() { print("second"); }
  public void third() { print("third"); }
}
```
Foo 类会被 A，B，C 三个线程分别调用里面的 `first()`，`second()`， `third()`。要求的是打印输出一定是保证了 `second()` 在 `first()` 后面，`third()` 在 `second()` 后面。

同时，给出了一个代码模板。我们要做的就是完善里面的内容。

```java
class Foo {
    public Foo() {
    }

    public void first(Runnable printFirst) throws InterruptedException {
        printFirst.run();
    }

    public void second(Runnable printSecond) throws InterruptedException {
        printSecond.run();
    }

    public void third(Runnable printThird) throws InterruptedException {
        printThird.run();
    }
}
```