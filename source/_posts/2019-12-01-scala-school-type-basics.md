---
title: 类型和多态基础
date: 2019-12-01 10:47:32
tags: [scala]
---

#### 什么是静态类型？它们为什么有用？
> 按 Pierce 的话讲：“类型系统是一个语法方法，它们根据程序计算的值的种类对程序短语进行分类，通过分类结果错误行为进行自动检查。”

类型允许你表示函数的定义域和值域。例如，从数学角度看这个定义：

`f: R -> N`

它告诉我们函数 f 是从实数集到自然数集的映射。抽象地说，这就是*具体*类型的准确定义。类型系统给我们提供了一些更强大的方式来表达这些集合。鉴于这些注释，编译器可以*静态地*（在编译时）验证程序是*合理*的。也就是说，如果值（在运行时）不符合程序规定的约束，编译将失败。一般说来，类型检查只能保证*不合理*的程序不能编译通过。它不能保证每一个合理的程序都*可以*编译通过。

随着类型系统表达能力的提高，我们可以生产更可靠的代码，因为它能够在我们运行程序之前验证程序的不变性（当然是发现类型本身的模型 bug！）。学术界一直很努力地提高类型系统的表现力，包括值依赖（value-dependent）类型！

需要注意的是，所有的类型信息会在编译时被删去，因为它已不再需要。这就是所谓的`类型擦除`。

### Scala 中的类型
Scala 强大的类型系统拥有非常丰富的表现力。其主要特性有：
* **参数化多态性 (parametric polymorphism )**，粗略地说，就是泛型编程
* **局部类型推断**，粗略地说，就是为什么你不需要这样写代码 val i: Int = 12: Int
* **存在量化 (existential quantification)**粗略地说，为一些没有名称的类型进行定义
* **视图 (views)**粗略地说，就是将一种类型的值“强制转换”为另一种类型

#### 参数化多态性
多态性是在不影响静态类型丰富性的前提下，用来（给不同类型的值）编写通用代码的。

例如，如果没有参数化多态性，一个通用的列表数据结构总是看起来像这样（事实上，它看起来很像使用泛型前的 Java）：

```scala
scala> 2 :: 1 :: "bar" :: "foo" :: Nil
res5: List[Any] = List(2, 1, bar, foo)
```
现在我们无法恢复其中成员的任何类型信息。

```scala
scala> res5.head
res6: Any = 2
```
所以我们的应用程序将会退化为一系列类型转换（“asInstanceOf[]”），并且会缺乏类型安全的保障（因为这些都是动态的）。

多态性是通过指定*类型变量*实现的。

```scala
scala> def drop1[A](l: List[A]) = l.tail
drop1: [A](l: List[A])List[A]

scala> drop1(List(1,2,3))
res1: List[Int] = List(2, 3)
```
#### Scala 有秩 1 多态性 (rank-1 polymorphism)
粗略地说，这意味着在 Scala 中，有一些你想表达的类型概念“过于泛化”以至于编译器无法理解。假设你有一个函数

```scala
def toList[A](a: A) = List(a)
```
你希望继续泛型地使用它：

```scala
def foo[A, B](f: A => List[A], b: B) = f(b)
```

这段代码不能编译，因为所有的类型变量只有在调用上下文中才被固定。即使你“钉住”了类型 B：

```scala
def foo[A](f: A => List[A], i: Int) = f(i)
```
你也会得到一个类型不匹配的错误。

#### 类型推断
静态类型的一个传统反对意见是，它有大量的语法开销。Scala 通过*类型推断*来缓解这个问题。

在函数式编程语言中，类型推断的经典方法是 Hindley Milner 算法，它最早是实现在 ML 中的。

Scala 类型推断系统的实现稍有不同，但本质类似：`推断约束`，并试图统一类型。

例如，在 Scala 中你无法这样做：

```scala
scala> { x => x }
<console>:7: error: missing parameter type
       { x => x }
```
而在 OCaml 中你可以：

```OCaml
# fun x -> x;;
- : 'a -> 'a = <fun>
```
在 Scala 中所有类型推断是`局部的`。Scala 一次分析一个表达式。例如：

```scala
scala> def id[T](x: T) = x
id: [T](x: T)T

scala> val x = id(322)
x: Int = 322

scala> val x = id("hey")
x: java.lang.String = hey

scala> val x = id(Array(1,2,3,4))
x: Array[Int] = Array(1, 2, 3, 4)
```
类型信息都保存完好，Scala 编译器为我们进行了类型推断。请注意我们并不需要明确指定返回类型。

#### 变性 Variance
Scala 的类型系统必须同时解释类层次和多态性。类层次结构可以表达子类关系。在混合 OO 和多态性时，一个核心问题是：如果 T’是 T 一个子类，Container[T’] 应该被看做是 Container[T] 的子类吗？变性（Variance）注解允许你表达类层次结构和多态类型之间的关系：


|                    | 含义               | Scala 标记 |
| ------------------ | -------------------- | ---------- |
| 协变(covariant)  | C[T’] 是 C[T] 的子类 | [+T]       |
| 逆变(contravariant) | C[T] 是 C[T’] 的子类 | [-T]       |
| 不变(invariant)   | C[T] 和 C[T’] 无关 | [T]        |

子类型关系的真正含义：对一个给定的类型 T，如果 T’是其子类型，你能替换它吗？

**协变**
```scala
scala> class Covariant[+A]
defined class Covariant

scala> val cv: Covariant[AnyRef] = new Covariant[String]
cv: Covariant[AnyRef] = Covariant@4035acf6

scala> val cv: Covariant[String] = new Covariant[AnyRef]
<console>:6: error: type mismatch;
 found   : Covariant[AnyRef]
 required: Covariant[String]
       val cv: Covariant[String] = new Covariant[AnyRef]
                                   ^
```

