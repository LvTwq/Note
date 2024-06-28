[TOC]


[参考文档](https://mp.weixin.qq.com/s/JZE22Ndvo0tWC2P-MD0ROg)


# 整体结构
![](..\images\netty01.webp)

## Core 核心层
提供了底层通信的通用抽象和实现，包括事件模型、通用API、支持零拷贝的 ByteBuf 等。

## Protocol Support 协议支持层
覆盖了主流协议的编解码实现

## Transport Service 传输服务层
提供网络传输能力的定义和实现方法。支持 Socket、HTTP 隧道、虚拟机管道等传输方式。


# 逻辑架构
![](..\images\netty02.webp)

## 网络通信层
执行网络 I/O 操作，支持多种网络协议和 I/O 模型的连接操作。当网络数据读取到内核缓冲区后，触发各种网络事件，这些网络事件会分发给事件调度层进行处理。

网络通信层的核心组件包含：**BootStrap、ServerBootStrap、Channel** 三个组件。

* BootStrap： `引导`，负责 Netty 客户端程序的启动、初始化、服务器连接等过程，串联了其它核心组件
* ServerBootStrap： 用于**服务器启动绑定**本地端口，会绑定 Boss 和 Worker 两个 EventLoopGroup
* Channel：提供了基于 NIO 更高层次的抽象，如 register、bind、connect、read、write、flush 等

## 事件调度层
通过 Reactor 线程模型对各类事件进行聚合处理，通过 Selector 主循环线程集成多种事件（I/O 事件、信号事件、定时事件等），实际的业务处理逻辑是交由服务编排层中相关的 Handler 完成。

事件调度层的核心组件包括 **EventLoopGroup、EventLoop**

![](..\images\netty03.webp)

EventLoop 负责处理 Channel 生命周期内的所有 I/O 事件，如 accept、connet、read、write 等 I/O 事件。

1. 一个 EventLoopGroup 包含一个或多个 EventLoop
2. EventLoop 同一时间会与一个 Channel 绑定，每个 EventLoop 负责处理一种类型 Channel
3. Channel 在生命周期内可以对和多个 EventLoop 进行多次绑定和解绑。

EventLoopGroup 是 Netty 核心处理引擎，本质是一个线程池，主要负责接收 I/O 请求，并分配线程执行处理请求。通过创建不同的 EventLoopGroup 参数配置，可以支持 Reactor 的三种线程模型：
* 单线程模型：EventLoopGroup 只包含一个 EventLoop，Boss 和 Worker 使用同一个EventLoopGroup
* 多线程模型：EventLoopGroup 包含多个 EventLoop，Boss 和 Worker 使用同一个EventLoopGroup
* 主从多线程模型：EventLoopGroup 包含多个 EventLoop，Boss 是主 Reactor，Worker 是从 Reactor，它们分别使用不同的 EventLoopGroup，主 Reactor 负责新的网络连接 Channel 创建，然后把 Channel 注册到从 Reactor

## 服务编排层
组装各类服务，它是 Netty 核心处理链，用以实现网络事件的动态编排和有序传播。

核心组件包括：**ChannelPipeline、ChannelHandler、ChannelHandlerContext**

ChannelPipeline 负责组装各种 ChannelHandler，当 I/O 事件触发时，PipeLine 会依次调用 Handler 列表对 Channel 数据进行拦截处理。
![](..\images\netty04.webp)

客户端和服务端都有各自的 ChannelPipeline。客户端和服务端一次完整的请求：客户端出站（Encoder 请求数据）、服务端入站（Decoder接收数据并执行业务逻辑）、服务端出站（Encoder响应结果）。
ChannelHandler 完成数据的编解码以及处理工作
![](..\images\netty05.webp)

ChannelHandlerContext 用于保存Handler 上下文，通过 HandlerContext 我们可以知道 Pipeline 和 Handler 的关联关系。HandlerContext 可以实现 Handler 之间的交互，HandlerContext 包含了 Handler 生命周期的所有事件，如 connect、bind、read、flush、write、close 等。同时，HandlerContext 实现了Handler通用的逻辑的模型抽象

![](..\images\netty06.webp)


# 网络传输
## 五种IO模型区别
### 1、阻塞I/O(BIO)
![](..\images\netty07.webp)
应用进程向内核发起 I/O 请求，发起调用的线程一直等待内核返回结果。一次完整的 I/O 请求称为BIO（Blocking IO，阻塞 I/O），所以 BIO 在实现异步操作时，只能使用多线程模型，一个请求对应一个线程。但是，线程的资源是有限且宝贵的，创建过多的线程会增加线程切换的开销。

### 2、同步非阻塞I/O(NIO)
![](..\images\netty08.webp)
应用进程向内核发起 I/O 请求后不再会同步等待结果，而是会立即返回，通过轮询的方式获取请求结果。NIO 相比 BIO 虽然大幅提升了性能，但是轮询过程中大量的系统调用导致上下文切换开销很大。所以，单独使用非阻塞 I/O 时效率并不高，而且随着并发量的提升，非阻塞 I/O 会存在严重的性能浪费


### 3、多路复用I/O（select和poll）
![](..\images\netty09.webp)
多路复用实现了一个线程处理多个 I/O 句柄的操作。多路指的是多个数据通道，复用指的是使用一个或多个固定线程来处理每一个 Socket。select、poll、epoll 都是 I/O 多路复用的具体实现，线程一次 select 调用可以获取内核态中多个数据通道的数据状态。其中，select只负责等，recvfrom只负责拷贝，阻塞IO中可以对多个文件描述符进行阻塞监听，是一种非常高效的 I/O 模型

### 4、信号驱动I/O（SIGIO）
![](..\images\netty10.webp)
信号驱动IO模型，应用进程告诉内核：当数据报准备好的时候，给我发送一个信号，对SIGIO信号进行捕捉，并且调用我的信号处理函数来获取数据报


## Reactor多线程模型
Netty 的 I/O 模型是基于非阻塞 I/O 实现的，底层依赖的是 NIO 框架的多路复用器 Selector。采用 epoll 模式后，只需要一个线程负责 Selector 的轮询。当有数据处于就绪状态后，需要一个事件分发器（Event Dispather），它负责将读写事件分发给对应的读写事件处理器（Event Handler）

![](..\images\netty11.webp)


## 自定义协议
```java
// Netty 常用编码器类型：
MessageToByteEncoder //对象编码成字节流；

MessageToMessageEncoder //一种消息类型编码成另外一种消息类型。

// Netty 常用解码器类型：
ByteToMessageDecoder/ReplayingDecoder //将字节流解码为消息对象；

MessageToMessageDecoder //将一种消息类型解码为另外一种消息类型。
```


## WriteAndFlush
![](..\images\netty12.webp)

1. writeAndFlush 属于出站操作，它是从 Pipeline 的 Tail 节点开始进行事件传播，一直向前传播到 Head 节点
2. write 方法并没有将数据写入 Socket 缓冲区，只是将数据写入到 ChannelOutboundBuffer 缓存中，ChannelOutboundBuffer 缓存内部是由单向链表实现的
3. flush 方法才最终将数据写入到 Socket 缓冲区


# 内存管理
## 堆外内存
堆外内存与堆内内存相对应，对于整个机器内存而言，除堆内内存以外部分即为堆外内存。堆外内存不受 JVM 虚拟机管理，直接由操作系统管理。使用堆外内存有如下几个优点
1. 堆外内存由于不受 JVM 管理，所以在一定程度上可以降低 GC 对应用运行时带来的影响
2. 堆外内存需要手动释放，这一点跟 C/C++ 很像，稍有不慎就会造成应用程序内存泄漏，当出现内存泄漏问题时排查起来会相对困难
3. 当进行网络 I/O 操作、文件读写时，堆内内存都需要转换为堆外内存，然后再与底层设备进行交互，所以直接使用堆外内存可以减少一次内存拷贝
4. 堆外内存可以方便实现进程之间、JVM 多实例之间的数据共享

在堆内存放的 DirectByteBuffer 对象并不大，仅仅包含堆外内存的地址、大小等属性，同时还会创建对应的 Cleaner 对象，通过 ByteBuffer 分配的堆外内存不需要手动回收，它可以被 JVM 自动回收。当堆内的 DirectByteBuffer 对象被 GC 回收时，Cleaner 就会用于回收对应的堆外内存
![](..\images\netty13.webp)

## 数据载体ByteBuf

### JDK NIO 的 ByteBuffer

### Netty 中的 ByteBuf


## 内存分配 jemalloc

### 动态内存分配（DMA）
### Slab 算法（解决伙伴算法内部碎片问题）

## jemalloc 架构

## 零拷贝技术
1. 当用户进程发起 read() 调用后，上下文从用户态切换至内核态。DMA引擎从文件中读取数据，并存储到内核态缓冲区，这是**第一次数据拷贝**
2. 请求的数据从内核态缓冲区拷贝到用户态缓冲区，然后返回给用户进程。**第二次数据拷贝**的过程同时，会导致上下文从内核态再次切换到用户态
3. 用户进程调用 send() 方法期望将数据发送到网络中，用户态会再次切换到内核态，**第三次数据**拷贝请求的数据从用户态缓冲区被拷贝到 Socket 缓冲区
4. 最终 send() 系统调用结束返回给用户进程，发生了第四次上下文切换。第四次拷贝会异步执行，从 Socket 缓冲区拷贝到协议引擎中

![](..\images\netty14.webp)

优化，主要体现在以下 5 个方面：
1. 堆外内存，避免 JVM 堆内存到堆外内存的数据拷贝
2. CompositeByteBuf 类，可以组合多个 Buffer 对象合并成一个逻辑上的对象，避免通过传统内存拷贝的方式将几个 Buffer 合并成一个大的 Buffer
3. 通过 Unpooled.wrappedBuffer 可以将 byte 数组包装成 ByteBuf 对象，包装过程中不会产生内存拷贝
4. ByteBuf.slice ，slice 操作可以将一个 ByteBuf 对象切分成多个 ByteBuf 对象，切分过程中不会产生内存拷贝，底层共享一个 byte 数组的存储空间
5. Netty 使用 封装了transferTo() 方法 FileRegion，可以将文件缓冲区的数据直接传输到目标 Channel，避免内核缓冲区和用户态缓冲区之间的数据拷贝


# 高性能数据结构
## FastThreadLocal
使用数组替代 ThreadLocal 的键值对形式存储，具有以下优点：
1. 高效查找：FastThreadLocal 在定位数据的时候可以直接根据数组下标 index 获取，时间复杂度 O(1)。而 JDK 原生的 ThreadLocal 在数据较多时哈希表很容易发生 Hash 冲突
2. 安全性更高：JDK 原生的 ThreadLocal 使用不当可能造成内存泄漏，只能等待线程销毁。然而 FastThreadLocal 不仅提供了 remove() 主动清除对象的方法，而且在线程池场景中 Netty 还封装了 FastThreadLocalRunnable，任务执行完毕后一定会执行 FastThreadLocal.removeAll() 将 Set 集合中所有 FastThreadLocal 对象都清理掉。