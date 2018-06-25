---
title: 使用 Travis CI 部署博客 - 踩坑记录
date: 2018-06-25 15:03:32
tags:
- Travis CI
---

我最近也是想不开了，以前用过 Jenkins，也觉得还行，最近想试试 Travis CI，然后就进了大坑了。

## 简单介绍

还是应该简单的介绍一下，毕竟 CI 是好东西呀。
Travis CI，只支持 Github，不支持其他代码托管服务，分为[免费版](https://travis-ci.org/) 和 [收费版](https://travis-ci.com/) ，如果只是 Github 的开源项目使用免费版就可以了。
要学习怎么使用，看[文档](https://docs.travis-ci.com/)最好啦，其实我也没看完，就看了个入门，大致会用了，主要看了 [Getting started](https://docs.travis-ci.com/user/getting-started/) 和 [Encrypting Files](https://docs.travis-ci.com/user/encrypting-files/) 。 

## 简单使用

### 网上指南
看看别人的文章吧
- [持续集成服务 Travis CI 教程](http://www.ruanyifeng.com/blog/2017/12/travis_ci_tutorial.html)
- [如何简单入门持续集成( Travis-CI )](https://github.com/nukc/how-to-use-travis-ci)

看完之后还不懂，就看看文档。

### 命令行工具

有配套的命令行工具 [Travis CI Client](https://github.com/travis-ci/travis.rb/) ，功能还是蛮多的，不过是 ruby 写的，要使用 `gem install travis` 安装 。

### 跳过构建

在 Commit message 中 [ci skip] 或者 [skip ci] 就可以跳过构建了，并不是每次都需要 ci 的。

## Travis CI 使用不便之处

- 测试成本高  

每次测试 .travis.yml 能不能成功，都要提交一下，测试成本很高，很花时间。

- 构建历史不能删除  

测试成本高就算了，在使用初期因为不熟悉配置，肯定会出现各种构建错误，以我来说，是希望后期删除这些构建历史的，然后并不能。
虽然可以删除每个 Build 的 `Job log`，但是 `View config` 还是可以查看，在测试阶段不小心填了敏感信息，就惨了。

- 多文件加密很麻烦  

使用 `travis encrypt-file` 可以加密文件，这本身是一个安全措施，但是如果要加密多文件，就变的比较麻烦，虽然也给出了[解决方法](https://docs.travis-ci.com/user/encrypting-files/#Encrypting-multiple-files)，但是不好用。

<!-- more --> 

## Travis CI 踩坑记录

- yml 格式正确性  

好几次提交了之后，ci 一直没有工作，我还以为 ci 挂了，折腾了很久原来是 yml 写错了，可以使用 `travis lint` 在提交文件之前，测试 `.travis.yml` 文件准确性。

- `~/.ssh/id_rsa: No such file or directory`  

加密文件使用命令 `travis encrypt-file ~/.ssh/id_rsa --add` 就会添加相应的信息到 .travis.yml 中的 before_install 字段。
但是呢 1.8.8 的命令行工具有个 bug，生成的命令的-out选项的值多了一个\，类似 `-in ./id_rsa.enc -out ~\/.ssh/id_rsa -d`，这会导致报错，要手工去掉。
就这里真的是折腾了很久，总以为工具生成的是正确的，那就考虑其他地方吧，是不是没这个目录？是不是没权限？外加测试成本很高，真是心累。
相关 [GitHub Issue](https://github.com/travis-ci/travis.rb/issues/555) ，还是 open 的 。

- ssh known_hosts  
Travis CI 默认只添加了 github.com, gist.github.com 和 ssh.github.com 为 known_hosts，在进行 ssh 连接的时候又不能在控制台添加手工添加 host ，那就只能预先设置。
可以使用 [addons-ssh_known_hosts](https://docs.travis-ci.com/user/ssh-known-hosts/) 解决 。
坑就坑在这里要填写 ip 和 port ，ip 是很容易被人查到的，主要是 port 不能暴露了，那就加入到 ci 的环境变量里就好了吧，我就是这么想当然。
ci 的解析流程是 1、执行 addons 的内容 2、把设置的环境变量加入在环境中 。坑，好的为了不暴露 port 此方法不可用。

解决方案，在后台设置一个 known_hosts 变量，在 script 中运行 ` "echo $known_host >> ~/.ssh/known_hosts"` 

- 加密 known_hosts 无效

就是因为 encrypt known_hosts 无效，才不得不在后台设置 known_hosts 变量的，因为 known_hosts 有特殊字符 ？尝试多次无果，懒的尝试了。

### 总结

使用 CI 主要做两件事情吧，
- 测试 
- 部署。
主要是进行测试，部署功能是可选项的。
下次我还是选择 `GitLab CI`，自己搭 GitLab，自己用 ci，就没那么多安全性的考虑了。
在部署上，被坑了一天时间。


>
> 原创文章，欢迎转载。转载请注明出处，谢谢。
> 原文链接地址：http://dryyun.com/2018/06/25/travis-ci-deploy-blog/
> 作者: [dryyun](https://dryyun.com/)  
> 发表日期: 2018-06-25 15:03:32
>