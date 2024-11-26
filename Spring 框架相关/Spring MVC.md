[TOC]


## Spring MVC

Spring MVC 是目前主流的实现 MVC 设计模式的企业级开发框架，Spring 框架的一个子模块，无需整合，开发起来更加便捷。

### 什么是 MVC 设计模式？

将应用程序分为 Controller、Model、View 三层，Controller 接收客户端请求，调用 Model 生成业务数据，传递给 View。

Spring MVC 就是对这套流程的封装，屏蔽了很多底层代码，开放出接口，让开发者可以更加轻松、便捷地完成基于 MVC 模式的 Web 开发。

![](..\images\TIM截图20200205134935.png)

### Spring MVC 的核心组件

- DispatcherServlet：前置控制器，是整个流程控制的核心，控制其他组件的执行，进行统一调度，降低组件之间的耦合性，相当于总指挥。
- Handler：处理器，完成**具体的业务逻辑**，相当于 Servlet 或 Action。
- HandlerMapping：DispatcherServlet 接收到请求之后，通过 HandlerMapping 将不同的请求映射到不同的 Handler。
- HandlerInterceptor：***处理器拦截器***，是一个 ***接口***，如果需要完成一些拦截处理，可以实现该接口。
- HandlerExecutionChain：处理器执行链，包括两部分内容：Handler 和 HandlerInterceptor（系统会有一个默认的 HandlerInterceptor，如果需要额外设置拦截，可以添加拦截器）。
- HandlerAdapter：处理器适配器，Handler 执行业务方法之前，需要进行一系列的操作，包括表单数据的验证、数据类型的转换、将表单数据封装到 JavaBean 等，这些操作都是由 HandlerApater 来完成，开发者只需将注意力集中业务逻辑的处理上，DispatcherServlet 通过 HandlerAdapter 执行不同的 Handler。
- ModelAndView：装载了模型数据和视图信息，作为 Handler 的处理结果，返回给 DispatcherServlet。
- ViewResolver：视图解析器，DispatcheServlet 通过它将逻辑视图解析为物理视图，最终将渲染结果响应给客户端。



### Spring MVC 的工作流程

![](..\images\TIM截图20200205135308.png)

- 客户端请求被 DisptacherServlet 接收。
- 根据 HandlerMapping 映射到 Handler。
- 生成 Handler 和 HandlerInterceptor。
- Handler 和 HandlerInterceptor 以 HandlerExecutionChain 的形式一并返回给 DisptacherServlet。
- DispatcherServlet 通过 HandlerAdapter 调用 Handler 的方法完成业务逻辑处理。
- Handler 返回一个 ModelAndView 给 DispatcherServlet。
- DispatcherServlet 将获取的 ModelAndView 对象传给 ViewResolver 视图解析器，将逻辑视图解析为物理视图 View。
- ViewResovler 返回一个 View 给 DispatcherServlet。
- DispatcherServlet 根据 View 进行视图渲染（将模型数据 Model 填充到视图 View 中）。
- DispatcherServlet 将渲染后的结果响应给客户端。

Spring MVC 流程非常复杂，实际开发中很简单，因为大部分的组件不需要开发者创建、管理，只需要通过配置文件的方式完成配置即可，真正需要开发者进行处理的只有 Handler 、View。



### 如何使用？

- 创建 Maven 工程，pom.xml

```xml
<dependencies>

    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-webmvc</artifactId>
        <version>5.0.11.RELEASE</version>
    </dependency>

</dependencies>
```

- 在 web.xml 中配置 DispatcherServlet。

```xml
<!DOCTYPE web-app PUBLIC
 "-//Sun Microsystems, Inc.//DTD Web Application 2.3//EN"
 "http://java.sun.com/dtd/web-app_2_3.dtd" >

<web-app>
  <display-name>Archetype Created Web Application</display-name>

  <servlet>
    <servlet-name>dispatcherServlet</servlet-name>
    <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
<!--读取springmvc自己的配置文件-->
    <init-param>
      <param-name>contextConfigLocation</param-name>
      <param-value>classpath:springmvc.xml</param-value>
    </init-param>
  </servlet>


<!-- 拦截所有请求-->
  <servlet-mapping>
    <servlet-name>dispatcherServlet</servlet-name>
    <url-pattern>/</url-pattern>
  </servlet-mapping>

</web-app>
```

- springmvc.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xmlns:mvc="http://www.springframework.org/schema/mvc"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context.xsd
       http://www.springframework.org/schema/mvc
       http://www.springframework.org/schema/mvc/spring-mvc-3.2.xsd">

    <!-- 自动把所有组件扫描到 IOC，在 Java 中写的任何一个类的组件全都交给 IOC 来管理 -->
    <context:component-scan base-package="com.southwind"></context:component-scan>

    <!-- 配置视图解析器
        比如本来返回的是一个 index，会自动给它加上前后缀，变成 /index.jsp
    -->
    <bean class="org.springframework.web.servlet.view.InternalResourceViewResolver">
        <property name="prefix" value="/"></property>
        <property name="suffix" value=".jsp"></property>
    </bean>

</beans>
```

- 创建 Handler

  创建好这个控制器之后，要交给`IOC`来管理并实例化，加上`@Controller`注解

  ***注意：***

  * @Component 只是把它交给`IOC`了，没有控制器的功能
  * `index`是逻辑视图，结合视图解析器，就可以找到 /index.jsp 了

```java
package com.southwind.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class HelloHandler {

    @RequestMapping("/index")
    public String index(){
        System.out.println("执行了index...");
        return "index";
    }
}
```

然后配置 Tomcat 就可以访问http://localhost:8080/index

##### 流程：

1）上面配置的`DispatcherServlet`就能捕获到 `index`请求，`index`就根据`HandlerMapping`去找`Handler`（映射）。

2）然后通过 `@RequestMapping`映射到此方法，调用方法是**springmvc**完成的，它会首先实例化这个`Handler`，然后调用这个 index 方法。

3）**"index"** 这个字符串就是逻辑视图，会返回到`DispatcherServlet` 中，把这个逻辑视图交给`ViewResolver`进行解析，根据定义好的前后缀规则，变成了物理视图的路径，在根目录中找到***/index.jsp***，把***index.jsp***返回给客户端，就能在浏览器看到了。





## Spring MVC 注解

### 1. @RequestMapping 

Spring MVC 通过 @RequestMapping 注解将 URL 请求与业务方法进行映射，在 Handler 的**类**定义处以及**方法**定义处都可以添加 @RequestMapping ，在类定义处添加，相当于客户端多了一层访问路径。

### 2. @Controller

@Controller 在**类**定义处添加，将该类交给 IoC 容器来管理（结合 springmvc.xml 的自动扫描配置使用），同时使其成为一个**控制器**，<u>可以接收客户端请求</u>。

```java
package com.southwind.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/hello")
public class HelloHandler {

