---
layout: post
title:  "GraphQL 优化分享"
date:   2018-06-14 +0800
categories: graphql
---
上周给公司的研发同事们做了一次服务端的 GraphQL 优化分享，主要是后端同事，这里打算写博文的方式记下来。

### 缓存
其实缓存这个词，我个人会觉得比较含糊，有时候我们会把 cache 和 buffer 这两个东西弄混淆

`Cache` 为了弥补高速设备和低速设备的鸿沟而引入的中间层，最终起到“加快访问速度”的作用。比如：CPU 缓存，NoSQL缓存

`Buffer` 主要目的进行流量整形，把突发的大数量较小规模的 I/O 整理成平稳的小数量较大规模的 I/O，以“减少响应次数”（比如从网上下电影，你不能下一点点数据就写一下硬盘，而是积攒一定量的数据以后一整块一起写，不然硬盘都要被你玩坏了，比如TCP做数据传递的时候，单位是“帧”而不是一个个的字节）

浏览器/APP -> 网络转发 -> 应用服务器 -> DB 每个地方都可以用缓存方式来做。比如这里的分享主要来自于应用服务器。

### Chatty
其实在我另一篇博文里面有提到这一方面的优化，这里我打算详细分析。

“GraphQL 是一种可以让程序员编写clean code的方法，每个type的field都有着单一的目的（single-purpose）。然而，如果我们不多加考虑，那么我们的GraphQL服务端就会变得非常’chatty’，或者说会执行很多重复的查询” – https://graphql.org/learn/best-practices(个人翻译)

比如我司有一个服务端查询：

```graphql
query clazz($id: ID) {
    clazz(id: $id) {
        subjects{
            id
            activities {
                id
                teacher {
                    id
                    name
                }
            }
        }
    }
}
```
这样一个查询，如果不做适当的处理会变得很慢。这里的查询会遍历两个列表 `subjects` 和 `activities` 用来获取 `teacher` 数据，如果做一下复杂度分析，可能很容易得到，执行SQL的数目就是两个列表的矩阵数，也就是O(N * M)。这样当然会很慢，所以不得不用上一些batching技术。

```ruby
gem 'graphql-batch'
```

用上这个技术之后，我之前的这种大量SQL的查询，就会被整型成少量的 `in` 查询。这里关于 N + 1 query的东西不再赘述。做复杂度分析的时候就会发现SQL执行数目只和数据嵌套深度有关。

### Promise
在做GraphQL Server开发的时候，我对一个事情一直很好奇，就是每个field获取是不是异步的？所以我做了以下实验：

``` ruby
def blocking_query(id)
  p Thread.current.to_s
  sleep 3
  id
end

field :a, types.String do
  resolve -> (o, args, c) {
      blocking_query "a"
  }
end

field :b, types.String do
  resolve -> (o, args, c) {
      blocking_query "b"
  }
end

field :c, types.String do
  resolve -> (o, args, c) {
      blocking_query "c"
  }
end

field :d, types.String do
  resolve -> (o, args, c) {
      blocking_query "d"
  }
end

```

结果非常不乐观

```shell
#<Thread:0x007fe15e1887fb0>
#<Thread:0x007fe15e1887fb0>
#<Thread:0x007fe15e1887fb0>
#<Thread:0x007fe15e1887fb0>

Completed 200 OK in 12641ms
```

可以发现我每个field的耗时被叠加起来了。同时发现每个field的获取打印线程都是一样的内容。

这时候可以加上异步优化来处理，完成一个Promise，来自[issue](https://github.com/lgierth/promise.rb/issues/23#issuecomment-276437726)

```ruby
require 'promise'

module ConcurrentPromise
  def self.execute
    promise = Promise.new
    promise.source = Source.new(promise) { yield }
    promise
  end

  class Source
    def initialize(promise)
      @promise = promise

      # Promise isn't thread-safe, so the thread needs to store the result
      # on a separate object
      @thread_result = Promise.new
      @thread = Thread.new(@thread_result) do |result|
        begin
          result.fulfill(yield)
        rescue => err
          result.reject(err)
        end
      end
    end

    def wait
      @thread.join
      @promise.fulfill(@thread_result)
    end
  end
  private_constant :Source
end
```
同时优化我的查询方法
```ruby
def blocking_query(id)
  ConcurrentPromise.execute do
    p Thread.current.to_s
    sleep 3
    id
  end
end
```
执行结果

```shell
#<Thread:0x007fe15e18897d0>
#<Thread:0x007fe15e1888f60>
#<Thread:0x007fe15e1884g30>
#<Thread:0x007fe15e1887g60>

Completed 200 OK in 3577ms
```
可以发现打印的线程堆栈是不同的内容，同时接口速度接近于单个field的执行速度。

在阅读 `graphql-batch` 源码中我也发现了这样子类似的一段
```ruby
def load(key)
  cache[cache_key(key)] ||= begin
    queue << key
    ::Promise.new.tap { |promise| promise.source = self }
  end
end
```
基于Promise来和缓存key的方式来完成。

### 后记
缓存，异步，这一类的词眼在现代的研发体系中总是很常见，GraphQL 的ruby生态还需推进。
