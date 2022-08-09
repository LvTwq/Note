[TOC]

#### 简介

用于Web和独立环境的服务器端的java模板引擎，能够处理HTML,XML,javascript,CSS,纯文本；

使用的是Spring框架。



#### 步骤

1. 创建一个Maven项目

![1571622110705](..\images\1571622110705.png)

2. 设置工作目录
3. 选择原型（Archetype）

![1571622219483](..\images\1571622219483.png)

4. 完整目录结构如下









#### 标准方言

1. ##### 什么是标准方言

Thymeleaf是可扩展的，允许自定义一组模板属性（甚至是标签），用自定义语法评估计算表达式和应用逻辑。

***标准方言***，定义了一组功能，足以满足大多数情况，以“***th***”前缀开头的属性，如

```xml
<span th:text="...">
```



2. ##### 标准表达式语法

大多数Thymeleaf属性允许将他们的值设置为包含表达式，由于使用的是方言，称为标准表达式，共有5种类型

- `${...}` : 变量表达式。
- `*{...}` : 选择表达式。
- `#{...}` : 消息 (i18n) 表达式。
- `@{...}` : 链接 (URL) 表达式。
- `~{...}` : 片段表达式。

###### 2.1）变量表达式

变量表达式是OGNL表达式，看起来是这样：

> ${session.user.name}

它们作为属性值或作为它们的一部分，取决于属性

```html
<span th:text="${book.author.name}">
```

在OGNL中，这么写是相同的

```html
((Book)context.getVariable("book")).getAuthor().getName()
```

在不涉及输出的场景中找到变量表达式，还可以使用更复杂的处理方式，比如条件，迭代

```xml
<li th:each="book : ${books}">
```

这里的${books} 从上下文选择名为 books 的变量，并在 th:each 中使用循环将其评估为迭代器



###### 2.2）选择表达式

不是在整个上下文变量映射上执行，而是在先前选择的对象。

> *{customer.name}

它们做作用的对象由 th:object 属性指定

```xml
<div th:object="${book}">
  ...
  <span th:text="*{title}">...</span>
  ...
</div>
```

所以，相当于

```java
{
  // th:object="${book}"
  final Book selection = (Book) context.getVariable("book");
  // th:text="*{title}"
  output(selection.getTitle());
}
```



###### 2.3）消息表达式

允许从外部源（如：.properties）文件中检索特定语言环境的消息，通过键来引用这引用消息

在spring应用程序中，它将自动与Spring的MessageSource机制集成

```xml
#{main.title}
#{message.entrycreated(${entryId})}
```

以下是在模板中使用的方式

```xml
<table>
  ...
  <th th:text="#{header.address.city}">...</th>
  <th th:text="#{header.address.country}">...</th>
  ...
</table>
```

注：如果希望消息键由上下文变量的值确定，或者希望将变量指定为参数，则可以在消息表达式中使用变量表达式

> #{${config.adminWelcomeKey}(${session.user.name})}





###### 2.4）链接（URL）表达式

在构建URL并向其添加有用的上下文和会话消息（通过称为URL重写的过程）。因此，对于部署在Web服务器的 /myapp 上下文的Web应用程序，可以使用以下表达式：

```xml
<a th:href="@{/order/list}">...</a>
```

可以转换为如下的：

```xml
<a href="/myapp/order/list">...</a>
```

甚至，如果需要保持会话，并且cookie未启用（或者服务器还不知道），那么生成的格式为：

```xml
<a href="/myapp/order/list;jsessionid=s2ds3fa31abd241e2a01932">...</a>
```

网址也可以带参数：

```xml
<a th:href="@{/order/details(id=${orderId},type=${orderType})}">...</a>
```

这将产生类似以下的结果

```xml
<!-- 注意＆符号会在标签属性中进行HTML转义... -->
<a href="/myapp/order/details?id=23&type=online">...</a>
```



















###### 2.5）片段表达式

片段表达式是一种简单的方法用来表示标记的片段并将其移动到模板中。由于这些表达式，片段可以被复制，传递给其他模板的参数等等

最常见的是使用 th:insert 或者 th:replace 来插入片段：

```xml
<div th:insert="~{commons :: main}">...</div>
```

但是它们可以在任何地方使用，就像任何其他变量一样：

```xml
<div th:with="frag=~{footer :: #main/text()}">
  <p th:insert="${frag}">
</div>
```

片段表达式可以有参数





###### 2.6）文字和操作

有很多类型的文字和操作可用，它们分别如下:

- 文字
  - 文本文字，例如:`'one text'`, `'Another one!'`,`…`
  - 数字文字，例如:`0`,`10`, `314`, `31.01`, `112.83`,`…`
  - 布尔文字，例如:`true`,`false`
  - Null文字，例如:`Null`
  - 文字标记，例如:`one`, `sometext`, `main`,`…`
- 文本操作:
  - 字符串连接:`+`
  - 文字替换:`|The name is ${name}|`
- 算术运算:
  - 二进制操作:`+`, `-`, `*`, `/`, `%`
  - 减号(一元运算符):`-`
- 布尔运算:
  - 二进制运算符，`and`,`or`
  - 布尔否定(一元运算符):`!`,`not`
- 比较和相等:
  - 比较运算符:`>`,`<`,`>=`,`<=`(`gt`,`lt`,`ge`,`le`)
  - 相等运算符:`==`, `!=` (`eq`, `ne`)
- 条件操作符:
  - If-then:`(if) ? (then)`
  - If-then-else:`(if) ? (then) : (else)`
  - Default: `(value) ?: (defaultvalue)`



###### 2.7）表达式预处理 

在 __ 之间指定，如下

> #{selection.\__${sel.code}__}

第一被执行的变量表达式是 \__{sel.code}__}，并且将使用他的结果作为表达式的一部分（假设${sel.code} 的结果为：ALL），将查找***selection.ALL*** 消息





3. ##### 基本的属性

***th:文本***，代表了标签的主体

```xml
<p th:text="#{msg.welcome}">Welcome everyone!</p>
```

***th:each***，重复他所在元素的次数，由它的表达式返回的数组或列表所指定的次数，由他的表达式返回的数组或列表所指定的次数，为迭代元素创建一个内部变量

```xml
<li th:each="book : ${books}" th:text="${book.title}">En las Orillas del Sar</li>
```

这些属性只评估他们的表达式，并将这些属性的值设置为结果

```xml
<form th:action="@{/createOrder}">
<input type="button" th:value="#{form.submit}" />
<a th:href="@{/admin/users}">
```

