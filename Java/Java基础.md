[TOC]









## 一、数据类型

### 1. 为什么要有数据类型

虽然 Java 是面向对象编程，一切皆对象，但是为了加快常规的数据处理速度，提供了9种基本数据类型，它们都不具备对象的特性，没有属性和行为。

字节（最小单位）是存储容量的基本单位，由8位二进制组成。

字符是数字，字母，汉字以及其它语言的各种符号

![image.png](http://bed.thunisoft.com:9000/ibed/2019/12/19/29d481b33efa4c02b8ab17791299be6a.png)

![image.png](http://bed.thunisoft.com:9000/ibed/2019/12/19/87c8310694ae48cc8e07029dd9593a1c.png)



### 2. 基本类型与引用类型的区别

#### 2.1 基本类型保存原始值

基本数据类型是指**不可再分的原子数据类型**，内存中直接存储此类型的值，通过内存地址即可直接访问到数据，并且此内存区域只能存放这种类型的值。

默认值虽然都与0有关，但是他们之间是存在区别的。

* boolean 的默认值以0表示的false，JVM 没有针对 boolean 数据类型复制进行专用字节码指令，boolean flag = false 就是用 ICONST_0，即常数0进行赋值
* byte 的默认值以**一个字节**的0表示，在默认值的表示上使用了强制类型转化
* float 的默认值以单精度浮点数**0.0f**表示
* char 的默认值只能是单引号的 '\u0000' 表示 NUL，注意不是 null，它就是一个空的不可见字符，在码表中是第一个，其码值是0，与'\n'换行之类的不可见控制符的理解角度是一样的
  * 注意：不可以用双引号对 char 赋值，那是字符串的表示方式
* 在代码中直接出现的没有上下文的0和0.0分别默认为 int 和 double 类型
  * 推断：以下代码编译出错，因为在自动装箱时，0默认 int 类型，自动装箱为 Integer，无法转化为 Long 类型

```java
// JDK10 可以使用var作为局部变量类型推断标识符，此符号仅适用于局部变量
		var a = 0;
        Long b =a;
```



#### 2.2 引用类型保存的是引用值

引用类型分为两种数据类型：引用变量本身(Reference Variable)和引用指向对象(Referred Object)。

refvar 是基本数据类型，默认值是 null，存储 refobj的首地址，可以用 == 进行等值判断。而平时使用 refvar.hashCode() 返回的值，只是对象的某种哈希计算，可能与地址有关，与 refvar 本身存储的内存单元地址是两回事。作为





### 3. 装箱和拆箱

自动装箱是 Java 编译器在基本数据类型和对应的对象包装类型之间做的一个转化。比如：把 int 转化为 Integer。

| 原始类型 | 封装类型  |
| -------- | --------- |
| boolean  | Boolean   |
| char     | Character |
| byte     | Byte      |
| short    | Short     |
| int      | Integer   |
| long     | Long      |
| float    | Float     |
| double   | Double    |

##### 示例

```java
Integer x = 2;      // 装箱 调用了 Integer.valueOf(2)
int y = x;          // 拆箱 调用了 X.intValue()
```

valueOf() 方法用于返回给定参数 Number 对象值，参数可以是原生数据类型，String等

* **Integer valueOf(int i)：**返回一个表示指定的 int 值的 Integer 实例。

```java
Integer x = Integer.valueOf  (9);      //  9
Double c = Double.valueOf  (5);   // 5.0
```

* **Integer valueOf(String s):**返回保存指定的 String 的值的 Integer 对象。

```java
Float a = Float.valueOf  ("80");      // 80.0
```

* **Integer valueOf(String s, int radix):** 返回一个 Integer 对象，该对象中保存了用第二个参数提供的基数进行解析时从指定的 String 中提取的值。

```java
Integer b = Integer.valueOf  ("444",16);   // 使用 16 进制，1092
```





### 4. 缓冲池

既然提到了 valueOf，那就再谈谈new Integer(123)与Integer.valueOf(123)的区别：

* new Integer(123)每次都会创建一个新对象
* Integer.valueOf(123)会使用缓存池中的对象，多次调用会取得同一个对象的引用

```java
Integer x = new Integer(123);
Integer y = new Integer(123);
System.out.println(x == y);      // false
Integer z = Integer.valueOf(123);
Integer k = Integer.valueOf(123);
System.out.println(z == k);      // true
```

 ***valueOf() 方法的实现：***

先判断值是否在缓冲池中，如果在的话就直接返回缓冲池的内容

```java
public static Integer valueOf(int i) {
    if (i >= IntegerCache.low && i <= IntegerCache.high)
        return IntegerCache.cache[i + (-IntegerCache.low)];
    return new Integer(i);
}
```

在 Java 8 中，Integer 缓存池的大小默认为 -128~127。编译器会在自动装箱过程调用 valueOf() 方法，因此多个值相同且值在缓存池范围内的 Integer 实例使用自动装箱来创建，那么就会引用相同的对象。

```java
Integer m = 123;
Integer n = 123;
System.out.println(m == n); // true
```

为什么JDK要这么多此一举呢？ 举个例子， 淘宝的商品大多数都是100以内的价格， 一天后台服务器会new多少个这个的Integer， 用了IntegerCache，就减少了new的时间也就提升了效率。同时JDK还提供cache中high值得可配置，这无疑提高了灵活性，方便对JVM进行优化。

基本类型对应的缓冲池如下：

* boolean values true and false
* all byte values
* short values between -128 and 127
* int values between -128 and 127
* char in the range \u0000 to \u007F

使用这些基本类型对应的包装类型时，如果该数值范围在缓冲池范围内，就可以直接使用缓冲池中的对象。



### 5. 自动类型提升

```java
byte b = 3;     // 3是整数，自动判断是否在byte范围内，故没问题
b = b+2;   
```

因为2是默认 int，在 b + 2 运算时会自动提升表达式为 int，那么将 int 赋予byte 类型的变量 b 会出现类型转换错误。

```java
short s1 = 1;
s1 += 1;
```

+= 是 Java 规定的运算符，编译器会对它进行特殊处理，因此可以正确编译。



### 6. Integer 和 int 的区别

1）int 是 Java 的8中基本类型之一

​	 Integer 是 Java 为 int 类型提供的封装类

2）Integer 变量必须实例化后才能使用，而 int 变量不需要

3）int 变量的默认值为 0

​	  Integer 变量默认值是 null

4）Integer 实际上是***对象的引用***，当 new 一个 Integer 时，实际上是生成一个指针指向此对象，所以两个通过 new 生成的 Integer 变量永不相等，内存地址不同

```java
    	Integer i = new Integer(100);
    	Integer j = new Integer(100);
    	System.out.println(i == j);		// false
```

​	 ***int 是直接存储数据值***，Integer 变量和 int 变量比较时，只要两个变量的值是相等的，则结果为 true，因为包装类 Integer 和基本数据类型 int 比较时，Java 会自动拆箱为 int，然后进行比较，实际上就变成了两个 int 变量的比较。

```java
    	Integer i = new Integer(100);
    	int j = 100;
    	System.out.println(i == j);		// true
```

***补充***：非 new 生成的 Integer 变量和 new Integer() 生成的变量比较时，结果为false。（因为非 new 生成的 Integer 变量指向的是 java 常量池中的对象，而 new Integer() 生成的变量指向堆中新建的对象，两者在内存中的地址不同）

```java
    	Integer i = new Integer(100);
    	Integer j = 100;
    	System.out.println(i == j);		// false
```

而对于两个非new生成的Integer对象，进行比较时，如果两个变量的值在区间-128到127之间，则比较结果为true，如果两个变量的值不在此区间，则比较结果为false

```java
    	Integer i = 100;
    	Integer j = 100;
    	System.out.println(i == j);		// true
    	
    	Integer a = 128;
    	Integer b = 128;
    	System.out.println(a == b);		// false
```



### 7. char 类型变量能不能存储一个中文的汉字？

char 类型变量是用来存储 Unicode 编码的字符的，Unicode 字符集包含了汉字，所以char 类型当然可以用来存储汉字。

如果某个生僻字没有包含在unicode编码字符集中，那么char就不能存储该生僻字。







## 二、运算符

### 1. 算数运算符

#### 1.1 除法运算符

除法运算符比较特殊，如果除法运算符的两个操作数都是整数类型，则计算结果也是整数，就是将自然除法的结果截断取整，例如 19/4 的结果是 4，而不是 5。

如果除法运算的两个操作数都是整数类型，则除数不能为 0。

#### 1.2 求余运算符

```java
    	System.out.println(-1%-5);		// -1
    	System.out.println(1%-5);		// 1
    	System.out.println(-1%5);		// -1
```

#### 1.3 自加运算符

1）自加是单目运算符，只能操作一个操作数

2）自加运算符只能操作单个数值型的变量，不能操作常量或表达式

3）运算符可以放在操作数的左边：先把操作数加一，然后再放入表达式中运算；

也可以放在操作数的右边：先把操作数放入表达式中运算，然后再把操作数加一

```java
int a = 3, b; 
// 定义两个变量，一个为a被赋值；一个为b未被赋值，不能直接使用
b = a++; 
// a的值先赋给b，a++是指给a这个变量中的值进行一次+1操作，并把操作后的值重新赋给a，等同于a = a + 1；
System.out.println("a="+a+",b="+b);     // 输出a=4,b=3
```



### 2. 赋值运算符

```java
x+=4;     // x=x+4
```

```java
    	short s = 4;
    	//s = s+5;  s+5 是一个int值，赋给s装不下，丢失精度
    	s += 5;		// 只做赋值运算，内部自动转换，结果为 9
```



### 3. 逻辑运算符

***逻辑运算符用于连接 Boolean 型表达式***

&：无论左边是真是假，右边都运算

&&：左边位 false，右边不运算，效率较高

|：两边都运算

||：左边为 true，右边不运算

### 4. 位运算

直接对二进制运算



### 5. 三元运算符

#### 5.1 格式

(条件表达式)？表达式1：表达式2；

* 如果条件为 true，运算后的结果为表达式1
* 如果条件为 false，运算后的结果为表达式2

#### 5.2 示例

获取两个数中大数

```java
		int i = 100, j;
		j = (i > 1) ? 100 : 200;
		System.out.println("j=" + j); // j = 100
```



### 6. 运算符的结合性和优先级

