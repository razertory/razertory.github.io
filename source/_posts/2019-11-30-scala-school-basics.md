---
title: Scala 课堂 - 基础
date: 2019-11-30 21:26:36
tags: 
---

### 为什么选择 Scala?
* 表达能力
* 函数是一等公民
* 闭包
* 简洁
* 类型推断
* 函数创建的文法支持
* Java 互操作性
* 可重用 Java 库
* 可重用 Java 工具
* 没有性能惩罚

### Scala 如何工作？
编译成 Java 字节码， 可在任何标准 JVM 上运行，甚至是一些不规范的 JVM 上，如 Dalvik，Scala 编译器是 Java 编译器的作者写的。

### 用 Scala 思考
Scala 不仅仅是更好的 Java。你应该用全新的头脑来学习它，你会从这些课程中认识到这一点的。

### 启动解释器
使用自带的`sbt console`启动。

```java
scala> 1 + 1
res0: Int = 2
```
res0 是解释器自动创建的变量名称，用来指代表达式的计算结果。它是 Int 类型，值为 2。Scala 中（几乎）一切都是表达式。

### 值 (val)
你可以给一个表达式的结果起个名字赋成一个不变量（val）。

```java
scala> val two = 1 + 1
two: Int = 2
```
你不能改变这个不变量的值。

### 变量 (var)
如果你需要修改这个名称和结果的绑定，可以选择使用 var。

```java
scala> var name = "steve"
name: java.lang.String = steve
scala> name = "marius"
name: java.lang.String = marius
```
### 函数
你可以使用 `def` 创建函数。

```scala
scala> def addOne(m: Int): Int = m + 1
addOne: (m: Int)Int
```
在 Scala 中，你需要为函数参数指定类型签名。

```scala
scala> val three = addOne(2)
three: Int = 3
```
如果函数不带参数，你可以不写括号。

```scala
scala> def three() = 1 + 2
three: ()Int

scala> three()
res2: Int = 3

scala> three
res3: Int = 3
```
### 匿名函数
你可以创建匿名函数。

```scala
scala> (x: Int) => x + 1
res2: (Int) => Int = <function1>
```
这个函数为名为 x 的 `Int` 变量加 1。

```scala
scala> res2(1)
res3: Int = 2
```
你可以传递匿名函数，或将其保存成不变量。（回过头看 `res0 是解释器自动创建的变量名称，用来指代表达式的计算结果`)

```scala
scala> val addOne = (x: Int) => x + 1
addOne: (Int) => Int = <function1>

scala> addOne(1)
res4: Int = 2
```
如果你的函数有很多表达式，可以使用{}来格式化代码，使之易读。

```scala
def timesTwo(i: Int): Int = {
  println("hello world")
  i * 2
}
```
对匿名函数也是这样的。

```scala
scala> { i: Int =>
  println("hello world")
  i * 2
}
res0: (Int) => Int = <function1>
```
在将一个匿名函数作为参数进行传递时，这个语法会经常被用到。

### 部分应用（Partial Application）
你可以使用下划线`_`部分应用一个函数，结果将得到另一个函数。Scala 使用下划线表示不同上下文中的不同事物，你通常可以把它看作是一个没有命名的神奇通配符。在{ _ + 2 }的上下文中，它代表一个`匿名参数`。你可以这样使用它：

```scala
scala> def adder(m: Int, n: Int) = m + n
adder: (m: Int,n: Int)Int
scala> val add2 = adder(2, _:Int)
add2: (Int) => Int = <function1>

scala> add2(3)
res50: Int = 5
```
你可以部分应用参数列表中的任意参数，而不仅仅是最后一个。

### 柯里化函数 (Currying Function)
有时会有这样的需求：允许别人一会在你的函数上应用一些参数，然后又应用另外的一些参数。

例如，一个乘法函数，在一个场景需要选择乘数，而另一个场景需要选择被乘数。

```scala
scala> def multiply(m: Int)(n: Int): Int = m * n
multiply: (m: Int)(n: Int)Int
```
你可以直接传入两个参数。

```scala
scala> multiply(2)(3)
res0: Int = 6
```
你可以填上第一个参数并且部分应用第二个参数。

```scala
scala> val timesTwo = multiply(2) _
timesTwo: (Int) => Int = <function1>

scala> timesTwo(3)
res1: Int = 6
```
你可以对任何多参数函数执行柯里化 (`.curried`)。例如之前的 adder 函数

```scala
scala> (adder _).curried
res1: (Int) => (Int) => Int = <function1>
```

### 可变长度参数
这是一个特殊的语法，可以向方法传入任意多个同类型的参数。例如要在多个字符串上执行 String 的首字母大写 (capitalize) 函数，可以这样写：

```scala
def capitalizeAll(args: String*) = {
  args.map { arg =>
    arg.capitalize
  }
}

scala> capitalizeAll("rarity", "applejack")
res2: Seq[String] = ArrayBuffer(Rarity, Applejack)
```

