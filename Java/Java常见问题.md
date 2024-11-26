# 一、Java基础

## int 是多少字节

4字节，占32位
取值范围：-2^31 ~ 2^31 - 1
32个格子里放满0或1，有2^32中可能（约43亿）

## 为什么要重写 hashcode() 方法

主要原因是默认从Object继承来的hashCode是基于**对象的ID**实现的。
如果你重写了equals，比如说是基于**对象的内容**实现的，而保留hashCode的实现不变，那么很可能某两个对象明明是“相等”，而hashCode却不一样。
这样，当你用其中的一个作为键保存到hashMap、hashTable或hashSet中，再以“相等的”找另一个作为键值去查找他们的时候，则根本找不到。
new 了两个对象，内存地址肯定不一样，但我们比较对象是想比较这俩对象的内容

* 对于值对象，== 比较的是两个对象的值
* 对于引用对象，比较的是两个对象的地址
  默认的equals方法同==，一般来说我们的对象都是引用对象，要重写equals方法。
  **所以如果我们对equals方法进行了重写，建议一定要对hashCode方法重写，以保证相同的对象返回相同的hash值，不同的对象返回不同的hash值。**

## Java 是引用传递还是值传递

JAVA都是值传递的

```java
int num = 10;
String str = "hello";
```

num是基本类型，值就直接保存在变量中。而str是引用类型，变量中保存的只是实际对象的地址。一般称这种变量为"引用"，引用指向实际对象，实际对象中保存着内容。

其实就是操作的是一块内存还是新开辟了一块内存的区别，结果搞一堆术语来反而没人理解，局限于术语上去了

## 什么是面向对象

面向对象是一种编程思想，Java语言实现了这种思想。
之所以要面向对象，是为了应对需求的变化。

说到面向对象，一般都会提到面向过程：
举一个刚学Java的时候经常听到的例子，为了把大象装进冰箱，需要三个过程
1）把冰箱门打开
2）把大象装进去
3）把冰箱门关上
对于面向对象：
为了把大象装进冰箱，需要做三个动作，每个动作有一个执行者，他就是对象
1）冰箱，给我把门打开
2）冰箱，给我把大象装进去
3）冰箱，给我把门关上

如果这个时候要求再装一只熊猫，再装一只其他动物，面向过程就要扩展整个过程，而面向对象，由于我已经封装了装东西这个方法，无论是装什么，只是入参不同。

**纵向增加代码复杂度**，换取**对代码进行增删改查时最小工作量**

面向对象有三大特点：封装、继承、多态，就是为了强化代码应对变化时的适应能力，
面向过程把视角放在不稳定的操作之上，把描述客体的属性和行为分开了，应用程序日后的维护和扩展相当困难，甚至一个微小的变动，都会涉及整个系统。

## 注解

1、@Retention（保留策略）：编译、类加载、运行时
2、@Target：指定该注解能用于修饰哪些程序单元
3、提取注解信息：通过反射API读取：getAnnotation(Class)
4、重复注解：通过注解**容器**，可以在一个元素前使用多个相同类型的注解

## 创建一个对象的过程

### 创建对象的方法

1、new 关键字：调用任意构造函数

2、Class类的newInstance（反射）

3、Constructor类的newInstance（反射）

4、clone方法

5、反序列化

### 对象创建过程

![](..\images\对象的创建过程.awebp)

1、类加载检查：

遇到new指令之后，首先到**静态常量池**中看看能不能找到这个指令对应的**符号引用**

然后检查**符号引用**对应的类是否被**加载-连接-初始化**，如果有的话，就进行第二步，如果没有就先进行类的加载

2、分配内存

类加载检查通过后，对象的**大小**在类加载完成之后就可以确定，所以首先为新创建的对象根据对象大小**分配内存**，这块内存在**堆**中划分，那么如何进行内存的分配呢？

有两种情况，**“指针碰撞”和“空闲列表”**，根据**Java堆是否规整**决定

3、初始化零值

从类加载过程中，我们了解到：在准备过程中会将final修饰的静态变量直接赋初值，对static修饰的静态变量赋零值

对应普通成员变量，我们不清楚是何时初始化的，那么这个阶段就是给成员变量进行初始化

