---
layout: post
date: 2019-05-09 21:28:23 +0800
title: 「Linux 内核」」代码分析 select, poll, epoll
tags: 操作系统
---

现在有很多讲这三个 system call 的文章，这里我从代码层面去分析和理解。

首先，他们分别来自于 `<sys/select.h>`，`<sys/poll.h>`，`<sys/epoll.h>`。如果是 Mac OS，是没有第三个的，其中前两个都在 `/usr/include/sys`。

当一个客户端请求服务端的时候，服务端会调用 accept() 产生一个 socket，这个 socket 相当于一个状态机，最基本的包括是否可读，是否可写，服务端和客户端在进行数据传输的过程中，这个 socket 的状态就会不断发生变化。这只是一个客户端的情况，实际上肯定是有很多的。也就是说，服务端需要同时控制许多的 socket 的读写。并且总是需要以最快的时间，最小的系统开销来向 socket 读或者写数据。庆幸的是，这些事情都由开发操作系统内核的工程师们搞定了。

> fd: 一个文件描述符; fds: 一组文件描述符

### select

> fd_set ：`<sys/select.h>` 提供的文件描述符集合，是一个能存放最多 1024 个元素的数组。

select 需要传入 fd_set 的地址，然后将它们修改成只包含就绪并用来读写。这个方法的签名为
```c
// 按照顺序，参数的意思分别是
// fd_set 的 最大编号，准备就绪读的，准备就绪写的，异常的，以及超时时间
int select(int nfds, fd_set *readfds, fd_set *writefds, fd_set *exceptfds, struct timeval *timeout);
```
简单点，比如说你有 fds，编号 1 到 5 并且只想让内核告诉你哪些 fd 可读。那么只需要调用 select(5, fds, NULL, NULL, NULL) 就好了。
服务端会不断地循环调用这个方法来做数据的读写。

按照 select 的做法，假设最大为 600 的五个 fd 传入，那么 select 会从 0 开始遍历到 600，这样做会浪费掉大量的 CPU 资源。

### poll

poll 与 select 相比较，最大的区别在于不再使用 fd_set 这样的数据结构。而是为每一个 fd 都封装了一个 `pollfd`

```c
struct pollfd {
    int fd; // 对应的 fd
    short events;
    short revents;
};
```
只需要给 poll() 方法传入已经打开的 fds，方法签名为

```c
int poll (struct pollfd *fds, unsigned int nfds, int timeout);
```

在上述 select 的案例中，同样最大 600 的五个 fd 传入，poll 只需要传入这个 5 个 fds 即可。在调用了 poll() 之后， 就绪的 pollfd 中的 revents 就会被修改，也就能确认哪些 fds 就绪。

### epoll

epoll 包含了多个方法，使用起来实际上会分成几个步骤

- 初始化 epoll 事件驱动所用到的数据结构 `epoll_event`
- `epoll_create()` 初始化当前的 context
- 初始化 `epoll_event` 中的 `data.fd` 关联到当前系统的 fds
- 依照 `epoll_event` 的内容，调用 `epoll_ctl()` 来对当前的 context 进行控制，通常是给 context 写入或者删除 fds
- `epoll_wait()` 只返回就绪的 fds

由于没有无效的遍历，epoll 的理论时间复杂度是 O(1)。 select 和 poll 的复杂度是 O(n)。

[源码](https://github.com/razertory/c-code-lab)

#### 参考
https://devarea.com/linux-io-multiplexing-select-vs-poll-vs-epoll/#.XNOXutMzYQE

https://jvns.ca/blog/2017/06/03/async-io-on-linux--select--poll--and-epoll/

[《Linux/Unix 系统编程手册》](https://book.douban.com/subject/25809330/)


