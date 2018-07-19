---
title: 群晖 Nas 用上 VPN 更加安全
date: 2018-07-19 19:47:11
tags:
- vpn
- Nas
- synology
- 群晖
- openvpn
---

本文所讲的 VPN 并不是一般理解的翻墙哦。
VPN：在公用网络上建立专用网络，进行加密通讯。

## 为什么考虑使用 VPN

安全的问题值得深思，虽然也是能力有限，在有限的能力里尽力吧。
虽然已经用上了 https，在浏览器访问的时候应该是没啥问题了，但是使用其他协议的安全性如何保证？
考虑使用 vpn，在我的外网环境机器和 nas 之间建立一个加密通道，一切都是加密的，并且也可以使用内网的任何服务。

### Nas 安全设置

链接 [如何为 Synology NAS 增加额外的安全性](https://www.synology.com/zh-cn/knowledgebase/DSM/tutorial/General/How_to_add_extra_security_to_your_Synology_NAS) 给出了一些方法提高安全等级。

### SSH 功能的使用

程序员用了 ssh 连接到 nas，活脱脱就是一台 linux 服务器呀，岂不是可以为所欲为。😆。
所以这个不能放弃呀。
但是如果在外网使用的，又要多转发一个 ssh 的端口了，基于 `尽量少的开放端口` 的原则，这个端口是开放呢还是不开放呢。
如果使用了 vpn，那么不开放，也能使用哦。

## 如何使用 VPN

### 安装 VPN Server

群晖自带套件，安装即可

<img src="/vpn.jpg" width="600px" >

### 使用 VPN

打开 vpn server ，一目了然，给需要的用户分配权限即可。
<img src="/vpnm.jpg" width="600px" >


### PPTP vs L2TP vs OpenVPN 如何选择？

支持这三种不同的协议，如何选择？
> PPTP 坚决不用
> L2TP 如果有手机访问需求，可以使用
> OpenVPN 没有手机访问需求，就使用

OpenVPN 综合来说最好，只不过不支持手机端。

### OpenVPN 小小踩坑

经过上一篇，域名证书是自签的，在开启 OpenVPN 的时候一直报错，让我导入安全证书 。
是不是需要把证书拷贝到 openvpn 的特定文件夹？试了好几次，也改了配置文件，都没成功，遂放弃，单独使用群晖的证书吧。。  

<img src="/openvpn.jpg" width="600px" >  
<img src="/set.jpg" width="600px" >  

### 转发 OpenVPN 端口

要在外网使用服务还是需要端口转发，默认是 1194 ，我就转发了两个端口 
- OpenVPN 端口
- DSM https 端口

其他的，只要能连上 vpn 就行了。  

### 客户端安装

点击配置页面的 `导出配置文件`，里面有 `README.txt`，里面的有详细的介绍。


## 总结

通过 vpn 连上了 nas ，就可以使用 nas 所在地区的网络了，想想，是不是可以做点什么？
以后就可以无忧无虑的玩耍了。



>
> 原创文章，欢迎转载。转载请注明出处，谢谢。
> 原文链接地址：http://dryyun.com/2018/07/19/synology-nas-with-vpn/
> 作者: [dryyun](https://dryyun.com/)  
> 发表日期: 2018-07-19 19:47:11
>