**虚拟机需要把分配到的内存空间中的数据类型都初始化为零值（不包括对象头）**，这一步操作保证了对象的实例字段在Java代码中可以不赋初始值直接使用，程序能访问这些字段的数据类型所对应的零值

4、设置对象头

初始化零值完成之后，虚拟机要对对象进行必要的设置，例如这个对象是那个类的实例，如果能找到类的元数据信息，对象的哈希码，对象的GC分代年龄等信息。

这些信息存放在对象头中

5、指向init方法

在上面工作都完成之后，从虚拟机的视角来看，一个新的对象已经产生了，但从 Java 程序的视角来看，对象创建才刚开始，方法还没有执行，所有的字段都还为零。所以一般来说，执行 new 指令之后会接着执行方法，把对象按照程序员的意愿进行初始化，这样一个真正可用的对象才算完全产生出来。

## 反射

### 如何通过反射改变对象的内容

得到 Class 对象，通过getMethods()或者getMethod()方法获取**Method对象**，然后通过该对象来调用它对应的方法。Method 包含一个 invoke() 方法

```java
    /**
     * @param obj  执行该方法的对象
     * @param args 执行该方法时传入的实参
    */
    @CallerSensitive
    public Object invoke(Object obj, Object... args)
        throws IllegalAccessException, IllegalArgumentException,
           InvocationTargetException
    {
        if (!override) {
            if (!Reflection.quickCheckMemberAccess(clazz, modifiers)) {
                Class<?> caller = Reflection.getCallerClass();
                checkAccess(caller, clazz, obj, modifiers);
            }
        }
        MethodAccessor ma = methodAccessor;             // read volatile
        if (ma == null) {
            ma = acquireMethodAccessor();
        }
        return ma.invoke(obj, args);
    }
```

![](..\images\反射invoke.png)

### 可以改变枚举对象内容吗？

可以，但这个枚举类必须提供了Set方法，一般来说，枚举类通常设计成不可变类，也就是说他的成员变量值不允许改变，建议枚举类的成员变量都使用 private final 修饰，那么就要在构造器里为这些成员变量指定初始值
一旦定义了带参数的构造器，罗列 **枚举值（在第一行列出，逗号分隔，分号结尾）** 时就必须对应的传入参数

### 原理

```java
    // 1. 使用外部配置的实现，进行动态加载类
    TempFunctionTest test = (TempFunctionTest)Class.forName("com.tester.HelloReflect").newInstance();
    test.sayHello("call directly");
    // 2. 根据配置的函数名，进行方法调用（不需要通用的接口抽象）
    Object t2 = new TempFunctionTest();
    Method method = t2.getClass().getDeclaredMethod("sayHello", String.class);
    method.invoke(test, "method invoke");
```

执行流程如下：
![](..\images\java-basic-reflection-1.png)

#### 反射获取类实例

首先调用Class的静态方法，获取类信息：

```java
    @CallerSensitive
    public static Class<?> forName(String className)
                throws ClassNotFoundException {
        // 先通过反射，获取调用此方法的类信息，从而获取当前的 classLoader
        Class<?> caller = Reflection.getCallerClass();
        // 调用native方法进行获取class信息
        return forName0(className, true, ClassLoader.getClassLoader(caller), caller);
    }
```

forName() 反射获取类信息，并没有将实现留给java，而是交给jvm去加载。
主要是先获取 ClassLoader，然后调用 native 方法，获取信息，加载类回调 java.lang.ClassLoader，最后，jvm 又会回调 ClassLoader 进行类加载。
最后，jvm又会回调ClassLoader进行类加载。

怎么在运行时，获取到这些类的信息

1、获取到反射类及反射方法

2、每个类都有一个与之对应的Class实例，从而每个类都可以获取method反射方法，作用于其他实例

3、反射使用软引用relectionData缓存class信息，避免每次重新从jvm获取带来的开销

4、反射调用多次生成的新代理Accessor

5、当找到需要的方法时，都会copy一份出来，而不是使用原来的实例，从而保证了数据隔离

6、调度反射方法，最终由jvm执行 invoke0();

## lambda 原理

1、以 `@FunctionalInterface`修饰的接口，**有且只有一个抽象方法（public abstract在接口中可以默认省略）**，可以有多个静态和默认方法

2、

## IO

### 为什么要有IO

程序要和外部进行数据交互

