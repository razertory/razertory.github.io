---
layout: post
categories:
date: 2018-10-23 10:09:07 +0800
title: Map-reduce-mit-6.824
---

我认为今后很多系统，当规模达到一定程度的时候，都会渴望做成分布式。而这其中，分布式存储可能是最容易实现无缝迁移的。这也是我今后的一个工作职业发展方向。所以在研究整理学习之后我开始了 MIT-6.824 的修炼。应该是目前最适合我学分布式系统的课程。从这个文章开始我会记录学习和完成对应 lab 的要点。

MapReduce 论文中，最核心的一段应该是实现这个过程的标准步骤：

1. The MapReduce library in the user program first
splits the input files into M pieces of typically 16
megabytes to 64 megabytes (MB) per piece (controllable
by the user via an optional parameter). It
then starts up many copies of the program on a cluster
of machines.

2. One of the copies of the program is special – the
master. The rest are workers that are assigned work
by the master. There are M map tasks and R reduce
tasks to assign. The master picks idle workers and
assigns each one a map task or a reduce task.

3. A worker who is assigned a map task reads the
contents of the corresponding input split. It parses
key/value pairs out of the input data and passes each
pair to the **user-defined Map function**. The intermediate
key/value pairs produced by the Map function
are buffered in memory.

4. Periodically, the buffered pairs are written to local
disk, partitioned into R regions by the partitioning
function. The locations of these buffered pairs on
the local disk are passed back to the master, who
is responsible for forwarding these locations to the
reduce workers.

5. When a reduce worker is notified by the master
about these locations, it uses remote procedure calls
to read the buffered data from the local disks of the
map workers. When a reduce worker has read all intermediate
data, it sorts it by the intermediate keys
so that all occurrences of the same key are grouped
together. The sorting is needed because typically
many different keys map to the same reduce task. If
the amount of intermediate data is too large to fit in
memory, an external sort is used.

6. The reduce worker iterates over the sorted intermediate
data and for each unique intermediate key encountered,
it passes the key and the corresponding
set of intermediate values to the **user’s Reduce function**.
The output of the Reduce function is appended
to a final output file for this reduce partition.

7. When all map tasks and reduce tasks have been
completed, the master wakes up the user program.
At this point, the MapReduce call in the user program
returns back to the user code.

**在 lab 中，map 就是将输入的内容转化成中间文件暂存在磁盘中**

1. 按照题目规则创建好 N(reduce worker 个数）个中间文件
2. 解析输入的内容转化成 key-value 组成的数组 kvs
3. 遍历 kvs，对每个 key 进行 hash + 取模 N 的得到文件索引找到对应的中间文件，并把遍历中的 key-value json 化之后写到对应的中间文件

这里的 Hash + 取模过程与许多负载均衡算法类似，都是为了平衡资源，让每个中间文件的大小一致。生成的每个中间文件的文件名都会包含 map worker 的编号和 reduce worker 的编号。

**reduce 的工作就是解析 map 过程产生的中间文件，写到输出文件中**
1. 根据调度器传入的当前 reduce worker 的编号和正在进行工作的 map worker 个数来找到并读取对应的中间文件
2. 遍历这些中间文件，把里面的内容反序列化之后存到一个 kvs 中
3. 给 kvs 按照 key 排序
4. 把 kvs json 序列化之后写到输出文件中(序列化之前可能会按照用户的意图进一步处理)

reduce 的过程，实际上就是在合并然后处理这些中间文件

**reduce 和 map 过程一定是可以同时运行的。**