    @RequestMapping("/index")
    public String index(){
        System.out.println("执行了index...");
        return "index";
    }
}
```

### 3. @RequestMapping 相关参数

#### 1、value：

指定 URL 请求的实际地址，是 @RequestMapping 的默认值。

```java
@RequestMapping("/index")
public String index(){
    System.out.println("执行了index...");
    return "index";
}
```

等于

```java
@RequestMapping(value="/index")
public String index(){
    System.out.println("执行了index...");
    return "index";
}
```

#### 2、method：

指定请求的 method 类型，GET、POST、PUT、DELET。

```java
@RequestMapping(value = "/index",method = RequestMethod.GET)
public String index(){
    System.out.println("执行了index...");
    return "index";
}
```

上述代码表示 index 方法只能接收 GET 请求。

#### 3、params：

指定请求中必须包含某些参数，否则无法调用该方法。

```java
@RequestMapping(value = "/index",method = RequestMethod.GET,params = {"name","id=10"})
public String index(){
    System.out.println("执行了index...");
    return "index";
}
```

上述代码表示请求中必须包含 name 和 id 两个参数，同时 id 的值必须是 10。

关于参数绑定，在形参列表中通过添加 `@RequestParam` 注解完成 ***HTTP 请求参数与业务方法形参的映射***。

且通过请求参数名和形参名**一致**，来将***请求参数赋值给形参***，如果不一致要使用`@RequestParam`进行映射。

```java
@RequestMapping(value = "/index",method = RequestMethod.GET,params = {"name","id=10"})
public String index(@RequestParam("name") String str,@RequestParam("id") int age){
    System.out.println(str);
    System.out.println(age);
    System.out.println("执行了index...");
    return "index";
}
```

> 上述代码表示将请求的参数 name 和 id 分别赋给了形参 str 和 age ，同时自动完成了数据类型转换，将 “10” 转为了 int 类型的 10，再赋给 age，这些工作都是由 HandlerAdapter 来完成的。
>

Spring MVC 也支持 RESTful 风格的 URL。

传统类型：http://localhost:8080/hello/index?name=zhangsan&id=10

RESTful：http://localhost:8080/hello/index/zhangsan/10

```java
// 在定义的时候就要把参数写出来
@RequestMapping("/rest/{name}/{id}")
public String rest(@PathVariable("name") String name,@PathVariable("id") int id){
    System.out.println(name);
    System.out.println(id);
    return "index";
}
```

> 通过 `@PathVariable` 注解**接收请求路径中占位符的值**，完成请求参数与形参的映射。





### 4. 映射 Cookie

Spring MVC 通过映射可以直接在业务方法中获取 Cookie 的值。

`@CookieValue`：可以把想要的值取出来

```java
@RequestMapping("/cookie")
// 把客户端的cookie里面的JSESSIONID取出来，赋值给当前的 sessionId
public String cookie(@CookieValue(value = "JSESSIONID") String sessionId){
    System.out.println(sessionId);
    return "index";
}
```



### 5. 使用 JavaBean 绑定参数

把参数直接绑定到一个 Java 对象里，在业务方法里直接获取到对象，Spring MVC 会根据***请求参数名和 JavaBean 属性名进行自动匹配***，自动为对象填充属性值，同时支持及联（对象里面有对象）属性。

```java
package com.southwind.entity;

import lombok.Data;

@Data
public class Address {
    private String value;
}
```

```java
package com.southwind.entity;

import lombok.Data;

@Data
public class User {
    private long id;
    private String name;
    // User 里面有 Address，表单里写的是 address.value，这就是级联
    private Address address;
}
```

```html
<html>
<head>
    <title>Title</title>
</head>
<body>
    <form action="/hello/save" method="post">
        用户id：<input type="text" name="id"/><br/>
        用户名：<input type="text" name="name"/><br/>
        用户地址：<input type="text" name="address.value"/><br/>
        <input type="submit" value="注册"/>
    </form>
</body>
</html>
```

当点击`注册`按钮时，就会把这个表单发送给***/hello/save***方法，并且把在页面填入的`id`，`name`，`address.value`分别赋给形参 **`user`**的属性（名称要一一对应），

```java
// 这个形参是你需要拿到的对象，HandlerAdapter 会自动封装，把对象创建好
@RequestMapping(value = "/save",method = RequestMethod.POST)
public String save(User user){
    System.out.println(user);
    return "index";
}
```



如果出现中文乱码问题，只需在 web.xml 添加 Spring MVC 自带的过滤器即可。

```xml
<filter>
    <filter-name>encodingFilter</filter-name>
    <filter-class>org.springframework.web.filter.CharacterEncodingFilter</filter-class>
    <init-param>
        <param-name>encoding</param-name>
        <param-value>UTF-8</param-value>
    </init-param>
</filter>

