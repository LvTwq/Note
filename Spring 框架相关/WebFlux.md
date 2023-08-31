[TOC]

# 什么是WebFlux
![](..\images\webflux01.awebp)

**Spring MVC 构建于 Servlet API 之上，使用的是同步阻塞式 I/O 模型，什么是同步阻塞式 I/O 模型呢？就是说，每一个请求对应一个线程去处理**

**Spring WebFlux 是一个异步非阻塞式的 Web 框架，它能够充分利用多核 CPU 的硬件资源去处理大量的并发请求**

# WebFlux 的优势&提升性能?
WebFlux 内部使用的是响应式编程（Reactive Programming），以 Reactor 库为基础, 基于异步和事件驱动，可以让我们在不扩充硬件资源的前提下，**提升系统的吞吐量和伸缩性，并不能使接口的响应时间缩短**。


# WebFlux 应用场景
Spring WebFlux 是一个异步非阻塞式的 Web 框架，所以，它特别适合应用在 IO 密集型的服务中，比如微服务网关这样的应用中。
IO 密集型包括：**磁盘IO密集型, 网络IO密集型**，微服务网关就属于网络 IO 密集型，使用异步非阻塞式编程模型，能够显著地提升网关对下游服务转发的吞吐量。
![](..\images\webflux02.awebp)


# WebFlux Spring MVC 异同
![](..\images\webflux03.awebp)

## 相同点
* 都可以使用 Spring MVC 注解，如 @Controller, 方便我们在两个 Web 框架中自由转换；
* 均可以使用 Tomcat, Jetty, Undertow Servlet 容器（Servlet 3.1+）


# Demo
Spring MVC 的前端控制器是 DispatcherServlet, 而 WebFlux 是 DispatcherHandler，它实现了 WebHandler 接口：
```java
public interface WebHandler {
    Mono<Void> handle(ServerWebExchange var1);
}
```

DispatcherHandler类中处理请求的 handle 方法：
```java
// ServerWebExchange 对象中放置每一次 HTTP 请求响应信息，包括参数等
	@Override
	public Mono<Void> handle(ServerWebExchange exchange) {
        // 判断整个接口映射 mappings 集合是否为空，空则创建一个 Not Found 的错误
		if (this.handlerMappings == null) {
			return createNotFoundError();
		}
		return Flux.fromIterable(this.handlerMappings)
        // 根据具体的请求地址获取对应的 handlerMapping
				.concatMap(mapping -> mapping.getHandler(exchange))
				.next()
				.switchIfEmpty(createNotFoundError())
                // 调用具体业务方法，也就是我们定义的接口方法
				.flatMap(handler -> invokeHandler(exchange, handler))
                // 处理返回的结果
				.flatMap(result -> handleResult(exchange, result));
	}
```

# 什么是响应式编程

响应式编程是一种面向数据流和变化传播的编程范式。这意味着可以在编程语言中很方便地表达静态或动态的数据流，而相关的计算模型会自动将变化的值，通过数据流进行传播。

这段话很晦涩，在编程方面，它表达的意思就是：把生产者消费者模式，使用简单的API 表示出来，并自动处理背压（Backpressure）问题。

背压，指的是生产者与消费者之间的流量控制，通过将操作全面异步化，来减少无效的等待和资源消耗。