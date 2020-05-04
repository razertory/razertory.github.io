---
title: Scala 总览
date: 2019-11-30 21:26:36
---

### Why Scala 
* JVM 生态
* 简洁
* 类型推断
* 函数式
* 多范式
* Actor

> 下面的所有操作都在 Scala REPL 中进行

### 表达式
```scala
scala> 1 + 1
res0: Int = 2
```
res0 是解释器自动创建的变量名称，用来指代表达式的计算结果。它是 Int 类型，值为 2。意味着你可以继续使用这个变量。
```scala
scala> res0 + 1
res1: Int = 3
```
Scala 中（几乎）一切都是表达式。

### 值 (val) 和变量 (var)
你可以给一个表达式的结果起个名字赋成一个不变量（val）。

```scala
scala> val two = 1 + 1
two: Int = 2
scala> two = 3
           ^
       error: reassignment to val
```
你不能改变这个不变量的值，但如果是 var 声明的就可以改变。

### 函数
**你可以使用 `def` 创建函数。**
```scala
scala> def addOne(m: Int): Int = m + 1
addOne: (m: Int)Int
```
**你可以创建匿名函数。**

```scala
scala> (x: Int) => x + 1
res2: (Int) => Int = <function1>
```
**你可以把匿名函数赋值给 val。**
```scala
scala> val addOne = (x: Int) => x + 1
addOne: (Int) => Int = <function1>

scala> addOne(1)
res4: Int = 2
```

**你可以部分应用一个函数**
```scala
scala> def adder(m: Int, n: Int) = m + n
adder: (m: Int,n: Int)Int

// 你可以「部分应用」参数列表中的任意参数，而不仅仅是最后一个。
scala> val add2 = adder(2, _:Int) 
add2: (Int) => Int = <function1>

scala> add2(3)
res50: Int = 5
```

**你可以柯里化函数 (Currying Function)**

```scala
scala> def multiply(m: Int)(n: Int): Int = m * n
multiply: (m: Int)(n: Int)Int

//你可以直接传入两个参数。
scala> multiply(2)(3)
res0: Int = 6

//你可以填上第一个参数并且部分应用第二个参数。
scala> val timesTwo = multiply(2) _
timesTwo: (Int) => Int = <function1>

scala> timesTwo(3)
res1: Int = 6

// 你可以对任何多参数函数执行柯里化 (`.curried`)
scala> (adder _).curried
res1: (Int) => (Int) => Int = <function1>
```

**你可以参数可变参数函数**
```scala
def capitalizeAll(args: String*) = {
  args.map { arg =>
    arg.capitalize
  }
}

scala> capitalizeAll("rarity", "applejack")
res2: Seq[String] = ArrayBuffer(Rarity, Applejack)
```

### OOP
类、继承和 Java 比较类似。额外的 Scala 还引入了
- trait。实现类似于 Ruby、Python 这样的动态语言的 mix-in
- object 关键字 和 apply() 方法。方便实现 single instance
- case class。为方便存放值和模式匹配引入了 

**Trait**
```scala
// trait 是一些字段和行为的集合，可以扩展或混入（`mixin`）你的类中。
trait Car {
  val brand: String
}

trait Shiny {
  val shineRefraction: Int
}
class BMW extends Car {
  val brand = "BMW"
}

// 通过 with 关键字，一个类可以扩展多个 trait：
class BMW extends Car with Shiny {
  val brand = "BMW"
  val shineRefraction = 12
}
```

**object**
```scala
// object 实现 single instance
object Timer {
  var count = 0

  def currentCount(): Long = {
    count += 1
    count
  }
}
// 不必再用 new 关键字
scala> Timer.currentCount()
res0: Long = 1

// Companion Objec 伴生对象，用来给 object 初始化值
class Bar(foo: String)
object Bar {
  def apply(foo: String) = new Bar(foo)
}
```

**case class**
```scala
case class Calculator(brand: String, model: String)
def calcType(calc: Calculator) = calc match {
  case Calculator("HP", "20B") => "financial"
  case Calculator("HP", "48G") => "scientific"
  case Calculator("HP", "30B") => "business"
  case Calculator(_, _) => "Calculator: %s %s is of unknown type".format(ourBrand, ourModel)
  case _ => "Not a calculator"
}
```