<filter-mapping>
    <filter-name>encodingFilter</filter-name>
    <url-pattern>/*</url-pattern>
</filter-mapping>
```





### 6. JSP 页面的转发和重定向：

Spring MVC 默认是以***转发*** 的形式响应 JSP。

#### 1、转发：

地址栏**不会改变**，***服务器***跳转，**一次**请求，所以在请求里传的数据可以在页面里取出来

```java
@RequestMapping("/forward")
public String forward(){
    return "forward:/index.jsp";
    //        return "index";
}
```

#### 2、重定向：

地址栏会改变，***客户端***跳转，**两次**请求

```java
@RequestMapping("/redirect")
public String redirect(){
    return "redirect:/index.jsp";
}
```



## Spring MVC 数据绑定

数据绑定：在后端的业务方法中直接获取客户端 HTTP 请求中的参数，将请求参数映射到业务方法的形参中，Spring MVC 中数据绑定的工作是由 HandlerAdapter 来完成的。

### 1. 基本数据类型

```java
@RequestMapping("/baseType/{id}")
@ResponseBody
public String baseType(@PathVariable("id") int id){
    // 如果不加@ResponseBody，id加上空字符串会变成string类型，如果请求里传的是 1，就会变成 /1.jsp，而现在会直接在页面显示 1
    return id+"";
}
```

`@ResponseBody` 表示 Spring MVC 会直接将业务方法的**返回值**响应给客户端，如果不加 @ResponseBody 注解，Spring MVC 会将业务方法的返回值传递给 DispatcherServlet，再由 DisptacherServlet 调用 ViewResolver 对返回值进行解析，映射到一个 JSP 资源。



### 2. 包装类

```java
@RequestMapping("/packageType")
@ResponseBody
public String packageType(@RequestParam(value = "num",required = false,defaultValue = "0") Integer id){    
    return id+"";
}
```

包装类可以接收 null，当 HTTP 请求没有参数时，使用包装类定义形参的数据类型，程序不会抛出异常。

但这时就不能使用 RESTful 风格。

***设置默认值：***

**@RequestParam**

* value = "num"：将 HTTP 请求中名为 num 的参数赋给形参 id。

* requried：设置 num 是否为必填项，true 表示必填，false 表示非必填，可省略。

* defaultValue = “0”：如果 HTTP 请求中没有 num 参数，默认值为0.



### 3. 数组

```java
@RestController
@RequestMapping("/data")
public class DataBindHandler {
    @RequestMapping("/array")
    public String array(String[] name){
        String str = Arrays.toString(name);
        return str;
    }
}
```

**@RestController 表示该控制器会直接将业务方法的数据返回值响应给客户端，不进行视图解析。**

@Controller 表示该控制器的每一个业务方法的返回值都会交给视图解析器进行解析，如果只需要将数据响应给客户端，而不需要进行视图解析，则需要在对应的业务方法定义处添加 @ResponseBody。

```java
@RestController
@RequestMapping("/data")
public class DataBindHandler {
    @RequestMapping("/array")
    public String array(String[] name){
        String str = Arrays.toString(name);
        return str;
    }
}
```

等同于

```java
@Controller
@RequestMapping("/data")
public class DataBindHandler {
    @RequestMapping("/array")
    @ResponseBody
    public String array(String[] name){
        String str = Arrays.toString(name);
        return str;
    }
}
```





### 4. List

比如前端传3个user对象，在后台业务方法中把这3个业务对象装到一个集合里面。

> list 不能直接绑定，需要先把它封装成一个对象，因为前端只能给一个对象的***属性*** 赋值，不能直接给一个***对象本身*** 赋值，所以要定义一个封装类，把 list 集合作为某一个对象的属性才能完成赋值。

Spring MVC 不支持 List 类型的直接转换，需要对 List 集合进行包装。

* 集合封装类

```java
package com.southwind.entity;

import lombok.Data;

import java.util.List;

@Data
public class UserList {
    private List<User> users;
}
```

* JSP

`name`应该和这个jsp对应的方法的***形参对应的属性***，这里也就是 ***userList 的属性*** 进行映射，也就是 `users`，而是是要把它赋值给集合里面对象的属性，users[0]是把集合里的第一个对象取出来，然后给第一个对象的id赋值

```html
<%--
  Created by IntelliJ IDEA.
  User: southwind
  Date: 2019-03-14
  Time: 09:12
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Title</title>
</head>
<body>
    <form action="/data/list" method="post">
        用户1编号：<input type="text" name="users[0].id"/><br/>
        用户1名称：<input type="text" name="users[0].name"/><br/>
        用户2编号：<input type="text" name="users[1].id"/><br/>
        用户2名称：<input type="text" name="users[1].name"/><br/>
        用户3编号：<input type="text" name="users[2].id"/><br/>
        用户3名称：<input type="text" name="users[2].name"/><br/>
        <input type="submit" value="提交"/>
    </form>
</body>
</html>
```

* 业务方法

```java
@RequestMapping("/list")
public String list(UserList userList){
    StringBuffer str = new StringBuffer();
    // userList 是一个对象，不是集合，它的属性才是集合，而这里是要遍历集合
    // 下面直接添加 user，是调用了 toString()方法，转成string类型，所以能累加到 string里面
    for (User user:userList.getUsers()){
        str.append(user);
    }
    // 因为str是StringBuffer，但需要返回一个string
    return str.toString();
}
```

* 处理 @ResponseBody 中文乱码，在 springmvc.xml 中配置消息转换器。

```xml
<mvc:annotation-driven>
    <!-- 消息转换器 -->
    <mvc:message-converters register-defaults="true">
        <bean class="org.springframework.http.converter.StringHttpMessageConverter">
            <property name="supportedMediaTypes" value="text/html;charset=UTF-8"></property>
        </bean>
    </mvc:message-converters>
</mvc:annotation-driven>
```



### 5. Map

* 自定义封装类

```java
package com.southwind.entity;

import lombok.Data;

import java.util.Map;

@Data
public class UserMap {
    private Map<String,User> users;
}
```

* 业务方法：

  map 实际上是两组集合，要把 key 取出来，遍历 key值，然后取出对应的 value 值

```java
@RequestMapping("/map")
public String map(UserMap userMap){
    StringBuffer str = new StringBuffer();
    for(String key:userMap.getUsers().keySet()){
        User user = userMap.getUsers().get(key);
        str.append(user);
    }
    return str.toString();
}
```

* JSP：

把`id`，`name`取出来之后，封装成一个 `users`，把它装到 map 里面，同时它的 `key`值是“a"，然后遍历 key值时，取得就是 “a”，就是张三。

所以其实key值定义成什么都可以，因为他都是存进去再取出来。

![](..\images\TIM截图20200206204713.png)

```html
<%--
  Created by IntelliJ IDEA.
  User: southwind
  Date: 2019-03-14
  Time: 09:12
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Title</title>
</head>
<body>
    <form action="/data/map" method="post">
        用户1编号：<input type="text" name="users['a'].id"/><br/>
        用户1名称：<input type="text" name="users['a'].name"/><br/>
        用户2编号：<input type="text" name="users['b'].id"/><br/>
        用户2名称：<input type="text" name="users['b'].name"/><br/>
        用户3编号：<input type="text" name="users['c'].id"/><br/>
        用户3名称：<input type="text" name="users['c'].name"/><br/>
        <input type="submit" value="提交"/>
    </form>
</body>
</html>
```





### 6. JSON

客户端发送 JSON 格式的数据，直接通过 Spring MVC 绑定到业务方法的形参中。

***前端把一个json数据的user对象传到后台，用Java对象接收，进行处理，再以json数据的形式返回（都是借助于 fastjson）***

处理 Spring MVC 无法加载静态资源，在 web.xml 中添加配置即可。

```xml
<servlet-mapping>
    <servlet-name>default</servlet-name>
    <url-pattern>*.js</url-pattern>
</servlet-mapping>
```

JSP

```html
<%--
  Created by IntelliJ IDEA.
  User: southwind
  Date: 2019-03-14
  Time: 10:35
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Title</title>
    <script type="text/javascript" src="https://code.jquery.com/jquery-3.3.1.min.js"></script>
    <script type="text/javascript">
        $(function(){
           var user = {
               "id":1,
               "name":"张三"
           };
           $.ajax({
               url:"/data/json",
               data:JSON.stringify(user),
               type:"POST",
               contentType:"application/json;charset=UTF-8",
               // 返回的数据的类型
               dataType:"JSON",
               // data 就是后台返回的数据（是一个对象）
               success:function(data){
                   alert(data.id+"---"+data.name);
               }
           })
        });
    </script>
</head>
<body>

</body>
</html>
```

* 业务方法

这个 user 不是通过表单提交的普通对象，而json数据需要用 @RequestBody

@ResponseBody 是做响应的时候把数据以 json 形式返回到客户端

@RequestBody 是接收一个客户端的 json 数据，然后赋给形参

```java
@RequestMapping("/json")
public User json(@RequestBody User user){
    System.out.println(user);
    user.setId(6);
    user.setName("张六");
    return user;
}
```

Spring MVC 中的 JSON 和 JavaBean 的转换需要借助于 fastjson，pom.xml 引入相关依赖。

```xml
<dependency>
    <groupId>com.alibaba</groupId>
    <artifactId>fastjson</artifactId>
    <version>1.2.32</version>
</dependency>
```

springmvc.xml 添加 fastjson 配置。

```xml
<mvc:annotation-driven>
    <!-- 消息转换器 -->
    <mvc:message-converters register-defaults="true">
        <bean class="org.springframework.http.converter.StringHttpMessageConverter">
            <property name="supportedMediaTypes" value="text/html;charset=UTF-8"></property>
        </bean>
        <!-- 配置fastjson -->
        <bean class="com.alibaba.fastjson.support.spring.FastJsonHttpMessageConverter4"></bean>
    </mvc:message-converters>
</mvc:annotation-driven>
```





## Spring MVC 模型数据解析

JSP 四大作用域对应的内置对象：pageContext、request、session、application。

**模型数据解析**：把模型数据**绑定**到域对象中，把域对象传到 JSP，再从 JSP 中解析出来。

模型数据的绑定是由 **ViewResolver** 来完成的，实际开发中，我们需要**先添加模型数据，再交给 ViewResolver 来绑定**。

Spring MVC 提供了以下几种方式 ***添加模型数据***：

- Map
- Model
- ModelAndView
- @SessionAttribute
- @ModelAttribute

### 一、将模式数据绑定到 request 对象。

#### 1. Map

要把user在视图中进行展示，就是模型数据解析：首先要把user加到域对象中，jsp再从域对象中取出来进行解析

```java
@RequestMapping("/map")
public String map(Map<String,User> map){
    User user = new User();
    user.setId(1L);
    user.setName("张三");
// map里面存的就是模型数据，会自动传到视图里面，并且把map里的数据取出来放到 request中:
// 把map的key，value作为 request 的key和value  
    map.put("user",user);
    return "view";
}
```

* JSP

```html
<%--
  Created by IntelliJ IDEA.
  User: southwind
  Date: 2019-03-14
  Time: 11:36
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page isELIgnored="false" %>
<html>
<head>
    <title>Title</title>
</head>
<body>
    ${requestScope.user}
</body>
</html>
```





#### 2. Model

```java
@RequestMapping("/model")
public String model(Model model){
    User user = new User();
    user.setId(1L);
    user.setName("张三");
    model.addAttribute("user",user);
    return "view";
}
```





#### 3. ModelAndView

相当于把 user 和 view 整到一个对象里面

```java
@RequestMapping("/modelAndView")
public ModelAndView modelAndView(){
    User user = new User();
    user.setId(1L);
    user.setName("张三");
    ModelAndView modelAndView = new ModelAndView();
    // 添加模型数据
    modelAndView.addObject("user",user);
    // 添加视图信息名称
    modelAndView.setViewName("view");
    return modelAndView;
}

@RequestMapping("/modelAndView2")
public ModelAndView modelAndView2(){
    User user = new User();
    user.setId(1L);
    user.setName("张三");
    ModelAndView modelAndView = new ModelAndView();
    // 添加模型数据
    modelAndView.addObject("user",user);
    // InternalResourceView 是 View的一个实现类，传的是物理视图路径
    View view = new InternalResourceView("/view.jsp");
    // 需要传一个 view 对象，所以在上面实例化一个
    modelAndView.setView(view);
    return modelAndView;
}

@RequestMapping("/modelAndView3")
public ModelAndView modelAndView3(){
    User user = new User();
    user.setId(1L);
    user.setName("张三");
    // 实例化时，利用构造函数，可以直接把它的名字传进来
    ModelAndView modelAndView = new ModelAndView("view");
    // 添加模型数据
    modelAndView.addObject("user",user);
    return modelAndView;
}

@RequestMapping("/modelAndView4")
public ModelAndView modelAndView4(){
    User user = new User();
    user.setId(1L);
    user.setName("张三");
    View view = new InternalResourceView("/view.jsp");
    // 实例化时，利用构造函数，可以直接把view传进来，但同样需要实例化一个 view对象
    ModelAndView modelAndView = new ModelAndView(view);
    // 添加模型数据
    modelAndView.addObject("user",user);
    return modelAndView;
}

@RequestMapping("/modelAndView5")
public ModelAndView modelAndView5(){
    User user = new User();
    user.setId(1L);
    user.setName("张三");
    Map<String,User> map = new HashMap<>();
    map.put("user",user);
    // 把user装进map里，调用构造函数直接传视图和模型
    ModelAndView modelAndView = new ModelAndView("view",map);
    return modelAndView;
}

@RequestMapping("/modelAndView6")
public ModelAndView modelAndView6(){
    User user = new User();
    user.setId(1L);
    user.setName("张三");
    Map<String,User> map = new HashMap<>();
    map.put("user",user);
    View view = new InternalResourceView("/view.jsp");
    // 把user装进map里，调用构造函数直接传视图对象和模型
    ModelAndView modelAndView = new ModelAndView(view,map);
    return modelAndView;
}

@RequestMapping("/modelAndView7")
public ModelAndView modelAndView7(){
    User user = new User();
    user.setId(1L);
    user.setName("张三");
    ModelAndView modelAndView = new ModelAndView("view","user",user);
    return modelAndView;
}

@RequestMapping("/modelAndView8")
public ModelAndView modelAndView8(){
    User user = new User();
    user.setId(1L);
    user.setName("张三");
    View view = new InternalResourceView("/view.jsp");
    ModelAndView modelAndView = new ModelAndView(view,"user",user);
    return modelAndView;
}
```





#### 4. HttpServletRequest

直接存到 request 里面

```java
@RequestMapping("/request")
public String request(HttpServletRequest request){
    User user = new User();
    user.setId(1L);
    user.setName("张三");
    request.setAttribute("user",user);
    return "view";
}
```





#### 5. @ModelAttribute

- 定义一个方法，该方法专门用来返回要填充到模型数据中的对象。
  - @ModelAttribute 加上此注解，此方法会优先业务方法执行，业务方法就不需要处理模型数据

```java
@ModelAttribute
public User getUser(){
    User user = new User();
    user.setId(1L);
    user.setName("张三");
    return user;
}
```

```java
@ModelAttribute
public void getUser(Map<String,User> map){
    User user = new User();
    user.setId(1L);
    user.setName("张三");
    map.put("user",user);
}
```

```java
@ModelAttribute
public void getUser(Model model){
    User user = new User();
    user.setId(1L);
    user.setName("张三");
    model.addAttribute("user",user);
}
```

- 业务方法中无需再处理模型数据，只需返回视图即可。

```java
@RequestMapping("/modelAttribute")
public String modelAttribute(){
    return "view";
}
```





### 二、将模型数据绑定到 session 对象

#### 1. 直接使用原生的 Servlet API。

因为session就是从request对象中拿出来的，既然能拿到request就能拿到session，但一般不这么写，因为 session 可以直接拿到

```java
@RequestMapping("/session")
public String session(HttpServletRequest request){
    HttpSession session = request.getSession();
    User user = new User();
    user.setId(1);
    user.setName("lvmc");
    // 存到 session 里面
    session.setAttribute("user",user);
    return "view";
}

@RequestMapping("/session2")
public String session2(HttpSession session){
    User user = new User();
    user.setId(1);
    user.setName("lvmc");
    session.setAttribute("user",user);
    return "view";
}
```

* view.jsp 中添加 ${sessionScope.user}

```html
<body>
    ${requestScope.user}
    <hr/>
    ${sessionScope.user}
</body>
```

![](..\images\TIM截图20200207172541.png)

因为前面有一个 getUser() 方法，执行就会向 request 中添加对象，然后 session() 方法往 session 里添加对象，如果把@ModelAttribute注释掉，就只进 session() 方法。





#### 2. @SessionAttribute

轻易不要用此注解，因为我们大多数情况下都只使用request

```java
@SessionAttributes(value = {"user","address"})
public class ViewHandler {
}
```

**对于 ViewHandler 中的所有业务方法，只要向 request 中添加了 key = "user"、key = "address" 的对象时，Spring MVC 会自动将该数据添加到 session 中，保存 key 不变。**

```java
@SessionAttributes(types = {User.class,Address.class})
public class ViewHandler {
}
```

对于 ViewHandler 中的所有业务方法，只要向 request 中添加了**数据类型**是 User 、Address 的对象时，Spring MVC 会自动将该数据添加到 session 中，保存 key 不变。



### 三、将模型数据绑定到 application 对象

```java
@RequestMapping("/application")
public String application(HttpServletRequest request){
    ServletContext application = request.getServletContext();
    User user = new User();
    user.setId(1L);
    user.setName("张三");
    application.setAttribute("user",user);
    return "view";
}
```











## Spring MVC 自定义数据转换器

数据转换器是指将客户端 HTTP 请求中的参数转换为业务方法中定义的形参，自定义表示开发者可以自主设计转换的方式，HandlerApdter 已经提供了通用的转换，String 转 int，String 转 double，表单数据的封装等，但是在特殊的业务场景下，HandlerAdapter 无法进行转换，就需要开发者自定义转换器。



### 1. String 转 Date

客户端输入 String 类型的数据 "2019-03-03"，自定义转换器将该数据转为 Date 类型的对象。

- 创建 DateConverter 转换器，实现 Conveter 接口。

```java
package com.southwind.converter;

import org.springframework.core.convert.converter.Converter;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

public class DateConverter implements Converter<String, Date> {

    private String pattern;

    public DateConverter(String pattern){
        this.pattern = pattern;
    }

    @Override
    public Date convert(String s) {
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat(this.pattern);
        Date date = null;
        try {
            date = simpleDateFormat.parse(s);
        } catch (ParseException e) {
            e.printStackTrace();
        }
        return date;
    }
}
```

- springmvc.xml 配置转换器。

```xml
<!-- 配置自定义转换器 -->
<bean id="conversionService" class="org.springframework.context.support.ConversionServiceFactoryBean">
    <property name="converters">
        <list>
            <bean class="com.southwind.converter.DateConverter">
                <constructor-arg type="java.lang.String" value="yyyy-MM-dd"></constructor-arg>
            </bean>
        </list>
    </property>
</bean>

<mvc:annotation-driven conversion-service="conversionService">
    <!-- 消息转换器 -->
    <mvc:message-converters register-defaults="true">
        <bean class="org.springframework.http.converter.StringHttpMessageConverter">
            <property name="supportedMediaTypes" value="text/html;charset=UTF-8"></property>
        </bean>
        <!-- 配置fastjson -->
        <bean class="com.alibaba.fastjson.support.spring.FastJsonHttpMessageConverter4"></bean>
    </mvc:message-converters>
</mvc:annotation-driven>
```

- JSP

```html
<%--
  Created by IntelliJ IDEA.
  User: southwind
  Date: 2019-03-14
  Time: 14:47
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Title</title>
</head>
<body>
    <form action="/converter/date" method="post">
        请输入日期:<input type="text" name="date"/>(yyyy-MM-dd)<br/>
        <input type="submit" value="提交"/>
    </form>
</body>
</html>
```

- Handler

```java
package com.southwind.controller;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Date;

@RestController
@RequestMapping("/converter")
public class ConverterHandler {

    @RequestMapping("/date")
    public String date(Date date){
        return date.toString();
    }
}
```

点击`提交`之后，首先会调用**有参构造**来实例化转化器对象，然后进入转换方法，转成一个 data 对象之后再进入ConverterHandler





### 2. String 转 Student

* StudentConverter

```java
package com.southwind.converter;

import com.southwind.entity.Student;
import org.springframework.core.convert.converter.Converter;

public class StudentConverter implements Converter<String, Student> {
    @Override
    public Student convert(String s) {
        // 1-zhangsan-22
        // {"1","zhangsan","22"}
        // 拆成数组，id是此数组的第一个值，取出来转成long类型
        String[] args = s.split("-");
        Student student = new Student();
        student.setId(Long.parseLong(args[0]));
        student.setName(args[1]);
        student.setAge(Integer.parseInt(args[2]));
        return student;
    }
}
```

* springmvc.xml

```xml
<!-- 配置自定义转换器 -->
<bean id="conversionService" class="org.springframework.context.support.ConversionServiceFactoryBean">
    <property name="converters">
        <list>
            <bean class="com.southwind.converter.DateConverter">
                <constructor-arg type="java.lang.String" value="yyyy-MM-dd"></constructor-arg>
            </bean>
            <bean class="com.southwind.converter.StudentConverter"></bean>
        </list>
    </property>
</bean>

<mvc:annotation-driven conversion-service="conversionService">
    <!-- 消息转换器 -->
    <mvc:message-converters register-defaults="true">
        <bean class="org.springframework.http.converter.StringHttpMessageConverter">
            <property name="supportedMediaTypes" value="text/html;charset=UTF-8"></property>
        </bean>
        <!-- 配置fastjson -->
        <bean class="com.alibaba.fastjson.support.spring.FastJsonHttpMessageConverter4"></bean>
    </mvc:message-converters>
</mvc:annotation-driven>
```

* JSP

```html
<%--
  Created by IntelliJ IDEA.
  User: southwind
  Date: 2019-03-14
  Time: 15:23
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Title</title>
</head>
<body>
    <form action="/converter/student" method="post">
        请输入学生信息：<input type="text" name="student"/>(id-name-age)<br/>
        <input type="submit" value="提交"/>
    </form>
</body>
</html>
```

* Handler

```java
@RequestMapping("/student")
public String student(Student student){
    return student.toString();
}
```

点击`提交`之后，首先会调用**无参构造**来实例化转化器对象，然后进入转换方法，转成一个 student 对象之后再进入







## Spring MVC REST

REST：Representational State Transfer，资源表现层状态转换，是目前比较主流的一种互联网软件架构，它结构清晰、标准规范、易于理解、便于扩展。

- 资源（Resource）

网络上的一个实体，或者说网络中存在的一个具体信息，一段文本、一张图片、一首歌曲、一段视频等等，总之就是一个具体的存在。可以用一个 URI（**统一资源定位符**）指向它，每个资源都有对应的一个特定的 URI，要获取该资源时，只需要访问对应的 URI 即可。

- 表现层（Representation）

资源具体呈现出来的形式，比如文本可以用 txt 格式表示，也可以用 HTML、XML、JSON等格式来表示。

- 状态转换（State Transfer）

每发出一次请求就是客户端和服务器进行一次交互，HTTP 协议是无状态的协议，所有的状态都保存在服务端，**因此客户端如果希望操作服务器中的某个资源，就需要通过某种方式让服务端发生状态转换**，而这种转换是建立在表现层之上的，所有叫做"表现层状态转换"。



#### 特点

- URL 更加简洁。
- 有利于不同系统之间的资源共享，只需要遵守一定的规范，不需要进行其他配置即可实现资源共享。



#### 如何使用

REST 具体操作就是 HTTP 协议中四个表示操作方式的动词分别对应 **CRUD** 基本操作。

GET 用来表示获取资源。

POST 用来表示新建资源。

PUT 用来表示修改资源。

DELETE 用来表示删除资源。



1）Student

这两个注解用于生成构造方法：

@AllArgsConstructor
@NoArgsConstructor

```java
@Data
@AllArgsConstructor
@NoArgsConstructor
public class Student {

    private long id;
    private String name;
    private int age;
}
```



2）StudentRepository

先写接口

```java
package com.southwind.repository;

import com.southwind.entity.Student;

import java.util.Collection;

public interface StudentRepository {
    public Collection<Student> findAll();
    public Student findById(long id);
    public void saveOrUpdate(Student student);
    public void deleteById(long id);
}
```



3）StudentRepositoryImpl

再写接口对应的实现类

```java
@Repository
public class StudentRepositoryImpl implements StudentRepository {

    // 添加集合用于模拟数据库，但需要给 student 类加上构造方法
    private static Map<Long,Student> studentMap;

    static{
        studentMap = new HashMap<>();
        studentMap.put(1L,new Student(1L,"张三",22));
        studentMap.put(2L,new Student(2L,"李四",23));
        studentMap.put(3L,new Student(3L,"王五",24));
    }

    @Override
    public Collection<Student> findAll() {
        return studentMap.values();
    }

    @Override
    public Student findById(long id) {
        return studentMap.get(id);
    }

    @Override
    public void saveOrUpdate(Student student) {
        studentMap.put(student.getId(),student);
    }

    @Override
    public void deleteById(long id) {
        studentMap.remove(id);
    }
}
```

现在需要把 StudentRepositoryImpl 注入到 handler，

① 使用注解 @Repository，交给 IOC

② springmvc.xml 中配置了扫描器

先在 IOC 里面就有了实例了

③ private StudentRepository studentRepository; 注入



4）Handler

```java
@RestController
@RequestMapping("/rest")
public class RESTHandeler {

    @Autowired
    private StudentRepository studentRepository;

    // 这是一个同步请求，需要手动设置编码格式，而异步请求可以在springmvc.xml中设置
    @GetMapping("/findAll")
    public Collection<Student> findAll(HttpServletResponse response){
        response.setContentType("text/json;charset=UTF-8");
        return studentRepository.findAll();
    }

    @GetMapping("/findById/{id}")
    public Student findById(@PathVariable("id") long id){
        return studentRepository.findById(id);
    }

    @PostMapping("/save")
    public void save(@RequestBody Student student){
        studentRepository.saveOrUpdate(student);
    }

    @PutMapping("/update")
    public void update(@RequestBody Student student){
        studentRepository.saveOrUpdate(student);
    }

    @DeleteMapping("/deleteById/{id}")
    public void deleteById(@PathVariable("id") long id){
        studentRepository.deleteById(id);
    }

}
```















## Spring MVC 文件上传下载

### 一、单文件上传

底层是使用 Apache fileupload 组件完成上传，Spring MVC 对这种方式进行了封装。

***原理：***

通过**IO流**和**网络请求**来实现的，上传就是把客户端的资源通过网络请求传到服务器，服务器通过**input流**读进程序里，再通过**output流**保存到服务器

下载是服务器从本地把文件通过输入流

- pom.xml

```xml
<dependency>
    <groupId>commons-io</groupId>
    <artifactId>commons-io</artifactId>
    <version>2.5</version>
</dependency>

<dependency>
    <groupId>commons-fileupload</groupId>
    <artifactId>commons-fileupload</artifactId>
    <version>1.3.3</version>
</dependency>
```

- JSP

```html
<%--
  Created by IntelliJ IDEA.
  User: southwind
  Date: 2019-03-15
  Time: 09:09
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page isELIgnored="false" %>
<html>
<head>
    <title>Title</title>
</head>
<body>
    <form action="/file/upload" method="post" enctype="multipart/form-data">
        <input type="file" name="img"/>
        <input type="submit" value="上传"/>
    </form>
   <!-- 读图片-->
    <img src="${path}">
</body>
</html>
```

1、input 的 type 设置为 file。

2、form 的 method 设置为 **post**（get 请求只能将文件名传给服务器）

3、from 的 enctype 设置为 **multipart-form-data**（如果不设置只能将文件名传给服务器）

> 点击`提交`之后，会把所选文件**以二进制的形式**传到业务代码

- Handler

MultipartFile 把客户端传过来的二进制数据封装成一个对象

```java
package com.southwind.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import java.io.File;
import java.io.IOException;

@Controller
@RequestMapping("/file")
public class FileHandler {

    @PostMapping("/upload")
    public String upload(MultipartFile img, HttpServletRequest request){
        if(img.getSize()>0){
            // 获取保存上传文件的file路径
            String path = request.getServletContext().getRealPath("file");
            // 获取上传的文件名
            String name = img.getOriginalFilename();
            // 在 path 里面 创建一个名为 name 的空文件 file
            File file = new File(path,name);
            try {
                // 把 img 的数据赋给 file
                // 这是 springmvc 封装的输入输出流
                img.transferTo(file);
                //保存上传之后的文件路径,再从 jsp 中读出
                request.setAttribute("path","/file/"+name);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        return "upload";
    }
}
```

- springmvc.xml

```xml
<!-- 配置上传组件 -->
<bean id="multipartResolver" class="org.springframework.web.multipart.commons.CommonsMultipartResolver"></bean>
```

- web.xml 添加如下配置，否则客户端无法访问 png

```xml
<servlet-mapping>
    <servlet-name>default</servlet-name>
    <url-pattern>*.png</url-pattern>
</servlet-mapping>
```







### 二、多文件上传

**单文件传一个对象，多文件传一个数组**

pom.xml

```xml
<dependency>
    <groupId>jstl</groupId>
    <artifactId>jstl</artifactId>
    <version>1.2</version>
</dependency>

<dependency>
    <groupId>taglibs</groupId>
    <artifactId>standard</artifactId>
    <version>1.1.2</version>
</dependency>
```

JSP

```html
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>Title</title>
</head>
<body>
    <form action="/file/uploads" method="post" enctype="multipart/form-data">
        file1:<input type="file" name="imgs"/><br/>
        file2:<input type="file" name="imgs"/><br/>
        file3:<input type="file" name="imgs"><br/>
        <input type="submit" value="上传"/>
    </form>
    <c:forEach items="${files}" var="file" >
        <img src="${file}" width="300px">
    </c:forEach>
</body>
</html>
```

Handler

```java
@PostMapping("/uploads")
public String uploads(MultipartFile[] imgs,HttpServletRequest request){
    List<String> files = new ArrayList<>();
    for (MultipartFile img:imgs){
        if(img.getSize()>0){
            //获取保存上传文件的file绝对路径
            String path = request.getServletContext().getRealPath("file");
            //获取上传的文件名
            String name = img.getOriginalFilename();
            File file = new File(path,name);
            try {
                img.transferTo(file);
                //保存上传之后的文件路径
                files.add("/file/"+name);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
    request.setAttribute("files",files);
    return "uploads";
}
```





### 三、下载

- JSP

```html
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Title</title>
</head>
<body>
    <a href="/file/download/1">1.png</a>
    <a href="/file/download/2">2.png</a>
    <a href="/file/download/3">3.png</a>
</body>
</html>
```

- Handler

```java
@GetMapping("/download/{name}")
public void download(@PathVariable("name") String name, HttpServletRequest request, HttpServletResponse response){
    if(name != null){
        name += ".png";
        // 获取 file 的绝对路径
        String path = request.getServletContext().getRealPath("file");
        // 把 path路径 里的 name 文件取出来
        File file = new File(path,name);
        OutputStream outputStream = null;
        if(file.exists()){
            response.setContentType("application/forc-download");
            // 设置下载后的文件名
            response.setHeader("Content-Disposition","attachment;filename="+name);
            try {
                outputStream = response.getOutputStream();
                outputStream.write(FileUtils.readFileToByteArray(file));
                outputStream.flush();
            } catch (IOException e) {
                e.printStackTrace();
            } finally {
                if(outputStream != null){
                    try {
                        outputStream.close();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }
        }
    }
}
```









## Spring MVC 表单标签库

控制层返回模型数据到视图层，视图层需要用 el 表达式将模型数据绑定到页面，原来的写法是：

### 不使用标签

```java
@Controller
@RequestMapping("/tag")
public class TagHandler {

    @GetMapping("/get")
    public ModelAndView get(){
        ModelAndView modelAndView = new ModelAndView("show");
        Student student = new Student(1L, "张三", 22);
        modelAndView.addObject("student",student);
        return modelAndView;
    }
}
```

```html
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page isELIgnored="false" %>
<html>
<head>
    <title>Title</title>
</head>
<body>
<h1>学生信息</h1>
    <form>
        学生ID：<input type="text" name="id" value="${student.id}"/><br/>
        学生姓名：<input type="text" name="name" value="${student.name}"/><br/>
        学生年龄：<input type="text" name="age" value="${student.age}"/><br/>
        <input type="submit" value="提交">
    </form>
</body>
</html>
```

启动后可以在客户端拿到

![](..\images\TIM截图20200208161650.png)



### 使用标签

- Handler

```java
@GetMapping("/get")
public ModelAndView get(){
    ModelAndView modelAndView = new ModelAndView("tag");
    Student student = new Student(1L,"张三",22);
    modelAndView.addObject("student",student);
    return modelAndView;
}
```

- JSP

```html
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<html>
<head>
    <title>Title</title>
</head>
<body>
    <h1>学生信息</h1>
    <form:form modelAttribute="student">
        学生ID：<form:input path="id"/><br/>
        学生姓名：<form:input path="name"/><br/>
        学生年龄：<form:input path="age"/><br/>
        <input type="submit" value="提交"/>
    </form:form>
</body>
</html>
```

1、JSP 页面导入 Spring MVC 表单标签库，与导入 JSTL 标签库的语法非常相似，前缀 prefix 可以自定义，通常定义为 form。

```html
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
```

2、将 form 表单与模型数据进行绑定，通过 **modelAttribute** 属性完成绑定，将 modelAttribute 的值设置为模型数据对应的 key 值。

```java
Handeler:modelAndView.addObject("student",student);
JSP:<form:form modelAttribute="student">
```

3、form 表单完成绑定之后，将模型数据的值取出绑定到不同的标签中，通过设置标签的 path 属性完成，将 path 属性的值设置为模型数据对应的属性名即可。

```html
学生ID：<form:input path="id"/><br/>
学生姓名：<form:input path="name"/><br/>
学生年龄：<form:input path="age"/><br/>
```



### 常用的表单标签

- #### form

第一个form是上面定义的别名；
第二个form是调用表单标签库里的组件
modelAttribute 可以直接和handler里返回的模型数据绑定

```html
<form:form modelAttribute="student"/>
```

渲染的是 HTML 中的`<form></from>`，通过 modelAttribute 属性绑定具体的模型数据。

- #### input

path 是绑定对象的属性

```html
<form:input path="name"/>
```

渲染的是 HTML 中的 `<input type="text"/>`，from 标签绑定的是模型数据，input 标签绑定的是模型数据中的属性值，通过 path 属性可以与模型数据中的属性名对应，并且支持及联操作。

```html
<form:input path="address.name"/>
```

- #### password

```html
<form:password path="password"/>
```

渲染的是 HTML 中的 `<input type="password"/>`，通过 path 属性与模型数据的属性值进行绑定，password 标签的值不会在页面显示。

- #### checkbox

```html
<form:checkbox path="hobby" value="读书"/>
```

```java
student.setFlag(false);
```

```html
checkbox：<form:checkbox path="flag" value="flag"></form:checkbox><br/>
```

渲染的是 HTML 中的 `<input type="checkbox"/>`，通过 path 与模型数据的属性值进行绑定，可以绑定 boolean、数组和集合。

如果绑定 boolean 值，若该变量的值为 true，则表示该复选框选中，否则表示不选中。

如果绑定数组或者集合，数组/集合中的元素等于 checkbox 的 value 值，则选中。

```java
student.setHobby(Arrays.asList("读书","看电影","玩游戏"));
modelAndView.addObject("student",student);
```

```html
爱好：<form:checkbox path="hobby" value="摄影"></form:checkbox>摄影<br/>
<form:checkbox path="hobby" value="读书"></form:checkbox>读书<br/>
<form:checkbox path="hobby" value="听音乐"></form:checkbox>听音乐<br/>
<form:checkbox path="hobby" value="看电影"></form:checkbox>看电影<br/>
<form:checkbox path="hobby" value="旅游"></form:checkbox>旅游<br/>
<form:checkbox path="hobby" value="玩游戏"></form:checkbox>玩游戏<br/>
<input type="submit" value="提交"/>
```

- #### checkboxes

```html
<form:checkboxes items=${student.hobby} path="selecHobby"/>
```

渲染的是 HTML 中的一组 `<input type="checkbox"/>`，是对 `<form:checkbox/>` 的一种简化，需要结合 items 和 path 属性来使用，items 绑定被遍历的集合或数组，path 绑定被选中的集合或数组，可以这样理解，items 为全部可选集合，path 为默认的选中集合。

```java
student.setHobby(Arrays.asList("摄影","读书","听音乐","看电影","旅游","玩游戏"));
student.setSelectHobby(Arrays.asList("摄影","读书","听音乐"));
modelAndView.addObject("student",student);
```

```html
爱好：<form:checkboxes path="selectHobby" items="${student.hobby}"/><br/>
```

需要注意的是 path 可以直接绑定模型数据的属性值，items 则需要通过 EL 表达式的形式从域对象中获取数据，不能直接写属性名。

- #### rabiobutton

```html
<from:radiobutton path="radioId" value="0"/>
```

渲染的是 HTML 中的一个 `<input type="radio"/>`，绑定的数据与标签的 value 值相等则为选中，否则不选中。

```java
student.setRadioId(1);
modelAndView.addObject("student",student);
```

```html
radiobutton:<form:radiobutton path="radioId" value="1"/>radiobutton<br/>
```

- #### radiobuttons

```html
<form:radiobuttons itmes="${student.grade}" path="selectGrade"/>
```

渲染的是 HTML 中的一组 `<input type="radio"/>`，这里需要结合 items 和 path 两个属性来使用，items 绑定被遍历的集合或数组，path 绑定被选中的值，items 为全部的可选类型，path 为默认选中的选项，用法与 `<form:checkboxes/>` 一致。

```java
Map<Integer,String> gradeMap = new HashMap<>();
gradeMap.put(1,"一年级");
gradeMap.put(2,"二年级");
gradeMap.put(3,"三年级");
gradeMap.put(4,"四年级");
gradeMap.put(5,"五年级");
gradeMap.put(6,"六年级");
student.setGradeMap(gradeMap);
student.setSelectGrade(3);
modelAndView.addObject("student",student);
```

```html
学生年级：<form:radiobuttons items="${student.gradeMap}" path="selectGrade"/><br/>
```

- #### select

```html
<form:select items="${student.citys}" path="selectCity"/>
```

渲染的是 HTML 中的一个 `<select/>` 标签，需要结合 items 和 path 两个属性来使用，items 绑定被遍历的集合或数组，path 绑定被选中的值，用法与 `<from:radiobuttons/>`一致。

```java
Map<Integer,String> cityMap = new HashMap<>();
cityMap.put(1,"北京");
cityMap.put(2,"上海");
cityMap.put(3,"广州");
cityMap.put(4,"深圳");
student.setCityMap(cityMap);
student.setSelectCity(3);
modelAndView.addObject("student",student);
```

```html
所在城市：<form:select items="${student.cityMap}" path="selectCity"></form:select><br/>
```

- #### options

`form:select` 结合 `form:options` 的使用，`from:select` 只定义 path 属性，在 `form:select` 标签内部添加一个子标签 `form:options` ，设置 items 属性，获取被遍历的集合。

```html
所在城市：<form:select path="selectCity">
  				<form:options items="${student.cityMap}"></form:options>
				</form:select><br/>
```

- #### option

  `form:select` 结合 `form:option` 的使用，`from:select` 定义 path 属性，给每一个 `form:option` 设置 value 值，path 的值与哪个 value 值相等，该项默认选中。

```html
所在城市：<form:select path="selectCity">
            <form:option value="1">杭州</form:option>
            <form:option value="2">成都</form:option>
            <form:option value="3">西安</form:option>
        </form:select><br/>
```

- #### textarea

渲染的是 HTML 中的一个 `<textarea/>` ，path 绑定模型数据的属性值，作为文本输入域的默认值。

```java
student.setIntroduce("你好，我是...");
modelAndView.addObject("student",student);
```

```html
信息：<form:textarea path="introduce"/><br/>
```

- #### errors

处理错误信息，一般用在数据校验，该标签需要结合 Spring MVC 的验证器结合起来使用。









## Spring MVC 数据校验

对用户提交的数据进行验证，一般会在前端进行验证，比如非空，正则。但也可以在后台再次验证。

Spring MVC 提供了两种数据校验的方式：

1、基于 Validator 接口：

需要自定义 Validator 验证器，每一条数据的验证规则需要开发者手动完成。

2、使用 Annotation JSR - 303 标准进行校验：

不需要自定义验证器，通过注解的方式可以直接在实体类中添加每个属性的验证规则，这种方式更加方便，实际开发中推荐使用。





### 一、基于 Validator 接口

- 实体类 Account

```java
package com.southwind.entity;

import lombok.Data;

@Data
public class Account {
    private String name;
    private String password;
}
```

- 自定义验证器 AccountValidator，实现 Validator 接口。

```java
package com.southwind.validator;

import com.southwind.entity.Account;
import org.springframework.validation.Errors;
import org.springframework.validation.ValidationUtils;
import org.springframework.validation.Validator;

public class AccountValidator implements Validator {
    
   /**
     * 对要被验证的数据类型进行检测，判断是否支持
     * 判断 传进来的对象是不是 Account 类型
     * 因为传的参数是运行时类，判断 aClass 和 Account 是否相等就行
     * @param aClass 运行时类
     * @return true 执行validate()
     *          false 不执行validate()
     */
    @Override
    public boolean supports(Class<?> aClass) {
        return Account.class.equals(aClass);
    }

    
   /**
     * 具体验证方法
     * 一旦出错，验证器就会给前台返一个对象errors
     * @param o
     * @param errors 存放错误信息
     *
     */
    @Override
    public void validate(Object o, Errors errors) {
        ValidationUtils.rejectIfEmpty(errors,"name",null,"姓名不能为空");
        ValidationUtils.rejectIfEmpty(errors,"password",null,"密码不能为空");
    }
}
```

- 控制器

```java
package com.southwind.controller;

