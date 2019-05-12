---
layout: post
categories: [mit-6824]
date: 2019-05-12 13:43:13 +0800
title: MIT6.824 Raft 2A
published: false
---

### 初识 Raft
CAP

### 代码阅读
作为一套标准的 TDD 作业，从测试代码开始阅读是很好的选择

- [makeConfig()](https://github.com/razertory/MIT6.824/blob/master/src/raft/config.go#L59) 方法会初始化默认 n = 3 个 Raft 节点，利用 golang 自带的 RPC 包进行通信

- [Make()](https://github.com/razertory/MIT6.824/blob/master/src/raft/raft.go#L249) 方法会启动这个 Raft 节点，需要在方法的后实现 Raft 的入口和调度

- [checkOneLeader()](https://github.com/razertory/MIT6.824/blob/master/src/raft/config.go#L298) 方法会检查是否有且只有一个 leader 节点

- [disconnect()](https://github.com/razertory/MIT6.824/blob/master/src/raft/config.go#L258) 方法会 disable 掉这个节点的 RPC 调用，也就是说让这个节点不可用

### 2A

*TestInitialElection2A*

1. 在 Make() 初始化的时候，一定是 follower。然后就会开始超时计时，如果没有收到 leader 的心跳，那么就转换成 candidate 状态。在转换成 candidate 之后就会发起投票请求。

2. candidate 会向当前集群的每个节点进行广播式的消息发送。每个收到投票请求消息的节点会比较当前的 term 和 广播消息的term，如果小于，就投票给他，同时赋值给自己的term。

3. candidate 收集到超过半数的确认投票的结果时，就会将自己转换成 leader。

要注意的是。第 1 点中，follower 变成了 canditate 的时候，要term++；第 2 点里面一定要赋值给自己的 term 不然有很多 leaders。

*TestReElection2A*