### 类
```scala
scala> class Calculator {
     |   val brand: String = "HP"
     |   def add(m: Int, n: Int): Int = m + n
     | }
defined class Calculator

scala> val calc = new Calculator
calc: Calculator = Calculator@e75a11

scala> calc.add(1, 2)
res1: Int = 3

scala> calc.brand
res2: String = "HP"
```
上面的例子展示了如何在类中用 `def` 定义方法和用 `val` 定义字段值。方法就是可以访问类的状态的函数。函数和方法在很大程度上是可以互换的。由于函数和方法是如此的相似，你可能都不知道你调用的东西是一个函数还是一个方法。而当真正碰到的方法和函数之间的差异的时候，你可能会感到困惑。在实践中，即使不理解方法和函数上的区别，你也可以用 Scala 做伟大的事情。如果你是 Scala 新手，而且在读两者的差异解释，你可能会跟不上。不过这并不意味着你在使用 Scala 上有麻烦。它只是意味着函数和方法之间的差异是很微妙的，只有深入语言内部才能清楚理解它。

### 构造函数
构造函数不是特殊的方法，他们是除了类的方法定义之外的代码。让我们扩展计算器的例子，增加一个构造函数参数，并用它来初始化内部状态。

```scala
class Calculator(brand: String) {
  /**
   * A constructor.
   */
  val color: String = if (brand == "TI") {
    "blue"
  } else if (brand == "HP") {
    "black"
  } else {
    "white"
  }

  // An instance method.
  def add(m: Int, n: Int): Int = m + n
}
```
注意两种不同风格的注释。

你可以使用构造函数来构造一个实例：

```scala
scala> val calc = new Calculator("HP")
calc: Calculator = Calculator@1e64cc4d

scala> calc.color
res0: String = black
```
### 表达式
上文的 Calculator 例子说明了 Scala 是如何面向表达式的。颜色的值就是绑定在一个 if/else 表达式上的。Scala 是高度面向表达式的：`大多数东西都是表达式而非指令`。

```scala
scala> class C {
     |   var acc = 0
     |   def minc = { acc += 1 }
     |   val finc = { () => acc += 1 }
     | }
defined class C

scala> val c = new C
c: C = C@1af1bd6

scala> c.minc // calls c.minc()

scala> c.finc // returns the function as a value:
res2: () => Unit = <function0>
```
当你可以调用一个不带括号的“函数”，但是对另一个却必须加上括号的时候，你可能会想哎呀，我还以为自己知道 Scala 是怎么工作的呢。也许他们有时需要括号？你可能以为自己用的是函数，但实际使用的是方法。

### 继承
```scala
class ScientificCalculator(brand: String) extends Calculator(brand) {
  def log(m: Double, base: Double) = math.log(m) / math.log(base)
}
```
参考 Effective Scala 指出如果子类与父类实际上没有区别，类型别名是优于继承的。A Tour of Scala 详细介绍了子类化。

### 重载方法
```scala
class EvenMoreScientificCalculator(brand: String) extends ScientificCalculator(brand) {
  def log(m: Int): Double = log(m, math.exp(1))
}
```
### 抽象类 (Abstract Class)
你可以定义一个抽象类，它定义了一些方法但没有实现它们 （在 Java 中通常是定义来抽象方法的类）。取而代之是由扩展抽象类的子类定义这些方法。你不能创建抽象类的实例。

```scala
scala> abstract class Shape {
     |   def getArea():Int    // subclass should define this
     | }
defined class Shape

scala> class Circle(r: Int) extends Shape {
     |   def getArea():Int = { r * r * 3 }
     | }
defined class Circle

scala> val s = new Shape
<console>:8: error: class Shape is abstract; cannot be instantiated
       val s = new Shape
               ^

scala> val c = new Circle(2)
c: Circle = Circle@65c0035b
```
### 特质（Traits）
特质是一些字段和行为的集合，可以扩展或混入（`mixin`）你的类中。

```scala
trait Car {
  val brand: String
}

trait Shiny {
  val shineRefraction: Int
}
class BMW extends Car {
  val brand = "BMW"
}

// 通过 with 关键字，一个类可以扩展多个特质：

class BMW extends Car with Shiny {
  val brand = "BMW"
  val shineRefraction = 12
}
```
参考 Effective Scala 对特质的观点。什么时候应该使用特质而不是抽象类？ 如果你想定义一个类似接口的类型，你可能会在特质和抽象类之间难以取舍。这两种形式都可以让你定义一个类型的一些行为，并要求继承者定义一些其他行为。一些经验法则：

* 优先使用特质。一个类扩展多个特质是很方便的，但却只能扩展一个抽象类。

* 如果你需要构造函数参数，使用抽象类。因为抽象类可以定义带参数的构造函数，而特质不行。例如，你不能说 trait t(i: Int) {}，参数 i 是非法的。

* 你不是问这个问题的第一人。可以查看更全面的答案：[stackoverflow: Scala 特质 vs 抽象类](https://stackoverflow.com/questions/1991042/scala-traits-vs-abstract-classes) , [抽象类和特质的区别](https://stackoverflow.com/questions/2005681/difference-between-abstract-class-and-trait)，以及 [Scala 编程：用特质，还是不用特质？](https://www.artima.com/pins1ed/traits.html#12.7)

### 类型
此前，我们定义了一个函数的参数为 `Int`，表示输入是一个数字类型。其实函数也可以是泛型的，来适用于所有类型。当这种情况发生时，你会看到用方括号语法引入的类型参数。下面的例子展示了一个使用泛型键和值的缓存。

```scala
trait Cache[K, V] {
  def get(key: K): V
  def put(key: K, value: V)
  def delete(key: K)
}
```
方法也可以引入类型参数。

```scala
def remove[K](key: K)
```