import com.southwind.entity.Account;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/validator")
public class ValidatorHandler {

   /**
     * 给前台绑定模型数据，不需要有数据，把空对象传给 login.jsp，modelAttribute 才能绑定起来
     * @param model
     * @return
     */
    @GetMapping("/login")
    public String login(Model model){
        model.addAttribute("account",new Account());
        return "login";
    }

   /**
     * 然后前台页面点击 登录 ， post 请求，
     * 这里的 account 就是 modelAttribute 绑定的，已经进行验证了
     * @param account
     * @return
     */
    @PostMapping("/login")
    public String login(@Validated Account account, BindingResult bindingResult){
        if(bindingResult.hasErrors()){
            return "login";
        }
        return "index";
    }
}
```

- springmvc.xml 配置验证器。

```xml
<bean id="accountValidator" class="com.southwind.validator.AccountValidator"></bean>
<mvc:annotation-driven validator="accountValidator"></mvc:annotation-driven>
```

- JSP

```html
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="from" uri="http://www.springframework.org/tags/form" %>
<html>
<head>
    <title>Title</title>
</head>
<body>
    <form:form modelAttribute="account" action="/validator/login" method="post">
        姓名：<form:input path="name"/><from:errors path="name"></from:errors><br/>
        密码：<form:input path="password"/><from:errors path="password"></from:errors><br/>
        <input type="submit" value="登录"/>
    </form:form>
