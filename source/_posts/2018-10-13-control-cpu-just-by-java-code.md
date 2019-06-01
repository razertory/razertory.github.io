---
layout: post
title: "Java 控制 CPU 占用"
date: 2018-10-13 00:40:18 +0800
tags: [os]
---

选自《编程之美》。

在日常工作中，我们时不时会去看服务器的性能，比较关键的一个就是 CPU 占有率。那么 CPU 占有率到底是什么呢？在本书中就可以找到答案。用 Java 可以实现一个简单的版本用于更深入理解 CPU。

`CPU 占有率：` 在任务管理器的一个刷新周期内，CPU 忙（执行应用程序）的时间和刷新周期总时间的比率， 就是 CPU 的占用率，也就是说，任务管理器中显示的是每个刷新周期内 CPU 占用率的统计平均值。
因此，我们可以写一个程序，让它在任务管理器的刷新期间内一会儿忙， 一会儿闲， 然后通过调节忙／ 闲的比例， 就可以控制任务管理器中显示的 CPU 占用率。

可以同时参考操作系统原理中，描述进程管理的时候说道：操作系统在运行的时候有一个个的进程，这些进程或忙，或闲。很多人都只关注了进程忙的时候做了什么而忽略了进程闲的手
在干什么。实际上，进程闲的时候通常有以下状态：

* 等待用户输入
* 监听事件发生
* 处于休眠状态

也就是说：可以通过实现以上三种状态的任意一种，通过代码级别的控制在实现。

占用 cpu 最简单的方式就是一个循环
```java
while(true){} // 考虑执行的时候程序在占用 CPU
```
不占用 cpu 最简单的方式就是让 CPU 休眠
```java
 Thread.sleep(TIME)
```
最终需要的是一会儿占用一会儿不占用，同时这个控制是人为通过程序干预的，当前我们考虑只是单核的情况。

实际上，操作系统统计 CPU 占有率很简单的一个实现就是，在单位时间 T 中，CPU 存在繁忙时间 R，和空闲时间 I。通常情况下，对于单核 CPU 而言， T = R + I

> CPU 占有率 = R/T

如果有兴趣，可以把代码贴下来跑一下。
```java
public class ControlCPU{
    public static final double TIME = 1000;  //TIME= 周期

    private static void control(double rate) throws InterruptedException{
        while (true){
            runCPU(rate * TIME);
            Thread.sleep((long) (TIME - rate * TIME));
        }
    }

    private static void runCPU(double time) {
        long startTime = System.currentTimeMillis();
        while ((System.currentTimeMillis() - startTime) < time) {
        }
    }

    public static void main(String[] args) throws InterruptedException {
        control(0.5);
    }
}
```
以上在 MacOS 10 运行中，CPU 占有率维持在了 50% 左右。（注意只会有一个 CPU 核心是被利用了）。书中还有很多高级的做法，比如实现一条 sin 三角函数曲线、多核心下的处理。如果有兴趣可以一起分享一下。
