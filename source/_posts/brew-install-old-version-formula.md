---
title: HomeBrew 安装特定版本的 Formula
categories:
  - 技术
  - homebrew
date: 2022-07-05 23:23:41
tags:
---

在 Mac 上 brew 作为常用的包管理软件，一直被我使用。

一般来说，使用 brew 都会安装最新版本的软件，有时候需要安装特定版本的软件的时候，我都会考虑使用 Docker 实现。

不过也有偷懒的时候，brew 也确实是方便，所以考虑一下怎么使用 brew 安装特定版本、本机安装多版本的 Formula

## brew 安装 Formula 简单原理介绍

```shell
$ brew tap-info homebrew/core 

output :
homebrew/core: 3 commands, 6162 formulae
/usr/local/Homebrew/Library/Taps/homebrew/homebrew-core (6,606 files, 643.2MB)
From: https://github.com/Homebrew/homebrew-core

```

可以看到，整个就是一个 github repo

具体的每个 formula 在目录 `https://github.com/Homebrew/homebrew-core/tree/master/Formula` 

如果软件作者希望 formula 被添加或者被更新，都给这个 repo 提 PR 即可

```
$ brew install grafana 

会读文件
https://github.com/Homebrew/homebrew-core/blob/master/Formula/grafana.rb
```

安装 grafana 会依赖本地的 grafana.rb 文件，根据文件内容下载 url 的压缩包，然后校验 sha256 

<!-- more --> 

## 安装一个老版本的 Formula 

知道了基本原理，只要把 *.rb 文件恢复到以前的某个特定版本，就可以直接 brew install 了

可以通过 git log 查看

```
$ cd /usr/local/Homebrew/Library/Taps/homebrew/homebrew-core/Formula
$ git log grafana.rb 
```

可以直接查看 github page history 

https://github.com/Homebrew/homebrew-core/commits/master/Formula/grafana.rb

恢复到特定版本即可



## 安装多版本

上面的方法可以安装一个 formula 的某个特定版本，但是不能多版本同时安装



### 创建本地的 formula 文件

```
# Create a local tap for storing the formula
$ brew tap-new $USER/local-grafana

output :
Warning: tap-new is a developer command, so
Homebrew's developer mode has been automatically turned on.
To turn developer mode off, run brew developer off

Initialized empty Git repository in /usr/local/Homebrew/Library/Taps/dryyun/homebrew-local-grafana/.git/
[master (root-commit) 8fc7092] Create dryyun/local-grafana tap
 3 files changed, 90 insertions(+)
 create mode 100644 .github/workflows/publish.yml
 create mode 100644 .github/workflows/tests.yml
 create mode 100644 README.md
==> Created dryyun/local-grafana
/usr/local/Homebrew/Library/Taps/dryyun/homebrew-local-grafana

When a pull request making changes to a formula (or formulae) becomes green
(all checks passed), then you can publish the built bottles.
To do so, label your PR as `pr-pull` and the workflow will be triggered.

```

会在 `/usr/local/Homebrew/Library/Taps/` 生成一个模板文件 

### 创建特定版本的副本

```
$ brew extract --version=8.4.2 grafana $USER/local-grafana

output :

==> Searching repository history
==> Writing formula for grafana from revision 456d182 to:
/usr/local/Homebrew/Library/Taps/dryyun/homebrew-local-grafana/Formula/grafana@8.4.2.rb

```



### 安装特定版本

```
$ brew search grafana

==> Formulae
dryyun/local-grafana/grafana@8.4.2           grafana

// 搜索出现两个版本的 grafana 

$ brew install dryyun/local-grafana/grafana@8.4.2  // 安装 local grafana

```



### 运行

有些软件，可以起一个 server ，有些就只是一个 lib ，安装 grafana 可以起 server  

```
$ brew services list // 查看
$ brew services start grafana@8.4.2 // 运行
$ brew services stop grafana@8.4.2 // 停止

```



### 问题 - 配置文件内容是否共用了

以我安装的 grafana 举例，最新版本是 v9，上面我安装了 v8.4 ，我都安装了，已经可以切换运行了

但是可以查看具体的 .rb 文件，里面其实已经写好了一些 conf 的路径，`/usr/local/var/lib/grafana`，这就导致了不管是运行 v9 还是 v8 都使用的是同一份配置，运行就会有问题。

可以修改具体的 local grafana 文件的内容，指定额外的 conf 地址，避免冲突。

安装不同的软件，设置是不一样的，具体问题具体分析了。

## 说明 

理论上，通过上面的方法，可以安装任何版本。

实际上，几个月前甚至更久的版本，其实还是会安装失败，因为安装一个软件有很多依赖的过程，其他的依赖可能已经不在维护了，找不到源了。

## 参考 

- https://blog.sandipb.net/2021/09/02/installing-a-specific-version-of-a-homebrew-formula/









