---
title: 读 PHP - Pimple 源码笔记
date: 2018-04-18 14:36:40
tags:
- php
- pimple
- Dependency Injection
- 依赖注入
---

也就是闲时为了写文章而写的一篇关于 Pimple 源码的阅读笔记。
Pimple 代码有两种编码方式，一种是以 PHP 编写的，另一种是以 C 扩展编写的方式，当然个人能力有限呀，也就看看第一种了。



> Pimple 链接  
> [官网 WebSite](https://pimple.symfony.com/)   
> [GitHub - Pimple](https://github.com/silexphp/Pimple)   
> 



## 前提知识

### ArrayAccess（数组式访问）接口

提供像访问数组一样访问对象的能力的接口。

> http://php.net/manual/zh/class.arrayaccess.php 

一个 Class 只要实现以下规定的 4 个接口，就可以是像操作数组一样操作 Object 了。

```php
ArrayAccess {
    /* 方法 */
    abstract public boolean offsetExists ( mixed $offset )
    abstract public mixed offsetGet ( mixed $offset )
    abstract public void offsetSet ( mixed $offset , mixed $value )
    abstract public void offsetUnset ( mixed $offset )
}
```

伪代码如下
```php

class A implements \ArrayAccess {
    // 实现了 4 个接口
}

$a = new A();

// 可以这么操作
$a['x'] = 'x'; // 对应 offsetSet  
echo $a['x']; // 对应 offsetGet  
var_dump(isset($a['x'])); // 对应 offsetExists  
unset($a['x']); // 对应 offsetUnset  

```

特别说明，只支持上面四种操作，千万别以为实现了 ArrayAccess，就可以使用 foreach 了，要实现循环 = 迭代，要实现 [Iterator（迭代器）接口](http://php.net/manual/zh/class.iterator.php)，其实 PHP 定义了很多 [预定义接口](http://php.net/manual/zh/reserved.interfaces.php) 有空可以看看。

### 




>
> 原创文章，欢迎转载。转载请注明出处，谢谢。
> 原文链接地址：http://dryyun.com/2018/04/18/read-pimple-soure-code/
> 作者: [dryyun](https://dryyun.com/)  
> 发表日期: 2018-04-18 14:36:40
>