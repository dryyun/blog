---
title: GVM - Go 的多版本管理工具，使用介绍
categories:
  - 技术
tags:
  - Go
date: 2018-11-28 09:58:17
---


## 基本介绍
#### 项目地址
> [Go GitHub](https://github.com/golang/go)  
> [GVM GitHub](https://github.com/moovweb/gvm)   
<!-- more --> 

#### 本机环境
> 设备 MacBook Pro  
> 系统 macOS High Sierra 10.13.6   

## 多版本管理使用场景
在 Mac 上使用 `brew install go` 真的很简单，一个命令就安装了最新版本的 Go，但是在实际使用过程中
- 线上版本跟你本地版本不一样，你需要切换
- 想尝试一下最新版本的 Go，但是实际开发还是不变
- 其他语言都有 xxvm 工具，Go 也要来一个 

brew 有一点不好就是不能安装旧版本的软件，不能安装旧版本的 Go，在切换 Go 版本上也略显麻烦，这个时候就要用到多版本管理了。

> 吐槽一下 brew 的升级，让我不能开心的切换 PHP 版本了，以前的 formula 有 php55，php56，php70，php71 ，都是独立的存在，只要 brew unlink，brew link 就可以了   
> 现在改成 php@5.6，php@7.0，php@7.1，实现方式不同了，要切换版本，每次都要改 .zshrc 文件  

## 使用
#### 安装

`bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)`   
如果使用的 zsh，那么把 bash 改成 zsh 即可  

安装成功，会在家目录下增加 .gvm 的隐藏目录，并且在 .bashrc 或者 .zshrc 文件最底部增加一行  
`[[ -s "/Users/someone/.gvm/scripts/gvm" ]] && source "/Users/someone/.gvm/scripts/gvm"`   

#### 命令

`基于 GVM v1.0.22 `  

特别说明 
> 由于 Go 1.5 使用了自举，也就是用 Go 写 Go，如果在系统环境完全没有 Go 命令的情况下，使用 `gvm install go` 会报错，可以参考 [gvm 文档相关说明](https://github.com/moovweb/gvm#a-note-on-compiling-go-15)，会要求先安装 Go 1.4，但是呢，对于高版本的 macOS 来说，安装 Go 1.4 是会失败的。
所以我的做法是使用 `brew install go` 先安装一个 Go，然后再使用 gvm 安装多版本，不过也只是建议安装 >= 1.5 的版本。  

> GVM 本质上就是 shell 脚本，而作者的文档写的也不尽如人意，如果对命令不了解，对命令不满意，完全可以进入 `cd ~/.gvm/scripts`，查看、修改相应的命令。  
> 比如查看各个命令的 help 帮助就很不同，`gvm install - `,`gvm listall help`,`gvm use -h`，只能感慨作者 。

```text
Usage: gvm [command]

Description:
  GVM is the Go Version Manager

Commands:
  version    - print the gvm version number
             - 打印 GVM 的版本
             
  get        - gets the latest code (for debugging)
             - 获取 GVM 最新的代码
             
  use        - select a go version to use (--default to set permanently)
             - 当前终端环境使用某个 go 版本，加上 --default 代表所有新打开的终端环境都使用这个版本
             - 查看帮助，`gvm use -h`
             
  diff       - view changes to Go root
             - ？？？
             
  help       - display this usage text
             - 显示帮助信息
  
  implode    - completely remove gvm
             - 彻底删除 gvm 和安装的所有 go 版本和包
             - 如果命令没用，那么删除 `rm -rf ~/.gvm` 目录，去掉 .bashrc 或者 .zshrc 的相关内容即可  
  
  install    - install go versions
             - 安装某个 go 的版本
             - 可以加上 tag， gvm install [tag]，参考 https://github.com/golang/go/tags ，安装一些非稳定版本  
             - 查看帮助，`gvm install - `
             
  uninstall  - uninstall go versions
             - 卸载某个 go 版本
             
  cross      - install go cross compilers
             - 安装交叉编译器
             - gvm cross [os] [arch]，os = linux/darwin/windows，arch = amd64/386/arm
  
  linkthis   - link this directory into GOPATH
             - 链接指定目录到 GOPATH 路径
             - 以个人使用来说，只要正确设置 GOPATH 就行，这个命令基本用不到，可以往下看 GOPATH 设置部分
             - 查看帮助，gvm linkthis -h
             - 吐槽，是不是缺了 unlink 命令。。
             
  list       - list installed go versions
             - 列出安装的 Go 版本
             
  listall    - list available versions
             - 列出可用的 Go 版本
             - 使用 `--all `，列出所有的 tags 
             - 查看帮助，gvm listall help
             
  alias      - manage go version aliases
             - 管理 Go 版本别名
             - gvm alias list ，列出所有别名
             - gvm alias create [alias name] [go version name]，创建别名
             - gvm alias delete [alias name] ，删除别名
             - 个人感觉也基本用不到
             
  pkgset     - manage go packages sets
             - gvm pkgset [create/use/delete/list/empty] [pkgset name] 
             - 管理 GOPATHs 环境变量
             - 会在 `~/.gvm/environments` 目录下创建相应的文件
             - 吐槽，没有类似的 unuse 命令 
             
  pkgenv     - edit the environment for a package set
             - 编辑 pkgset 的环境变量
             - gvm pkgenv [pkgset name] 
  
```   
  
  
#### 环境设置  
通过 `go env` 可以查看当前设置的 Go 的环境。    
其中 `GOPATH` 的设置，肯定是最重要的，`不过在 go 1.11 版本中，推出了 go module，好像弱化了 gopath 的作用 ` 。    
通过 `gvm use [version]` 切换 Go 的版本，也会更改相应的环境变量，其中就包括 `GOPATH="/Users/someone/.gvm/pkgsets/go1.10.4/global"` 。    
那么问题来了，我每次切换版本，都会改变 GOPATH ，这在开发中很蛋疼，你可以看出有三个命令，`linkthis`,`pkgset`,`pkgenv` 都是跟环境变量有关的。    

对我而言，这些命令都不用，承接上文中[安装](#安装)，再在 `[[ -s "/Users/someone/.gvm/scripts/gvm" ]] && source "/Users/someone/.gvm/scripts/gvm"` 这句话后面增加相应的环境变量就可以覆盖了。    
  
>GOPATH="xxxx"
>GOBIN="$GOPATH/bin"
>PATH=="$PATH:$GOBIN" 


## 总结
虽然使用过程中有点小不如意，但是总体上很满意呀，我要的功能也不多，感谢作者，感谢开源。🙄。  




