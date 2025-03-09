[toc]

# 一、常用命令

```shell
[root@localhost share]# jps -l
```

-q：只输出进程 ID
-m：输出传入 main 方法的参数
-l：输出完全的包名，应用主类名，jar的完全路径名
-v：输出jvm参数
-V：输出通过flag文件传递到JVM中的参数

```sh
jar tf jar包名称 | find "寻找的class名称"
# 结果：BOOT-INF/classes/xxx.class

# 创建目录
mkdir BOOT-INF\classes\

# 替换
jar uvf xxx.jar BOOT-INF/classes/

```

# 二、常见参数

-Xms 为jvm启动时分配的初始堆的大小，也是堆大小的最小值，比如-Xms200m，表示分配200M
-Xmx 为jvm运行过程中分配的最大堆内存，比如-Xmx500m，表示jvm进程最多只能够占用500M内存
-Xss 为jvm启动的每个线程分配的内存大小，默认JDK1.4中是256K，JDK1.5+中是1M

# 三、内存分析

## Java 堆内存溢出

Java 堆内存（Heap Memory)主要有两种形式的错误：

### 1. OutOfMemoryError: Java heap space

在 Java 堆中只要不断的创建对象，并且 GC-Roots 到对象之间存在引用链，这样 JVM 就不会回收对象

### 2. OutOfMemoryError: GC overhead limit exceeded

通过统计GC时间来预测是否要OOM了，提前抛出异常，防止OOM发生

## MetaSpace (元数据) 内存溢出

> JDK8 中将永久代移除，使用 MetaSpace 来保存类加载之后的类信息，字符串常量池也被移动到 Java 堆

可以使用 -XX:MaxMetaspaceSize=10M 来限制最大元数据。这样当不停的创建类时将会占满该区域并出现 OOM

> 可以使用 -XX:MaxMetaspaceSize=10M 来限制最大元数据。这样当不停的创建类时将会占满该区域并出现 OOM

## 如何获取堆内存dump

### 通过OOM获取

即在OutOfMemoryError后获取一份HPROF二进制Heap Dump文件，在jvm中添加参数：

```sh
-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=$LOG_DIR/java.hprof"
```

### jmap获取

```sh
jmap -dump:live,format=b,file=<文件名XX.hprof> <pid>
```

## 堆外内存

# 四、线程分析

## Thread Dump分析

* 头部信息：时间，JVM信息

```sh
2011-11-02 19:05:06  
Full thread dump Java HotSpot(TM) Server VM (16.3-b01 mixed mode): 
```

* 线程INFO信息块

```sh
1. "Timer-0" daemon prio=10 tid=0xac190c00 nid=0xaef in Object.wait() [0xae77d000] 
# 线程名称：Timer-0；线程类型：daemon；优先级: 10，默认是5；
# JVM线程id：tid=0xac190c00，JVM内部线程的唯一标识（通过java.lang.Thread.getId()获取，通常用自增方式实现）。
# 对应系统线程id（NativeThread ID）：nid=0xaef，和top命令查看的线程pid对应，不过一个是10进制，一个是16进制。（通过命令：top -H -p pid，可以查看该进程的所有线程信息）
# 线程状态：in Object.wait()；
# 起始栈地址：[0xae77d000]，对象的内存地址，通过JVM内存查看工具，能够看出线程是在哪儿个对象上等待；
2.  java.lang.Thread.State: TIMED_WAITING (on object monitor)
3.  at java.lang.Object.wait(Native Method)
4.  -waiting on <0xb3885f60> (a java.util.TaskQueue)     # 继续wait 
5.  at java.util.TimerThread.mainLoop(Timer.java:509)
6.  -locked <0xb3885f60> (a java.util.TaskQueue)         # 已经locked
7.  at java.util.TimerThread.run(Timer.java:462)
Java thread statck trace：是上面2-7行的信息。到目前为止这是最重要的数据，Java stack trace提供了大部分信息来精确定位问题根源。
```

* Java thread statck trace
  堆栈信息应该逆向解读：

```sh
- locked <0xb3885f60> (a java.util.ArrayList)
- waiting on <0xb3885f60> (a java.util.ArrayList) 
```

## jstack

jstack（Stack Trace for Java 堆栈跟踪工具），用于生成虚拟机当前时刻的线程快照

