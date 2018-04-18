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
> [Pimple 中文版文档](https://dryyun.com/2018/04/17/php-pimple/)
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

### SPL - SplObjectStorage

#### SPL

[SPL](http://php.net/manual/zh/book.spl.php) 是 Standard PHP Library（PHP标准库）的缩写，一组旨在解决标准问题的接口和类的集合。SPL 提供了一套标准的数据结构，一组遍历对象的迭代器，一组接口，一组标准的异常，一系列用于处理文件的类，提供了一组函数，具体可以查看文档。

#### SplObjectStorage

[SplObjectStorage](http://php.net/manual/zh/class.splobjectstorage.php) 是 SPL 标准库中的数据结构对象容器，用来存储一组对象，特别是当你需要唯一标识对象的时候 。

```php
SplObjectStorage implements Countable , Iterator , Serializable , ArrayAccess {

    /* 
     * 向 SplObjectStorage 添加一个 object，$data 是可选参数
     * 因为 SplObjectStorage 实现了 ArrayAccess 的接口，所以可以通过数组的形式访问，这里相当于设置 object 为数组的 key ，data 是对应的 value，默认 data 是 null
     */
    public void attach ( object $object [, mixed $data = NULL ] )
    
    /* 
     * 检查 SplObjectStorage 是否包含 object ，相当于 isset 判断
     */
    public bool contains ( object $object )
    
    /* 
     * 从 SplObjectStorage 移除 object ，相当于 unset 
     */
    public void detach ( object $object )
    // 其他接口定义可以自行查看文档
    
}
```
SplObjectStorage 实现了 [Countable](http://php.net/manual/zh/class.countable.php)、Iterator、Serializable、ArrayAccess 四个接口，可实现统计、迭代、序列化、数组式访问等功能，其中 Iterator 和 ArrayAccess 在上面已经介绍过了。

### 魔术方法 __invoke()

[__invoke()](http://php.net/manual/zh/language.oop5.magic.php#object.invoke) 当尝试以调用函数的方式调用一个对象时，__invoke() 方法会被自动调用。


## 读源码


### 目录接口

```
pimple
├── CHANGELOG
├── LICENSE
├── README.rst
├── composer.json
├── ext // C 扩展，不展开
│   └── pimple
├── phpunit.xml.dist
└── src
    └── Pimple
        ├── Container.php
        ├── Exception // 异常类定义，不展开
        ├── Psr11
        │   ├── Container.php
        │   └── ServiceLocator.php
        ├── ServiceIterator.php
        ├── ServiceProviderInterface.php
        └── Tests // 测试文件，不展开

```

PS， Markdown 写目录格式真是麻烦，后来找了一个工具 [tree](http://mama.indstate.edu/users/ice/tree/) 可以直接生成结构。

### Container.php

```php
class Container implements \ArrayAccess
{
    private $values = array();
    private $factories;
    private $protected;
    private $frozen = array();
    private $raw = array();
    private $keys = array();
    
    public function __construct(array $values = array())
    {
        $this->factories = new \SplObjectStorage();
        $this->protected = new \SplObjectStorage();

        foreach ($values as $key => $value) {
            $this->offsetSet($key, $value);
        }
    }
    
    public function offsetSet($id, $value){}
    public function offsetGet($id){}
    public function offsetExists($id){}
    public function offsetUnset($id){}
    public function factory($callable){}
    public function protect($callable){}
    public function raw($id){}
    public function extend($id, $callable){}
    public function keys(){}
    public function register(ServiceProviderInterface $provider, array $values = array()){}
}
```
实现了 ArrayAccess 接口，这就可以理解为什么可以通过数组的方式定义服务了。



>
> 原创文章，欢迎转载。转载请注明出处，谢谢。
> 原文链接地址：http://dryyun.com/2018/04/18/read-pimple-soure-code/
> 作者: [dryyun](https://dryyun.com/)  
> 发表日期: 2018-04-18 14:36:40
>