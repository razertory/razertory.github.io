---
title: Scala 函数式编程设计
date: 2020-02-20 23:53:05
layout: post
---
在这个 2020 年初的特殊时期。

Scala 是一门现代化，多范式的 JVM 语言。

传送门（可能需要🚀)
- [Functional Program Design in Scala on Coursera](https://www.coursera.org/learn/progfun2)
- [没什么用的 certificate](https://www.coursera.org/account/accomplishments/certificate/BP5FRUVSFPN8)

---

## W1
### case class 和模式匹配
用 Scala 来表示 JSON 对象可以这样
```scala
abstract class JSON
case class JSeq (elems: List[JSON]) extends JSON  // JSON 的数组
case class JObj (bindings: Map[String, JSON]) extends JSON // JSON 对象
case class JNum (num: Double) extends JSON // 数字类型
case class JStr (str: String) extends JSON
case class JBool(b: Boolean) extends JSON
case object JNull extends JSON // 空
```
所以，
```json
{
    "firstName" : "John",
    "lastName" : "Smith",
    "address" : {
        "streetAddress" : "21 2 nd Street",
        "state" : "NY",
        "postalCode": 10021
    },
    "phoneNumbers": [
        {"type" : "home","number ": "212 555 -1234"} ,
        {"type" : "fax","number ": "646 555 -4567"}
    ]
}
```
可以表示为
```scala
val data = JObj(Map(
    "firstName" -> JStr("John"),
    "lastName" -> JStr("Smith"),
    "address" -> JObj(Map(
    "streetAddress" -> JStr("21 2nd Street"),
    "state" -> JStr("NY"),
    "postalCode" -> JNum(10021)
)),
"phoneNumbers" -> JSeq(List(
    JObj(Map(
    "type" -> JStr("home"), "number" -> JStr("212 555-1234")
)),
JObj(Map(
    "type" -> JStr("fax"), "number" -> JStr("646 555-4567")
)) )) ))
```
比如说我要实现一个打印 JSON 对象的方法，就可以
```scala
def show(json: JSON): String = json match {
    case JSeq(elems) =>
    "[" + (elems map show mkString ", ") + "]"
    case JObj(bindings) =>
    val assocs = bindings map {
        case (key, value) => "\"" + key + "\": " + show(value)
    }
    "{" + (assocs mkString ", ") + "}"
    case JNum(num) => num.toString
    case JStr(str) => '\"' + str + '\"'
    case JBool(b) => b.toString
    case JNull => "null"
}
```
上述的 show(data) 就输出
```scala
res1: String = {"firstName": "John", "lastName": "Smith", "address": {"streetAddress": "21 2nd Street", "state": "NY", "postalCode": 10021.0}, "phoneNumbers": [{"type": "home", "number": "212 555-1234"}, {"type": "fax", "number": "646 555-4567"}]}
```
第 6 行代码里面 map 传入的函数是，我们知道，在这里 map 函数的签名是 `def map[B](f: (A) => B): List[B]`
那么第六行的 `f` 就是 `case (key, value) => "\"" + key + "\": " + show(value)`。 这个函数如果单独拎出来，其实就是
```scala
val f: (String, JSON) => String = { case (key, value) => key + ”: ” + value } // 注意看 JObj 定义
```
所以用 case class 最方便的地方在于**模式匹配中的 decompose**

### 函数即对象
任何情况下，函数 `A => B` 其实就是
```scala
scala.Function1[A, B]
```
的简写。

#### 普通函数
根据 Function1 的定义

```scala
trait Function1[-A, +R] {
    def apply(x: A): R
}
```
例如，
```scala
val f1: Int => Int = (x: Int) => x + 1
val f2 = new Function1[Int, Int] {def apply(x: Int) = x + 1}
```
f1 和 f2 等价。

#### 偏函数
对于偏函数 PartialFunction 定义为
```scala
trait PartialFunction[-A, +R] extends Function1[-A, +R] {
    def apply(x: A): R
    def isDefinedAt(x: A): Boolean
}
```
例如，
```scala
val f1: PartialFunction[String, String] = { case "ping" => "pong" }
val f2 = new PartialFunction[String, String] {
    def apply(x: String) = x match {
        case "ping" => "pong"
    }
    def isDefinedAt(x: String) = x match {
        case "ping" => true
        case _ => false
    }
}
```
f1 和 f2 等价。

ps: 以上，「等价」的意思是两个函数只要输入相同，输出一定相同。
## W2
### LazyList
下面代码
```scala
def f(x: Int): Boolean = {
  println(x + " ")
  x % 11 == 0
}

val v1 = (1 to 100000).filter(f)(1)
val v2 = (1 to 100000).to(LazyList).filter(f)(1)
```

v1 和 v2 等价。计算 v1 的时候会打印 `1 2 3...9999 100000`, 而计算 v2 的时候打印 `1 2 3 ... 21 22`。这是因为对于 v2，`(1 to 100000).to(LazyList)` 产生的是 `scala.collection.immutable.LazyList`。其中官方文档对其有个简单的描述

> This class implements an immutable linked list that evaluates elements in order and only when needed

也就是当 LazyList 里面的元素被需要的时候，才会进行有序计算，并且计算会终止知道所需的元素计算结束。这也就是为什么会有上述的输出了。

### 惰性求值 Lazy Evaluation
在 Scala 里面，Lazy 意味着两点

- **尽量延后求值计算**
- **只计算一次**

例如
```scala
def expr = {
  val x = { print(”x”); 1 }
  lazy val y = { print(”y”); 2 }
  def z = { print(”z”); 3 }
  z + y + x + z + y + x // last line
}
expr
```
这样的输出为 `xzyz`

### Infinite Sequences
利用 LazyList 的特性，可以构造出无限序列。比如

```scala
scala> def from(n: Int): LazyList[Int] = n #:: from(n + 1) // 无限序列
from: (n: Int)LazyList[Int]

scala> val natures = from(0) // 自然数
natures: LazyList[Int] = LazyList(<not computed>)

scala> val hundreds = natures.filter(_ % 100 == 0)
hundreds: scala.collection.immutable.LazyList[Int] = LazyList(<not computed>)

scala> val fourHundred = hundreds(4) // 计算
fourHundred: Int = 400
```

**埃拉托斯特尼筛法**
> 埃拉托斯特尼筛法是列出所有小素数最有效的方法之一，其名字来自于古希腊数学家埃拉托斯特尼，并且被描述在另一位古希腊数学家尼科马库斯所著的《算术入门》中。-[维基百科](https://zh.wikipedia.org/wiki/%E5%9F%83%E6%8B%89%E6%89%98%E6%96%AF%E7%89%B9%E5%B0%BC%E7%AD%9B%E6%B3%95)

用 LazyList 实现会非常简单，
```scala
def from(n: Int): LazyList[Int] = {
  n #:: from(n + 1)
}

def sieve(s: LazyList[Int]): LazyList[Int] = {
  s.head #:: sieve(s.tail.filter(_ % s.head != 0))
}

def primeNumber(n: Int): Int = {
    sieve(from(2))(n)
}

val n = sieve(from(2))(100) // 输出 547
```

### 题目：倒水问题
给几个知道容量，但是没有刻度的杯子，有个可以取之不尽的水源用来给杯子装满水和将杯子的水全部倒出。我们需要做的就是盛出给定容量的水。我们能做的操作有三个
- empty 清空
- fill 放满水
- pour(a, b) 把 a 的水全部往 b 倒直至 b 杯满了或者 a 杯没水了

现在需要找到取得容量为 N 的水时，需要的操作。

附：1. [Scala 完整代码](https://github.com/razertory/scala-code-lab/blob/master/src/main/scala/scalaschool/WaterPouring.scala) 2. [python 解法](https://www.youtube.com/watch?v=q6M_pco_5Vo)



## W3

## W3