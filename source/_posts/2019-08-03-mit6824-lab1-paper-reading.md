---
title: mit6824-lab1 读论文
date: 2019-08-03 10:20:20
tags: [mit-6824]
---
MapReduce 论文公布自 2003 [MapReduce: Simplified Data Processingn](https://research.google.com/archive/mapreduce-osdi04.pdf)。在这之前 google 每天已经有大量的数据需要处理。MapReduce 的诞生让程序员在面对大数据量环境下只需要专注于实现业务逻辑，并在一定程度上遵循当时 MapReduce 架构下的规则即可。在当时， MapReduce 已经被用到: 计算 URL 访问频率、 分布式 Grep、倒排索引和分布式排序等。

MapReduce 的核心思想是：首先将需要处理的大量数据分片，然后对分片之后的内容进行处理，输出中间内容，这个过程称为 Map。随后再整合这些中间内容得到最终结果，这个过程称为 Reduce。

这个过程，实现起来有很多种方式，需要考虑实际业务场景，硬件资源等。在 Google，通常是某个成百上千庞大的机器集群组成。这些机器在同时且不断地做着 Map 和 Reduce 的工作。

![](http://ww1.sinaimg.cn/large/a67b702fly1g5mcdixbwcj20l80bpdg7.jpg)


1. **分片**: 大量的数据首先会被分成小片，大小通常是 16M 到 64M。这个数值涉及到后面提到的数据本地化策略，数据本地化目的是为了节省带宽。（毕竟03年的时候带宽比现在差太多）

2. **MapReduce 任务分配**: 由一个 master 程序来产生多个 worker 程序的副本跑在集群中，这些 worker 程序通常分配 M 个 Map 任务，R 个 Reduce 任务。

3. **Map 阶段**: Map workers 会去读入分片之后的数据，按照用户自定义的函数处理，然后把产生的结构为 key-value 类型结果输出到中间文件中。

4. **Reduce 阶段一**：Master 获取阶段 3 的中间文件的 index，传给 Reduce worker。

5. **Reduce 阶段二**：Reduce worker 找到对应的中间文件，然后按照 key 进行排序，排序的目的是让相同 key 的文件排在一起。这个过程我个理解为整合。同时，由于把大量的文件在单独的某个 worker 中做排序是非常耗费时间空间的，因此应该在这之前排好序，整合的时候只是一个 merge-sort 中的 merge 阶段。比方说
```ruby
# 输入 
[{k3, v1}, {k1, v2}, {k2 v1}, {k1, v3}, {k2, v2}, {k1: v1}]

# 排序 
[{k1: v1}, {k1, v2}, {k1, v3}, {k2 v1}, {k2, v2}, {k3, v1}]

# 相同 key 整合
[{k1: [v1, v2, v3]}, {k2, [v1, v2]}, {k3, [v1]}]
```

6. **Reduce 阶段三**: 阶段 5 之后就是整合之后的内容以 key-value 为单位传给用户自定义的函数。

7. **结束工作**: 通常当所有的 Map worker 和 Reduce worker 都结束的时候，master 此时唤醒用户程序（通常就是一个最开始的调用函数）。这个时候调用放就可以收到返回。

整个系统中 master 唯一，也就是说 master 如果挂了那么外部就认为当前集群不可用。worker 数目较多，可以接受一定数量的 worker 不可用。通常 master 会不断 ping 这些 worker 同时保存他们的状态。当某个 worker 挂掉之后，master 就认为他的工作没有做过，并转交给别的 worker，这样做的好处是每个 worker 的工作都是原子的。当 MapReduce 执行到后面的时候，通常是有大量的 Reduce 工作需要做。这个时候 master 又可以让之前的 Map worker 转为 Reduce worker。
