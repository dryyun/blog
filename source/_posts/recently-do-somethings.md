---
title: 最近折腾两三事
categories:
  - 技术
  - 杂谈
date: 2019-01-16 13:45:46
tags:
  - Shadowsocks
  - 极路由
  - 群晖
---

## 折腾不止

需求就是来源于生活，好赖是个菜鸟码农，还有些个谷歌复制粘贴的能力。

<!-- more --> 

## 搭建 SS

有需要就准备新搭建一个 SS ，也是各种折腾，好在云服务器，各种 rebuild 很快。
尝试了 
- SS、V2Ray、Brook
- Ubuntu 、Centos
- SS 的锐速、BBR、魔改 BBR、Kcptun 加速方案

最后选用了 Centos + SS + 魔改 BBR + obfs 的方案，我基本也是瞎测试了一下速度，就这么定了，比起以往，更满意了。

> 选 SS 主要是因为周边完善，支持齐全。
> 值得感慨的就是这 fq 技术，层出不穷，我是跟不上了。


## 极路由刷固件

- 极路由信号不稳定，三天两头掉线
- 希望路由器可以全局 SS，附带很多其他功能

本来都准备买网件的路由器了，就是有点小贵，有点下不去手，还是手头的闲置路由器试试吧。  
刷机过程还算顺利，折腾了几个小时吧，变砖几次，就差被我扔了。  
刷机完成，全局 ss 是用上了，信号是否稳定，还有待测试。  


详情参考 - [极路由刷固件 Padavan 固件](https://github.com/dryyun/gather/tree/master/hiwifi_padavan)    


## 群晖开启备份 Hyper Backup

我使用群晖本身的组盘方式是 Raid 10，运气没这么背，坏个两块硬盘，也是没事的。  

群晖数据安全大致以我看来  

- 备份，Hyper Backup
- 同步，Cloud Station、Drive
- 快照，Snapshot Replication
- 网盘同步，Cloud Sync


还是选用最保险的 Hyper Backup，进行备份，研究了一下支持的各种云存储设备，选择了微软 Azure 。  
选择的是 Azure 国外版本，上传速度还行，下载因为要 fq 就太慢了，才有了以上两点需求，恩，全部完成了。  

## 以上

算是一点小折腾，最近觉得 NAS 是真的重要了，数据无价。



