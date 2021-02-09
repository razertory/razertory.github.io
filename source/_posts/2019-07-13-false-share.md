---
title: 伪共享 
date: 2019-07-13 20:41:36
tags: 操作系统
---

## 数组和链表谁快？
众所周知数组和链表有个区别在于数组是一段连续的内存空间。那么如果说存放的值一样，长度一样的数组和链表都做简单的遍历谁会更快呢？比如
```Java
public class CPUCache1 {
    // 遍历数组
    void traverseArray(int[] arr) {
        for (int i : arr) {
        }
    }

    // 遍历链表
    void traverseListNode(ListNode head) {
        while (head != null) head = head.next;
    }
}
```
测试代码
```java
public class CPUCache1Test {

    private int quantity = 1024 * 1024 * 10;

    @Test
    public void traverseArray() {
        int[] arr = new int[quantity];
        long now = System.currentTimeMillis();
        new CPUCache1().traverseArray(arr);
        System.out.println(System.currentTimeMillis() - now);
    }

    @Test
    public void traverseListNode() {
        ListNode head = new ListNode(0);
        ListNode tail = head;
        for (int i = 1; i < quantity; i++) {
            tail.next = new ListNode(0);
            tail = tail.next;
        }
        long now = System.currentTimeMillis();
        new CPUCache1().traverseListNode(head);
        System.out.println(System.currentTimeMillis() - now);
    }
}
```
在我这台的 MBP 上 traverseArray 耗费 5 毫秒，traverseListNode 耗费 26 毫秒。（多次测试稳定在这个数值）

### CPU 缓存
上述的案例中，遍历数组计算机利用到了 CPU 缓存从而加快了速度。

计算机系统中，CPU 缓存，内存，磁盘有着庞大的存取速度差异，所以往往会在这三者的协作之间通过设计缓存来达到更快的速度。
![](https://gitee.com/razertory/razertory-statics/raw/master/razertory-me/photo-1.jpg)

多核心 CPU 中的缓存是分层的，每个核心独有缓存模块，不过 L3 是多核心共享。当计算机收到找寻变量的指令的时候就会按照 L1，L2，L3 ，RAM 这样的顺序寻找。Java 语言中的数组其实就是在一定程度上部分存到了缓存当中。这里产生了一个叫做缓存行的东西，它是 CPU 缓存中的最小单元，占 64 字节（早期的 CPU 是 32 字节）。Java 中的一个 int 占 4 字节，意味着一个缓存行可以存下 16 个 int 类型的变量。在遍历的时候就能利用到从而加快速度。链表就没有这个福利了。

### 并发场景的 CPU 缓存
那么在并发的场景中，又该如何利用 CPU 缓存呢？比如说这段代码 [false_sharing.c](https://github.com/razertory/c-code-lab/raw/master/multithread/false_sharing.c) 在我的 Mac 上打印出了
```shell
1) 8.85049 4.8528e+08 ips
2) 22.4329 3.82917e+08 ips
3) 30.1988 4.26669e+08 ips
4) 35.8548 4.79151e+08 ips
```
原本认为，在每次增加线程的时候新的线程有着独立的内存空间。这个不假，但是内存中的一些数据会存入 CPU 缓存当中。在多核 CPU 中，每个核都会有自身独立的缓存区。当只有其中一个核的内容发生先变更的时候，由于内核发现内存中的变量和另一个未发生变更的内容不一致，这个时候就会花一定的时间去同步另一个核的内容。这个现象就称为**伪共享**（false sharing）。维基百科中伪共享的定义有这么一段

> False sharing is an inherent artifact of automatically synchronized cache protocols and can also exist in environments such as distributed file systems or databases, but current prevalence is limited to RAM caches.

大意为伪共享目前是自动同步缓存协议中固有的机制。

所以，现代编程语言如何解决这个问题的呢？

以 Ruby、Python 为代表的动态语言，天生有全局解释锁（GIL）这么个东西，任何一个时刻本质上只有一个线程在跑，也就不需要考虑这个问题。

以 Java，C++，Golang 为代表的静态语言采用补齐（Padding）的方式。比方说：Java 对象头占 8 个字节，如果定义的类所含的变量加起来也低于 64 个字节，那么就声明几个不用的变量让一个对象的实际内存大于 64 字节从而避免通过 CPU 缓存读写。在 Java 8 中，可以直接对一个对象加上 @sun.misc.Contended 并且开启 jvm 选项 -XX:-RestrictContended。
