---
title: 服务器安装 Shadowsocks 客户端，代理，实现无障碍访问
date: 2018-03-22 14:50:20
tags:
- Centos
- Shadowsocks
- Privoxy
- 代理
---

想给国内的腾讯云服务器安装一些服务，虽说配置不高吧，还是能勉强用用的，本来想安装 Docker 最方便了，不过呢就是防火墙厉害了点，服务器上 [Docker Hub](https://hub.docker.com/) 访问不了，[GitHub](https://github.com/) 访问速度就看人品了，寻思安装一个 Shadowsocks 客户端吧。

## 前提

有一个 Shadowsocks 服务端，提供服务。

## 安装 Shadowsocks 客户端

其实 Shadowsocks 客户端和服务端是一起安装的，Shadowsocks 有很多实现的版本，最有名的 Python 实现的版本了吧，网上的很多教程都是安装这个版本的，不过这里我要使用 [C 语言版本的 Shadowsocks](https://github.com/shadowsocks/shadowsocks-libev)

### 服务器配置

配置 1核 2GB   
系统 Centos 7.4  
已安装 Git 

### 安装 Shadowsocks  
> 参考  
> [shadowsocks 官网](https://shadowsocks.org/)  
> [ C 语言版本](https://github.com/shadowsocks/shadowsocks-libev)  

```bash

$ cd /usr/local/src
$ git clone https://github.com/shadowsocks/shadowsocks-libev.git
$ cd shadowsocks-libev
$ git submodule update --init --recursive
$ yum install epel-release -y
$ yum install gcc gettext autoconf libtool automake make pcre-devel asciidoc xmlto c-ares-devel libev-devel libsodium-devel mbedtls-devel -y
$ ./autogen.sh && ./configure && make
$ sudo make install
$ ss-local -h

```
安装客户端成功

### 配置客户端