</body>
</html>
```





### 二、Annotation JSR - 303 标准

使用 Annotation JSR - 303 标准进行验证，需要导入支持这种标准的依赖 jar 文件，这里我们使用 Hibernate Validator。

- pom.xml

```xml
<!-- JSR-303 -->
<dependency>
  <groupId>org.hibernate</groupId>
  <artifactId>hibernate-validator</artifactId>
  <version>5.3.6.Final</version>
</dependency>

<dependency>
  <groupId>javax.validation</groupId>
  <artifactId>validation-api</artifactId>
  <version>2.0.1.Final</version>
</dependency>

<dependency>
  <groupId>org.jboss.logging</groupId>
  <artifactId>jboss-logging</artifactId>
  <version>3.3.2.Final</version>
</dependency>
```

- 通过注解的方式直接在实体类中添加相关的验证规则。

```java
package com.southwind.entity;

import lombok.Data;
import org.hibernate.validator.constraints.Email;
import org.hibernate.validator.constraints.NotEmpty;
import javax.validation.constraints.Pattern;
import javax.validation.constraints.Size;

@Data
public class Person {
    @NotEmpty(message = "用户名不能为空")
    private String username;
    @Size(min = 6,max = 12,message = "密码6-12位")
    private String password;
    @Email(regexp = "^[a-zA-Z0-9_.-]+@[a-zA-Z0-9-]+(\\\\.[a-zA-Z0-9-]+)*\\\\.[a-zA-Z0-9]{2,6}$",message = "请输入正确的邮箱格式")
    private String email;
    @Pattern(regexp = "^((13[0-9])|(14[5|7])|(15([0-3]|[5-9]))|(18[0,5-9]))\\\\\\\\d{8}$",message = "请输入正确的电话")
    private String phone;
}
```

- ValidatorHandler

```java
@GetMapping("/register2")
public String register(Model model){
    model.addAttribute("person",new Person());
    return "register2";
}

