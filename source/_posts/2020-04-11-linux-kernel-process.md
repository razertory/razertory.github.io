---
title: 「Linux 内核」进程管理
date: 2020-04-11 18:15:42
tags: [操作系统]
---

#### 概览
进程是处于执行期的程序以及相关资源的总称。比如打开的文件、挂起的信号、内核内部数据等等。在 linux 源码中，一个进程的相关信息维护在 task_struct [task_struct](https://github.com/torvalds/linux/raw/master/include/linux/sched.h#L632)的结构体中。这里面包含了进程的状态(pid，运行状态)、相关资源、以及相关进程（子进程、父进程）信息。内核会维护一个双向链表，每个链表的节点指向对应的 task_struct。

#### 状态
- TASK_RUNNING: 可执行的；等待执行的
- TASK_INTERRUPTIBLE: 可中断的; 比如被阻塞、或者在 sleep
- TASK_UNINTERRUPTIBLE: 不可中断的; 对外界的信号不做出响应
- EXIT_ZOMBIE: 主动退出；还没有完全释放资源

![进程状态图](http://ww1.sinaimg.cn/large/a67b702fgy1gdq0dnlo0cg20fw09b0sw.gif)

#### 生命周期
在进程被 fork 出来之后 task_struct 会有自己的 pid 和父进程的 pid。但一些必要的系统资源并不会拷贝过来，而是当需要写入的时候再做(copy-on-write)。进程调用 exit() 结束, 部分资源会释放，同时调用 exit_notify() 向父进程发信号。若父进程及时响应，此时释放所有的资源；否则认为此时的这个进程是僵尸进程。同理，如果父进程先于子进程退出，子进程就会成为孤儿进程。内核会将这类进程归给 pid 为 1 的进程。

#### 线程
线程是一种特殊的进程（强调只是 linux）同一个进程的 N 个线程只是 N 个共享同一块资源的
task_struct。比如进程创建的时候会依赖 clone 方法
```c
clone(SIGCHLD, 0)
```
而线程的创建就是传递来一些参数来指明被共享的资源，这个设计现在看起来也是非常优雅的。
```c
clone(CLONE_VM | CLONE_FS | CLONE_FILES | CLONE_SIGHAND, 0)
```