### 文件系统

以最常见的输入输出设备为例：硬盘，也可以理解为文件系统。

Java程序是运行在JVM上的，对于Java程序来说硬盘并不可见，可见的是操作系统提供的文件系统，要用Java操作文件系统，首先要表示文件，即**FIle类**。

### 抽象基类

IO流的概念不仅仅局限在操作文件上，是要能操作**所有输入输出**，所以有两个顶层抽象类表示操作所有输入输出：InputStream、OutputStream

这两个类表示字节的输入输出，而字节是最基本的流，因为计算机底层传递的就是字节

### 访问文件

按照面向对象的思想，既然要操作文件，那就有了FileInputStream、FileOutputStream作为子类

### 缓冲流

原始的字节流不高效，每个字节都调用底层的操作系统API

而缓冲区的流对象，可以一次读一个缓冲区，缓冲区空了才去调用一次底层API，可以大大提高效率，所以有了BufferedInputStream和BufferedOutputSteam，他们的用法是把字节流对象传入后再使用，也相当于把它俩套在了字节流的外面，给字节流装了个“外挂”

### 转换流

InputStreamReader和OutputStreamWriter。把字节流转成字符流，就不用操作字节流了，可以用人类的方式read和write各种“文字”

### 字符输入输出流

最常见的是和文件系统打交道，读取文本文件能不能用一种方便的方式呢？

FileReader和FileWriter这两个流对象可以直接把文件转成读取、写入流。让你省去了创建字节流，再套上转换流的步骤

### 字符缓冲流

再把Reader和writer做成高效的，就需要BufferedReader和BufferedWriter，把他们套在Reader和Writer上，就能实现高效的字符流。

### java io一般有哪些操作 一般会出现什么样的问题

#### 字符编码

不管是什么文字，计算机中都是按照**一定规则**将其以二进制保存的，这个规则就是字符集，在进行文件读写的时候，如果是在**字节**层面进行操作，不会涉及字符编码问题；
但如果是在**字符**层面进行读写，需要明确字符集。
写入和读取时，使用的不是同一个字符集，会出问题。

比如 FileReader 是以当前机器的默认字符集来读取文件的，如果这个文件写入是GBK，读取是UTF-8，就会乱码
如果需要指定字符集，需要直接使用 InputStreamReader 和 FileInputStream

#### 文件句柄

程序打开过多文件会导致 `Too many open files`，所以要关流

可以使用 `ulimit -a`查看系统可用资源：open files，默认1024

排查问题，可以先用 lsof -p pid 查看该进程打开了哪些文件，然后 lsof -p pid | grep 文件名 | wc -l

数据库安装时，一般会修改这个配置，因为数据库会占用大量的文件

一般数据库服务器要求和应用服务器分开，应用服务请求**数据库连接池**中的一个连接，然后数据库自己的操作是IO操作

#### 不关闭流

使用 FileInputStream 读取一个文件但没有显式关闭输入流，会导致一些潜在的问题

1. 资源泄露：文件句柄资源被耗尽
2. 文件锁定：某些操作系统，打开一个文件会产生文件锁，阻止其它进程操作该文件
3. 内存泄漏：相关对象一直在内存里

使用网络流发起一个请求（比如使用 URLConnection 或者 HttpClient）但没有关闭这个流

1. 资源泄露：网络资源一直被占用，比如本地端口
2. 连接池耗尽
3. 占用内存

#### 设置缓冲区

使用 FileInputStream 获得一个文件输入流，然后调用其 read 方法每次读取一个字节，最后通过一个 FileOutputStream 文件输出流把处理后的结果写入另一个文件。
每读取一个字节、每写入一个字节都进行一次 IO 操作，代价太大了，而且这样将文件转为字节全部读入，有OOM的风险。

解决方案就是，考虑使用**一块内存区域作为直接操作的中转**，也就是缓冲区，一次性从原文件读取一定数量的数据到缓冲区，一次性写入一定数量的数据到目标文件
在进行文件 IO 处理的时候，使用合适的缓冲区可以明显提高性能

BufferedInputStream 和 BufferedOutputStream在内部实现了一个默认 8KB 大小的缓冲区。但是，在使用 BufferedInputStream 和 BufferedOutputStream 时，我还是建议你再使用一个缓冲进行读写，不要因为它们实现了内部缓冲就进行逐字节的操作

