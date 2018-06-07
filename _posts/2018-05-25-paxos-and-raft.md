---
layout: post
title:  "关于分布式协议Paxos和Raft的一些共同理解"
date:   2018-05-25 +0800
categories: jekyll update
---
第一次到Paxos协议，大概是`TiDB`这个团队的产品介绍里面提到的。虽然他们用的是Raft协议，不过既然都是分布式协议，那么我这一次打算把两个分布式协议先单独分析，再合在一起。希望自己的语言最为简练，但内容绝对详细。

### Paxos