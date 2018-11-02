---
title: 读 PHP - Pimple 源码笔记（下）
date: 2018-04-19 16:03:02
tags:
- php
- pimple
- Dependency Injection
- 依赖注入
---

接着[上篇](http://dryyun.com/2018/04/18/read-pimple-soure-code/) 还有一些内容没有写，上篇已经把关于 Pimple 最主要的代码分析了一下，这篇主要是关于 PSR-11 兼容性的分析。

## PSR-11 服务容器接口

### PSR

[PSR](https://www.php-fig.org/psr/) 是 PHP Standard Recommendations 的简写，由 [PHP FIG](https://github.com/php-fig) 组织制定的 PHP 规范，是 PHP 开发的实践标准 。
有一份 [PSR 中文版](https://psr.phphub.org/) 推荐看看，不过由于是翻译的，难免不是很及时，但是对于理解 PSR 1 - PSR 7 还是很有帮助的。

### PSR-11

[PSR-11](https://www.php-fig.org/psr/psr-11/) 是服务容器接口 。

```php
interface ContainerInterface
{
     public function get($id);
     public function has($id);
}
```
只需要实现这个两个接口就行。

<!-- more --> 

## Pimple - PSR-11 兼容性

Pimple 的作者自己也说了，由于历史原因，没有实现 PSR-11，但是提供了辅助类 。
1、Pimple\Psr11\Container.php
2、Pimple\Psr11\ServiceLocator.php
3、Pimple\ServiceIterator.php


### Pimple\Psr11\Container.php

实现 PSR-11 的容器类

```php
final class Container implements ContainerInterface
{
    private $pimple;

    public function __construct(PimpleContainer $pimple)
    {
        $this->pimple = $pimple;
    }

    public function get($id)
    {
        return $this->pimple[$id];
    }

    public function has($id)
    {
        return isset($this->pimple[$id]);
    }
}
```
源码很简单，主要是传入 pimple 变量，然后设置 get、has 这个两个方法。

### Pimple\Psr11\ServiceLocator.php

服务定位
1、在获取依赖 service 的时候，传入有限个 service，而不是全部
2、可以为 service 设置别名


### Pimple\ServiceIterator.php 

服务迭代，实现了 Iterator 接口，可以循环 service 。

## 总结

Pimple 的确是一个简单的依赖注入容器，代码很容易看懂，对于学习入门来说很好，比 Laravel 的 DI 好懂多了。


