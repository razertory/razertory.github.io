---
layout: post
title:  "向 GraphQL 迁移"
date:   2018-1-20 0:21:00 +0800
tags: 系统设计 
---
时间大概是 17 年九月，我司的新 App 开工。在技术选型上，我们很激进地选择了 `graphql` instead of restful。当时想到的理由是很简单，但是也无可厚非的：我们的 App 和后期将要做的新 Web 在业务上有很大的相通性，并且功能模块有不少类似的地方，所以用 graphql 这样的技术来做 API 层复用性会很高。后期在做一些管理后台的时候，效率也会高不少。

很有幸的是，自己成了研发团队中这个技术的主要推进者。我们的服务端主语言是 Ruby，所以像 github，Shopify 这样的 GraphQL + Ruby 的领先者对我们而言如同教科书一般。我研究了几乎每个 Github 的 Query 和 Mutation，所以很大程度上也受于他们优质的思路，和客户端同学们踩了一些坑，但最后也都得出了这个在开发过程中，很多方面都会优于 rest 的结论。具体的优势，和官方说的差不多，我也不愿再赘述。这篇博客，更多的是关于技术的感悟和一些架构上的理念。吹架构可能有点悬乎。好吧，就再抽象一点，应该是做工程的一些总结；当然 GraphQL 的干货内容也不会少的。

## 开发模式
用 graphql 很大程度上，省去了一些不必要的沟通成本。当你受够了用 rest 要去构建 API 文档之后，graphql 这种天然的 ` 代码即文档 ` 的便捷性让团队受益匪浅。服务端只需要在编码期间，按照标准的写法，加上对应的 desc 方法，就可以无缝生成对应的文档。
```ruby
GuardianType = GraphQL::ObjectType.define do
  name 'Guardian'
  description 'A guardian has his/her children'

  field :id, types.ID
  field :name, types.String
  field :children, types[ChildType]
end
```
也许很多人会问，这样做，服务端的业务逻辑不久会分散一部分到客户端上了？客户端的工作量不就提升了？

但实际上，graphql 的自动化 + 强类型 + '强结构'让客户端的工作量反而下降了。首先，客户端的的确是要写查询代码，就像是服务端写 SQL 一样。但是 graph 的查询要比 SQL 简单了不知道多少倍，更准确的，我可以称之为 ` 描述 `

```json
query guardian{
  guardain(id: 9527){
    id
    name
    children{
      id
      name
      avatar
    }
  }
}
```
在传统的 rest 开发模式中，客户端并不知道一个请求服务端会返回什么结果。除非有准确，准时，详尽的文档。客户端会恐惧，服务端某个返回结果数据结构不对自己 crash 了。所以反而会在这一层上，思考很多。（我们评价一个技术体系的工作成本，除了实际的编码产出，还应该评估思考，权衡所带来的开销）维护未知响应结果的开销，总是会大于自己决定响应结果的开销。

> 技术上的恐惧感，往往来源于未知。没有测试，不知道原理，没有约定，没有规范，都是会带来未知。

## 查询性能
解决 N+1 query 和查询环几乎是 graphql 服务端使用者遇到的第一个问题。

