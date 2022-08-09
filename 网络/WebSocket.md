[TOC]

# WebSocket 的设计与功能

即 Web 浏览器与 Web 服务器之间全双工通信标准，主要是为了解决 Ajax 和 Comet 里 XMLHttpRequest 附带的缺陷所引起的问题。

HTTP 协议有一个缺陷：通信只能由客户端发起。举例来说，我们想了解今天的天气，只能是客户端向服务器发出请求，服务器返回查询结果。HTTP 协议做不到服务器主动向客户端推送信息。HTTP 协议的这种单向请求的特点，注定了如果服务器有连续的状态变化，客户端要获知就非常麻烦。我们只能使用“轮询”：每隔一段时候，就发出一个询问，了解服务器有没有新的信息。最典型的场景就是聊天室。

轮询的效率低，非常浪费资源（因为必须不停连接，或者 HTTP 连接始终打开）。因此，工程师们一直在思考，有没有更好的方法。WebSocket 就是这样发明的。

# WebSocket 协议

由于是建立在 HTTP 基础上的协议，因此连接的发起方仍是客户端，而一旦确立 WebSocket 通信连接，不论是服务器还是客户端，任意一方都可直接向对方发送报文



## 推送功能

服务器可直接发送数据，不必等待客户端的请求

## 减少通信量

只要建立起 WebSocket 连接，就一直保持连接状态，不但每次连接时的总开销减少，而且由于 WebSocket 首部信息量很小，通信量也相应减少了

为了实现 WebSocket 通信，在 HTTP 连接建立后，需要完成一次“握手”（Handshaking）的步骤

## 握手

### 请求

需要用到 HTTP 的 Upgrade 首部字段，告知服务器通信协议发生改变，以达到握手的目的

Sec-WebSocket-Key：记录握手过程中必不可少的键值

Sec-WebSocket-Protocol：记录使用的子协议

### 响应

对于之前的请求，返回状态码 101 Switching Protocols 的响应

Sec-WebSocket-Accept：由 Sec-WebSocket-Key 生成

成功握手确立 WebSocket 连接之后，通信不再使用 HTTP 的数据帧，而采用 WebSocket 独立的数据帧

### WebSocket  API

由 JavaScript 调用 “WebSocket API” 内提供的 WebSocket 接口，实现 WebSocket 协议下全双工通信。



[教程参考]: https://wangdoc.com/webapi/websocket.html

