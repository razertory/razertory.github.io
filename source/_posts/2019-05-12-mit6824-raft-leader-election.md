---
layout: post
date: 2019-05-12 13:43:13 +0800
title: MIT6.824 Raft 2A
published: true
---

### 初识 Raft
现有的分布式系统往往会在 CAP 之前权衡

![CAP Sample](/img/cap-samples.jpg)

Raft 在 CAP 理论中, 着重强调 C 和 P。


通常，完备的分布式存储系统应该做到对外提供看起来只有一个节点的服务，暴露简单的 API。简单的实现数据库的主从可以通过一个 master 多个 slave 来实现。比如现有的 RDS 提供商都提供了这样的功能。
不过如果 master 到 slave 之前的通信断了，那么很有可能我们从 master 和 slave 读到的数据就会不一致了。网络，存储，硬件这些东西在集群数量庞大的时候，就会看起来不再那么可靠。这个时候就需要设计出一个协议来让多个节点总是保持一致，并且如果某个节点挂了或者节点之前的通信故障了，在修复了之后这个系统能够自愈。-- Paxos 和 Raft 就随之而来了。其实在个人看来这两个算法本质都是通过

 1. 基于某个由协议产生的 master 来同步数据
 2. 用多数派的方式来决定数据的走向

由于 Raft 更加容易理解和实现，MIT 6.824 Lab 2A 也是基于了 Raft。


### 代码阅读
作为一套标准的 TDD 作业，从测试代码开始阅读是很好的选择

- [makeConfig()](https://github.com/razertory/MIT6.824/blob/master/src/raft/config.go#L59) 方法会初始化默认 n = 3 个 Raft 节点，利用 golang 自带的 RPC 包进行通信

- [Make()](https://github.com/razertory/MIT6.824/blob/master/src/raft/raft.go#L249) 方法会启动这个 Raft 节点，需要在方法的后实现 Raft 的入口和调度

- [checkOneLeader()](https://github.com/razertory/MIT6.824/blob/master/src/raft/config.go#L298) 方法会检查是否有且只有一个 leader 节点

- [disconnect()](https://github.com/razertory/MIT6.824/blob/master/src/raft/config.go#L258) 方法会 disable 掉这个节点的 RPC 调用，也就是说让这个节点不可用

### 2A leader 选举

*TestInitialElection2A*

1. 在 Make() 初始化的时候，一定是 follower。然后就会开始超时计时，如果没有收到 leader 的心跳，那么就转换成 candidate 状态。在转换成 candidate 之后就会发起投票请求。

2. candidate 会向当前集群的每个节点进行广播式的消息发送。每个收到投票请求消息的节点会比较当前的 term 和 广播消息的 term，如果小于，就投票给他，同时赋值给自己的 term。

3. candidate 收集到超过半数的确认投票的结果时，就会将自己转换成 leader。

要注意的是。第 1 点中，follower 变成了 canditate 的时候，要 term++；第 2 点里面一定要赋值给自己的 term 不然有很多 leaders。

*TestReElection2A*

可以注意到, 当选举出了 leader 之后， 测试 代码会 disconnect 掉它，并且经过一定时间的 sleep 再去检查有没有 leader。另一方面，将 leader 和剩余的两个中任意一个 disconnect 之后也要确保再没有 leader。

1. leader 断开之后，系统中剩余的节点又将进入超时倒计时选举新的 Leader。
2. leader 断开之后，leader 与剩余节点的 term 就会不一样，因为此时剩余节点会继续开始新的 term
3. leader 重连之后，由于 2 此时当任何一个节点发起 RequestVote 的时候，收到消息的 leader 在比较 term 之后发现如果自己小于请求投票的节点，那么自己就变成 follower。


2A 用到了 Go 中的 select 来进行事件等待，也就是等待超时或者另外节点的请求 / 回复。一些读取 term 并赋值的地方需要加上 mu.Lock() 来避免 Data Race。



