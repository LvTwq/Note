[toc]

# 什么是WebFlux

![](..\images\webflux01.awebp)

* **Spring MVC 构建于 Servlet API 之上，使用的是同步阻塞式 I/O 模型，什么是同步阻塞式 I/O 模型呢？就是说，每一个请求对应一个线程去处理，高并发时线程可能被耗尽，导致请求排队或拒绝。**
* **Spring WebFlux 是一个异步非阻塞式的 Web 框架，它能够充分利用多核 CPU 的硬件资源去处理大量的并发请求**
* 

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

## 响应式编程的核心：`Reactive Streams` 规范与 `Publisher` ：

* WebFlux 基于 **Reactive Streams** 规范，核心接口是 `Publisher<T>`。
* 在 WebFlux 中，`Mono<T>` 和 `Flux<T>` 就是 `Publisher` 的实现。
  * `Mono`：表示 0 或 1 个元素的异步序列（如单个用户查询）。
  * `Flux`：表示 0 到 N 个元素的异步序列（如用户列表）。
* 数据流是“ **背压（Backpressure）** ”驱动的，在响应式流中， **消费者可以主动告知生产者自己的处理能力** ，从而让生产者 **按需发送数据** ，实现“削峰填谷”。

```java
@GetMapping("/stream-data")
public Flux<Data> getData() {
    return dataService.fetchLargeData() // 返回 Flux<Data>
               .limitRate(100); // 背压控制：每次请求最多 100 条
}
```

### “非阻塞”的真正含义：

* 当 WebFlux 处理一个请求，需要调用数据库或远程服务时，它不会阻塞当前线程等待结果。
* 而是 **注册一个回调** ，然后释放线程去处理其他请求。
* 当数据库返回结果时，事件循环（Event Loop）会通知并继续执行后续逻辑。
* 这使得**少量线程**就能处理 **海量并发连接** 。

### 适用场景（更具体） ：

* **高 I/O 密集型** ：如频繁调用外部 REST API、消息队列、数据库（需响应式数据库驱动，如 R2DBC）。
* **长连接/实时通信** ：如 WebSocket、Server-Sent Events (SSE)、推送服务。
* **微服务网关** ：需要聚合多个后端服务的响应。
* **不适用场景** ：CPU 密集型任务（如复杂计算、图像处理），因为非阻塞模型对此帮助不大，甚至可能因线程切换开销而变慢。

## 背压如何工作

Reactive Streams 定义了四个核心接口：

```java
Publisher<T>
Subscriber<T>
Subscription
Subscription
```

其中最关键的是 Subscription —— 它是 生产者和消费者之间的“协商通道”。

```plaintext
1. 订阅阶段：
   Subscriber → subscribe(Publisher) 
                ↓
           Publisher → 返回一个 Subscription

2. 消费者声明需求：
   Subscriber → subscription.request(N)   // “我先处理 N 个”

3. 生产者响应：
   Publisher  → 只发送 ≤ N 个数据项
                ↓
                用 onNext(data) 逐个发送

4. 消费者处理完可以再要：
   Subscriber → 再次调用 subscription.request(M)  // “再给我 M 个”

5. 生产者继续按需发送...
```
