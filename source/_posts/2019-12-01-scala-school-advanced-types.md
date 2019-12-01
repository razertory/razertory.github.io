---
title: 高级类型
date: 2019-12-01 11:20:54
tags: [scala]
---

### 视界（View Bound “类型类”）
有时候，你并不需要指定一个类型是等/子/超于另一个类，你可以通过转换这个类来伪装这种关联关系。一个视界指定一个类型可以被“看作是”另一个类型。这对对象的只读操作是很有用的。

隐式 (`implicit`) 函数允许类型自动转换。更确切地说，如果隐式函数有助于满足类型推断时，隐式函数可以按需地应用。例如：

```scala
scala> implicit def strToInt(x: String) = x.toInt
strToInt: (x: String)Int

scala> "123"
res0: java.lang.String = 123

scala> val y: Int = "123"
y: Int = 123

scala> math.max("123", 111)
res1: Int = 123
```
视界，就像类型边界，要求存在一个能够将某类型转换为指定类型的函数。你可以使用 `<%` 指定类型限制，例如：

```scala
scala> class Container[A <% Int] { def addIt(x: A) = 123 + x }
defined class Container
这是说 A 必须“可被视作” Int 。让我们试试。

scala> (new Container[String]).addIt("123")
res11: Int = 246

scala> (new Container[Int]).addIt(123) 
res12: Int = 246

scala> (new Container[Float]).addIt(123.2F)
<console>:8: error: could not find implicit value for evidence parameter of type (Float) => Int
       (new Container[Float]).addIt(123.2)
        ^
```

> 注意，新版本的 Scala 可能会提示：  view bounds are deprecated; use an implicit parameter instead.
### 其他类型限制
方法可以通过隐式参数执行更复杂的类型限制。例如，List 支持对数字内容执行 sum，但对其他内容却不行。可是 Scala 的数字类型并不都共享一个超类，所以我们不能使用 `T <: Number`。相反，要使之能工作，Scala 的 math 库对适当的类型 T 定义了一个隐含的 `Numeric[T]`。 然后在 List 定义中使用它：

```scala
sum[B >: A](implicit num: Numeric[B]): B
```

如果你调用 List(1,2).sum()，你并不需要传入一个 num 参数；它是隐式设置的。但如果你调用 List("whoop").sum()，它会抱怨无法设置 num。

在没有设定陌生的对象为 Numeric 的时候，方法可能会要求某种特定类型的“证据”。这时可以使用以下`类型-关系运算符`：

* A `=:=` B	A 必须和 B 相等
* A `<:<` B	A 必须是 B 的子类
* A `<%<` B	A 必须可以被看做是 B

（如果你在尝试使用 `<:<` 或者 `<%<` 的时候出错了，那请注意这些符号在 Scala 2.10 中被移除了。Scala School 里的例子仅能在 Scala 2.9.x 下正常工作。你可以使用新版本的 Scala，但可能会遇到错误。）

```scala
scala> class Container[A](value: A) { def addIt(implicit evidence: A =:= Int) = 123 + value }
defined class Container

scala> (new Container(123)).addIt
res11: Int = 246

scala> (new Container("123")).addIt
<console>:10: error: could not find implicit value for parameter evidence: =:=[java.lang.String,Int]
```
类似地，根据之前的隐式转换，我们可以将约束放松为可视性：

```scala
scala> class Container[A](value: A) { def addIt(implicit evidence: A <%< Int) = 123 + value }
defined class Container

scala> (new Container("123")).addIt
res15: Int = 246
```
使用视图 (View) 进行泛型编程
在 Scala 标准库中，视图主要用于实现集合的通用函数。例如 `min` 函数（在 `Seq[]` 上）就使用了这种技术：

```scala
def min[B >: A](implicit cmp: Ordering[B]): A = {
  if (isEmpty)
    throw new UnsupportedOperationException("empty.min")

  reduceLeft((x, y) => if (cmp.lteq(x, y)) x else y)
}
```
其主要优点是：

集合中的元素不必实现 Ordered trait，但 Ordered 的使用仍然可以执行静态类型检查。
无需任何额外的库支持，你也可以定义自己的排序：
```scala
scala> List(1,2,3,4).min
res0: Int = 1

scala> List(1,2,3,4).min(new Ordering[Int] { def compare(a: Int, b: Int) = b compare a })
res3: Int = 4
```

作为旁注，标准库中有视图来将 Ordered 转换为 `Ordering`（反之亦然）。

```scala
trait LowPriorityOrderingImplicits {
  implicit def ordered[A <: Ordered[A]]: Ordering[A] = new Ordering[A] {
    def compare(x: A, y: A) = x.compare(y)
  }
}
```
### 上下文边界和 implicitly[]
Scala 2.8 引入了一种串联和访问隐式参数的简单记法。

