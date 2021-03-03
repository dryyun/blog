---
title: Go Modules 历史变迁
categories:
  - Go
tags:
  - Go
date: 2021-02-25 12:13:11
---
> Go 分类文章，学习笔记，会不定时修改，补充，纠错，增加内容，路漫漫。

# 两种包管理运行模式

- GOPATH mode，从 `vendor` 和 `GOPATH` 下寻找依赖,依赖会被下载至 `GOPATH/src` 目录下
- module-aware mode



# Go 1.11 – 2018.8

正式推出 go modules ，可以查看 `go help modules` 获取相关信息



## GO111MODULE 

新增的环境变量，用于控制 Go 代码包管理运行模式



```txt
For more fine-grained control, the module support in Go 1.11 respects
a temporary environment variable, GO111MODULE, which can be set to one
of three string values: off, on, or auto (the default).
If GO111MODULE=off, then the go command never uses the
new module support. Instead it looks in vendor directories and GOPATH
to find dependencies; we now refer to this as "GOPATH mode."
If GO111MODULE=on, then the go command requires the use of modules,
never consulting GOPATH. We refer to this as the command being
module-aware or running in "module-aware mode".
If GO111MODULE=auto or is unset, then the go command enables or
disables module support based on the current directory.
Module support is enabled only when the current directory is outside
GOPATH/src and itself contains a go.mod file or is below a directory
containing a go.mod file.

In module-aware mode, GOPATH no longer defines the meaning of imports
during a build, but it still stores downloaded dependencies (in GOPATH/pkg/mod)
and installed commands (in GOPATH/bin, unless GOBIN is set).
```



- GO111MODULE = auto，默认值（设置为 auto 或者不设置）
  - 在 GOPATH/src 目录外，且文件夹包含 go.mod 文件，就运行 module-aware mode，其余情况都是 GOPATH mode
- GO111MODULE = on，开启
  - 不管目录所在路径，都是 module-aware mode
  - 运行 go build 等命令，会优先判断 go.mod 是否存在，不存在的话，先创建 go.mod 文件
- GO111MODULE = off，关闭
  - 任何情况下，都关闭

## 包下载路径

- module-aware mode 在 `GOPATH/pkg/mod` 目录下
- GOPATH mode 在 `GOPATH/src` 目录下



## Go Get 

运行在不同 mode 下，行为不同

- module-aware mode 会修改 go.mod 文件
- GOPATH mode ，按照之前的行为运行

### Go Get 存在的问题

如果 GO111MODULE = on ，且当前目录没有 go.mod 文件，会报错 `go: cannot find main module; see 'go help modules'`



## vendor 目录支持

运行 `go mod vendor` ，会在当前目录生成 vendor 目录，从 GOPATH/pkg/mod 复制 packge 过来

运行命令类似，`go build -mod=vendor`  加上 `-mod=vendor`，会使用 vendor 目录下依赖，否则还是使用 GOPATH/pkg/mod 下依赖



## GOPROXY

新增 GOPROXY 环境变量，用于设置 go module 下载代理地址

<!-- more --> 

# Go 1.12  – 2019.2

## 解决 Go get 问题


GO111MODULE=on 时，获取go  get module不再显式需要 go.mod

## go.mod 新增 go version 字段

用于指示该 module 内源码所使用的 go 版本。  

如果 go.mod 中 go 指示器指示的版本高于你使用的 go tool 版本，那么 go 也会尝试继续编译。





# Go 1.13 – 2019.8

## GO111MODULE = auto 行为变化

module mode 优先级提升  

只要文件夹内包含 go.mod 文件，就进入 module mode ，不管是否在 GOPATH/src 下面



## GOPROXY 变化

GOPROXY 设定了默认值 https://goproxy.cn,direct ，且支持多个代理地址

## GOSUMDB、GOPRIVATE、GONOPROXY、GONOSUMDB

- GOSUMDB 设置检查 go.sum 的地址，默认是 sum.golang.org
- GOPRIVATE 设置支持自建内部的地址，不需要 goproxy 和不需要 gosumdb 校验
- GONOPROXY、GONOSUMDB ，取消设置





# Go 1.14 - 2020.2

## vendor 目录支持

如果当前目录下有 vendor，默认使用 verndor 下依赖，而不是 $GOPATH/pkg/mod下  

可以通过 `-mod=mod` 改变行为



## GOINSECURE 

设置 GOINSECURE，不再要求 proxy server 地址必须以 https 方式获取，即使使用 https，也不再对 server 证书进行校验  



## subversion 支持

go module 支持 subversion 仓库获取



# Go 1.15 - 2020.8

## GOMODCACHE

通过 GOMODCACHE 可以设置 go module cache 位置，之前版本不能修改，一定为 ` $GOPATH/pkg/mod`  

这次版本默认没变，但是已经可以修改了，进一步跟 GOPATH 脱离  





# Go 1.16 - 2021.2 

## module mode  成为默认

Go module-aware模式成为了默认模式，即默认设置 GO111MODULE = on  

当然可以通过设置为 off 改变行为，回到 GOPATH 模式

## GOVCS

设置 GOVCS ，用于控制源码获取所使用的版本控制工具 



# 总结

从 Go 1.11 - 1.16 ，go module 已经很成熟，据传 Go 1.17 会完全移除 GOPATH 。

Go 被人吐槽的几大问题

- 包管理
- 错误处理
- 泛型支持

终于是解决了一个了 