#### 缓存导致数据丢失

![](..\images\刷新输出流.jpg)

图中WEB服务器通过输出流向客户端响应了一个300字节的信息，但是，这时的输出流有一个1024字节的缓冲区。所以，输出流就一直等着WEB服务器继续向客户端响应信 息，当WEB服务器的响应信息把输出流中的缓冲区填满时，这时，输出流才向WEB客户端响应消息。

为了解决这种尴尬的局面，flush()方法出现了。flush()方法可以强迫输出流(或缓冲的流)发送数据，即使此时缓冲区还没有填满，以此来打破这种死锁的状态。

当我们使用输出流发送数据时，当数据不能填满输出流的缓冲区时，这时，数据就会被存储在输出流的缓冲区中。如果，我们这个时候调用关闭(close)输出流，存储在输出流的缓冲区中的数据就会丢失。所以说，关闭(close)输出流时，应先刷新(flush)换冲的输出流，话句话说就是：“迫使所有缓冲的输出数据被写出到底层输出流中”。

## String、StringBuilder、StringBuffer

### 为什么 String 不可变

String 类被声明为 final，因此不可被继承，
内部使用char数组存储数据，该数组被申明为final，意味着value数组初始化之后，就不能再引用其它数组。并且String内部没有改变value数组的方法，保证了String不可变

```java
public final class String
    implements java.io.Serializable, Comparable<String>, CharSequence {
    /** The value is used for character storage. */
    private final char value[];
```

### 可变性

* String 不可变
* StringBuffer 和 StringBuilder 可变

### 线程安全

* String 不可变，因此是线程安全的
* StringBuilder 不是线程安全的
* StringBuffer 是线程安全的，内部使用 synchronized 进行同步

### 泛型

为什么要用泛型：

> 通过泛型指定的不同类型，来控制形参具体限制的类型

\<?> 无限制通配符
\<? extends E> 声明了类型的上界，表示参数化的类型可能是所指定的类型，或者是此类型的**子类**
\<? super E> 声明了类型的下界，表示参数化类型可能是指定的类型，或者是此类型的**父类**

* 如果参数化类型表示一个 T 的生产者，使用 \<? extends T>，只能取（get），不能放（set）
* 如果表示一个 T 的消费者，使用 \<? super T>
* 如果既是生产者又是消费者，使用通配符就没意义了，需要精确的参数类型

# 二、容器

> 容器主要包括 Collection 和 Map 两种，Collection 存储着对象的集合，而 Map 存储着键值对(两个对象)的映射表。

![](..\images\java_collections_overview.png)

## Collection

定义了一些通用的方法：增加/删除元素，是否包含某个元素 之类。
Collection 继承了 Iterable 接口，它定义了hasNext() 和 next()方法，让每个具体的实现类定义自己的迭代方式，因为每个集合内部的数据结构可能都不相同

### List 接口

有序集合，集合中的元素可以重复，根据索引访问集合中的元素

#### ArrayList

##### 底层数据结构

```java
    transient Object[] elementData; // non-private to simplify nested class access
    private int size;
```

基于**动态数组**，对于随机访问get和set，拥有绝对优势，因为LinkedList要移动指针

##### 扩容机制

如果通过无参构造，初始容量为0，开始添加第一个元素时，才真正分配容量，默认分配容量是10
当容量不足时（容量为size，添加第size+1个元素时），先判断按照1.5倍（位运算）的比例扩容能否满足最低容量要求，如果满足则以1.5倍扩容，否则以最低容量的要求扩容

扩容时，会将老数组中的元素重新拷贝一份到新的数组中，这种代价是比较高的，所以在实际使用中，如果知道要保存多少元素，构建实例时，就手动指定容量。

#### LinkedList

*LinkedList*同时实现了*List*接口和*Deque*接口，也就是说它既可以看作一个顺序容器，又可以看作一个队列(*Queue*)，同时又可以看作一个栈(*Stack*)

##### 底层数据结构

```java
private static class Node<E> {
    E item;
    Node<E> next;
    Node<E> prev;

    Node(Node<E> prev, E element, Node<E> next) {
        this.item = element;
        this.next = next;
        this.prev = prev;
    }
}
```