```scala
scala> def foo[A](implicit x: Ordered[A]) {}
foo: [A](implicit x: Ordered[A])Unit

scala> def foo[A : Ordered] {}                        
foo: [A](implicit evidence$1: Ordered[A])Unit
```

隐式值可以通过 `implicitly` 被访问

```scala
scala> implicitly[Ordering[Int]]
res37: Ordering[Int] = scala.math.Ordering$Int$@3a9291cf
```

相结合后往往会使用更少的代码，尤其是串联视图的时候。

### 高阶多态性类型和特设多态性
Scala 可以对“高阶”的类型进行抽象。例如，假设你需要用几种类型的容器处理几种类型的数据。你可能定义了一个 Container 的接口，它可以被实现为几种类型的容器：Option、List 等。你要定义可以使用这些容器里的值的接口，但不想确定值的类型。

这类似于函数柯里化。例如，尽管“一元类型”有类似 List[A] 的构造器，这意味着我们必须满足一个“级别”的类型变量来产生一个具体的类型（就像一个没有柯里化的函数需要只提供一个参数列表来被调用），更高阶的类型需要更多。

```scala
scala> trait Container[M[_]] { def put[A](x: A): M[A]; def get[A](m: M[A]): A }

scala> val container = new Container[List] { def put[A](x: A) = List(x); def get[A](m: List[A]) = m.head }
container: java.lang.Object with Container[List] = $anon$1@7c8e3f75

scala> container.put("hey")
res24: List[java.lang.String] = List(hey)

scala> container.put(123)
res25: List[Int] = List(123)
```
注意：*Container* 是参数化类型的多态（“容器类型”）。

如果我们结合隐式转换 implicits 使用容器，我们会得到“特设的”多态性：即对容器写泛型函数的能力。

```scala
scala> trait Container[M[_]] { def put[A](x: A): M[A]; def get[A](m: M[A]): A }

scala> implicit val listContainer = new Container[List] { def put[A](x: A) = List(x); def get[A](m: List[A]) = m.head }

scala> implicit val optionContainer = new Container[Some] { def put[A](x: A) = Some(x); def get[A](m: Some[A]) = m.get }

scala> def tupleize[M[_]: Container, A, B](fst: M[A], snd: M[B]) = {
     | val c = implicitly[Container[M]]                             
     | c.put(c.get(fst), c.get(snd))
     | }
tupleize: [M[_],A,B](fst: M[A],snd: M[B])(implicit evidence$1: Container[M])M[(A, B)]

scala> tupleize(Some(1), Some(2))
res33: Some[(Int, Int)] = Some((1,2))

scala> tupleize(List(1), List(2))
res34: List[(Int, Int)] = List((1,2))
```
### F-界多态性
通常有必要来访问一个泛型 trait 的具体子类。例如，想象你有一些泛型 trait，但需要可以与它的某一子类进行比较。

```scala
trait Container extends Ordered[Container]
```

现在子类必须实现 `compare` 方法

```scala
def compare(that: Container): Int
```
但我们不能访问具体子类型，例如：

```scala
class MyContainer extends Container {
  def compare(that: MyContainer): Int
}
```
编译失败，因为我们对 Container 指定了 Ordered 特质，而不是对特定子类型指定的。

一个可选的解决方案是将 Container 参数化，以便我们能在子类中访问其子类型。

```scala
trait Container[A] extends Ordered[A]
```
现在子类可以这样做：

```scala
class MyContainer extends Container[MyContainer] {
  def compare(that: MyContainer): Int
}
```
但问题在于 A 类型没有被任何东西约束，这导致你可能会做类似这样的事情：

```scala
class MyContainer extends Container[String] {
  def compare(that: String): Int
}
```
为了调和这一点，我们改用 F-界的多态性。

```scala
trait Container[A <: Container[A]] extends Ordered[A]
```
奇怪的类型！但注意现在如何用 A 作为 Ordered 的类型参数，而 A 本身就是 Container[A]

所以，现在

```scala
class MyContainer extends Container[MyContainer] { 
  def compare(that: MyContainer) = 0 
}
```
他们是有序的了：

```scala
scala> List(new MyContainer, new MyContainer, new MyContainer)
res3: List[MyContainer] = List(MyContainer@30f02a6d, MyContainer@67717334, MyContainer@49428ffa)

scala> List(new MyContainer, new MyContainer, new MyContainer).min
res4: MyContainer = MyContainer@33dfeb30
```

鉴于他们都是 Container[_] 的子类型，我们可以定义另一个子类并创建 Container[_] 的一个混合列表：

