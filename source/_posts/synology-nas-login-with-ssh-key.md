---
title: 群晖 Nas 使用 SSH Key 实现免密登录
categories:
  - 技术
date: 2019-01-08 11:05:56
tags:
- Nas
- synology
- 群晖
- ssh
---

> 最近直观的加上了文章访问统计和整站访问统计，虽然知道肯定没人访问，也就是纯粹加点新功能，但是没想到，关于 Nas 的文章访问量遥遥领先。 

承接之前关于 Nas 的文章
- [群晖 Nas 折腾 https - 更安全的外网访问](/2018/07/19/synology-nas-use-https/)
- [群晖 Nas 用上 VPN 更加安全](/2018/07/19/synology-nas-with-vpn/)

开启了 VPN 可以更安全的访问 Nas ，同时我也需要使用 SSH 功能，但是每次使用的时候，都要输入密码，很是麻烦，如果能改成 ssh 免密登录就好了。    
本质上跟其他的 linux 服务器设置免密登录原理差不多，稍微有点差别吧。  

<!-- more --> 

## 前提假设

连接 ip ，10.8.0.1
连接端口 ，2222
设置用户 ，test

## 客户端设置

### 生成密钥

> `$ cd ~/.ssh`  
> `$ ssh-keygen -t rsa -C "xxx@mail.com" -f nas` // 生成 nas、nas.pub 两个文件 ，采用多密钥管理方式

## Nas 端设置

### home 目录权限设置
> `$ cd /var/services/homes` 
> `$ chmod 755 ./test` // 对于普通 linux 来说，这步就不需要了

### 设置 ssh
> `$ cd test`
> `$ mkdir ./.ssh`
> `$ chmod 700 ~/.ssh`
> `$ touch ~/.ssh/authorized_keys` 

将本机的 nas.pub 内容复制进入 authorized_keys 文件内

> `$ chmod 600 ~/.ssh/authorized_keys`

### 群晖 Nas sshd 设置
配置文件路径 `/etc/ssh/sshd_config` 在修改之前，最好先备份

> `$ sudo vim /etc/ssh/sshd_config` 

设置一下三行，先确认一下原有的配置文件是否存在这几行
```text
RSAAuthentication yes
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
```

### 重启 sshd 

> `$ sudo synoservicectl --restart sshd` 

> 重启之后，如果遇到 ssh 连接 connection refuse，要去网页控制台重新关闭、打开 ssh 设置

## 免密登录

本机设置

> `$ ssh -i ~/.ssh/nas test@10.8.0.1 -p 2222` 
> // 因为密钥不是默认的 id_rsa 文件，所以要通过 -i 参数指定，port 是连接的端口

但是每次这样运行也很麻烦，我比较喜欢配置的更简单

> `$ cd ~/.ssh`
> `$ vim config` // 创建 config 文件

写入一下内容
```text
Host nas 
    HostName 10.8.0.1
    user test
    IdentityFile ~/.ssh/nas
    Port 2222
```

至此，以后只需要运行 `ssh nas` 就能以 test 用户免密登录 nas 了  

## 总结

设置免密登录很简单，最主要的一步是 [home 目录权限设置](#home-目录权限设置)，明白这步就可以了。  
本文八成是滥竽充数的。  