基于**双向链表**，链表的每个节点用内部类Node表示。

对于新增/删除，LinkedList比较占优，因为ArrayList要移动数据

这一点要看实际情况的。若只对**顺序**插入或删除，ArrayList的速度反而优于LinkedList。但若是**批量随机**的插入删除数据，LinkedList的速度大大优于ArrayList. 因为ArrayList每插入一条数据，要移动插入点及之后的所有数据。

### Queue

#### Deque

`Deque`是"double ended queue", 表示双向的队列，英文读作"deck". Deque 继承自 Queue接口

关于栈或队列，现在的首选是*ArrayDeque*，它有着比*LinkedList*(当作栈或队列使用时)有着更好的性能

### Set接口

无序集合，元素不可重复，根据**元素本身**来访问集合中的元素

由于不包含重复元素，任意两个元素e1、e2都有e1.equals(e2)=false，Set最多有一个null元素

虽然Set中元素没有顺序（不会按照存入的顺序排序），但是元素在Set中的位置是由该元素的HashCode决定的，其位置是固定的。

也就是说，如果某个类重写了hashcode和equals方法，那么这两个对象如果内容相同，add第二个对象会返回false

#### HashSet

由HashMap实现，不保证插入的顺序和输出的顺序一致，允许使用Null

通过一个HashMap存储元素，**元素存放在Key中**，Value统一使用一个Object对象

#### LinkedHashSet

底层基于LinkedHashMap，同样也是根据元素的hashCode值来决定元素的存储位置，但它同时使用**链表**维护元素的次序，所以是有序的

#### TreeSet

基于TreeMap，支持**自然排序和定制排序**

它不是通过hashcode和equals方法来比较元素的，而是通过 `Comparator`来判断元素是否相等，如果相等，不会被加入到集合中。

## Map

保存的是Key-value形式的数据，Key不能相同，value可以相同

### LinkedHashMap

是HashMap的子类，**二者唯一的区别是LinkedHashMap在HashMap的基础上，采用双向链表(doubly-linked list)的形式将所有 `entry`连接起来，这样是为保证元素的迭代顺序跟插入顺序相同**

### TreeMap

有序的key-value集合，基于**红黑树**实现，每一个key-value节点作为红黑树的一个节点

**存储时**会进行排序，**根据key**来对key-value键值对进行排序。

#### 自然排序

Key 的类，要实现 `Comparable`接口，重写 compareTo() 方法。

Compareable 是排序接口，如果一个类实现了Compareable接口，意味着**该类支持排序**，相当于**内部比较器**。

```java
@AllArgsConstructor
@ToString
@EqualsAndHashCode
class R implements Comparable<R> {

    int count;

    @Override
    public int compareTo(R r) {
        return Integer.compare(count, r.count);
    }
}

@Test
public void testComparable() {
    TreeMap<R, String> tm = new TreeMap<>();
    tm.put(new R(3), "java");
    tm.put(new R(9), "php");
    tm.put(new R(-5), "python");
    tm.put(new R(-4), "js");
    // 会报错
//        tm.put(null, "js");
    log.info("{}", tm);
    log.info("{}", tm.firstEntry());
    log.info("{}", tm.lastKey());
}
```

#### 定制排序

Comparator 是比较器接口，如果我们要控制某个类的次序，而该类本身不支持排序（即没有实现Comparable接口）；
那么，我们可以建立一个**该类的比较器**来进行排序，相当于**外部比较器**
需要注意的是，这个时候，TreeMap的构造器要传入我们实现的Comparator实现类。

```java
@AllArgsConstructor
@ToString
@EqualsAndHashCode
class R1 implements Comparator<R1> {

    int count;

    @Override
    public int compare(R1 o1, R1 o2) {
        return Integer.compare(o1.count, o2.count);
    }
}

@Test
public void testComparator() {
    TreeMap<R1, String> tm = new TreeMap<>(new R1(0));
    tm.put(new R1(3), "java");
    tm.put(new R1(9), "php");
    tm.put(new R1(-5), "python");
    tm.put(new R1(-4), "js");
    log.info("{}", tm);
}
```

### HashMap

#### 数组结构

* 优点：由于数组是连续的，读取/修改效率高
* 缺点：插入/删除效率低，因为插入数据，这个位置后面的数据都要往后移动，且大小固定，不易扩展

