---
title: FastRoute - 快速请求路由
date: 2018-04-21 10:14:21
categories:
- 技术
tags:
- PHP
- FastRoute
- Route
- 路由
---

> 链接
> https://github.com/nikic/FastRoute 

这个库提供了基于正则表达式的快速路由实现。[这篇文章解释了 FastRoute 是如何工作的和它为什么很快](http://nikic.github.io/2014/02/18/Fast-request-routing-using-regular-expressions.html)。

## 安装

通过 [composer](https://getcomposer.org/) 安装

> composer require nikic/fast-route

要求 PHP 5.4 及更高的版本

## 使用

这是一个基本的使用示例

```php
<?php

require '/path/to/vendor/autoload.php';

$dispatcher = FastRoute\simpleDispatcher(function(FastRoute\RouteCollector $r) {
    $r->addRoute('GET', '/users', 'get_all_users_handler');
    // {id} 必须是一个数字 (\d+)
    $r->addRoute('GET', '/user/{id:\d+}', 'get_user_handler');
    //  /{title} 后缀是可选的
    $r->addRoute('GET', '/articles/{id:\d+}[/{title}]', 'get_article_handler');
});

// 获取请求的方法和 URI
$httpMethod = $_SERVER['REQUEST_METHOD'];
$uri = $_SERVER['REQUEST_URI'];

// 去除查询字符串( ? 后面的内容) 和 解码 URI
if (false !== $pos = strpos($uri, '?')) {
    $uri = substr($uri, 0, $pos);
}
$uri = rawurldecode($uri);

$routeInfo = $dispatcher->dispatch($httpMethod, $uri);
switch ($routeInfo[0]) {
    case FastRoute\Dispatcher::NOT_FOUND:
        // ... 404 Not Found 没找到对应的方法
        break;
    case FastRoute\Dispatcher::METHOD_NOT_ALLOWED:
        $allowedMethods = $routeInfo[1];
        // ... 405 Method Not Allowed  方法不允许
        break;
    case FastRoute\Dispatcher::FOUND: // 找到对应的方法
        $handler = $routeInfo[1]; // 获得处理函数
        $vars = $routeInfo[2]; // 获取请求参数
        // ... call $handler with $vars // 调用处理函数
        break;
}
```

<!-- more --> 

### 定义路由
通过调用 `FastRoute\simpleDispatcher()` 函数来定义路由，该函数接受一个以 `FastRoute\RouteCollector` 实例为参数的闭包作为参数。通过在 collector 实例里面调用 `addRoute()` 增加路由。

```php
$r->addRoute($method, $routePattern, $handler);
``` 

`$method` 是大写的 HTTP 方法，能够被某个路由匹配，可以使用数组指定多个有效的 $method 。

```php
// 这里两行调用
$r->addRoute('GET', '/test', 'handler');
$r->addRoute('POST', '/test', 'handler');
// 等同于这一行调用
$r->addRoute(['GET', 'POST'], '/test', 'handler');
```

默认情况下 `$routePattern` 使用一种语法，比如 `{foo}` 是指定名称为 `foo` 的占位符，可以匹配正则表达式 `[^/]+.` 。要调整占位符匹配的模式，可以通过编写 `{bar：[0-9] +}` 来指定自定义模式。一些例子
```php
// 匹配 /user/42，不匹配 /user/xyx
$r->addRoute('GET', '/user/{id:\d+}', 'handler');

// 匹配 /user/foobar，不匹配 /user/foo/bar
$r->addRoute('GET', '/user/{name}', 'handler');

// 匹配 /user/foobar，也匹配 /user/foo/bar
$r->addRoute('GET', '/user/{name:.+}', 'handler');
```
路由占位符的自定义模式不能使用捕获组，例如 {lang:(en|de)} 不是有效的占位符，因为 `()` 是一个捕获组，可以使用 `{lang:en|de}` 或者 `{lang:(?:en|de)}` 代替。

另外，在路由 `[...]` 中定义的部分是可选匹配的，所以 `/foo[bar]` 将匹配 `/foo` 和 `/foobar` 。路由可选部分只支持在定义的末尾，而不能在定义的中间。

```php
// 这个路由有，[/{name}] 可选择匹配部分
$r->addRoute('GET', '/user/{id:\d+}[/{name}]', 'handler');
// 等同于这两个路由
$r->addRoute('GET', '/user/{id:\d+}', 'handler');
$r->addRoute('GET', '/user/{id:\d+}/{name}', 'handler');

// 多层嵌套可选路由，也是支持的
$r->addRoute('GET', '/user[/{id:\d+}[/{name}]]', 'handler');

// 这个路由定义无效，因为可选部分只能在定义的末尾
$r->addRoute('GET', '/user[/{id:\d+}]/{name}', 'handler');
```
`$handler` 参数不一定必须是回调函数，它也可以是控制器类名或任何其他类型的数据。FastRoute 只告诉你哪个 handler 对应 URI，如何解释它取决于你。

#### 请求方法的书写快捷方式

对于 GET、POST、PUT、PATCH、DELETE 和 HEAD 请求方法，可使用快捷方式。
```php
$r->get('/get-route', 'get_handler');
$r->post('/post-route', 'post_handler');

// 等同于
$r->addRoute('GET', '/get-route', 'get_handler');
$r->addRoute('POST', '/post-route', 'post_handler');

```


#### 路由组

你可以在一个组内定义路由，同一组内的路由有相同的前缀。

```php
$r->addGroup('/admin', function (RouteCollector $r) {
    $r->addRoute('GET', '/do-something', 'handler');
    $r->addRoute('GET', '/do-another-thing', 'handler');
    $r->addRoute('GET', '/do-something-else', 'handler');
});

// 等同于
$r->addRoute('GET', '/admin/do-something', 'handler');
$r->addRoute('GET', '/admin/do-another-thing', 'handler');
$r->addRoute('GET', '/admin/do-something-else', 'handler');

```
可以定义多层嵌套组结构。

### 缓存

使用 `simpleDispatcher` 定义路由的回调函数可以无缝缓存。通过使用 `cachedDispatcher` 而不是 `simpleDispatcher`，可以缓存生成的路由数据并从缓存的信息构建调度。

```php
<?php

$dispatcher = FastRoute\cachedDispatcher(function(FastRoute\RouteCollector $r) {
    $r->addRoute('GET', '/user/{name}/{id:[0-9]+}', 'handler0');
    $r->addRoute('GET', '/user/{id:[0-9]+}', 'handler1');
    $r->addRoute('GET', '/user/{name}', 'handler2');
}, [
    'cacheFile' => __DIR__ . '/route.cache', /* required 缓存文件路径，必须设置 */
    'cacheDisabled' => IS_DEBUG_ENABLED,     /* optional, enabled by default 是否缓存，可选参数，默认情况下开启 */
]);
```
该函数的第二个参数是一个选项数组，可用于指定缓存文件路径等等。

### 调度 URI

通过调用 `dispatch()` 调度 URI。这个方法接受 HTTP 方法 和一个 URI 作为参数。获得这两个信息是你自己的工作，这个库并不绑定到 PHP web SAPIs 。
`dispatch()` 返回一个数组，第一个元素是一个状态码，状态码是  `Dispatcher::NOT_FOUND`、`Dispatcher::METHOD_NOT_ALLOWED`、`Dispatcher::FOUND` 其中之一。对于 `Dispatcher::METHOD_NOT_ALLOWED` 状态，第二个数组元素包含允许提供的 URI 的 HTTP 方法列表。
```php
[FastRoute\Dispatcher::METHOD_NOT_ALLOWED, ['GET', 'POST']]
```

对于 `Dispatcher::FOUND` 状态，第二个数组元素是 $handler ，第三个数组元素是是一个包含所有占位符的数组

```php
/* Routing against GET /user/nikic/42 */

[FastRoute\Dispatcher::FOUND, 'handler0', ['name' => 'nikic', 'id' => '42']]
```

### 重写路由解析器和调度器

这个库使用三个组件，一个路由解析器，一个数据生成器，一个调度器。这个三个组件实现以下接口

```php
<?php

namespace FastRoute;

interface RouteParser {
    public function parse($route);
}

interface DataGenerator {
    public function addRoute($httpMethod, $routeData, $handler);
    public function getData();
}

interface Dispatcher {
    const NOT_FOUND = 0, FOUND = 1, METHOD_NOT_ALLOWED = 2;

    public function dispatch($httpMethod, $uri);
}
```
路由解析器获取路由模式字符串并将其转换为路由信息数组，其中每个路线信息又是它的部分数组。
```text
/* The route /user/{id:\d+}[/{name}] converts to the following array: */
[
    [
        '/user/',
        ['id', '\d+'],
    ],
    [
        '/user/',
        ['id', '\d+'],
        '/',
        ['name', '[^/]+'],
    ],
]
```

然后可以将该数组传递给数据生成器的 `addRoute()` 方法，在添加了所有路由之后，调用生成器的 `getData()`，它将返回调度器所需的所有路由数据。
调度程序通过构造函数接受路由数据，并提供 `dispatch()`方法。

路由解析器可以被单独覆盖，然而数据生成器和调度器应该总是一起修改，因为前者的输出与后者的输入紧密耦合。

当使用 `simpleDispatcher / cachedDispatcher` 时，可以通过传入额外的参数，进行覆盖
```php
<?php

$dispatcher = FastRoute\simpleDispatcher(function(FastRoute\RouteCollector $r) {
    /* ... */
}, [
    'routeParser' => 'FastRoute\\RouteParser\\Std',
    'dataGenerator' => 'FastRoute\\DataGenerator\\GroupCountBased',
    'dispatcher' => 'FastRoute\\Dispatcher\\GroupCountBased',
]);
```
上面给出了默认的设置，通过把 `GroupCountBased` 替换成 `GroupPosBased` 可以使用完全不同的调度策略

### 关于HEAD请求的说明

HTTP 规范要求服务器 [同时支持 GET 和 HEAD 方法](https://www.w3.org/Protocols/rfc2616/rfc2616-sec5.html#sec5.1.1) 

> GET和HEAD方法必须得到所有通用服务器的支持  

为避免强制用户为每个资源手动注册 HEAD 路由，将使用一个匹配的 GET 路由响应请求。PHP web SAPI 透明地从 HEAD 响应中移除实体主体，所以这种行为对绝大多数用户没有影响。

但是，在 Web SAPI 环境外部使用 FastRoute ，绝不能发送响应 HEAD 请求而生成的实体主体，如果你是非 SAPI 用户，这是你的责任;在这种情况下，FastRoute 无权限制你破坏 HTTP 。

最后，请注意，应用程序可以始终为给定资源指定其自己的 HEAD 方法路由以完全绕过此行为。

## 总结

文档还是很好理解，下次就要看源码了。

