---
title: 模式匹配与函数组合
date: 2019-12-01 10:28:36
tags:
published: false
---

### 函数组合
让我们创建两个函数：

```scala
scala> def f(s: String) = "f(" + s + ")"
f: (String)java.lang.String
```

```scala
scala> def g(s: String) = "g(" + s + ")"
g: (String)java.lang.String
```
#### compose
`compose` 组合其他函数形成一个新的函数 `f(g(x))`

```scala
scala> val fComposeG = f _ compose g _
fComposeG: (String) => java.lang.String = <function>
```

```scala
scala> fComposeG("yay")
res0: java.lang.String = f(g(yay))
```

#### andThen
`andThen` 和 `compose` 很像，但是调用顺序是先调用第一个函数，然后调用第二个，即 `g(f(x))`

```scala
scala> val fAndThenG = f _ andThen g _
fAndThenG: (String) => java.lang.String = <function>
scala> fAndThenG("yay")
res1: java.lang.String = g(f(yay))
```

### 柯里化(Curried) vs 部分应用(Partial Application)
#### case 语句
* 那么究竟什么是 case 语句？ 这是一个名为 `PartialFunction` 的函数的子类。

* 多个 case 语句的集合是什么？ 他们是共同组合在一起的多个 `PartialFunction`。

> ps: PartialFunction 详见 https://www.scala-lang.org/api/2.12.9/scala/PartialFunction.html

#### 函数 vs 偏函数 (PartialFunction)
**函数**: 对给定的输入参数类型，函数可接受该类型的任何值。换句话说，一个 (Int) => String 的函数可以接收任意 Int 值，并返回一个字符串。

**偏函数**: 对给定的输入参数类型，`偏函数`只能接受该类型的某些特定的值。一个定义为 (Int) => String 的`偏函数`可能不能接受所有 Int 值为输入。`isDefinedAt` 是偏函数的一个方法，用来确定是否能接受一个给定的参数。注意偏函数和我们前面提到的`部分应用`函数是无关的。

参考 Effective Scala 对 [PartialFunction](https://twitter.github.com/effectivescala/#Functional%20programming-Partial%20functions) 的意见。

```scala
scala> val one: PartialFunction[Int, String] = { case 1 => "one" }
one: PartialFunction[Int,String] = <function1>

// `isDefinedAt` 是`偏函数`的一个方法，用来确定是否能接受一个给定的参数
scala> one.isDefinedAt(1)
res0: Boolean = true

scala> one.isDefinedAt(2)
res1: Boolean = false
```

您可以调用一个偏函数。

```scala
scala> one(1)
res2: String = one
```

偏函数可以使用 `orElse` 组成新的函数，得到的偏函数反映了是否对给定参数进行了定义。

```scala
scala> val two: PartialFunction[Int, String] = { case 2 => "two" }
two: PartialFunction[Int,String] = <function1>

scala> val three: PartialFunction[Int, String] = { case 3 => "three" }
three: PartialFunction[Int,String] = <function1>

scala> val wildcard: PartialFunction[Int, String] = { case _ => "something else" }
wildcard: PartialFunction[Int,String] = <function1>

scala> val partial = one orElse two orElse three orElse wildcard
partial: PartialFunction[Int,String] = <function1>

scala> partial(5)
res24: String = something else

scala> partial(3)
res25: String = three

scala> partial(2)
res26: String = two

scala> partial(1)
res27: String = one

scala> partial(0)
res28: String = something else
```
#### case 之谜
[上一篇](/2019/12/01/scala-school-collections/#drop-amp-dropWhile) 我们看到一些新奇的东西。我们在通常应该使用函数的地方看到了一个 case 语句。

```scala
scala> case class PhoneExt(name: String, ext: Int)
defined class PhoneExt

scala> val extensions = List(PhoneExt("steve", 100), PhoneExt("robey", 200))
extensions: List[PhoneExt] = List(PhoneExt(steve,100), PhoneExt(robey,200))

scala> extensions.filter { case PhoneExt(name, extension) => extension < 200 }
res0: List[PhoneExt] = List(PhoneExt(steve,100))
```

为什么这段代码可以工作？

filter 使用一个函数。在这个例子中是一个`谓词函数`(PhoneExt) => Boolean。(返回一个布尔值的函数通常被称为`谓词函数`)

偏函数 PartialFunction 是 Function 的`子类型`，所以 filter 也可以使用 PartialFunction。
