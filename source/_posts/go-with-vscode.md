---
title: 使用 VSCode 开发 Go - 浅尝辄止
categories:
  - Go
date: 2018-11-29 09:23:38
tags:
  - Go
  - VSCode
---
开发 Go 如果懒的折腾就直接上 [GoLand](https://www.jetbrains.com/go/) 就行了，我就是懒。

不过，这不是本文的目的，毕竟 GoLand 要钱，要内存，要机器性能，要求还蛮高的，相对来说 [VSCode](https://code.visualstudio.com/) 就简单了呀。

## 使用
默认你已经安装了 VSCode 了

### 安装 Go 插件

可以查看 [Go for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=ms-vscode.Go) 相关介绍  

只要使用 VSCode 打开任意 .go 文件，就会推荐安装 Go 插件

<img src="/go-extension.png" width="500px" >


### 安装依赖工具

只要任意编辑一下 .go 文件，哪怕就是保存一下，就会提示你安装依赖工具    

<img src="/go-extension2.png" width="500px" >

选择 `install all` 即可，其实也就是安装这些

<img src="/tools.png" width="200px" >

当然，在特殊的网络环境之下，基本是很难成功，只能手动安装了。

#### 手动安装依赖

需要 `fq`  

```text
go get -u -v github.com/nsf/gocode
go get -u -v github.com/uudashr/gopkgs/cmd/gopkgs
go get -u -v github.com/lukehoban/go-outline
go get -u -v github.com/newhook/go-symbols
go get -u -v golang.org/x/tools/cmd/guru
go get -u -v golang.org/x/tools/cmd/gorename
go get -u -v github.com/derekparker/delve/cmd/dlv
go get -u -v github.com/rogpeppe/godef 
go get -u -v github.com/sqs/goreturns
go get -u -v github.com/golang/lint/golint

查看文档需要安装更多的
go get -u -v github.com/cweill/gotests/...
go get -u -v github.com/haya14busa/goplay/cmd/goplay
go get -u -v github.com/fatih/gomodifytags
go get -u -v github.com/josharian/impl
```
安装完，可以查看 `$GOPATH/bin`，会看到生成的命令文件  

> 多说一句，我去年安装的时候，其实碰到了更多的问题，不过这次安装基本很顺利，看来是 Go 更完善了，Go 1.10.4 路过   

### 插件设置

可以打开 setting.json 配置文件，查看 `go.` 开头的配置项，按需修改就行了。。。

## 总结

VSCode 还有很多功能待垦，设置调试 Go 可能要花点时间，但是也是不难。  
爱折腾的看文档，查 Google，有问题基本都能解决。 
不爱折腾的，使用 GoLand，也会遇到很多问题，还是要慢慢解决。
所以并没有一劳永逸的工具，毕竟是码农。。。



