---
layout: post
date: 2018-10-23 10:09:07 +0800
title: MIT6.824 Map Reduce
tags: [mit-6824]
---

我认为今后很多系统，当规模达到一定程度的时候，都会渴望做成分布式。而这其中，分布式存储可能是最容易实现无缝迁移的。这也是我今后的一个工作职业发展方向。所以在研究整理学习之后我开始了 MIT-6.824 的修炼。应该是目前最适合我学分布式系统的课程。从这个文章开始我会记录学习和完成对应 lab 的要点。

所有 Lab 中的代码基本上都会用 Go 来写，对之前没有用过 Go 的我也算是一个挑战。

### 单机串行版（乞丐版）

假设有个字符串：
```go
var str = "The MapReduce library in the user program first splits the input files into M pieces of typically 16 megabytes to 64 megabytes (MB) per piece (controllable by the user via an optional parameter). It then starts up many copies of the program on a cluster of machines."
```
需要统计里面每个字母出现的次数。最直观简单的做法就是利用一个 map，从开始到末尾读这个字符串，并把字母作为 key，出现的次数作为 value。Map 中包含 key 的时候，value + 1，Map 中没有 key 的时候默认 1。最后读完这个字符串就 OK。

```go
var m = make(map[string]int)
temp := strings.Split(str, "")

for _, c := range temp {
    if !unicode.IsLetter([]rune(c)[0]) {
        continue
    }
    if count, ok := m[c]; ok {
        m[c] = count + 1
    } else {
        m[c] = 1
    }
}
```
```shell
[M:3 R:1 y:7 o:13 v:1 e:26 h:7 l:10 i:14 r:15 T:1 p:13 d:1 u:6 c:8 b:5 s:14 g:4 a:17 f:5 m:7 t:20 B:1 I:1 n:10]
```

### 单机并行版（小康版）
在现实世界中，这个 `str` 可能非常巨大，所以有时候我们需要将源文本拆分成多个小的字符串 map，然后多个线程同时处理，最后合并到一起 reduce。为了在单机上体现这一点，可以用 Go 自带的 goroutine 来实现。下面把拆分的工作省略，直接进入主题
接下来用 4 个 goroutine 同时处理这些 string，每个做 map 任务的 goroutine 利用 ` 单机串行版 ` 的逻辑，生产出一个小规模的 map。随后把每个 map 都整合成一个最终的 map。接下来需要考虑几点
* Map 和 Reduce 的过程应该可以并发进行
* Go 天生支持 CSP 编程模型，所以利用 channel 做通信没有问题
* 是否有 data race

```go
package main

import (
	"strings"
	"sync"
	"unicode"
)

// reduce 可能会同时进行
// TODO 用 1.9 的 sync.map 试试，顺便看看性能会不会更好
type ResultMap struct {
	sync.Mutex
	result map[string]int
}

func main()  {
	str1 := "The MapReduce library in the user program first"
	str2 := "splits the input files into M pieces of typically 16 megabytes to 64 megabytes (MB)"
	str3 := "per piece (controllable by the user via an optional parameter)."
	str4 := "It then starts up many copies of the program on a cluster of machines."

	strs := []string {str1, str2, str3, str4}

	// 主线程需要阻塞直到所有的 reduce 都结束
	var waitGroup sync.WaitGroup
	waitGroup.Add(len(strs))

	c := make(chan map[string]int)

	res := new(ResultMap)
	res.result = make(map[string]int)

	for _, str := range strs {
		go doMap(str, c)
		go doReduce(c, res, &waitGroup)
	}

	waitGroup.Wait()

	sortPrintMap(res.result)

}

// 生产出对应的 kv 传递给 channel
func doMap(str string, c chan map[string]int) {
	temp := strings.Split(str, "")
	m := make(map[string]int)

	for _, c := range temp {
		if !unicode.IsLetter([]rune(c)[0]) {
			continue
		}
		if count, ok := m[c]; ok {
			m[c] = count + 1
		} else {
			m[c] = 1
		}
	}
	c <- m
}

// 合并
func doReduce(c chan map[string]int, res *ResultMap, group *sync.WaitGroup) {
	res.Lock()
	defer res.Unlock()
	for k, v := range <- c {
		if count, ok := res.result[k]; ok {
			res.result[k] = count + v
		} else {
			res.result[k] = v
		}
	}
	group.Done()
}
```
检查一下结果 (Map 的 key 本身是无序的，这里是排好序之后的)
```shell
[M:3 R:1 y:7 o:13 v:1 e:26 h:7 l:10 i:14 r:15 T:1 p:13 d:1 u:6 c:8 b:5 s:14 g:4 a:17 f:5 m:7 t:20 B:1 I:1 n:10]
```
结果无误之后，这个问题可以再深入
* 上述的 reduce 和 map 是单机上的，之间的数据共享用了 channel，如果是物理隔离的场景下，如何用别的东西做数据共享？
* 任何一个子任务都有可能因为各种原因挂掉，如何再某个子任务挂掉的情况下，系统的准确性不受影响，甚至能自愈？
* 上述的 goroutine 在执行结束之后就会被调度器回收，但实际上因为 map 总是会比 reduce 先结束，那么这个 gorouine 实际上可以参与到 reduce 任务中，如何实现这种调度？


