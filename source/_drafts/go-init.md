---
title: Go 运行的初始化 
categories:
  - Go
tags:
  - Go
date: 2018-12-06 18:18:19
---
> Go 分类文章，学习笔记，会不定时修改，补充，纠错，增加内容，路漫漫。


## 结论
先上简单结论  
- 初始化依赖包，也就是 import 的包
- 在同一个包内，在解决依赖顺序的情况下，按照变量、常量出现的顺序依次初始化
- 按照 init 函数出现的顺序运行
- 运行 main 函数


## main 函数和 init 函数

Go 里包括两个保留函数
- main 函数，只能用于 package main 包，有且只能有一个
- init 函数，能用于所有 package，每个 package 中的 init 函数都是可选的，一个 package 能包含多个 init 函数，一个文件能包含多 init 函数

Go 程序会自动调用 init() 和 main() ，不能被显示调用。

## 初始化依赖包

- 按照依赖顺序，依次初始化包 （通过 gofmt，import 按照包字母顺序(a-f)排序，依赖顺序肯定是固定的）  
- 一个包被多次依赖，只初始化一次，在第一次时初始化，比如 A import B，C import B，A import C，B 被引用多次，但 B 包只会初始化一次
- 不能出现依赖死循环，比如 A import B，B import A

## 单个包初始化顺序
1、解决变量、常量依赖顺序，比如


```go
var a = b + c // a 第三个初始化, 为 3
var b = f()   // b 第二个初始化, 为 2, 通过调用 f (依赖c)
var c = 1     // c 第一个初始化, 为 1

func f() int { return c + 1 }
```

2、一个包存在多个 .go 文件怎么办。  
根据文件名顺序(a-f)排序，依次初始化

## init 函数初始化顺序
一个包存在多个 init 函数
- 先按照 .go 文件名顺序，依次初始化文件
- 同个文件多个 init ，根据 init 出现的顺序执行

## 运行 main 函数
最后就是运行 main 函数了 

## 代码

写的很挫的验证代码 - https://github.com/dryyun/try-go/tree/master/init_try 


## 参考
https://golang.org/ref/spec#Program_initialization_and_execution 