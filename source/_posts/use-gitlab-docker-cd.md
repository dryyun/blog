---
title: 使用 GitLab + Docker 实现 CD 持续部署 
date: 2018-07-22 16:36:47
tags:
- GitLab
- Docker
- CI
- CD
- Travis CI
---

接着上一篇文章 [使用 Travis CI 部署博客 - 踩坑记录](https://dryyun.com/2018/06/25/travis-ci-deploy-blog/) ，得出的结论就是使用 `GitLab CI` 。

## 参考内容
- [用 GitLab CI 进行持续集成](https://segmentfault.com/a/1190000006120164)
- [开始使用 GitLab CI/CD](https://segmentfault.com/a/1190000012989919)
- [使用 Gitlab CI & Docker 搭建 CI 环境](http://walterinsh.github.io/2016/04/18/using-gitlab-ci.html)

看完之后，在结合文档看看就差不多会了。

<!-- more --> 

## 优势

类似 `.gitlab-ci.yml` 语法其实没什么好阐述的，看看文档就行了。  
我觉得的优势在于有 runner 这个概念，这个 runner 就是你的自己的机器，你可以预先配置好所有的环境，使用 docker 更是方便，相比于 `Travis CI` 省去了很多的配置。  
单纯就我来说一个部署功能就行了。 

```yml
deploy:
  stage: deploy
  script:
  - ssh machine " cd ~/blog && sh hexo-deploy "
```

## 小问题

如果是使用 [docker - gitlab-runner](https://hub.docker.com/r/gitlab/gitlab-runner/~/dockerfile/) 的话，默认的执行用户是 `gitlab-runner`，可以通过设置参数 `--user=root` 更改执行用户。  

## 结论
公司部署用上了 GitLab + GitLab CI 还是很方便的。  
对于个人来说，搭建 GitLab 比 配置 CI 要复杂多了，如果嫌麻烦，其实不用 CI 也不影响生活。😆 ~


>
> 原创文章，欢迎转载。转载请注明出处，谢谢。
> 原文链接地址：http://dryyun.com/2018/07/22/use-gitlab-docker-cd/
> 作者: [dryyun](https://dryyun.com/)  
> 发表日期: 2018-07-22 16:36:47
>