**逆变**
```scala
scala> class Contravariant[-A]
defined class Contravariant

scala> val cv: Contravariant[String] = new Contravariant[AnyRef]
cv: Contravariant[AnyRef] = Contravariant@49fa7ba

scala> val fail: Contravariant[AnyRef] = new Contravariant[String]
<console>:6: error: type mismatch;
 found   : Contravariant[String]
 required: Contravariant[AnyRef]
       val fail: Contravariant[AnyRef] = new Contravariant[String]
                                     ^
```
逆变似乎很奇怪。什么时候才会用到它呢？令人惊讶的是，函数特质的定义就使用了它！

```scala
trait Function1 [-T1, +R] extends AnyRef
```
如果你仔细从替换的角度思考一下，会发现它是非常合理的。让我们先定义一个简单的类层次结构：

```scala
scala> class Animal { val sound = "rustle" }
defined class Animal

scala> class Bird extends Animal { override val sound = "call" }
defined class Bird

scala> class Chicken extends Bird { override val sound = "cluck" }
defined class Chicken
```
假设你需要一个以 Bird 为参数的函数：

```scala
scala> val getTweet: (Bird => String) = // TODO
```
标准动物库有一个函数满足了你的需求，但它的参数是 Animal。在大多数情况下，如果你说“我需要一个___，我有一个___的子类”是可以的。但是，在函数参数这里是`逆变`的。如果你需要一个接受参数类型 Bird 的函数变量，但却将这个变量指向了接受参数类型为 Chicken 的函数，那么给它传入一个 Duck 时就会出错。然而，如果将该变量指向一个接受参数类型为 Animal 的函数就不会有这种问题：

```scala
scala> val getTweet: (Bird => String) = ((a: Animal) => a.sound )
getTweet: Bird => String = <function1>
```
函数的返回值类型是协变的。如果你需要一个返回 Bird 的函数，但指向的函数返回类型是 Chicken，这当然是可以的。

```scala
scala> val hatch: (() => Bird) = (() => new Chicken )
hatch: () => Bird = <function0>
```

#### 边界
Scala 允许你通过`边界`来限制多态变量。这些边界表达了子类型关系。

```scala
scala> def cacophony[T](things: Seq[T]) = things map (_.sound)
<console>:7: error: value sound is not a member of type parameter T
       def cacophony[T](things: Seq[T]) = things map (_.sound)
                                                        ^

scala> def biophony[T <: Animal](things: Seq[T]) = things map (_.sound)
biophony: [T <: Animal](things: Seq[T])Seq[java.lang.String]

scala> biophony(Seq(new Chicken, new Bird))
res5: Seq[java.lang.String] = List(cluck, call)
```

类型下界也是支持的，这让逆变和巧妙协变的引入得心应手。List[+T] 是协变的；一个 Bird 的列表也是 Animal 的列表。List 定义一个操作：:(elem T) 返回一个加入了 elem 的新的 List。新的 List 和原来的列表具有相同的类型：

```scala
scala> val flock = List(new Bird, new Bird)
flock: List[Bird] = List(Bird@7e1ec70e, Bird@169ea8d2)

scala> new Chicken :: flock
res53: List[Bird] = List(Chicken@56fbda05, Bird@7e1ec70e, Bird@169ea8d2)
```

List 同样 定义了：:[B >: T](x: B) 来返回一个 List[B]。请注意 B >: T，这指明了类型 B 为类型 T 的超类。这个方法让我们能够做正确地处理在一个 List[Bird] 前面加一个 Animal 的操作：

```scala
scala> new Animal :: flock
res59: List[Animal] = List(Animal@11f8d3a8, Bird@7e1ec70e, Bird@169ea8d2)
```
注意返回类型是 Animal。

#### 量化
有时候，你并不关心是否能够命名一个类型变量，例如：

```scala
scala> def count[A](l: List[A]) = l.size
count: [A](List[A])Int
```
这时你可以使用通配符 `_` 取而代之：

```scala
scala> def count(l: List[_]) = l.size
count: (List[_])Int
```
这相当于是下面代码的简写：

```scala
scala> def count(l: List[T forSome { type T }]) = l.size
count: (List[T forSome { type T }])Int
```
注意量化会的结果会变得非常难以理解：

```scala
scala> def drop1(l: List[_]) = l.tail
drop1: (List[_])List[Any]
```
突然，我们失去了类型信息！让我们细化代码看看发生了什么：

```scala
scala> def drop1(l: List[T forSome { type T }]) = l.tail
drop1: (List[T forSome { type T }])List[T forSome { type T }]
```
我们不能使用 T 因为类型不允许这样做。

你也可以为通配符类型变量应用边界：

```scala
scala> def hashcodes(l: Seq[_ <: AnyRef]) = l map (_.hashCode)
hashcodes: (Seq[_ <: AnyRef])Seq[Int]

scala> hashcodes(Seq(1,2,3))
<console>:7: error: type mismatch;
 found   : Int(1)
 required: AnyRef
Note: primitive types are not implicitly converted to AnyRef.
You can safely force boxing by casting x.asInstanceOf[AnyRef].
       hashcodes(Seq(1,2,3))
                     ^

scala> hashcodes(Seq("one", "two", "three"))
res1: Seq[Int] = List(110182, 115276, 110339486)
```
参考 [D. R. MacIver 写的 Scala 中的存在类型](https://www.drmaciver.com/2008/03/existential-types-in-scala/)