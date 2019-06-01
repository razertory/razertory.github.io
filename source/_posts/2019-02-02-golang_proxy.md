---
layout: post
tags: os
date: 2019-02-02 13:25:29 +0800
title: Go 实现负载均衡服务
---
Go 语言有着不错的性能和强大的 http 包，这次用 Go 来实现一个类似于 nginx 的负载均衡服务器。这里直接用 `package httputil` 来实现。顺便可以看看源代码,  发现 `src/net/http/httputil/reverseproxy.go` 中有这样一个结构体
```go
// ReverseProxy is an HTTP Handler that takes an incoming request and
// sends it to another server, proxying the response back to the
// client.
type ReverseProxy struct {
	Director func(*http.Request)

	Transport http.RoundTripper

	FlushInterval time.Duration

        ErrorLog *log.Logger

	BufferPool BufferPool

	ModifyResponse func(*http.Response) error

	ErrorHandler func(http.ResponseWriter, *http.Request, errorko
}
```
简直不要太好，虽然我也喜欢造轮子，可是好东西不用白不用啊。按照这个文件的逻辑，随后就发现了提供反向代理的方法 `ServeHTTP`。

本质上，一个 http 代理服务器本质上还是实现了 `/src/net/http/server.go` 中的 `ListenAndServe(addr string, handler Handler)` 方法。这里的 addr 表示绑定的地址，handler 表示请求处理器。再去看 handler 就会发现实际上做 http 开发只需要实现这个接口


```go
// A Handler responds to an HTTP request.
//
// ServeHTTP should write reply headers and data to the ResponseWriter
// and then return. Returning signals that the request is finished; it
// is not valid to use the ResponseWriter or read from the
// Request.Body after or concurrently with the completion of the
// ServeHTTP call.
//
// Depending on the HTTP client software, HTTP protocol version, and
// any intermediaries between the client and the Go server, it may not
// be possible to read from the Request.Body after writing to the
// ResponseWriter. Cautious handlers should read the Request.Body
// first, and then reply.
//
// Except for reading the body, handlers should not modify the
// provided Request.
//
// If ServeHTTP panics, the server (the caller of ServeHTTP) assumes
// that the effect of the panic was isolated to the active request.
// It recovers the panic, logs a stack trace to the server error log,
// and either closes the network connection or sends an HTTP/2
// RST_STREAM, depending on the HTTP protocol. To abort a handler so
// the client sees an interrupted response but the server doesn't log
// an error, panic with the value ErrAbortHandler.
type Handler interface {
	ServeHTTP(ResponseWriter, *Request)
}
```
那么，应用方做的就是实现 `ServeHTTP(ResponseWriter, *Request)` 方法。大致的流程就是

* `ListenAndServe(addr string, handler Handler)` 启动服务, 客户端发起请求
* `handler` 处理请求过来的流量交给反向代理模块, 这里需要实现接口
* 反向代理模块按照用户自定义的方式去做负载均衡, 在接口的实现中调用反向代理中的 `ServeHTTP` 方法，注意这里两个方法同名，但是作用不同的。负载均衡的逻辑需要自己来写，其实就是判断流量交给哪台目标服务器。
* 目标服务器把响应给负载均衡服务器
* 负载均衡服务器再传递回响应

源码：https://github.com/razertory/Ginx

现阶段能做到 http 请求转发。
