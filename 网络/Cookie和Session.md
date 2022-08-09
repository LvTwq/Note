[TOC]

# Cookie

![](..\images\cookie1.png)

## 一、cookie是什么

* 浏览器 里面能永久存储的一种数据，是浏览器实现的一种数据存储功能
* 由**服务器生成，发送给浏览器**，浏览器把cookie以**k/v形式**保存到某个目录的文本文件内
  * 当客户端要发送HTTP请求时，浏览器会先检查下是否有对应的cookie。有的话，则**自动**地添加在request header中的cookie字段。注意，每一次的HTTP请求时，如果有cookie，浏览器都会**自动**带上cookie发送给服务端。
  * 那么把什么数据放到cookie中就很重要了，因为很多数据并不是每次请求都需要发给服务端，毕竟会增加网络开销，浪费带宽。所以对于那设置“**每次请求都要携带的信息（最典型的就是身份认证信息）**”就特别适合放在cookie中，其他类型的数据就不适合了
* 由于cookie是存在客户端上的，所以浏览器加了一些限制，确保cookie不会被恶意使用，同时不会占据太多磁盘空间，所以每个域的cookie数量是有限的

简单的说就是：

(1) cookie是以小的文本文件形式（即纯文本），完全存在于客户端；cookie保存了**登录的凭证**，有了它，只需要在下次请求时带着cookie发送，就不必再重新输入用户名、密码等重新登录了。

(2) 是设计用来在**服务端**和**客户端**进行**信息传递**的

## 二、cookie的属性

在浏览器的控制台中，可以直接输入：document.cookie来查看cookie。cookie是一个由键值对构成的字符串，每个键值对之间是“; ”即一个分号和一个空格隔开。

注意，这个方法只能获取非 HttpOnly 类型的cookie

每个cookie都有一定的属性，如什么时候失效，要发送到哪个域名，哪个路径等等。这些属性是通过cookie选项来设置的，cookie选项包括：expires、domain、path、secure、HttpOnly。在设置任一个cookie时都可以设置相关的这些属性，当然也可以不设置，这时会使用这些属性的默认值。在设置这些属性时，属性之间由一个分号和一个空格隔开。代码示例如下：

```javascript
"key=name; expires=Sat, 08 Sep 2018 02:26:00 GMT; domain=ppsc.sankuai.com; path=/; secure; HttpOnly"
```

cookie的属性可以在控制台查看：Application选项，左边选择Storage，最后一个就是cookie，点开即可查看。

- Expires、Max Age:

Expires选项用来设置“cookie 什么时间内有效”。Expires其实是cookie失效日期，Expires必须是 GMT 格式的时间（可以通过 new Date().toGMTString()或者 new Date().toUTCString() 来获得）。

如expires=Sat, 08 Sep 2018 02:26:00 GMT表示cookie将在2018年9月8日2:26分之后失效。对于失效的cookie浏览器会清空。如果没有设置该选项，这样的cookie称为会话cookie。它存在内存中，当会话结束，也就是浏览器关闭时，cookie消失。

补充：

>Expires是 http/1.0协议中的选项，在http/1.1协议中Expires已经由 Max age 选项代替，两者的作用都是限制cookie 的有效时间。Expires的值是一个时间点（cookie失效时刻= Expires），而Max age的值是一个以秒为单位时间段（cookie失效时刻= 创建时刻+ Max age）。 另外， Max age的默认值是 -1(即有效期为 session )； Max age有三种可能值：负数、0、正数。
>
>负数：有效期session；关闭浏览器就删除cookie
>
>0：立刻删除cookie，无需等待浏览器关闭；
>
>正数：有效期为创建时刻+ Max age

- Domain和Path

Domain是域名，Path是路径，两者加起来就构成了 URL，Domain和Path一起来**限制 cookie 能被哪些 URL 访问**。即请求的URL是Domain或其子域、且URL的路径是Path或子路径，则都可以访问该cookie，例如：

某cookie的 Domain为“baidu.com”, Path为“/ ”，若请求的URL(URL 可以是js/html/img/css资源请求，但不包括 XHR 请求)的域名是“baidu.com”或其子域如“api.baidu.com”、“dev.api.baidu.com”，且 URL 的路径是“/ ”或子路径“/home”、“/home/login”，则都可以访问该cookie。

补充：

> 发生跨域xhr请求时，即使请求URL的域名和路径都满足 cookie 的 Domain和Path，默认情况下cookie也不会自动被添加到请求头部中。

- Size

Cookie的大小

- Secure

Secure选项用来设置cookie只在确保安全的请求中才会发送。当请求是HTTPS或者其他安全协议时，包含 Secure选项的 cookie 才能被发送至服务器。

默认情况下，cookie不会带Secure选项(即为空)。所以默认情况下，不管是HTTPS协议还是HTTP协议的请求，cookie 都会被发送至服务端。但要注意一点，Secure选项只是限定了在安全情况下才可以传输给服务端，但并不代表你不能看到这个 cookie。

补充：

> 如果想在客户端即网页中通过 js 去设置Secure类型的 cookie，必须保证网页是https协议的。在http协议的网页中是无法设置secure类型cookie的。

- httpOnly

这个选项用来设置cookie是否能通过 js 去访问。默认情况下，cookie不会带httpOnly选项(即为空)，所以默认情况下，客户端是可以通过js代码去访问（包括读取、修改、删除等）这个cookie的。**当cookie带httpOnly选项时，客户端则无法通过js代码去访问（包括读取、修改、删除等）这个cookie。**