```shell
jstack [ option ] pid
```

-F 当正常输出的请求不被响应时，强制输出线程堆栈
-l 除了堆栈外，显示关于锁的附加信息
-m 如果调用的是本地方法的话，可以显示 c/c++的堆栈

pid：Java的进程号，可以通过jps来获取

### 如何解读

死锁，Deadlock（重点关注）
等待资源，Waiting on condition（重点关注）
等待获取监视器，Waiting on monitor entry（重点关注）
阻塞，Blocked（重点关注）
执行中，Runnable
暂停，Suspended
对象等待中，Object.wait() 或 TIMED_WAITING
停止，Parked

## 案例分析

* CPU 飙高，load高，响应慢
  * 一个请求过程中多次dump
  * 对比多次dump文件的runnable线程，如果执行的方法有比较大变化，说明比较正常。如果在执行同一个方法，就有一些问题了
* 查找占用CPU最多的线程
  * 使用命令：top -H -p pid（pid为被测系统的进程号），找到导致CPU高的线程ID，对应thread dump信息中线程的nid，只不过一个是十进制，一个是十六进制
  * 在thread dump中，根据top命令查找的线程id，查找对应的线程堆栈信息
* CPU 使用率不高，但是响应很慢
  * 进行dump，查看是否有很多thread struck在了i/o、数据库等地方，定位瓶颈原因
* 请求无法响应
  * 多次dump，对比是否所有的runnable线程都一直在执行相同的方法，如果是的，恭喜你，锁住了！

## 热锁

热锁，也往往是导致系统性能瓶颈的主要因素。其表现特征为：由于多个线程对临界区，或者锁的竞争，可能出现：

* 频繁的线程的上下文切换
* 大量的系统调用
* 大部分CPU开销用在“系统态”
* 随着CPU数目的增多，系统的性能反而下降

# GC

垃圾回收，并不是找到不再使用的对象，然后将这些对象清除掉。它的过程正好相反，JVM 会找到正在使用的对象，对这些使用的对象进行标记和追溯，然后一股脑地把剩下的对象判定为垃圾，进行清理。

* GC 的速度，和堆内存活对象的多少有关，与堆内所有对象的数量无关；
* GC 的速度与堆的大小无关，32GB 的堆和 4GB 的堆，只要存活对象是一样的，垃圾回收速度也会差不多；
* 垃圾回收不必每次都把垃圾清理得干干净净，最重要的是不要把正在使用的对象判定为垃圾。

**那么，如何找到这些存活对象，也就是哪些对象是正在被使用的，就成了问题的核心。**

如果想要保证一个 HashMap 能够被持续使用，可以把它声明成静态变量，这样就不会被垃圾回收器回收掉。我们把这些**正在使用的引用的入口，叫作GC Roots，即 可达性分析法**。

GC Roots 包括（入口大约有三个：线程、静态变量和 JNI 引用）：

* Java 线程中，当前所有正在被调用的方法的引用类型参数、局部变量、临时值等。也就是与我们栈帧相关的各种引用
* 当前被加载的所有Java类
* Java 类的引用类型静态变量
* 运行时常量池的引用类型常量（String 活 Class 类型）
* JVM 内部数据结构的一些引用
* 用于同步的监控对象，比如调用了对象的 wait() 方法
* JNI handles，包括 global handles 和 local handles

## 强、软、弱、虚引用

* 强引用：默认的对象关系是强引用，也就是我们默认的对象创建方式。这种引用属于最普通最强硬的一种存在，只有在和 GC Roots 断绝关系时，才会被消灭掉。
* 软引用：用于维护一些可有可无的对象。在内存足够的时候，软引用对象不会被回收；只有在内存不足时，系统则会回收软引用对象；如果回收了软引用对象之后，仍然没有足够的内存，才会抛出内存溢出异常。
* 弱引用：级别就更低一些，当 JVM 进行垃圾回收时，无论内存是否充足，都会回收被弱引用关联的对象。软引用和弱引用在堆内缓存系统中使用非常频繁，可以在内存紧张时优先被回收掉。
* 虚引用：是一种形同虚设的引用，在现实场景中用得不是很多。

## 新生代与老年代

在Java虚拟机（JVM）的垃圾收集（GC）架构中，堆内存被分为几个不同的区域，主要包括新生代（Young Generation）和老年代（Old Generation），这两个区域针对不同的垃圾收集策略和内存管理策略进行了优化。