### 论文学术版（中产版）
这些问题，Jeff Dean 大神都已经解决。按照论文的思路，应该是如下流程（已经是最精简并且完善的了）

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

在 lab 中，map 就是将输入的内容转化成中间文件暂存在文件系统中，生产环境下会用到 Google 三大神器之一的高富帅（GFS）。

1. 按照题目规则创建好 N(reduce worker 个数）个中间文件
2. 解析输入的内容转化成 key-value 组成的数组 kvs
3. 遍历 kvs，对每个 key 进行 hash + 取模 N 的得到文件索引找到对应的中间文件，并把遍历中的 key-value json 化之后写到对应的中间文件

这里的 Hash + 取模过程与许多负载均衡算法类似，都是为了平衡资源，让每个中间文件的大小一致。生成的每个中间文件的文件名都会包含 map worker 的编号和 reduce worker 的编号。

reduce 的工作就是解析 map 过程产生的中间文件，写到输出文件中
1. 根据调度器传入的当前 reduce worker 的编号和正在进行工作的 map worker 个数来找到并读取对应的中间文件
2. 遍历这些中间文件，把里面的内容反序列化之后存到一个 kvs 中
3. 给 kvs 按照 key 排序
4. 把 kvs json 序列化之后写到输出文件中 (序列化之前可能会按照用户的意图进一步处理)

我个人认为，MapReduce Lab 中，最难也是最精彩的部分应该是实现调度器
```go
func schedule(
	jobName string,
	mapFiles []string,
	nReduce int,
	phase jobPhase,
	registerChan chan string,
) {
	var waitGroup sync.WaitGroup // 等待一次 Map/Reduce 完成
	var ntasks, nOther int

	if phase == mapPhase {
		ntasks, nOther = len(mapFiles), nReduce
	} else {
		ntasks, nOther = nReduce, len(mapFiles)
	}

    // 缓存大小和任务个数一致
    readyChan := make(chan string, ntasks)

    // 重试计数器
	retryChan := make(chan *DoTaskArgs, ntasks) /
	failureCounts := WorkerFailureCount{workers: make(map[string]int)}

	// call 方法将准备好的参数交给 RPC 组件，并执行任务
	startTask := func(worker string, args *DoTaskArgs) {
		defer waitGroup.Done()
		success := call(worker, "Worker.DoTask", args, nil)
		readyChan <- worker
		if !success {
			fmt.Printf("Schedule: %v task #%d failed to execute by %s\n", phase, args.TaskNumber, worker)
			failureCounts.inc(worker)
			retryChan <- args
		}
	}

	// 任务参数 slice
	tasks := make([]*DoTaskArgs, 0)
	for currentTask := 0; currentTask < ntasks; currentTask++ {
		args := &DoTaskArgs{
			JobName:       jobName,
			File:          mapFiles[currentTask],
			Phase:         phase,
			TaskNumber:    currentTask,
			NumOtherPhase: nOther,
		}
		tasks = append(tasks, args)
	}

    // 没有重试任务时，检查是否可以执行
	for len(tasks) > 0 {
		select {
		case taskArgs := <-retryChan:
			tasks = append(tasks, taskArgs)
		case worker := <-registerChan:
			readyChan <- worker
		case worker := <-readyChan:
			if failureCounts.get(worker) < MaxWorkerFailures {
				waitGroup.Add(1)
				index := len(tasks) - 1
				args := tasks[index]
				tasks = tasks[:index]
				go startTask(worker, args)
			} else {
                fmt.Printf("Retry count is full")
			}
		}
	}
	waitGroup.Wait()
}

```

### 商业生产版（土豪版）
[Hadoop](https://github.com/apache/hadoop)