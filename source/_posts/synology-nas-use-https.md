---
title: 群晖 Nas 折腾 https - 更安全的外网访问
date: 2018-07-19 15:04:02
categories:
- 技术
tags:
- https
- Nas
- synology
- 群晖
- 安全
---


半个月前就折腾出来的东西，竟然拖延就今天才写出来。

前段时间买了个群晖，准备搞一个家庭私有云服务了，还是觉得自己搭比较安全、方便，但是如果是纯局域网访问，安全性是能相对保证了，但是就是去了便捷性，所以公网访问也是必不可少，只能说是尽力保证安全。

## 基本信息

> DSM 6.2 


## 为什么不使用 QuickConnect

其实是可以使用 QuickConnect，进行公网访问的，默认是使用 http，在 `控制面板 - 网络 - DMS 设置` 可以强制使用 https，乍一看其实满足了我们的需求了。   
但是为什么不用呢，QuickConnect 是什么呢 ？这里并不准备解释，需要知道的我并不是很清楚 QuickConnect 的原理，网上查了一下，有 2 点需要注意
- 我们的请求会在群晖的服务器上周转了一圈，类似 `我的请求 -> quickconnect -> 我的 nas -> quickconnect -> 返回我内容`
- 群晖的服务器指不定在哪，毕竟群晖是台湾企业，速度会比较慢

基于这 2 点还是决定自己用域名，自己签 https 证书吧。  

`出于安全考虑，可以在配置完成后，取消 quickconnect`  

<!-- more --> 

## 折腾 https 

### 准备条件

> 1、有公网 IP，只要有公网 IP 就行，并不要求说 IP 不能变，如果没有公网 IP 的话，可能要考虑内网穿透的方案了，并不在本文的讨论范围  
> 2、有一个顶级域名    

本人设备 + 部分假设信息  
> 极路由 4  
> DNS 服务商 DNSPod   
> 假设域名 abc.nas.com   
> ip 地址，115.2.2.2  ，ip 其实不固定，经常变动
> 内网地址，192.168.199.155 ，这个在后面会配置  


### DDNS 服务

什么是 `DDNS` ？动态域名服务。  
为什么需要 ？
一般是说有了域名之后，我们需要 `DNS` 域名解析服务，把域名指向某个 IP，可以使用域名服务商自带的 DNS 服务，也可以选一个第三方的，我使用的是 [DNSPod](https://www.dnspod.cn/)，DNSPod 前几年肯定是不错的，但是自从被腾讯收购了，就难说了，不过基于使用习惯，使用起来不错。

DDNS vs DNS ？其实就是差一个 `Dynamic` 动态，因为私人宽带的 ip 是变动的，所以需要 Dynamic 的 DNS 服务。

#### 选择哪家的 

> 花生壳动态域名  
> PubYun（3322）动态域名  
> 极路由自带的动态域名


一个都不选，😆，第三方的动态域名会给出他们自己的域名地址，比如极路由的就是 `***.jios.org` ，然后需要把自己的域名 cname 到三方的动态域名上去，感觉多此一举 。

#### 使用 Nas 自带的的 DDNS 服务

`其实极路由有一个第三方的插件 - DNSPod动态域名 `，也是可以使用，不过这通用性相对小。

首先在 dnspod 上配置一条对应域名的 A 记录。  
然后在设置其他

<img src="/ddns.jpg" width="700px" >

服务提供商选择 `DNSPod.cn`
主机名称 - 填写域名
用户名/电子邮件 - 可以在 DNSpod 的 `用户中心 - 安全设置 - API Token` 中创建后的 ID
密码/密钥 - 同上，创建后的 Token

<img src="/apitoken.jpg" width="500px" >

这样基本的配置好了，即使 ip 变动了，DDNS 也会帮你更新到 DNSPod 上去，这里要注意一点，普通用户 DNSPod 的 TTL 是 600 ，说白一点就是即使看着配置改了，但是要过 10 分钟才生效，这段时间内访问域名的话，不可用哦。

### 端口转发

为什么要端口转发，其实经过上一步我们通过域名访问到的其实是路由器，怎么才能访问到 Nas 了，就需要端口转发，把访问一个外网的服务对应到内网。

如果按照以下配置 
`abc.nas.com:3456 -> 192.168.199.155:4567`，就是请求了 nas 的 4567 端口上的服务。

#### 端口痛点

https 默认是 443 端口，如果能直接使用 443 端口的话，就可以直接访问 `https://abc.nas.com` ，不要带端口的写法，不过不过不过，我使用的电信封了 80，443 端口，逼得我使用高位端口。  

#### Nas 配置固定的内网地址
配置端口转发，首先就需要一个固定的内网 ip ，默认是 DHCP 动态获取的。

<img src="/ip.jpg" width="700px" >

#### 设置端口转发

可以使用 Nas 自带的端口转发服务，不过这里我选择这是极路由的`超级端口转发`插件转发，现在的路由器一般都有这个端口转发功能。

<img src="/port.jpg" width="700px" >

为什么内网端口是 5000 ？因为 Nas 默认 5000 提供 http 服务，5001 提供 https 服务。

<img src="/dsmport.jpg" width="700px" >

`要上 https 服务，肯定是要转发到 5001 的`   
`出于安全考虑，可以把默认端口都改了`  


### 申请证书

肯定是选用免费的 [Let’s Encrypt](https://letsencrypt.org/)  

群晖本身自带了申请证书的功能，不过不符合国情，因为运营商没开放 80 端口，所以自带的方法申请不能用。

<img src="/ssl.jpg" width="700px" >

#### 申请 Let’s Encrypt 证书

四种方法吧，一种比一种简单
- 按照官网教程，一步一步生成教程，导入到群晖里，一定要选 `dns 验证`
- 使用 [acme.sh](https://github.com/Neilpang/acme.sh) ，国人写的，有中文文档，学习一下也简单
- 可以看我参考文章第二篇的生成证书过程
- 看看这位国人基于 acme.sh 写的 [群晖 Let's Encrypt 泛域名证书自动更新](http://www.up4dev.com/2018/05/29/synology-ssl-wildcard-cert-update/) 懒人脚本  

作为我，肯定是选择了最后一种。。

😔，说来也是惨，获取知识的过程是渐进的，我真是的把所有的方法都尝试了一遍，最后才发现了懒人脚本，😔。


## 总结

群晖真的是 `买软件送硬件` 的公司，软件功能很强大，我这么不爱折腾的人，直接就上白群晖了 。
闲的没事瞎折腾呗。  


### 参考  
> 1、https://post.smzdm.com/p/536484/
> 2、https://www.appinn.com/ds218plus-https/
> 3、http://www.up4dev.com/2018/05/29/synology-ssl-wildcard-cert-update/

