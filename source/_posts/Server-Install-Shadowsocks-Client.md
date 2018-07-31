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

<!-- more --> 

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

```bash
$ cd ~
$ mkdir ss
$ cd ss
$ vim ss-local.json
```

写入内容
```
{
  "server":"my_server_ip",
  "server_port":my_server_port,
  "local_address": "127.0.0.1",
  "local_port":1080,
  "password":"my_password",
  "timeout":300,
  "method":"aes-256-cfb"
}
```

| Name | 说明 |
|:----------|:------|
|server | ss 服务器的 ip |
|server_port| ss 服务器的 port|
|local_address|本地地址|
|local_port|本地端口，一般1080|
|password|密码，ss 服务器的密码|
|timeout|超时重连|
|method| 连接 ss 服务器的方法|

### 启动 Shadowsocks 客户端

`ss-local -c /root/ss/ss-local.json`

默认是前台启动，可以改成后台启动，或者通过一些守护进程的工具运行。

## 使用 Privoxy 代理 

安装好了 Shadowsocks，但是它是 socks5 代理，而不是 http/https 的代理，在 shell 运行命令时，需要通过 Privoxy 代理

### 安装 Privoxy

```bash
$ yum install privoxy -y
$ privoxy --version
```
> 配置文件在 /etc/privoxy/config 
> 先搜索关键字 `listen-address` 找到 `listen-address 127.0.0.1:8118` 这一句，保证这一句没有注释，`8118` 就是将来 http 代理要输入的端口。
  然后搜索 `forward-socks5t`, 将 `#forward-socks5t / 127.0.0.1:9050` . 此句前面的注释去掉, 意思是转发流量到本地的 9050 端口, 而 9050 端口正是 ss-local 需要监听的 local_port


### 配置转发

> 我不想把 privoxy 设置为一个服务运行，而是设置成当需要代理的时候，才运行，方便切换

`vim ~/.bashrc`
写入
```
alias proxy='systemctl start privoxy && export http_proxy=http://127.0.0.1:8118 && export https_proxy=http://127.0.0.1:8118'   
alias unproxy='unset http_proxy && unset https_proxy && systemctl stop privoxy'

```

运行 proxy 的时候，开启代理，运行 `curl ip.cn`，`curl https://www.google.com` 可以进行测试   
运行 unproxy ，取消代理   

## 总结

`ss-local` 和 `proxy` 服务需要配合使用，才能友好使用，我设置 `ss-local` 后台运行，`proxy` 需要时才运行。


> 参考链接
> [Linux中使用ShadowSocks+Privoxy代理](https://docs.lvrui.io/2016/12/12/Linux%E4%B8%AD%E4%BD%BF%E7%94%A8ShadowSocks-Privoxy%E4%BB%A3%E7%90%86/ )
> [ss-local 全局代理](https://www.zfl9.com/ss-local.html)
> [sslocal + privoxy 实现 PAC 代理](https://blog.sliang.xyz/2017/12/12/sslocalprivoxy-%E5%AE%9E%E7%8E%B0-pac-%E4%BB%A3%E7%90%86/)
> [ss-redir透明代理](https://www.bjwf125.com/?p=9)
> 


>
> 原创文章，欢迎转载。转载请注明出处，谢谢。
> 原文链接地址：https://dryyun.com/2018/03/22/Server-Install-Shadowsocks-Client/
> 作者: [dryyun](https://dryyun.com/)  
> 发表日期: 2018-03-22 14:50:20
>
>

