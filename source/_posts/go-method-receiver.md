---
title: Go Method Receiver 方法接收器介绍
categories:
  - Go
tags:
  - Go
date: 2018-12-14 16:28:11
---
> Go 分类文章，学习笔记，会不定时修改，补充，纠错，增加内容，路漫漫。

## Receiver 基本介绍

就是类似于 Class 的 Method，使用 this 或者 self 调用 ？可以这么类比吧，但是并不等同。

看具体的代码
```go
type IntReceiver struct {
	X int
}

// 方法接收器声明
func (i IntReceiver) Double() int {
	return i.X * 2
}

// 普通函数声明
func IRDouble(i IntReceiver) int {
	return i.X * 2
}

func main() {
	i := IntReceiver{3}
	d1 := i.Double() // 在 i 上调用了 IntReceiver 类型带的 Method // func (i IntReceiver) Double() int
	fmt.Printf("type = %T，value = %v\n", d1, d1)

	d2 := IRDouble(i) // 调用了普通函数 // func IRDouble(i IntReceiver) int 
	fmt.Printf("type = %T，value = %v\n", d2, d2)
}

```
 
> 定义 method 并不局限于结构体 struct，可以任何 type 声明的类型定义 Method，最简单如 `type DInt int` ，就能为 DInt 类型定义 method  

<!-- more --> 

### 方法值

接上文代码例子，`i.Double` 叫作 "选择器"，选择器会返回一个 "方法值"-> 一个将方法 `IntReceiver.Double` 绑定到特定接收器变量的函数。这个函数可以不通过指定其接收器即可被调用，即调用时不需要指定接收器 。

```go
	i := IntReceiver{4}
	IntReceiverDouble := i.Double
	fmt.Println(IntReceiverDouble()) // 直接当做一个函数调用 // 8
```

### 方法表达式

方法值，其实还是实现指定了接收器 ，`IntReceiverDouble := i.Double`，所以在调用的时候不需要指明。    

方法表达式，不需要指出具体的变量，针对的是类型。 
当 T 是一个类型时，方法表达式可能会写作 `T.f` 或者 `(*T).f`，会返回一个函数 "值"，这种函数会将其第一个参数用作接收器，所以可以用通常的方式来对其进行调用。  

```go
// 带参数的方法声明
func (i IntReceiver) Add(a int) int {
  return i.X + a
}

// 调用
  IntReceiverDouble := IntReceiver.Double

  i := IntReceiver{4}
  fmt.Println(IntReceiverDouble(i)) // 8

  IntReceiverAdd := IntReceiver.Add
  fmt.Println(IntReceiverAdd(i, 1)) // 5，i 作为第一个参数
```

## 基于指针的方法

上面介绍的，都是基于值的，当这个接受者变量本身比较大时，就可以用其指针而不是值来声明方法。

```go
// 基于指针的方法声明
func (i *IntReceiver) Triple() (r int) {
	r = (*i).X * 3
	fmt.Println(r)
	return
}

// 调用
  i := IntReceiver{2}
  t := (&i).Triple()
  fmt.Println(t)


```
### Receiver 调用多种情况

查看代码

```go
	i1 := &IntReceiver{1}
	i1.Triple() // 指针 -》调用 receiver 是指针的 method

	i2 := IntReceiver{2}
	i2.Triple() // 值变量 -》调用 receiver 是指针的 method

	i3 := IntReceiver{3}
	i3.Double() // 值变量 -》调用 receiver 是值的 method

	i4 := &IntReceiver{4}
	i4.Double() // 指针 -》调用 receiver 是值的 method
```
> - 不管你的 method 的 receiver 是指针类型还是非指针类型，都是可以通过指针 / 非指针类型进行调用的，编译器会帮你做类型转换。
> - 对于接收器是指针的方法，通过值类型调用，其实是个语法糖，`编译器隐式的获取了它的地址` ，前提是这个值能获取地址，不是临时变量
> - 对于接收器是值的方法，传入指针类型，Go 会默认根据指针找到值，一种翻译说法是 `解引用` 

### 特别说明
```go
	IntReceiver{5}.Double() // 正确
	//IntReceiver{6}.Triple() // 错误  cannot take the address of IntReceiver literal
	// 正确做法
	//t := IntReceiver{6}
	//t.Triple()

	(&IntReceiver{7}).Double() // 正确
	(&IntReceiver{8}).Triple() // 正确
```

为什么 `IntReceiver{6}.Triple()` 是错的，因为 `IntReceiver{6}` 属于临时变量，不能寻址，不能直接调用，所以必须先赋值给一个变量，然后在调用。

## 接口方法调用规则

上文所述都是针对具体类型，具体类型完全适用。  
但是对接口方法的调用，有点不同，具体规则如下

- 类型 *T 的可调用方法集包含接受者为 *T 或 T 的所有方法集
- 类型 T 的可调用方法集包含接受者为 T 的所有方法
- 类型 T 的可调用方法集不包含接受者为 *T 的方法

```go
package main

import "fmt"

type TestStruct struct {
	X int
}

// 定义 double 接口
type Doubler interface {
	Double() int
}

// 定义 triple 接口
type Tripler interface {
	Triple() int
}

// 定义在值上的 method
func (ts TestStruct) Double() int {
	r := ts.X * 2
	fmt.Println("ts.Double = ", r)
	return r
}

// 定义在指针上的 method
func (ts *TestStruct) Triple() int {
	r := (*ts).X * 3
	fmt.Println("*ts.Triple = ", r)
	return r
}

// 定义接口
func DoubleFun(d Doubler) {
	d.Double()
}

// 定义接口
func TripleFun(t Tripler) {
	t.Triple()
}

func main() {

	// 接收者是值的方法可以通过指针调用，因为会先根据指针找到值
	t1 := &TestStruct{1}
	DoubleFun(t1)

	// 指针方法可以通过指针调用
	t2 := &TestStruct{2}
	TripleFun(t2)

	// 值方法可以通过值调用
	t3 := TestStruct{3}
	DoubleFun(t3)

	// 接收者是指针的方法不可以通过值调用，因为存储在接口中的值没有地址
	//t4 := TestStruct{4}
	//TripleFun(t4)
	//  报错
	//  cannot use t4 (type TestStruct) as type Tripler in argument to TripleFun:
	//  TestStruct does not implement Tripler (Triple method has pointer receiver)
}



```

## 以上

总结完毕，Go 帮助程序员简化了很多指针的操作。



