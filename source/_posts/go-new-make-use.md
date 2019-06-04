---
title: Go - var &  make & new 在复杂类型上的使用区别
categories:
  - Go
tags:
  - Go
date: 2019-05-30 12:22:09
---
> Go 分类文章，学习笔记，会不定时修改，补充，纠错，增加内容，路漫漫。

这里主要讲解 var &  make & new  在声明变量关于 array、slice、map、struct 这些类型上的区别。

# 预备知识

## var 声明变量

`var 变量名字 类型 = 表达式` ，如果省略了`表达式`，就使用类型的零值初始化变量 

## make 和 new 的知识
可以查看 GoDoc - builtin 的相关内容
- [new](https://godoc.org/builtin#new)
	- `func new(Type) *Type`	 
	- 创建一个 Type 类型的匿名变量，初始为 Type 类型的零值，返回变量地址，返回的指针类型为`*Type`
- [make](https://godoc.org/builtin#make)
	- `func make(t Type, size ...IntegerType) Type`
	- 分配并初始化一个类型为 slice 、map 、或 channel 的对象，返回类型与 Type 相同，而非指向它的指针

## 零值

- array、struct，每个元素或字段都是对应该类型的零值
- slice、map，对于零值 nil 

<!-- more --> 
# 使用区别

## array

数组是值类型，数组变量代表的就是值

```Go
	var a1 [3]int                   // 使用 int 零值初始化 a1，a1 就是 [3]int 类型
	fmt.Printf("%T\t%#v\n", a1, a1) // [3]int  [3]int{0, 0, 0}

	a2 := new([3]int)                       // a2 是指针，是 *[3]int类型
	fmt.Printf("%T\t%p\t%#v\n", a2, a2, a2) // *[3]int 0xc0000182c0    &[3]int{0, 0, 0}
	fmt.Println(a2[0], (*a2)[1])            // 0 0 // 都引用了数组的值，其中 a2[0] 是解引用，根据指针找到了变量

	a2[0] = 123
	(*a2)[1] = 234
	fmt.Println(a2, *a2) // &[123 234 0] [123 234 0]

	fmt.Println(len(a2), len(*a2)) // 3 3
	
	// make 不能用于 array
```


## slice 

切片是引用类型，slice 变量是指针

```Go
	var s1 []int                            // 使用 slice 零值就是 nil 初始化 s1
	fmt.Printf("%T\t%p\t%#v\n", s1, s1, s1) // []int   0x0     []int(nil)
	// s1 的地址是 0x0，就是说还没有分配地址
	fmt.Println(len(s1), s1 == nil) // 0 true，长度是 0，s1 = nil

	fmt.Println("========")

	s2 := []int{}   // s2 是指针，可以获取地址
	fmt.Printf("%T\t%p\t%#v\n", s2, s2, s2) // []int   0x118fff0       []int{}
	fmt.Println(len(s2), s2 == nil)         // 0 false

	//s1[0] = 1 // panic: runtime error: index out of range
	//s2[0] = 2 // panic: runtime error: index out of range
	// 因为 s1,s2 len 、cap 都是 0 ，所以赋值会报错

	// 对比 s1，s2 可以发现，s1 长度是 0 ，本身等于 nil，s2 长度也是 0 ，不等于 nil，
	// s1,s2 不同的声明方式，有差异

	fmt.Println("========")

	s3 := make([]int, 2)   // 或者  = make([]int,2,4) 加上第三个 cap 参数都可以
	fmt.Printf("%T\t%p\t%#v\n", s3, s3, s3)  // []int   0xc0000ae000    []int{0, 0}
	fmt.Println(len(s3), cap(s3), s3 == nil) // 2  2  false

	// s3 是指针，len = cap = 2 , 底层是数组

	fmt.Println("========")

	s4 := new([]int)   // s4 是指向开辟的匿名 slice 的指针，而匿名的 slice 使用零值也就是 nil 初始化
	fmt.Printf("%T\t%p\t%T\t%p\n", s4, s4, *s4, *s4) // *[]int  0xc0000a2060    []int   0x0
	// 看结果可以，s4 本身地址有值，*s4 就是切片了，0x0 意味着就是 nil

	fmt.Println(len(*s4), *s4 == nil) // 0 true

	// 怎么使用了，其实 *s4 就是切片了，当做一般变量使用就行了
	*s4 = append(*s4, 1, 2, 3)
	fmt.Printf("%T\t%p\t%T\t%p\n", s4, s4, *s4, *s4) // *[]int  0xc0000a2060    []int   0xc0000a0020
	fmt.Println(len(*s4), cap(*s4), *s4 == nil)      // 3 4 false

	*s4 = append(*s4, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11)
	fmt.Printf("%T\t%p\t%T\t%p\n", s4, s4, *s4, *s4) // *[]int  0xc0000a2060    []int   0xc0000aa000
	fmt.Println(len(*s4), cap(*s4), *s4 == nil)      // 14 14 false

	// 通过 append 操作发现
	// *s4 的指针地址会扩容，会改变，len 、cap 都会变
	// s4 的地址没有改变

```

## map

map 是引用类型

```Go
	var m1 map[string]int                   // 初始化为 map 的零值，nil
	fmt.Printf("%T\t%p\t%#v\n", m1, m1, m1) // map[string]int  0x0     map[string]int(nil)
	// 通过 0x0 就可以看出是零值 nil
	fmt.Println(len(m1), m1 == nil) // 0 true

	//m1["a"] = 0 // panic: assignment to entry in nil map
	// 因为 map 是 nil，还没真实分配空间，所以报错
	// 要真正使用，还必须要 m1 = make(map[string]int )
	m1 = make(map[string]int)
	m1["a"] = 0

	fmt.Println("========")

	m2 := map[string]int{}
	fmt.Printf("%T\t%p\t%#v\n", m2, m2, m2) // map[string]int  0xc0000a0000    map[string]int{}
	fmt.Println(len(m2), m2 == nil)         // 0 false

	m2["a"] = 0 // 这步没有报错，是因为已经分配空间了

	fmt.Println("========")

	m3 := make(map[string]int)

	fmt.Printf("%T\t%p\t%#v\n", m3, m3, m3)
	fmt.Println(len(m3), m3 == nil) // 0 false

	// m2，m3 声明其实是一样的，行为一样
	// 包括 m4 的声明都差不都
	//m4 := map[string]int{
	//	"a": 1,
	//}

	fmt.Println("========")

	m5 := new(map[string]int)
	fmt.Printf("%T\t%p\t%#v\n", m5, m5, m5)    // *map[string]int 0xc00000e010    &map[string]int(nil)
	fmt.Printf("%T\t%p\t%#v\n", *m5, *m5, *m5) // map[string]int  0x0     map[string]int(nil)

	// m5 是指向 map 的指针
	// *m5 是 nil 的 map

	*m5 = make(map[string]int)
	(*m5)["a"] = 1
	fmt.Printf("%T\t%p\t%#v\n", m5, m5, m5)    // *map[string]int 0xc00000e010    &map[string]int{"a":1}
	fmt.Printf("%T\t%p\t%#v\n", *m5, *m5, *m5) // map[string]int  0xc000068270    map[string]int{"a":1}

	// 要使用 *m5，必须先 make

```

## struct

struct 是值类型，零值是各个成员的零值  
struct 通常使用指针操作

```Go
	type Point struct {
		X, Y int
		Z    string
	}
	var p1 Point
	fmt.Printf("%T\t%#v\n", p1, p1) // main.Point      main.Point{X:0, Y:0, Z:""}

	p2 := Point{}
	fmt.Printf("%T\t%#v\n", p2, p2) // main.Point      main.Point{X:0, Y:0, Z:""}

	p3 := new(Point)
	fmt.Printf("%T\t%p\t%#v\n", p3, p3, p3) // *main.Point     0xc00000c080    &main.Point{X:0, Y:0, Z:""}
	fmt.Printf("%T\t%#v\n", *p3, *p3)       // main.Point      main.Point{X:0, Y:0, Z:""}
```

# 总结
通过代码验证，直观。