我记得在遇到这个问题的时候，我看到了 Facebook 官方出的 dataloader 来解决。所以像我们这种 Ruby 栈的团队，自然就选用了 Shopify 团队的 [graphql-batch](https://github.com/razertory/graphql-batch)，现在回忆起来依旧记得当时的兴奋感。好吧，还是贴两张图，对比一下。

#### before
```sql
INFO -- : (0.019141s) DESCRIBE `activities`
INFO -- : (0.018571s) SELECT * FROM `activities` WHERE (`subject_id` = 26)
INFO -- : (0.017604s) SELECT * FROM `activities` WHERE (`subject_id` = 32)
INFO -- : (0.015813s) SELECT * FROM `activities` WHERE (`subject_id` = 25)
INFO -- : (0.016458s) SELECT * FROM `activities` WHERE (`subject_id` = 28)
INFO -- : (0.016015s) SELECT * FROM `activities` WHERE (`subject_id` = 29)
INFO -- : (0.016588s) SELECT * FROM `activities` WHERE (`subject_id` = 27)
INFO -- : (0.019075s) SELECT * FROM `activities` WHERE (`subject_id` = 33)
INFO -- : (0.014484s) SELECT * FROM `activities` WHERE (`subject_id` = 31)
INFO -- : (0.017730s) SELECT * FROM `activities` WHERE (`subject_id` = 35)
INFO -- : (0.017332s) SELECT * FROM `activities` WHERE (`subject_id` = 34)
INFO -- : (0.015393s) SELECT * FROM `activities` WHERE (`subject_id` = 36)
INFO -- : (0.016545s) SELECT * FROM `activities` WHERE (`subject_id` = 39)
INFO -- : (0.014443s) SELECT * FROM `activities` WHERE (`subject_id` = 40)
```
#### after
```sql
INFO -- : (0.022229s) SELECT * FROM `subjects` WHERE ((`clazz_id` = 1) AND (`grade_id` = 1)) ORDER BY `ordering`
INFO -- : (0.018933s) DESCRIBE `activities`
INFO -- : (0.105159s) SELECT * FROM `activities` WHERE (`subject_id` IN (26, 32, 25, 28, 29, 27, 33, 31, 35, 34, 36, 39, 40))
```

作为一个非主流入门的 Ruby 用户（我第一个开始做的 Ruby 项目是用 Grape + ActiveRecord 搭建的），rails 其实也是最近才开始真正用上的。当遇到第一个让人兴奋的东西时，自然得去读他的源码。不过读之前，当发现了这个神奇的一幕时，我的第一直觉告诉我是不是和 JDBC 规范中的 prepared statement 一样？让相同语法的 sql 不再多执行，只要换 sql 的参数就行。这样 MySQl 编译开销就小了很多。反正缓存无处不在。不，难道是动态规划？。好吧，都是猜的。既然这个玩意儿解决了一个重要瓶颈问题，那么不管出于兴趣层面，还是业务层面，尽可能去熟悉它一定是很好的想法。

首先，这个玩意儿是学习了 Facebook 官方的 dataloader 做的。如果有去了解，自然猜到，这个项目用了 `promise.rb`。可以在源码里面看到这样的调用，并且作者的 sample 里面也很清晰地说明了这个玩意儿的输出开始就是个 Promise 对象。所以对于 graphql ruby 的
```ruby
resolve -> (obj, arg, ctx) {}
```
这样的 do block 块就应该和普通的 http api 框架不一样。可以理解的是，一次 graph 请求的，所需要的每个 field 对于服务端来说，是并发获取的。这里并发，肯定用了他自己的一套策略。可以猜测的是，就是用的异步 I/O的方式。所以从这一点来说，这个库本质上和 graphql ruby 是完全契合的。

## 架构
Ruby 在编程表达能力上，几乎是我见过的所有服务端语言中最强的。元编程 + Rails + 各种库，几乎算得上是互联网创业公司的神兵利器。当然，语言这种东西，好坏得看上下文的，不同的话在不同的语境中效果还是不一样的。至少对于我司的业务和人员编制，加上对于往后的预估，在大量的论证下，大家都对技术选型达成了一致。我们需要技术团队有强大的业务推进能力，并且能做出高效稳定的服务。

现在看来，这样的选择没有错。这里可以大致展示（公司没钱，服务器释放掉了 --): [http://rc.kid17.com:10000](http://rc.kid17.com:10000)

随着产品的重构和业务的迁移，我们的流量开始逐步转向 graphql 服务，各个规范也建立起来。随着业务模块的复杂度增高，用户数量的增加和数据量的增大，新一轮的挑战即将开始。首先就是要把这个巨大复杂的 Rails + GraphQL 项目拆掉，第二个就是确定新的架构，第三点就是拥抱变化，让这个项目本身变得可以维护，扩展和改进。

我司的的产品中，有两套用户体系，就像是美团的商家版和客户版，拉钩、Boss 的求职版和企业版。两种不同的身份的角色参与到整个业务。我们有 feed 流，电商，电子书，用户管理，教学管理等业务模块。我目前的想法是让 graphql 去代理这些服务给客户端调用。最外层用 [Kong](https://github.com/Kong/kong) 去完成用户鉴权和 ngixn 的一些基本功能。


以上拙见，都来自于各种踩坑之后的感悟。

ps: 很期待可以认识同样在用graphql 的团队或个人，欢迎打扰 `wechat: chendalichun`
