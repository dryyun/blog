---
title: Go 阅读 negroni 源码
categories:
  - Go
tags:
  - Go
date: 2019-06-10 23:49:20
---
> Go 分类文章，学习笔记，会不定时修改，补充，纠错，增加内容，路漫漫。


negroni 提供 golang 常用的中间件使用方式，项目地址 https://github.com/urfave/negroni/  

阅读版本是 2019.6.2 的 [7d1c5e commit](https://github.com/urfave/negroni/tree/7d1c5e0c31f98a3073127a273a4eb2f9690a715f)  

GoDoc - https://godoc.org/github.com/urfave/negroni

## 前提知识

了解 net/http server 的相关知识，也可以读我写的上一篇 【http-server】  

## 基本使用

```Go
	mux := http.NewServeMux()
	mux.HandleFunc("/", func(w http.ResponseWriter, req *http.Request) {
		fmt.Fprintf(w, "Welcome to the home page! "+req.URL.Path)
	})

	n := negroni.New()
	n.Use(negroni.NewLogger())
	
	n.UseHandler(mux)
	n.Run(":3000")
```

其中关于 `mux` 变量的部分，可以参考上一遍 `http-server`，这里就不说明了，主要关注 `n := negroni.New()`

<!-- more --> 

基本流程
```text
1、`n := negroni.New()` 返回 `negroni.*Negroni` 实例   
2、注册中间件，n.use(handler negroni.Handler)，类似的有两类  
    2.1、n.UseFunc()，传入满足 negroni.Handler 的  
    2.2、n.UseHandler()、n.UseHandlerFunc() ，传入满足 http.Handler 的  
    2.3、无论添加几个还是没添加中间件，最后都会添加一个 `func voidMiddleware() middleware{}` 空的中间件，作为最后的中间件     
3、使用 `http.NewServeMux()`，就是需要一个全权处理 req url 的 http.Handler，这里本质也就是作为中间件加入了   
4、n.Run 启动程序  
5、调用 `negroni.*Negroni` 的满足 http.Handler 的 method，`ServeHTTP(ResponseWriter, *Request)`  
6、调用中间件 middleware 的 `ServeHTTP(ResponseWriter, *Request)` ，
    func (m middleware) ServeHTTP(rw http.ResponseWriter, r *http.Request) { 
        m.handler.ServeHTTP(rw, r, m.nextfn) 
    } 
一直往下调用，知道直到的 voidMiddleware ，结束 

```

## negroni.Handler

```Go

type Handler interface {
	ServeHTTP(rw http.ResponseWriter, r *http.Request, next http.HandlerFunc)
}
```

会发现这里的 Handler 也是一个 interface ，而且类似 http.Handler ，只不过多了一个 next 参数，而 next 参数是 http.HandlerFunc 类型的 
意味着 next 实现了 http.Handler，包含 ServeHTTP(rw http.ResponseWriter, r *http.Request) 方法

这里就引出典型的中间件 middleware 的使用方法了

```text

ServeHTTP(rw http.ResponseWriter, r *http.Request, next http.HandlerFunc) {
    // 代码处理，一般跟 r 有关，比如修改 r 的请求参数
    
    next(rw, r)
    
    // 代码处理，一般处理跟 rw 有关
}

```

## middleware struct

查看相关源码

```Go
type middleware struct {
	handler Handler

	// nextfn stores the next.ServeHTTP to reduce memory allocate
	nextfn func(rw http.ResponseWriter, r *http.Request)
}

func newMiddleware(handler Handler, next *middleware) middleware {
	return middleware{
		handler: handler,
		nextfn:  next.ServeHTTP,
	}
}

func (m middleware) ServeHTTP(rw http.ResponseWriter, r *http.Request) {
	m.handler.ServeHTTP(rw, r, m.nextfn)
}

func build(handlers []Handler) middleware {
	var next middleware

	switch {
	case len(handlers) == 0:
		return voidMiddleware()
	case len(handlers) > 1:
		next = build(handlers[1:])
	default:
		next = voidMiddleware()
	}

	return newMiddleware(handlers[0], &next)
}

func voidMiddleware() middleware {
	return newMiddleware(
		HandlerFunc(func(rw http.ResponseWriter, r *http.Request, next http.HandlerFunc) {}),
		&middleware{},
	)
}

```


可以看出 middleware 包含两个属性 negroni.Handler 和 nextfn ，就是用于先调用 handler.ServeHTTP，然后调用下一个 middleware 的handler.ServeHTTP   
build 方法用于构建一个 middleware 的链式结构  

多个中间件会形成一个栈结构（middle stack），以"先进后出"（first-in-last-out）的顺序执行  


## func (n *Negroni) Run(addr ...string) 

查看源码

```Go
func (n *Negroni) Run(addr ...string) {
	l := log.New(os.Stdout, "[negroni] ", 0)
	finalAddr := detectAddress(addr...)
	l.Printf("listening on %s", finalAddr)
	l.Fatal(http.ListenAndServe(finalAddr, n))
}

func detectAddress(addr ...string) string {
	if len(addr) > 0 {
		return addr[0]
	}
	if port := os.Getenv("PORT"); port != "" {
		return ":" + port
	}
	return DefaultAddress
}

// Run 基本逻辑说明
// 自定义日志格式 l
// 获取 server 的地址，如果提供了 addr 参数，就用 addr，不然会从环境变量获取 PORT 使用，都没有的话就使用默认的 DefaultAddress = ":8080"  
// 日志输出
// 调用 http.ListenAndServe，`n *Negroni` 作为第二个参数传入
```

这么一看代码就明白了， *negroni.Negroni 肯定是实现了 http.Handler 接口，也就是有 method ，`func (n *Negroni) ServeHTTP(rw http.ResponseWriter, r *http.Request) `

## type Negroni struct 

查看 Negroni 结构体有关的代码

```Go
type Negroni struct {
	middleware middleware
	handlers   []Handler
}

// New returns a new Negroni instance with no middleware preconfigured.
func New(handlers ...Handler) *Negroni {
	return &Negroni{
		handlers:   handlers,
		middleware: build(handlers),
	}
}

func (n *Negroni) ServeHTTP(rw http.ResponseWriter, r *http.Request) {
	n.middleware.ServeHTTP(NewResponseWriter(rw), r)
}

```

type Negroni struct 有两个属性  
1、middleware middleware  
2、handlers   []Handler  

上面分别都讲过了 

对外提供的 method

- func (n *Negroni) Handlers() []Handler // 获取处理器
- func (n *Negroni) Run(addr ...string) // 执行程序，上面讲过了
- func (n *Negroni) ServeHTTP(rw http.ResponseWriter, r *http.Request) 
- func (n *Negroni) Use(handler Handler)
- func (n *Negroni) UseFunc(handlerFunc func(rw http.ResponseWriter, r *http.Request, next http.HandlerFunc))
- func (n *Negroni) UseHandler(handler http.Handler)
- func (n *Negroni) UseHandlerFunc(handlerFunc func(rw http.ResponseWriter, r *http.Request))
- func (n *Negroni) With(handlers ...Handler) *Negroni

## negroni.Classic()

negroni.Classic() 提供一些默认的中间件，这些中间件在多数应用都很有用。
- negroni.Recovery - 异常（恐慌）恢复中间件
- negroni.Logging - 请求 / 响应 log 日志中间件
- negroni.Static - 静态文件处理中间件，默认目录在 "public" 下.

## 调用顺序

中间件的注册顺序是有讲究的，最先注册的覆盖面最广，查看 negroni.Classic() 就能发现，negroni.Recovery 是第一个注册的

## 总结

几百行代码，很容易懂 
