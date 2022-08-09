[TOC]

# 一、工作原理
JavaScript 是浏览器的内置脚本语言。也就是说，浏览器内置了 JavaScript 引擎，并且提供各种接口，让 JavaScript 脚本可以控制浏览器的各种功能
浏览器加载 JavaScript 脚本，主要通过\<script>元素完成。正常的网页加载流程是这样的。

浏览器一边下载 HTML 网页，一边开始解析。也就是说，不等到下载完，就开始解析。
解析过程中，浏览器发现\<script>元素，就暂停解析，把网页渲染的控制权转交给 JavaScript 引擎。
如果\<script>元素引用了外部脚本，就下载该脚本再执行，否则就直接执行代码。
JavaScript 引擎执行完毕，控制权交还渲染引擎，恢复往下解析 HTML 网页。
加载外部脚本时，浏览器会暂停页面渲染，等待脚本下载并执行完成后，再继续渲染。原因是 JavaScript 代码可以修改 DOM，所以必须把控制权让给它，否则会导致复杂的线程竞赛的问题。

如果外部脚本加载时间很长（一直无法完成下载），那么浏览器就会一直等待脚本下载完成，造成网页长时间失去响应，浏览器就会呈现“假死”状态，这被称为“阻塞效应”。

为了避免这种情况，较好的做法是将\<script>标签都放在页面底部，而不是头部。这样即使遇到脚本失去响应，网页主体的渲染也已经完成了，用户至少可以看到内容，而不是面对一张空白的页面。如果某些脚本代码非常重要，一定要放在页面头部的话，最好直接将代码写入页面，而不是连接外部脚本文件，这样能缩短加载时间。

脚本文件都放在网页尾部加载，还有一个好处。因为在 DOM 结构生成之前就调用 DOM 节点，JavaScript 会报错，如果脚本都在网页尾部加载，就不存在这个问题，因为这时 DOM 肯定已经生成了。


# 二、基本数据类型
## number
整数和小数（比如1和3.14）。
## string
文本（比如Hello World）。
## boolean
表示真伪的两个特殊值，即true（真）和false（假）。
## undefined
表示“未定义”或不存在
即由于目前没有定义，所以此处暂时没有任何值。
## null
表示空值，即此处的值为空。
## object
各种值组成的集合
### 狭义的对象（object）
### 数组（array）
### 函数（function）


# 三、操作符、语句、变量
算术运算符、比较运算符、布尔运算符

# 四、操作DOM
DOM 是 JavaScript 操作网页的接口，全称为“文档对象模型”（Document Object Model）。它的作用是将网页转为一个 JavaScript 对象，从而可以用脚本进行各种操作（比如增删内容）。
浏览器原生提供**document**节点，代表整个文档
document节点对象代表整个文档，每张网页都有自己的document对象
## 节点集合属性

## 文档静态属性
* document.location
Location对象是浏览器提供的原生对象，提供 URL 相关的信息和操作方法。通过window.location和document.location属性，可以拿到这个对象。

## 文档状态属性
* document.cookie
用来操作浏览器 Cookie


## 方法
* document.open()，document.close()
document.open方法清除当前文档所有内容，使得文档处于可写状态，供document.write方法写入内容。
document.close方法用来关闭document.open()打开的文档。

* document.getElementsByTagName()
搜索 HTML 标签名，返回符合条件的元素。它的返回值是一个类似数组对象

## Element节点
Element节点对象对应网页的 HTML 元素。每一个 HTML 元素，在 DOM 树上都会转化成一个Element节点对象（以下简称元素节点）

元素对象有一个attributes属性，返回一个类似数组的动态对象，成员是该元素标签的所有属性节点对象，属性的实时变化都会反映在这个节点对象上。其他类型的节点对象，虽然也有attributes属性，但返回的都是null，因此可以把这个属性视为元素对象独有的。
元素节点提供六个方法，用来操作属性。

getAttribute()：读取某个属性的值
getAttributeNames()：返回当前元素的所有属性名
setAttribute()：写入属性值
hasAttribute()：某个属性是否存在
hasAttributes()：当前元素是否有属性
removeAttribute()：删除属性

# 五、事件
用法：
```javascript
document.addEventListener('click', function (e) {
  console.log(e.getModifierState('CapsLock'));
});
```
## 1、鼠标事件
### 1）点击事件
click：按下鼠标（通常是按下主按钮）时触发。
dblclick：在同一个元素上双击鼠标时触发。
mousedown：按下鼠标键时触发。
mouseup：释放按下的鼠标键时触发。
### 2）移动事件
### 3）其他事件

## 2、键盘事件
keydown：按下键盘时触发。
keypress：按下有值的键时触发，即按下 Ctrl、Alt、Shift、Meta 这样无值的键，这个事件不会触发。对于有值的键，按下时先触发keydown事件，再触发这个事件。
keyup：松开键盘时触发该事件。

## 3、表单事件
### input 事件
input事件当\<input>、\<select>、\<textarea>的值发生变化时触发

### select 事件
select事件当在\<input>、\<textarea>里面选中文本时触发

### change 事件

### rest、submit 事件