这种类型的cookie只能通过服务端来设置。

之所以限制客户端去访问cookie，主要还是出于安全的目的。因为如果任何 cookie 都能被客户端通过document.cookie获取，那么假如合法用户的网页受到了XSS攻击，有一段恶意的script脚本插到了网页中，这个script脚本，通过document.cookie读取了用户身份验证相关的 cookie，那么只要原样转发cookie，就可以达到目的了。

在代码中把这个属性设为true就行了

```yml
server:
  port: 2012
  servlet:
    session:
      cookie:
        name: ajslNew
        http-only: true
    context-path: /ajslbl（这是服务的根路径，不是Application中的Path）
```



## 三、cookie的设置、读取，删除方法

### 1、服务端设置cookie

**客户端第一次向服务端请求时，在相应的响应头中就有set-cookie字段**，用来标识是哪个用户。

（Response Headers）响应头中有两个set-cookie字段，每段对应一个cookie，注意每个cookie放一个set-cookie字段中，不能将多个cookie放在一个set-cookie字段中。具体每个cookie设置了相关的属性：expires、path、httponly

服务端可以设置cookie 的所有选项：expires、domain、path、secure、HttpOnly

### 2、客户端设置cookie

cookie不像web Storage有setItem，getItem，removeItem，clear等方法，需要自己封装。简单地在浏览器的控制台里输入：

```javascript
document.cookie = "name=lynnshen; age=18"
document.cookie = "name=lynnshen";
document.cookie = "age=18";
```

```javascript
// 设置cookie
function setCookie(name,value,iDay){
    var oDate = new Date();
    oDate.setDate(oDate.getDate() + iDay);
    document.cookie = name + "=" + value + ";expires=" + oDate;
}
// 读取cookie，该方法简单地认为cookie中只有一个“=”，即key=value，如有更多需求可以在此基础上完善:
function getCookie(name){
    //例如cookie是"username=abc; password=123"
    var arr = document.cookie.split('; ');//用“;”和空格来划分cookie
    for(var i = 0 ;i < arr.length ; i++){
        var arr2 = arr[i].split("=");
        if(arr2[0] == name){
            return arr2[1];
        }
    }
    return "";//整个遍历完没找到，就返回空值
}

//删除cookie:
function removeCookie(name){
    setCookie(name, "1", -1)//第二个value值随便设个值，第三个值设为-1表示：昨天就过期了，赶紧删除
}
```



## 四、cookie的缺点

1) 每个特定域名下的cookie数量有限：

IE6或IE6-(IE6以下版本)：最多20个cookie

IE7或IE7+(IE7以上版本)：最多50个cookie

FF:最多50个cookie

Opera:最多30个cookie

Chrome和safari没有硬性限制

当超过单个域名限制之后，再设置cookie，浏览器就会清除以前设置的cookie。IE和Opera会清理近期最少使用的cookie，FF会随机清理cookie；

(2) 存储量太小，只有4KB；

(3) 每次HTTP请求都会发送到服务端，影响获取资源的效率；

(4) 需要自己封装获取、设置、删除cookie的方法；



## 免用户名登录

![](..\images\cookie2.png)



# Session

1、是一个接口（HttpSession）

2、是会话，用来维护客户端和服务器之间关联的一种技术

3、每个客户端都有自己的一个session会话

4、session会话中，经常用来保存用户登录之后的信息

```java
// 创建和获取session会话对象
HttpSession session = request.getSession();
// 判断当前session会话是否是新创建的
boolean isNew = session.isNew();
// 获取session会话的唯一标识
String id = session.getId();
```

## 生命周期

session默认的超时时长为30分钟（在tomcat配置文件web.xml中配置的）

```xml
    <session-config>
        <session-timeout>30</session-timeout>
    </session-config>
```

如果要修改，也不要动tomcat的配置文件，修改自己工程的web.xml

![](..\images\session1.png)

![](..\images\session2.png)

Session技术，底层是基于Cookie来实现的

 



## cookie和session的区别

cookie是存在客户端浏览器上，session会话存在服务器上。会话对象用来存储特定用户会话所需的属性及配置信息。当用户请求来自应用程序的web页时，如果该用户还没有会话，则服务器将自动创建一个会话对象。当会话过期或被放弃后，服务器将终止该会话。cookie和会话需要配合

当cookie失效、session过期时，就需要重新登录了。



# localStorage和sessionStorage

在较高版本的浏览器中，js提供了两种存储方式：sessionStorage和globalStorage。在H5中，用localStorage取代了globalStorage。

sessionStorage用于本地存储一个会话中的数据，这些数据只有在同一个会话中的页面才能访问，并且当会话结束后，数据也随之销毁。所以sessionStorage仅仅是会话级别的存储，而不是一种持久化的本地存储。

localStorage是持久化的本地存储，除非是通过js删除，或者清除浏览器缓存，否则数据是永远不会过期的。

localStorage 属性是只读的。



# web storage和cookie的区别

(1) web storages和cookie的作用不同，web storage是用于本地大容量存储数据(web storage的存储量大到5MB);而cookie是用于客户端和服务端间的信息传递；

(2) web storage有setItem、getItem、removeItem、clear等方法，cookie需要我们自己来封装setCookie、getCookie、removeCookie