```java
transient Node<K,V>[] table;
```

#### 链表结构

* 优点：插入/删除速度快，没有固定大小，扩展灵活
* 缺点：不能随机查找，每次都是从第一个开始遍历

#### 哈希表结构

结合了两者的优点，HashMap就是这样的一种结构

![](https://img-blog.csdnimg.cn/20201218094332663.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzMzcwNzcx,size_16,color_FFFFFF,t_70)

Java8 中使用Node和TreeNode 来分别表示链表和红黑树

```java
static final class TreeNode<K,V> extends LinkedHashMap.Entry<K,V> {}

static class Node<K,V> implements Map.Entry<K,V> {}
```

#### 1、put(k,v) 实现原理

1）首先把key、value 封装到Node对象（节点）中
2）调用key的hashCode()方法得到hash值
3）通过哈希算法，把hash值转换成数组的下标，这个下标位置如果没有任何元素，就把Node添加到这个位置。
如果下标对应的位置上有链表，这时就拿着k和链表上每个节点的k进行equals，
如果所有equals方法返回的都是false，那么这个新的节点将被添加到链表末尾，如果有一个equals返回了true，那么这个节点将会被覆盖

#### 2、get(k) 实现原理

1）先调用k的hashCode()方法得到哈希值，通过哈希算法转换成数组的下标
2）通过下标快速定位到某个位置，如果这个位置上啥都没有，返回null
如果这个位置上有单向链表，那就拿着k和单向链表上的每个节点的k进行equals，如果所有equals方法都返回false，返回null
如果其中一个节点的k和参数k进行equals返回true，那么返回这个value

#### 3、为什么效率高

增删是在链表上完成的，而查询只需扫描部分，则效率高
HashMap集合的key，会先后调用两个方法，hashCode and equals方法，这这两个方法都需要重写。

##### 红黑树

当hash表的单一链表长度超过 8 个的时候，链表结构就会转为红黑树结构
![](..\images\20201218103447215.png)

* 红黑树查询：其访问性能近似于折半查找，时间复杂度 O(logn)；
* 链表查询：这种情况下，需要遍历全部元素才行，时间复杂度 O(n)；

简单的说，红黑树是一种近似平衡的二叉查找树，其主要的优点就是“平衡“，即左右子树高度几乎一致，以此来防止树退化为链表，通过这种方式来保障查找的时间复杂度为 log(n)。

#### HashMap 扩容

resize() 用于初始化数组或数组扩容，每次扩容后，新数组的容量为原来的**两倍**，遍历原数组进行数据迁移

#### 与Hashtable的区别：

1）HashMap允许将null作为一个entry的key或者null，而Hashtable不允许

2）HashMap继承自AbstractMap，而Hashtable继承自Dictionary，他们都实现了Map接口

3）Hashtable中大量的方法是synchronized修饰的，而HashMap不是

4）HashMap计算hash，对key的hashcode进行二次hash，但Hashtable是直接使用key的hashcode

#### 与TreeMap的区别

```java
public class HashMap<K,V> extends AbstractMap<K,V>
    implements Map<K,V>, Cloneable, Serializable

public class TreeMap<K,V>
    extends AbstractMap<K,V>
    implements NavigableMap<K,V>, Cloneable, java.io.Serializable
```

1）从类定义上来看：HashMap和TreeMap都继承自AbstractMap，不同的是HashMap实现的是Map接口，而TreeMap实现的是NavigableMap接口。NavigableMap是SortedMap的一种，实现了对Map中key的排序

2）从排序上看：所以TreeMap是有序的，而HashMap无序（插入/取出的顺序）

3）从Null上看：HashMap可以有一个null值的key和多个null值的value，但TreeMap不允许有null key，但可以有 null value

### Iterator 与 ListIterator

Iterator提供了三个api：

- boolean hasNext()：只能单向向后遍历，判断集合里是否存在下一个元素。如果有，hasNext()方法返回 true。
- Object next()：返回集合里下一个元素。
- void remove()：删除集合里上一次next方法返回的元素。
  - 这是唯一安全的方式来在迭代中增加/修改集合元素，并且每调用一次next方法，remove方法只能被调用一次，否则将会抛出异常

ListIterator只能用于各种List类型的访问，可以双向遍历
