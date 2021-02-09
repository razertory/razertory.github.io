---
title: 「Linux 内核」中断
date: 2020-04-12 13:50:04
tags: [操作系统]
---

### 中断信号
中断机制，简单说就是键盘、鼠标、磁盘之类的硬件，在需要的时候向内核发信号的一种机制。比如我此刻正在用键盘打字，其实就是在发出电信号给一个名叫「中断控制器」的物理芯片中，再通过一个和处理器直连的管线给处理器。处理器接收到之后，监测到了是中断信号，就会中断当前的工作处理该信号进而告诉操作系统，让操作系统处理这个信号。不同的中断信号，有的着唯一的 IRQ 编号。比如时钟 IRQ 0，键盘 IRQ 1，有的是动态分配的，比如在 PCI 总线上的设备。

### 中断处理
操作系统处理中断的过程一般分成两个部分，命名为「上半部（top half）」和「下半部（bottom half）」。一般上半部(中断处理程序)有严格时限的操作，比方说快速应答。而有的可以延后执行的操作就交给了下半部。举个例子，操作系统处理网卡数据包的时候，会在上半部把网络数据拷贝到内存，下半部做数据处理的操作。

![image.png](https://gitee.com/razertory/razertory-statics/raw/master/razertory-me/photo-11.jpg)

### 下半部
**时间敏感**，**硬件相关**或者**保证不能中断**的任务，通常一定是在上半部，否则都在下半部。下半部的实现机制，在 linux 内核发展中经历了几个版本。

![tasklet 基于软中断实现](https://gitee.com/razertory/razertory-statics/raw/master/razertory-me/photo-12.jpg)

软中断是编译期间分配的，由 softirq_action 表示。定义在 [linux/interrupt.h](https://github.com/torvalds/linux/raw/master/include/linux/interrupt.h)。

[kernel/softirq.c](https://github.com/torvalds/linux/raw/master/kernel/softirq.c) 里面定义了一个包含 32 个结构体的数组。每个结构体表示一个软中断，因此软中断最多有 32 个。不过目前这用到了 9 个。当软中断开始工作的时候，会执行一个名叫 `void softirq_handler(struct softirq_action *)` 的函数去标记注已经册的软中断。

等到合适的时候，该软中断就会执行，比如

- 从硬件中断代码返回的时候  
- 在 ksoftirqd 内核线程中
- 在一些显式执行、显式检查软中断的程序中，比如网络系统中

tasklet 源自软中断，提供了动态分配的特性，有着更广泛的应用场景。