```scala
scala> class YourContainer extends Container[YourContainer] { def compare(that: YourContainer) = 0 }
defined class YourContainer

scala> List(new MyContainer, new MyContainer, new MyContainer, new YourContainer)                   
res2: List[Container[_ >: YourContainer with MyContainer <: Container[_ >: YourContainer with MyContainer <: ScalaObject]]] 
  = List(MyContainer@3be5d207, MyContainer@6d3fe849, MyContainer@7eab48a7, YourContainer@1f2f0ce9)
```

注意现在结果类型是由 YourContainer with MyContainer 类型确定的下界。这是类型推断器的工作。有趣的是，这种类型甚至不需要是有意义的，它仅仅对列表的统一类型提供了一个逻辑上最优的下界。如果现在我们尝试使用 Ordered 会发生什么？

```scala
(new MyContainer, new MyContainer, new MyContainer, new YourContainer).min
<console>:9: error: could not find implicit value for parameter cmp:
  Ordering[Container[_ >: YourContainer with MyContainer <: Container[_ >: YourContainer with MyContainer <: ScalaObject]]]
```
对统一的类型 Ordered[] 不存在了。太糟糕了。

### 结构类型
Scala 支持结构类型（`structural types`） — 类型需求由接口结构表示，而不是由具体的类型表示。

```scala
scala> def foo(x: { def get: Int }) = 123 + x.get
foo: (x: AnyRef{def get: Int})Int

scala> foo(new { def get = 10 })                 
res0: Int = 133
```
这可能在很多场景都是相当不错的，但这个实现中使用了反射，所以要`注意性能`！

### 抽象类型成员
在特质中，你可以让类型成员保持抽象。

```scala
scala> trait Foo { type A; val x: A; def getX: A = x }
defined trait Foo

scala> (new Foo { type A = Int; val x = 123 }).getX   
res3: Int = 123

scala> (new Foo { type A = String; val x = "hey" }).getX
res4: java.lang.String = hey
```

在做`依赖注入`等情况下，这往往是一个有用的技巧。

你可以使用 hash 操作符来引用一个抽象类型的变量：

```scala
scala> trait Foo[M[_]] { type t[A] = M[A] }
defined trait Foo

scala> val x: Foo[List]#t[Int] = List(1)
x: List[Int] = List(1)
```

### 类型擦除和清单
正如我们所知道的，类型信息在编译的时候会因为擦除而丢失。 Scala 提供了清单（`Manifests`）功能，使我们能够选择性地恢复类型信息。清单作为一个隐式的值被提供，它由编译器根据需要生成。

```scala
scala> class MakeFoo[A](implicit manifest: Manifest[A]) { def make: A = manifest.erasure.newInstance.asInstanceOf[A] }

scala> (new MakeFoo[String]).make
res10: String = ""
```

### 案例分析：Finagle
参见：https://github.com/twitter/finagle

```scala
trait Service[-Req, +Rep] extends (Req => Future[Rep])

trait Filter[-ReqIn, +RepOut, +ReqOut, -RepIn]
  extends ((ReqIn, Service[ReqOut, RepIn]) => Future[RepOut])
{
  def andThen[Req2, Rep2](next: Filter[ReqOut, RepIn, Req2, Rep2]) =
    new Filter[ReqIn, RepOut, Req2, Rep2] {
      def apply(request: ReqIn, service: Service[Req2, Rep2]) = {
        Filter.this.apply(request, new Service[ReqOut, RepIn] {
          def apply(request: ReqOut): Future[RepIn] = next(request, service)
          override def release() = service.release()
          override def isAvailable = service.isAvailable
        })
      }
    }
    
  def andThen(service: Service[ReqOut, RepIn]) = new Service[ReqIn, RepOut] {
    private[this] val refcounted = new RefcountedService(service)

    def apply(request: ReqIn) = Filter.this.apply(request, refcounted)
    override def release() = refcounted.release()
    override def isAvailable = refcounted.isAvailable
  }    
}
```
一个服务可以通过过滤器对请求进行身份验证。

```scala
trait RequestWithCredentials extends Request {
  def credentials: Credentials
}

class CredentialsFilter(credentialsParser: CredentialsParser)
  extends Filter[Request, Response, RequestWithCredentials, Response]
{
  def apply(request: Request, service: Service[RequestWithCredentials, Response]): Future[Response] = {
    val requestWithCredentials = new RequestWrapper with RequestWithCredentials {
      val underlying = request
      val credentials = credentialsParser(request) getOrElse NullCredentials
    }

    service(requestWithCredentials)
  }
}
```
注意底层服务是如何需要对请求进行身份验证的，而且还是静态验证。因此，过滤器可以被看作是服务转换器。

许多过滤器可以被组合在一起：

```scala
val upFilter =
  logTransaction     andThen
  handleExceptions   andThen
  extractCredentials andThen
  homeUser           andThen
  authenticate       andThen
  route
```
享用安全的类型吧！