@PostMapping("/register2")
public String register(@Valid Person person, BindingResult bindingResult){
    if(bindingResult.hasErrors()){
        return "register2";
    }
    return "index";
}
```

- springmvc.xml

```xml
    <mvc:annotation-driven></mvc:annotation-driven>
```

- JSP

```html
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<html>
<head>
    <title>Title</title>
</head>
<body>
    <form:form modelAttribute="person" action="/validator/register2" method="post">
        用户名：<form:input path="username"></form:input><form:errors path="username"/><br/>
        密码：<form:password path="password"></form:password><form:errors path="password"/><br/>
        邮箱：<form:input path="email"></form:input><form:errors path="email"/><br/>
        电话：<form:input path="phone"></form:input><form:errors path="phone"/><br/>
        <input type="submit" value="提交"/>
    </form:form>
</body>
</html>
```

##### 校验规则详解：

@Null					被注解的元素必须为null

@NotNull				  被注解的元素不能为null

@Min(value)			     被注解的元素必须是一个数字，其值必须大于等于指定的最小值

@Max(value)			    被注解的元素必须是一个数字，其值必须小于于等于指定的最大值	

@Email				     被注解的元素必须是电子邮箱地址

@Pattern				  被注解的元素必须符合对应的正则表达式

@Length				   被注解的元素的大小必须在指定的范围内

@NotEmpty			      被注解的字符串的值必须非空

Null 和 Empty 是不同的结果，String str = null，str 是 null，String str = ""，str 不是 null，其值为空。


## HandlerMethodArgumentResolver 解析器
问：在享受Spring MVC带给你便捷的时候，你是否曾经这样疑问过：Controller的handler方法参数能够自动完成参数封装（有时即使没有@PathVariable、@RequestParam、@RequestBody等注解都可）？ 
答：**HandlerMethodArgumentResolver**

策略接口：用于在**给定请求上下文中**将方法参数解析为参数值，也就是处理**Handler**方法里的**所有入参**

HandlerMethodArgumentResolver = HandlerMethod + Argument(参数) + Resolver(解析器)

解释为：它是HandlerMethod方法的解析器，将HttpServletRequest(header + body 中的内容)解析为HandlerMethod方法的参数

![](..\images\springmvc1.png)

源码
```java
// @since 3.1   HandlerMethod 方法中 参数解析器
public interface HandlerMethodArgumentResolver {

	// 判断 HandlerMethodArgumentResolver 是否支持 MethodParameter
	// (PS: 一般都是通过 参数上面的注解|参数的类型)
	boolean supportsParameter(MethodParameter parameter);
	
    /**
     * 真正用于处理参数分解的方法
     * @param parameter     请求参数
     * @param mavContainer  ModelAndViewContainer用来提供访问Model
     * @param webRequest    从NativeWebRequest中获取数据
     * @param binderFactory 用于创建一个WebDataBinder用于数据绑定、校验
     * @return  controller方法上的形参对象
     * @throws Exception
     */
	@Nullable
	Object resolveArgument(MethodParameter parameter, @Nullable ModelAndViewContainer mavContainer, NativeWebRequest webRequest, @Nullable WebDataBinderFactory binderFactory) throws Exception;
}
```

可以自己实现这个接口，把从请求拿到的参数，封装成controller方法入参实体
