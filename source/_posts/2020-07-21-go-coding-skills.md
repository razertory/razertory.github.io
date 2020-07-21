---
title: 改善你的 Go 代码
date: 2020-07-21 14:29:48
tags:
---

之前参与翻译了 Uber 公司分享的 Go 语言编码规范。一直以来，我对编码规范的态度是**80%的正确性和20%的一致性**。写代码，重要的是让程序正确和高效以及可维护性。近期整理了工作中遇到的改善 Go 编码的一些案例。

### 闭包（Closure）和 defer
闭包的官方解释是：闭包是由函数和与其相关的引用环境组合而成的实体。defer 可以让一个闭包在函数 return 的时刻调用。比如有一个这样的代码
```go
for _, v := range values {
	conn := d.redis.Get(ctx)
	err := conn.Send("SADD")
	err = conn.Send("EXPIRE")
	err = conn.Flush()
	conn.Close()
}
```
3 到 5 行的代码都需要处理 err，同时还需要 conn.Close()。所以可以改为
```go
for _, v := range values {
	conn := d.redis.Get(ctx)
	err := conn.Send("SADD")
	if err != nil {
		// 处理错误
		conn.Close()
	}
	err = conn.Send("EXPIRE")
	if err != nil {
		// 处理错误
		conn.Close()
	}
	err = conn.Flush()
	if err != nil {
		// 处理错误
		conn.Close()
	}
	conn.Close()
}
```
这么写阅读起来有太多重复的逻辑，同时修改之后，也容易忘记 conn.Close()。这种情况，可以试着用闭包配合 defer 来改善
```go
for _, v := range values {
	err := func() error {
		conn := d.redis.Get(ctx)
		defer conn.Close()
		if err := conn.Send("SADD"); err != nil {
			return err
		}
		if err := conn.Send("EXPIRE"); err != nil {
			return err
		}
		if err := conn.Flush(); err != nil {
			return err
		}
	}
	if err != nil {
		// 处理错误
	}
}
```

### nil interface
```go
type Audi struct {
	price int
}
type Tesla struct {
	price int
}

func main() {
	car := getCar()
	if car == nil {
		fmt.Printf("nil")
		return
	}
	fmt.Printf("%+v is not nil", car)
}

func getCar() interface{}{
	var audi *Audi
	var tesla *Tesla
	if rand.Int63() / 2 == 0 {
		return tesla
	}
	return audi
}
```
这段代码的输出是 14 行的 `<nil> is not nil`。针对 interface{} 类型，判断是否 nil 需要判断类型的和值，本质上只要类型存在，比如这里可能是 `*Audi` 或者 `*Tesla`，那么就不会为 nil。如果需要设计返回 interface{} 的函数，可以加上一个 ok bool 表示是否存在。
```go
func main() {
	car, ok := getCar()
	if !ok {
		fmt.Printf("nil")
	}
	fmt.Printf("%+v is not nil", car)
}

func getCar() (interface{}, bool){
	var audi *Audi // 在确定类型的地方，判断是否空，这样再用 bool 类型给到外面
	return audi, false
}
```

### 命名返回值
named return value 在和 defer 相遇的时候，会有一些需要注意的细节。
```go
func main() {
	getName()
	getName2()
}

func getName() (name string){
	name = "john"
	defer func() {
		fmt.Printf(name)
	}()
	return "jerry"
}

func getName2() (string){
	name := "john"
	defer func() {
		fmt.Printf(name)
	}()
	return "jerry"
}
```
上述代码输出的是 `jerryjohn`。如果闭包用到了 named retrun value，就意味着这个值及时没有被明显的复制，比如 `return "jerry"` 实际上是让 `name` 这个变量赋值了。这种代码难以 review 和调试。所以在返回值只有一个、两个的时候，推荐不用 named return value。只有返回值多个，或者返回值的类型一样的时候，再推荐 named return value。

### 错误处理
编写生产环境代码的时候，为了让 err 产生的时候，尽量带有更多有利于排查问题的信息，推荐以下方法
- 标准库产生的 err，使用 `errors.WithStack()
- 除此之外的 err，用 github.com/pkg/errors 中的 Wrapf(), New(), Errorf()

### for 循环
Go 语言的 for 循环，循环变量实际上**总是指向同一块地址**，在循环过程中，不断进行覆盖值的操作。例如
```go
func main() {
	var arr []*int
	for i := 0; i < 3; i++ {
		arr = append(arr, &i)
	}
	fmt.Println("Values:", *arr[0], *arr[1], *arr[2])
	fmt.Println("Addresses:", arr[0], arr[1], arr[2])
}
```
输出是:
Values: 3 3 3
Addresses: 0xc00001c078 0xc00001c078 0xc00001c078

