---
title: 使用 Hexo 搭建博客记录，部署腾讯云
date: 2018-03-16 15:28:54
categories:
- 技术
tags:
- Hexo
- 腾讯云
---

前段时间，腾讯云的活动，看着蛮优惠的，一个冲动就买了 3 年的服务器，不过毕竟是冲动消费，也没想好要做啥，总要创造些需求，要对得起钱呀，那么搭个博客吧。   
搭博客么，也不是非要今天才搭，毕竟我从事码农工作以来，已经搭建过好几次了，只不过就是这么懒惰，什么都不写，也就自然放弃了。  
搭博客么，也不是非要使用服务器的，直接 Hexo + GitHub Pages 就可以了，还省钱，不过这不是给服务器派点活么。  


以下，鉴于我不善表述，也就是一个流水记录。

## 1、服务器基础软件设置  

### 1.1、服务器配置  
配置 1核 2GB   
系统 Centos 7.4  

<!-- more --> 

### 1.2、安装 Node

> 参考   
> [Node 官网](https://nodejs.org/)  
> [Node 包管理安装指南](https://nodejs.org/en/download/package-manager/)

```bash
$ curl --silent --location https://rpm.nodesource.com/setup_8.x | sudo bash - 
$ sudo yum -y install nodejs
$ node -v
```

### 1.3、安装 Yarn
> 参考 
> [Yarn 官网](https://yarnpkg.com/zh-Hans/)  
> [Yarn 安装](https://yarnpkg.com/zh-Hans/docs/install)  

```bash
$ curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
$ sudo yum install yarn
$ yarn -v 
```

### 1.4、安装 Git 
> 参考
> [Git 官网](https://git-scm.com/)

```bash
$ sudo yum install -y gcc gcc-c++
$ sudo yum install -y zlib zlib-devel  
$ 
$ cd /usr/local/src/
$ wget https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.16.0.tar.gz 
$ tar zxvf git-2.16.0.tar.gz
$ cd git-2.16.0
$ ./configure
$ make && make install
$ git --version 
```

## 2、Hexo 安装和设置

> 参考  
> [Hexo 官网](https://hexo.io/zh-cn/) 

### 2.1、Hexo 安装

```bash
$ yarn global add hexo-cli 
$ cd ~
$ hexo init blog
$ cd blog
$ yarn
$ hexo server -i {ip} -p {port} 
$ hexo server -i 127.0.0.1 -p 5000 // 使用这条即可
```

> 理论上，这样设置之后是可以在 http://ip:port/ 上看到效果的   
> 但是，我尝试了，不能绑定到服务器的 ip ，会报错，下面的内容我会使用 Web Server - `Caddy` 做一个代理，解决这个问题，同时能够使用域名访问，着急的话，可以先看 `第三部分的内容` 

### 2.2、Hexo 主题设置
> https://github.com/litten/hexo-theme-yilia 

### 2.3、Hexo Rss 插件设置
> https://github.com/hexojs/hexo-generator-feed  

### 2.4、Hexo 评论系统设置
> 选用 [畅言](https://changyan.kuaizhan.com/)  
> 配置好了畅言得到一个 appid 和 conf，因为选择的主题直接支持了，所以改一下配置文件就好了


## 3、Web 服务器 和 域名设置

### 3.1、域名设置

> 需要有一个域名，国内的话，是需要备案的  
> 域名指向服务器的 ip  
> 我是使用 [Dnspod](https://www.dnspod.cn/) 设置的.  

### 3.2、Caddy 安装和配置

> 参考  
> [Caddy 官网](https://caddyserver.com/)  
> [Caddy 文档](https://caddyserver.com/docs)  
> 其实，能提供相似功能的 Web 服务器真的是很多，Apache，Nginx，Haproxy 等等，选用 Caddy 就是因为他使用太简单了，而且直接集成 `Let's Encrypt` 很方便的就可以启用 `Https`

#### 3.2.1、安装
```bash
$ sudo yum install -y caddy  
$ caddy --version
```
#### 3.2.2、配置
```bash
$ cd /usr/local/etc/
$ mkdir caddy
$ cd caddy
$ touch Caddyfile
$ vim Caddyfile // 编辑 Caddy 的配置文件，内容参考下面的代码块
$ caddy -conf="/usr/local/etc/caddy/Caddyfile"
```

> 把根目录直接指向了 127.0.0.1:5000  
> 当然，通过 hexo generate 会生成静态文件，直接 caddy 指向静态文件也行  
```etc
{域名} {
        gzip
        proxy / 127.0.0.1:5000
}
```

## 4、守护程序运行

在时候用过程中，会发现 hexo 和 caddy 都是前台运行的，需要放到后台运行，且需要一个守护进程，就选择了 [pm2](https://github.com/Unitech/pm2)


先把之前运行的 hexo 和 caddy 都停止了。
```bash
$ yarn global add pm2
$ cd ~/blog
$ pm2 start hexo -- server -p 5000 -i 127.0.0.1 
$ pm2 start caddy -- -conf="/usr/local/etc/caddy/Caddyfile" 
```

## 5、改善

> 文章里有两个欠缺
> 1、如果发布内容，每次登录服务器写 ，太麻烦了，可以考虑建一个 GitHub 账号，本地写了，上传内容上去，但是这里就牵涉到复杂的使用了，不深入讨论
> 2、怎么发布到服务器内，更好的方法是怎么自动发布到服务器呢，可以考虑 webhook，不深入讨论。


## 6、结束

折腾了一天，终于搞好了。  
语文没学好，就是这样子的，文章可能不是面向非技术人员的😯。

