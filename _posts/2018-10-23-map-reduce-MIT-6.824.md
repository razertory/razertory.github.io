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

在这个 lab 中，我们要做的第一个就是实现上述步骤 3 中的 Map function 以及 步骤 6 中的 Reduce function。