### 新生代（Young Generation）

* 目的：用于存放新创建的对象。由于大多数新创建的对象“朝生夕死”，新生代频繁进行垃圾回收（称为Minor GC）
* 区域划分：新生代通常进一步划分为一个Eden区和两个幸存者区（Survivor spaces，通常称为S0和S1）
* 垃圾回收机制：采用复制算法（Copying），在每次Minor GC时，活跃对象从Eden区和一个幸存者区复制到另一个幸存者区，未被复制的对象则被清除。这种方法因为只处理存活的对象，所以非常快速
* 对象晋升：对象如果经过多次Minor GC依然存活，会被晋升到老年代，以避免频繁的复制操作

### 老年代（Old Generation）

* 目的：存放经过多次Minor GC后仍然存活的对象。这些对象通常被认为寿命较长或“几乎永久存活”的对象。
* 垃圾回收频率：相比新生代，老年代的垃圾回收（称为Major GC或Full GC）频率较低，但每次回收的开销较大，因为涉及到整个老年代区域的垃圾收集。
* 垃圾回收机制：通常采用标记-清除（Mark-Sweep）或标记-整理（Mark-Compact）算法。这些算法更适合处理大量数据，因为它们不需要像复制算法那样复制存活对象。

### 相互关系和影响

* 内存分配策略：大部分对象最初在新生代的Eden区分配。随着对象的存活时间增加和空间的填充，它们可能会被转移到Survivor区，最终晋升到老年代

## 如何排查Full GC（Full Garbage Collection）

### 1、检查JVM配置和日志

* 确保JVM启动参数是否合理，最大堆内存，元空间等
* GC 日志

### 2、分析GC日志

### 3、分析代码

重点查大对象和内存泄漏

### 4、是否有内存泄漏

jmap

### 5、监控

如果你观察到应用程序的响应时间随时间推移逐渐增加，使用jstat检查老年代（Old Gen）的填充情况和GC活动可能会帮助你确定是否存在内存泄漏或是否GC设置不当.
FullGC越少越好，最好控制在FullGC几个小时甚至几天一次，具体看业务的情况

```sh
# 每秒（1000毫秒）显示一次目标进程的垃圾收集利用率
jstat -gcutil <pid> 1000
# 每秒更新一次GC信息，总共更新10次
jstat -gc <pid> 1000 10
# 显示类的加载、卸载数量和空间信息
jstat -class <pid>

```

# 四、VirtualMachineError

## OutOfMemoryError

是一种内存溢出错误，通常发生在 Java 堆内存不足以分配新对象时

## StackOverflowError

是一种堆栈溢出错误，通常发生在递归方法或无限循环中，导致方法调用的堆栈深度超出了 JVM 的限制

# 类加载

![](..\images\java_jvm_classload_2.png)

`加载`、`验证`、`准备`和 `初始化`这四个阶段发生的顺序是确定的，*而 `解析`阶段则不一定，它在某些情况下可以在初始化阶段之后开始，这是为了支持Java语言的运行时绑定(也成为动态绑定或晚期绑定)*。另外注意这里的几个阶段是按顺序开始，而不是按顺序进行或完成，因为这些阶段通常都是互相交叉地混合进行的，通常在一个阶段执行的过程中调用或激活另一个阶段。

### 类的加载：查找并加载类的二进制数据

加载时类加载过程的第一个阶段，在加载阶段，虚拟机需要完成以下三件事情:

* 通过一个类的全限定名来获取其定义的二进制字节流
* 将这个字节流代表的静态存储结构转化为方法区的运行时数据结构
* 在Java堆中生成一个代表这个类的Class对象，作为对方法区中这些数据的访问入口。

#### 类的加载有三种方式

1、启动应用时由JVM初始化加载

2、通过CLass.forName() 方法动态加载

3、通过ClassLoader.loadClass()方法动态加载

#### 类加载顺序

在同一目录下的jar包，jvm 是按照jar包的先后顺序进行加载的，一旦一个**全路径名相同的类**被加载之后，后面再有相同的类就不会加载了。

#### 类加载器的隔离问题

每个类加载器都有一个自己的**命名空间**用来保存已加载的类。当一个类加载器加载一个类时，它会通过保存在命名空间里的**类全局限定名**搜索来检测这个类是否已经被加载了。

