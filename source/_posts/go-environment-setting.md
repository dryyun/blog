---
title: Go 学习 - 环境设置
categories:
  - Go
date: 2018-11-29 12:25:11
tags:
  - Go
---
> Go 分类文章，学习笔记，会不定时修改，补充，纠错，增加内容，路漫漫。

> 当前环境  
> - 设备 MacBook Pro  
> - 系统 macOS High Sierra 10.13.6  
> - Go 版本 1.10.4   

## 开发工具
- [VSCode](/2018/11/29/go-with-vscode/)
- [GoLand](https://www.jetbrains.com/go/) 

## Go 安装
- 源码安装，https://golang.org/dl/ 下载相应的 goVERSION.src.tar.gz 即可
- 标准包安装
    - 下载地址 https://golang.org/dl/
    - 需要判断操作系统是 32 位还是 64 位，uname -m
- 三方工具安装
    - homebrew，mac
    - apt-get、yum，linux
    - [gvm](/2018/11/28/how-to-use-gvm/)

<!-- more --> 

## 环境变量

### 环境变量设置
- GOPATH
    - 很重要，go 的很多命令都是依赖 GOPATH 的，比如 `go install`，`go get`  
    - GO 1.8 开始，GOPATH 如果不设置，默认是 $HOME/go
    - Go 1.1 - 1.7 ，必须手动设置
    - <del>GO 1.1 之前，好像是同 GOROOT ，这不确定</del>
    - 支持多目录，使用 : 分割，go get 的内容会放入第一个目录下
    - GO 1.11 开始，如果使用 `go modules` ，GOPATH 就不需要设置了 
    
- GOBIN，生成可执行文件的目录
    - 推荐方式，设置 GOBIN 环境变量为 GOPATH/bin 
    - 如果不设置，默认就是 GOPATH/bin
    - 单独设置成其他的目录，可执行文件会生成在相应的文件夹下面
    - 使用 GoLand 的终端，会默认把 GOPATH/bin 加入 PATH ，不管 GOBIN 设置了什么值
    
- PATH
    - 需要把 GOBIN 路径加入 PATH 路径里，才能调用生成的命令文件    

### 环境变量介绍
- GOROOT 
    - 用来指定 Go 的安装目录
    - GOROOT 的目录结构和 GOPATH 类似，因此存放 fmt 包的源代码对应目录应该为 $GOROOT/src/fmt 

- GOOS 、GOARCH
    - GOOS 环境变量用于指定目标操作系统（例如 android、linux、darwin 或 windows）
    - GOARCH 环境变量用于指定处理器的类型，例如 amd64、386 或 arm 等
    - 交叉编译需要用到，比如 `GOARCH="amd64"  GOOS="linux" go build`     


## GOPATH 目录
- src，源码文件目录，就是开发程序的目录，新建一个文件夹就代表开发一个项目
- pkg，编译后的文件目录，一般是非 main 包生成的 .a 文件
- bin，可执行文件目录，一般也就是 GOBIN 的路径

## 命令介绍
运行 ` go help` 查看所有的命令，`go help [command]`，查看关于单个命令的更多信息

最常用命令，简单介绍
- go build
    - 对于非 main 包，没有任何效果
    - 对于 main 包，会在当前目录生成可执行命令
- go install
    - 对于非 main 包，会在 pkg 目录下生成 .a 文件
    - 对于 main 包，会在 bin 目录生成可执行文件
- go run
    - 直接运行 main 包，但是不生成可执行命令    
- go get    
    - 获取远程包，并且 install
    - 分为两步，1、现在源码到 GOPATH/src 目录，2、go install 安装
- go test
    - 会默认读取目录下 *_test.go 的文件，运行测试 
- go env，查看环境配置
- go version，查看 Go 版本    

当然还有很多命令。。。


## Hello World

> `$ mkdir -p $GOPATH/src/hello `
> `$ cd $GOPATH/src/hello ` 
> ```text
    $ echo 'package main     
    
     import "fmt"
     
     func main() {
             fmt.Println("Hello, world or 你好，世界 or καλημ ́ρα κóσμ or こんにちはせかい")
     }
     ' > hello.go
     ```
> `$ go run hello.go`  

可以看出 Go 原生支持 Unicode，可以处理全世界任何语言的文本。      



