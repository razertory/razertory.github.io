---
title: Scala 函数式编程设计
date: 2020-02-20 23:53:05
layout: post
---
在这个 2020 年初的特殊时期。。。

Scala 是一门现代化，多范式的 JVM 语言。

传送门(可能需要🚀)
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
        case ”ping” => ”pong”
    }
    def isDefinedAt(x: String) = x match {
        case ”ping” => true
        case _ => false
    }
}
```
f1 和 f2 等价。

ps: 以上，「等价」的意思是两个函数只要输入相同，输出一定相同。
## W2

## W3

## W3