jvm 对类唯一的识别是 ClassLoader id + PackageName + ClassName，所以一个运行中是有可能存在两个包名和类名完全一致的类的。并且如果这两个类不是由一个 ClassLoader 加载，是无法将一个类的实例强转为另一个类的，这就是 classloader 隔离性

为了解决类加载器的隔离问题，jvm 引入了双亲委派机制

### 双亲委派机制

核心：**自底向上**检查类是否**已加载**；**自顶向下**尝试**加载**类

防止内存中出现多份同样的字节码

1、当AppClassLoader（应用程序类加载器）加载一个class时，他首先不会自己尝试加载这个类，而是把类加载请求委派给父类加载器ExtClassLoader（扩展类加载器）去完成

2、当ExtClassLoader加载一个class时，它首先也不会自己去尝试加载这个类，而是把类加载请求委派给BootStrapClassLoader去完成

3、如果BootStrapClassLoader加载失败(例如在$JAVA_HOME/jre/lib里未查找到该class)，会使用ExtClassLoader来尝试加载

4、若ExtClassLoader也加载失败，则会使用AppClassLoader来加载，如果AppClassLoader也加载失败，则会报出异常ClassNotFoundException。

### jar 包的加载顺序

一旦一个类被加载之后，全局限定名相同的类可能就无法被加载了。而Jar包被加载的顺序直接决定了类加载的顺序。

* 第一，Jar包所处的加载路径。也就是加载该Jar包的类加载器在JVM类加载器树结构中所处层级。上面讲到的四类类加载器加载的Jar包的路径是有不同的优先级的。
* 第二，文件系统的文件加载顺序。因Tomcat、Resin等容器的ClassLoader获取加载路径下的文件列表时是不排序的，这就依赖于底层文件系统返回的顺序，当不同环境之间的文件系统不一致时，就会出现有的环境没问题，有的环境出现冲突

## 内存结构

![](..\images\0082zybply1gc6fz21n8kj30u00wpn5v.jpg)

- **线程私有**：程序计数器、虚拟机栈、本地方法区
- **线程共享**：堆、方法区, 堆外内存（Java7的永久代或JDK8的元空间、代码缓存）

## 堆内存

### 堆内存划分

Java 堆是 Java 虚拟机管理的内存中最大的一块，被所有线程共享。此内存区域唯一的目的就是存放对象实例，几乎所有的对象实例以及数据都在这里分配内存。
为了进行高效的垃圾回收，虚拟机把堆内存**逻辑上**划分为三块区域

* 年轻代：新对象和没达到一定年龄的对象都在新生代
* 老年代：被长时间使用的对象，老年代的内存空间应该要比年轻代更大

## 方法区（元空间）

![](..\images\db050d0052a44605a13043a0bec204f0.png)

**方法区（method area）只是 JVM 规范中定义的一个概念。**
用于存储类信息、常量、静态变量等数据，**永久代是Hotspot虚拟机对方法区的实现，Java8的时候又被元空间取代了。**
JVM 规范说方法区在**逻辑上**是堆的一部分，但目前实际上是与 Java 堆分开的（Non-Heap）

元空间（JDK1.8之前叫永久代）：存储类元信息，只是逻辑上把元空间划分到堆，但它实际存于本地内存（也就是堆外内存，不受垃圾回收器管理）。

### JVM 调优：设置元空间内存大小

东方通部署应用时，报错：java.lang.OutOfMemoryError: Metaspace 即**元空间溢出**

它默认是192M，设置了-XX:MaxMetaspaceSize=512m

MetaSpace 用来保存类加载之后的类信息，MaxMetaspaceSize 用来限制Metaspace增长上限，防止不停创建类出现OOM

### 运行时常量池（Runtime Constant Pool）

一个Java源文件编译后产生一个字节码文件，字节码文件中除了包含类、字段、方法以及接口等信息外，还包含**常量池表**，也就是各种字面量对类型、域和方法的符号引用。
因为字节码需要数据支持，通常这种数据量很大，不能直接存到字节码中，所以存到常量池中，在字节码包含了指向常量池的引用。

**注意：类型信息、字段、方法、常量保存在本地内存的元空间，但字符串常量池、静态变量仍在堆中。**
