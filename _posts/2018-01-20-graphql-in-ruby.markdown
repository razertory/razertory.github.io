---
layout: post
title:  "GraphQL in Ruby"
date:   2018-1-20 0:21:00 +0800
categories: jekyll update
---
时间大概是17年九月，我司的新App开工。在技术选型上，我们很激进地选择了`Graphql` instead of restful。当时想到的理由是很简单，但是也无可厚非的：我们的App和后期将要做的新Web在业务上有很大的相通性，并且功能模块有不少类似的地方，所以用Graphql这样的技术来做API层复用性会很高。后期在做一些管理后台的时候，效率也会高不少。

很有幸的是，自己成了这块业务的'负责人'，也算是在研发团队中做了这个技术的主要推进者。我们的服务端主语言是Ruby，所以像github，Shopify这样的GraphQL + Ruby的领先者对我们而言如同教科书一般。我研究了几乎每个Github的Query和Mutation，所以很大程度上也受益于他们优质的思路，和客户端同学们踩了一些坑，但最后也都得出了这个在开发过程中，很多方面都会优于rustful的结论。具体的优势，和官方说的差不多，我也不愿再赘述。这篇博客，更多的是关于技术的感悟和一些架构上的理念。吹架构可能有点悬乎。好吧，就再抽象一点，应该是做工程的一些总结；当然Rails + GraphQL的干货内容也不会少的。

Ruby在编程表达能力上，几乎是我见过的所有服务端语言中最强的。元编程 + Rails + 各种库，几乎算得上是互联网创业公司的神兵利器。当然，语言这种东西，好坏得看上下文的，不同的话在不同的语境中效果还是不一样的。至少对于我司的业务和人员编制，加上对于往后一年的预估，在大量的论证下，大家都对技术选型达成了一致。我们需要技术团队有强大的业务推进能力，并且能做出高效稳定的服务。

现在看来，这样的选择没有错。我已经将rc环境的graphql api 开放。http://rc.kid17.com:10000

随着产品的重构和业务的迁移，我们的流量开始逐步转向graphql服务，各个规范也建立起来。随着业务模块的复杂度增高，用户数量的增加和数据量的增大，新一轮的挑战即将开始。首先就是要把这个巨大复杂的Rails + GraphQL项目拆掉，第二个就是确定新的架构，第三点就是拥抱变化，让这个服务本身变得可以维护，扩展和改进。

> 东西早晚要坏的，这就是生活。

## 查询性能
解决N+1 query和查询环几乎是Graphql服务端使用者遇到的第一个问题。

我记得在遇到这个问题的时候，我看到了Facebook官方出的dataloader来解决。所以像我们这种Ruby栈的团队，自然就选用了Shopify团队的[graphql-batch](https://github.com/razertory/graphql-batch)，现在回忆起来依旧记得当时的兴奋感。好吧，还是贴两张图，对比一下。

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

作为一个非主流入门的Ruby用户（我第一个开始做的Ruby项目是用Grape + ActiveRecord搭建的），rails其实也是最近才开始真正用上的。当遇到第一个让人兴奋的东西时（的确，像很多ORM，API框架的确吸引力不大)，自然得去读他的源码。不过读之前，当发现了这个神奇的一幕时，我的第一直觉告诉我是不是和JDBC规范中的prepared statement一样？让相同语法的sql不再多执行，只要换sql的参数就行。这样MySQl编译开销就小了很多。反正缓存无处不在，不，难道是动态规划？。。好吧，都是猜的。既然这个玩意儿解决了一个重要瓶颈问题，那么不管出于兴趣层面，还是业务层面，还是我的个人理念：

> The greatest enemy of knowledge is not ignorance, it is the ilussion of knowledge --史蒂芬·霍金

我都会把这个gem包玩转 :)