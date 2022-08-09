## RestTemplate

是Spring用于同步client端的核心类，简化了与http服务的通信，并满足RestFul原则，程序代码可以给它提供URL，并提取结果。默认情况下，RestTemplate默认依赖jdk的HTTP连接工具。当然你也可以 通过setRequestFactory属性切换到不同的HTTP源，比如Apache HttpComponents、Netty和OkHttp。



### 一、该类的入口是根据HTTP的六个方法制定：

| HTTP method | RestTemplate methods        |
| ----------- | --------------------------- |
| DELETE      | delete                      |
| GET         | getForEntity/getForObject   |
| HEAD        | headForHeaders              |
| OPTIONS     | optionsForAllow             |
| POST        | postForEntity/postForObject |
| PUT         | put                         |
| any         | exchange/excute             |

此外，exchange和excute可以通用上述方法。

在内部，RestTemplate默认使用HttpMessageConverter实例将HTTP消息转换成POJO或者从POJO转换成HTTP消息。默认情况下会注册主mime类型的转换器，但也可以通过setMessageConverters注册其他的转换器。



### 二、get请求

getForObject()其实比getForEntity()多包含了将HTTP转成POJO的功能，但是getForObject没有处理response的能力。因为它拿到手的就是成型的pojo。省略了很多response的信息。





### 三、exchange()指定调用方式

exchange()方法跟上面的getForObject()、getForEntity()、postForObject()、postForEntity()等方法不同之处在于它可以指定请求的HTTP类型。







### 四、excute()指定调用方式

excute()的用法与exchange()大同小异了，它同样可以指定不同的HttpMethod，不同的是它返回的对象是响应体所映射成的对象，而不是ResponseEntity。