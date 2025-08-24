## 1、整体介绍下Spring

Spring 的核心是依赖注入（Dependency Injection，DI）和控制反转（Inversion of Control，IoC）。

* 将对象的依赖关系注入到对象内部，使对象的创建和管理更加灵活
* 将对象的创建和管理权交给 Spring 容器

Spring 架构图

![img](..\images\spring01.png)

## 2、Bean 的注册过程

1）初始化Beanfactory
2）注册一个bean，其实就是一个key-value结构，key是名字，value是bean定义的信息
3）bean里面有class信息，属性信息
4）然后通过beanfactory获取bean，第一次获取不到，会往单例对象的缓存中singletonObjects存数据
5）第二次获取，会从singletonObjects中拿

## 3、Bean 的定义都包括什么信息

1）对象信息
2）属性信息
3）初始化方法
4）销毁时方法
5）单例、原型

## 4、Spring 事务

### 生效原理

当一个方法被@Transactional注解之后，Spring 会基于AOP**在方法执行之前开启一个事务**。当方法执行完毕之后，**根据方法是否报错，来决定回滚或提交事务**，Spring 在处理事务时，会从连接池中获得一个jdbc connection，将连接绑定到线程上（基于 ThreadLocal），那么同一个线程中用到的就是同一个 connection 了。

1）Spring 通过动态代理的方式实现AOP，对目标方法进行增强，private方法无法代理到
2）如果是同一个类中一个无事务方法调用另一个方法有事务的方法，事务是不会起作用的，因为这个时候调用方是this，通过this访问方法不会走代理，要调用增强过的方法，必然是调用代理后的对象，**必须通过代理过的类从外部调用目标方法才会生效**
3）只有目标方法**抛出**了**运行时异常或error**，事务才能回滚，TransactionAspectSupport  里面有个 invokeWithinTransaction 方法，处理事务逻辑：只有捕获到异常才进行后续事务处理
4）不要使用多线程，@Transactional在处理事务时会（基于ThreadLocal）将连接绑定到当前线程，由于@Transactional绑定管理的是主线程的事务，而parallelStream开启的新的线程与主线程无关。因此，事务也就无效了

### 隔离级别

事务隔离级别指的是一个事务对数据的修改与另一个并行的事务的隔离程度，当多个事务同时访问相同数据时，如果没有采取必要的隔离机制，就可能发生以下问题：

* 脏读：一个事务读到另一个事务未提交的更新数据，所谓脏读，就是指事务A读到了事务B还没有提交的数据，比如银行取钱，事务A开启事务，此时切换到事务B，事务B开启事务–>取走100元，此时切换回事务A，事务A读取的肯定是数据库里面的原始数据，因为事务B取走了100块钱，并没有提交，数据库里面的账务余额肯定还是原始余额，这就是脏读
* 幻读：是指当事务不是独立执行时发生的一种现象，例如第一个事务对一个表中的数据进行了修改，这种修改涉及到表中的全部数据行。 同时，第二个事务也修改这个表中的数据，这种修改是向表中插入一行新数据。那么，以后就会发生操作第一个事务的用户发现表中还有没有修改的数据行，就好象 发生了幻觉一样。
* 不可重复读：在一个事务里面的操作中发现了未被操作的数据 比方说在同一个事务中先后执行两条一模一样的select语句，期间在此次事务中没有执行过任何DDL语句，但先后得到的结果不一致，这就是不可重复读

Spring建议的是使用DEFAULT，就是数据库本身的隔离级别：

```java
@Transactional(isolation=Isolation.DEFAULT)
public void fun(){
	dao.add();
	dao.udpate();
}
```

### 生效机制

1）必须在public方法上：spring默认通过动态代理的方法实现aop，对目标方法进行增强，private方法无法代理到：

> 因为不管是Cglib，还是JDK自带的动态代理，本质上是通过在运行时定义新的Class来实现的，而这个Class**必须是原Class的接口实现类或者子类** ，因为如果不是接口实现类、子类的关系，就无法被注入到代码的引用中。

2）必须通过代理过的类从外部调用目标方法才生效
3）Spring 默认只会对标记 @Transactional 注解的方法出现了 RuntimeException 和 Error 的时候回滚，如果我们的方法捕获了异常，那么需要通过手动编码处理事务回滚

## 5、AOP

**面向切面编程 - Aspect Oriented Programming**

### 1）为什么要有aop

软件开发中，散布于应用多处的功能被称为横切关注点，这些横切关注点从概念上是和业务逻辑分离的（但是往往会直接嵌入到业务逻辑中），把这些横切关注点与业务逻辑分离正是面向切面编程要解决的问题。

### 2）aop如何实现

如何使用代理，给一个接口的实现类，用代理的方式替换掉这个实现类，使用代理类处理我需要的逻辑。

#### 方法拦截

Spring默认在目标类实现接口时是通过JDK代理实现的，只有非接口的是通过Cglib代理实现的

JDK:

```java
Proxy.newProxyInstance(target.getClass().getClassLoader(), target.getClass().getInterfaces(), new InvocationHandler() {}
```

CGLIB:

* 基于 Cglib 使用 Enhancer 代理的类可以在运行期间为接口使用底层 ASM 字节码增强技术处理对象的代理对象生成，因此被代理类不需要实现任何接口
* 扩展进去的用户拦截方法，主要是在 Enhancer#setCallback 中处理
* 被代理的对象不可以用final修饰，否则会报异常：java.lang.IllegalArgumentException

为什么不能代理**静态方法**：

Spring AOP的两种实现方式：Cglib和JDK动态代理，分别是通过生成目标类的子类和实现目标接口的方式来创建动态代理的，而静态方法不能被子类重写，更谈不上接口实现。

### 3）术语

#### 1）通知（Advice）

切面要完成的工作：
前置通知
后置通知
返回通知
异常通知
环绕通知

#### 2）连接点（Join point）

插入切面的时机，可以是调用方法时，抛出异常时
切面利用这些点插入到应用的正常流程中

#### 3）切点（Point）

匹配类和方法名称

#### 4）切面

通知+切点=切面

## 6、Bean 加载过程

## 7、Bean生命周期

![img](..\images\spring-framework-ioc-source-102.png)

#### 1. **实例化（Instantiation）**

* Spring 容器根据配置（XML、注解或 Java Config）通过反射（`newInstance()` 或构造函数）创建 Bean 实例。
* 此时 Bean 已经存在于 JVM 堆中，但属性还未赋值。

> ✅ 触发点：`InstantiationAwareBeanPostProcessor.postProcessBeforeInstantiation()`（可拦截创建过程）

#### 2. **属性赋值（Populate Properties）**

* Spring 容器将配置中定义的属性值或依赖的其他 Bean 注入到当前 Bean 中。
* 包括 `@Autowired`、`@Value`、`setter` 注入等。

> ✅ 例如：`this.userService = userService;`

#### 3. **初始化前（Bean Post Processor - postProcessBeforeInitialization）**

* 调用所有注册的 `BeanPostProcessor` 的 `postProcessBeforeInitialization()` 方法。
* 可以在此阶段对 Bean 进行增强或修改（如 AOP 代理的创建可能在此开始）。

#### 4. **初始化（Initialization）**

Bean 执行初始化逻辑，顺序如下：

##### a. **`@PostConstruct` 注解方法**

* JSR-250 注解，由 `InitDestroyAnnotationBeanPostProcessor` 处理。

##### b. **实现 `InitializingBean` 接口的 `afterPropertiesSet()` 方法**

* Spring 特有接口，不推荐直接使用（侵入性强）。

##### c. **自定义 `init-method`**

* 在 XML 中配置 `<bean init-method="init">` 或使用 `@Bean(initMethod = "init")`。

> ✅ 执行顺序：`@PostConstruct` → `afterPropertiesSet()` → `init-method`

#### 5. **初始化后（Bean Post Processor - postProcessAfterInitialization）**

* 调用所有 `BeanPostProcessor` 的 `postProcessAfterInitialization()` 方法。
* **AOP 代理对象通常在此阶段生成** （如 `@Transactional`、`@Async`）。
* 这是 Bean 生命周期的最后一个增强点。

#### 6. **就绪使用（In Use）**

* Bean 已完全初始化，放入 Spring 容器（`BeanFactory`）中，可以被其他 Bean 使用或从容器获取。

#### 7. **销毁（Destruction）**

当容器关闭时，执行销毁逻辑，顺序如下：

##### a. **`@PreDestroy` 注解方法**

* JSR-250 注解，由 `InitDestroyAnnotationBeanPostProcessor` 处理。

##### b. **实现 `DisposableBean` 接口的 `destroy()` 方法**

##### c. **自定义 `destroy-method`**

* 在 XML 中配置 `<bean destroy-method="cleanup">` 或使用 `@Bean(destroyMethod = "cleanup")`。

> ✅ 执行顺序：`@PreDestroy` → `destroy()` → `destroy-method`

> ⚠️ 注意：只有 **单例（Singleton）Bean** 会执行销毁方法。**原型（Prototype）Bean** 容器不管理其销毁。

### BeanFactory() ApplicationContext()区别

| 特性               | `BeanFactory`            | `ApplicationContext`                             |
| ------------------ | -------------------------- | -------------------------------------------------- |
| **初始化**   | 延迟初始化                 | 预实例化                                           |
| **功能**     | 基本的IoC容器功能          | 提供更多企业级功能，如事件机制、国际化、自动装配等 |
| **配置支持** | 主要通过XML配置            | 支持XML、注解、Java配置类                          |
| **使用场景** | 适合资源受限环境或简单应用 | 推荐用于大多数企业级应用                           |
| **集成支持** | 无                         | 提供与AOP、事务管理等的集成支持                    |

## 8、IOC

![](..\images\spring-framework-ioc-source-74.png)

 **Inversion of Control (IoC)**

如果不使用控制反转，多个组件用到了同一个service，就要创建多个对象，那就是我们只做到了逻辑复用，并没有做到资源复用。
许多组件只需要实例化一个对象就行，创建多个没意义

出现这个问题的原因是：组件的调用方参与了组件的创建和配置工作。
解决方案就是如果有一个东西帮我们创建和配置好那些组件，我们只负责调用。这个东西就是容器，称之为**ioc容器**。

控制反转，指对象的创建和配置的控制权，从调用方转移给容器，交由容器管理的对象称之为bean。

## 9、装配Bean

1、xml 显式配置
2、Java 显式配置
3、隐式的 bean 发现机制和自动装配

### 自动化装配 bean

什么是装配：创建**应用之间的协作关系**的行为
1、组件扫描（component scan）：spring 会自动发现应用上下文中创建的bean
	设置@ComponentScan基础包
2、自动装配（autowiring）：spring自动满足bean之间的依赖
	@Autowired

## 10、bean 的作用域

* 单例：在整个应用中，只创建bean的一个实例
* 原型：每次注入或者通过spring应用上下文获取的时候，都会创建一个新的bean实例
* 会话：在web应用中，为每个会话创建一个bean实例
* 请求：在web应用中，为每个请求创建一个bean实例

## 11、springmvc的请求

1）所有请求会通过DispatcherServlet（前端控制器）
2）DispatcherServlet 查询 handler mapping，确定请求的下一站，根据请求携带的url信息来决策
3）DispatcherServlet 把请求发送给选中的控制器（controller），卸下请求中所带的所有信息
4）将模型数据和视图名发送给 DispatcherServlet
5）DispatcherServlet 使用视图解析器来将逻辑视图名匹配成一个特定的视图实现
6）最后一站是视图的实现，在视图交付模型数据
7）通过响应对象传递给客户端

## 12、属性依赖

### 单例循环依赖

Spring只是解决了单例模式下属性依赖的循环问题，使用了三级缓存。

```java
/** Cache of singleton objects: bean name --> bean instance */
private final Map<String, Object> singletonObjects = new ConcurrentHashMap<String, Object>(256);
 
/** Cache of early singleton objects: bean name --> bean instance */
private final Map<String, Object> earlySingletonObjects = new HashMap<String, Object>(16);

/** Cache of singleton factories: bean name --> ObjectFactory */
private final Map<String, ObjectFactory<?>> singletonFactories = new HashMap<String, ObjectFactory<?>>(16);
```

* 第一层缓存（singletonObjects）：单例对象缓存池，已经实例化并且属性赋值，这里的对象是**成熟对象**
* 第二层缓存（earlySingletonObjects）：单例对象缓存池，已经实例化但尚未属性赋值，这里的对象是**半成品对象**；
* 第三层缓存（singletonFactories）：存放能创建早期暴露对象的 **`ObjectFactory，`**

关键的就是第三层：对象已经生产了，但还没初始化完成，但能够被人认出来（根据对象引用能定位到堆中的对象），**因此 Spring 提前将这个对象曝光出来，让别人使用**。

核心流程如下：

* 当 A 创建时，实例化后，会**立即**将一个 `ObjectFactory` 放入 **三级缓存** 。
* 然后开始填充属性，发现依赖 B。
* 此时 B 开始创建流程，实例化后也放入三级缓存。
* B 填充属性时发现依赖 A，于是去三级缓存查找 A 的 `ObjectFactory`。
* 调用 `ObjectFactory.getObject()`，这个方法会：
  1. 将 A 的原始对象从三级缓存移出。
  2. **（关键）** 如果 A 需要代理，则创建代理对象；否则返回原始对象。
  3. 将这个对象（原始或代理）放入 **二级缓存** 。
  4. 返回给 B。
* B 拿到 A 的引用后完成创建，放入一级缓存。
* 回到 A，继续初始化流程，完成后将 A 从二级缓存移入一级缓存。


#### ！**为什么不能直接把半成品放进二级缓存，而要通过三级缓存的工厂来创建？**

主要是为了支持 AOP。

如果只有二级缓存，我们只能提前暴露原始对象。但如果 A 需要代理，B 拿到的将是原始对象，这会导致 AOP 失效。三级缓存的 `ObjectFactory` 允许在真正需要时才创建代理对象，保证了最终所有引用都指向正确的代理实例。


### 其它循环依赖

#### Spring 不能解决构造器的循环依赖

调用构造方法之前，还没将它放入三级缓存，后续依赖调用构造方法的时候，并不能从三级缓存中获取到依赖的Bean。

使用 @DependsOn，指定加载先后关系。



## 13、缓存

@Cacheable：表明Spring调用该方法之前，首先在缓存中查找方法的返回值，如果这个值能够找到，就会返回缓存的值，否则，这个方法就会被调用，返回值会被放到缓存中。

@CachePut：表明Spring 应该将返回值放到缓存中，在方法调用前并不会检查缓存，方法始终会被调用。

@CacheEvit：表明Spring应该在缓存中清除一个或多个条目

@Caching：这是一个分组注解：能够同时应用多个其他缓存注解。

===============================================================

# 控制反转

在传统开发中，需要调用对象时，通常由调用者来创建被调用者的实例，即对象是由调用者主动new出来的。

但在Spring框架中创建对象的工作不再由调用者来完成，而是交给 IOC 容器来创建，再推送给调用者，整个流程完成反转，所以是控制反转。

![](..\images\TIM截图20200304140403.png)

## 如何使用 IoC

- 创建 Maven 工程，pom.xml 添加依赖

```xml
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-context</artifactId>
            <version>5.0.11.RELEASE</version>
        </dependency>
```

- 创建实体类 Student

```java
@Data
public class Student {
    private long id;
    private String name;
    private int age;
}
```

- 传统的开发方式，手动 new Student

```java
Student student = new Student();
student.setId(1L);
student.setName("张三");
student.setAge(22);
System.out.println(student);
```

- 通过 IoC 创建对象，在配置文件中添加需要管理的对象，XML 格式的配置文件，文件名可以自定义。
  - \<bean> 就是 JavaBean，就是一个对象
  - \<property> 中的 name 就会关联实体类的成员变量，value 赋值

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xmlns:p="http://www.springframework.org/schema/p"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-3.2.xsd
	http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context-4.3.xsd
">
    <bean id="student" class="com.southwind.entity.Student">
        <property name="id" value="1"></property>
        <property name="name" value="张三"></property>
        <property name="age" value="22"></property>
    </bean>

</beans>
```

- 从 IoC 中获取对象，通过 id 获取。

```java
// 加载配置文件
ApplicationContext applicationContext = new ClassPathXmlApplicationContext("spring.xml");
// applicationContext 就是 IOC 对象，传一个id就可以从里面取出对象
Student student = (Student) applicationContext.getBean("student");
System.out.println(student);
```

## 配置文件

- 通过配置 `bean` 标签来完成对象的管理。

  - `id`：对象名。
  - `class`：对象的模版类（所有交给 IoC 容器来管理的类**必须有无参构造函数**，因为 Spring 底层是通过**反射机制**来创建对象，调用的是无参构造）
- 对象的成员变量通过 `property` 标签完成赋值。

  - `name`：成员变量名。
  - `value`：成员变量值（基本数据类型，String 可以直接赋值，如果是其他引用类型，不能通过 value 赋值）
  - `ref`：将 IoC 中的另外一个 bean 赋给当前的成员变量（DI）

  ```xml
  <bean id="student" class="com.southwind.entity.Student">
      <property name="id" value="1"></property>
      <property name="name" value="张三"></property>
      <property name="age" value="22"></property>
      <property name="address" ref="address"></property>
  </bean>

  <bean id="address" class="com.southwind.entity.Address">
      <property name="id" value="1"></property>
      <property name="name" value="科技路"></property>
  </bean>
  ```

## IoC 底层原理

- 读取配置文件，解析 XML。
- 通过反射机制实例化配置文件中所配置所有的 bean。

  - 接口

  ```java
  package com.southwind.ioc;

  public interface ApplicationContext {
      public Object getBean(String id);
  }
  ```

  * 实现类

  ```java
  package com.southwind.ioc;

  public class ClassPathXmlApplicationContext implements ApplicationContext {

      private Map<String, Object> ioc = new HashMap<String, Object>();

      public ClassPathXmlApplicationContext(String path) {
          // 使用 dom4j 的方法读取 xml
          try {
              SAXReader reader = new SAXReader();
              Document document = reader.read("./src/main/resources/" + path);
              // 取根节点
              Element root = document.getRootElement();
              // 迭代
              Iterator<Element> iterator = root.elementIterator();
              while (iterator.hasNext()) {
                  Element element = iterator.next();
                  String id = element.attributeValue("id");
                  String className = element.attributeValue("class");
                  // 通过反射机制创建对象
                  Class clazz = Class.forName(className);
                  // 获取无参构造函数，创建目标对象
                  Constructor constructor = clazz.getConstructor();
                  Object object = constructor.newInstance();
                  // 给目标对象赋值
                  // 遍历读取property
                  Iterator<Element> beanIter = element.elementIterator();
                  while (beanIter.hasNext()) {
                      Element property = beanIter.next();
                      String name = property.attributeValue("name");
                      String valueStr = property.attributeValue("value");
                      String ref = property.attributeValue("ref");
                      if (ref == null) {
                          String methodName = "set" + name.substring(0, 1).toUpperCase() + name.substring(1);
                          Field field = clazz.getDeclaredField(name);
                          Method method = clazz.getDeclaredMethod(methodName, field.getType());
                          // 根据成员变量的数据类型将value进行转换
                          Object value = null;
                          if (field.getType().getName() == "long") {
                              value = Long.parseLong(valueStr);
                          }
                          if (field.getType().getName() == "java.lang.String") {
                              value = valueStr;
                          }
                          if (field.getType().getName() == "int") {
                              value = Integer.parseInt(valueStr);
                          }
                          method.invoke(object, value);
                      }
                      ioc.put(id, object);
                  }
              }
          } catch (DocumentException | ClassNotFoundException | NoSuchMethodException e) {
              e.printStackTrace();
          } catch (IllegalAccessException e) {
              e.printStackTrace();
          } catch (InstantiationException e) {
              e.printStackTrace();
          } catch (InvocationTargetException | NoSuchFieldException e) {
              e.printStackTrace();
          }
      }

      /**
       * 通过 id去容器（Map集合）里面取出对象
       *
       * @param id
       * @return
       */
      @Override
      public Object getBean(String id) {
          return ioc.get(id);
      }
  }
  ```

  * 测试类

  ```java
  package com.southwind.ioc;

  import com.southwind.entity.Student;

  /**
   * 使用自己写的 ApplicationContext
   * @author lvmc
   */
  public class Test {
      public static void main(String[] args) {
          ApplicationContext applicationContext = new ClassPathXmlApplicationContext("spring.xml");
          Student student = (Student) applicationContext.getBean("student");
          System.out.println(student);
      }
  }
  ```

## 通过运行时类获取 bean

```java
ApplicationContext applicationContext = new ClassPathXmlApplicationContext("spring.xml");
Student student = (Student) applicationContext.getBean(Student.class);
System.out.println(student);
```

这种方式存在一个问题，配置文件中一个数据类型的对象**只能有一个实例**，否则会抛出异常，因为没有唯一的 bean。

## 通过有参构造创建 bean

- 在实体类中创建对应的有参构造函数。

  ```java
  @Data
  @AllArgsConstructor
  @NoArgsConstructor
  public class Student {
      private long id;
      private String name;
      private int age;
      private Address address;
  }
  ```

  @AllArgsConstructor 生成的是4个参数的有参构造

  ```java
      public Student(long id, String name, int age, Address address) {
          this.id = id;
          this.name = name;
          this.age = age;
          this.address = address;
      }
  ```
- 配置文件

  写法一：

```xml
<bean id="student3" class="com.southwind.entity.Student">
    <constructor-arg name="id" value="3"></constructor-arg>
    <constructor-arg name="name" value="小明"></constructor-arg>
    <constructor-arg name="age" value="18"></constructor-arg>
    <constructor-arg name="address" ref="address"></constructor-arg>
</bean>
```

id，name，age，address 四个参数缺一不可，因为 `@AllArgsConstructor` 生成的构造函数是四个参数

    写法二：通过下标，按照有参构造4个参数的顺序，所以顺序不能变

```xml
<bean id="student3" class="com.southwind.entity.Student">
    <constructor-arg index="0" value="3"></constructor-arg>
    <constructor-arg index="2" value="18"></constructor-arg>
    <constructor-arg index="1" value="小明"></constructor-arg>
    <constructor-arg index="3" ref="address"></constructor-arg>
</bean>
```

## 给 bean 注入集合

```java
@Data
@AllArgsConstructor
@NoArgsConstructor
public class Student {
    private long id;
    private String name;
    private int age;
    private List<Address> addresses;
}
```

```xml
<bean id="student" class="com.southwind.entity.Student">
    <property name="id" value="2"></property>
    <property name="name" value="李四"></property>
    <property name="age" value="33"></property>
    <property name="addresses">
        <list>
            <ref bean="address"></ref>
            <ref bean="address2"></ref>
        </list>
    </property>
</bean>

<bean id="address" class="com.southwind.entity.Address">
    <property name="id" value="1"></property>
    <property name="name" value="科技路"></property>
</bean>

<bean id="address2" class="com.southwind.entity.Address">
    <property name="id" value="2"></property>
    <property name="name" value="高新区"></property>
</bean>
```

## scope 作用域

Spring 管理的 bean 是根据 scope 来生成的，表示 bean 的作用域，共4种，默认值是 singleton。

- singleton：单例，表示通过 IoC 容器获取的 bean 是唯一的。

```java
        // 加载配置文件
        ApplicationContext applicationContext = new ClassPathXmlApplicationContext("spring.xml");
        // applicationContext 就是 IOC 对象，传一个id就可以从里面取出对象
        Student student = (Student) applicationContext.getBean("student");
        Student student1 = (Student) applicationContext.getBean("student");
        // student 和 student1 都是引用类型，== 判断内存地址，若相同，说明引用同一块内存，则是同一个对象
        System.out.println(student==student1);
```

输出 true

- prototype：原型，表示通过 IoC 容器获取的 bean 是不同的。

```xml
<bean id="student" class="com.southwind.entity.Student" scope="prototype">
```

再次运行，输出 false，说明不是同一个对象

- request：请求，表示在一次 HTTP 请求内有效。
- session：回话，表示在一个用户会话内有效。

request 和 session 只适用于 Web 项目，大多数情况下，使用单例和原型较多。

prototype 模式当业务代码获取 IoC 容器中的 bean 时，Spring 才去调用无参构造创建对应的 bean。

singleton 模式无论业务代码是否获取 IoC 容器中的 bean，Spring 在加载 spring.xml 时就会创建 bean。

> 单例模式加载的时候就会把配置文件里所有bean创建好，单例对象的生命周期和容器相同，当容器创建时，对象出生，只要容器还在，对象一直活着。
>
> 缺点是：
>
> 如果业务代码不需要使用bean，那就白创建了；
>
> 优点是：
>
> 更加节省空间，多个bean指向同一个地址；
>
> 原型模式是在获取bean的时候才去创建。对象只要在使用过程中就一直活着，当对象长时间不用，且没有别的对象引用时，由 Java 的垃圾回收器回收
>
> 缺点：浪费空间
>
> 优点：避免了创建用不到的bean的情况

## Spring 的继承

与 Java 的继承不同，Java 是**类层面**的继承，子类可以继承父类的内部结构信息；Spring 是**对象层面**的继承，子对象可以继承父对象的属性值。

```xml
<bean id="student2" class="com.southwind.entity.Student">
    <property name="id" value="1"></property>
    <property name="name" value="张三"></property>
    <property name="age" value="22"></property>
    <property name="addresses">
        <list>
            <ref bean="address"></ref>
            <ref bean="address2"></ref>
        </list>
    </property>
</bean>

<bean id="address" class="com.southwind.entity.Address">
    <property name="id" value="1"></property>
    <property name="name" value="科技路"></property>
</bean>

<bean id="address2" class="com.southwind.entity.Address">
    <property name="id" value="2"></property>
    <property name="name" value="高新区"></property>
</bean>

<bean id="stu" class="com.southwind.entity.Student" parent="student2">
    <property name="name" value="李四"></property>
</bean>
```

Spring 的继承关注点在于具体的对象，而不在于类，即**不同的两个类的实例化对象可以完成继承，前提是子对象必须包含父对象的所有属性，同时可以在此基础上添加其他的属性。**

## Spring 的依赖

与继承类似，依赖也是描述 bean 和 bean 之间的一种关系，配置依赖之后，被依赖的 bean 一定先创建，再创建依赖的 bean，A 依赖于 B，先创建 B，再创建 A。

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-3.2.xsd
                           ">

    <bean id="student" class="com.southwind.entity.Student" depends-on="user"></bean>

    <bean id="user" class="com.southwind.entity.User"></bean>

</beans>
```

现在是先创建 user，再创建 student。

如果没有 depends-on="user"，默认顺序是从上往下，所以先创建 student，再创建 user。

## Spring 的 p 命名空间

p 命名空间是对 IoC / DI 的简化操作，使用 p 命名空间可以更加方便的完成 bean 的配置以及 bean 之间的依赖注入。

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xmlns:p="http://www.springframework.org/schema/p"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-3.2.xsd
	http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context-4.3.xsd
">

    <bean id="student" class="com.southwind.entity.Student" p:id="1" p:name="张三" p:age="22" p:address-ref="address"></bean>

    <bean id="address" class="com.southwind.entity.Address" p:id="2" p:name="科技路"></bean>

</beans>
```

## Spring 的工厂方法

IoC 通过工厂模式创建 bean 的方式有两种：

- 静态工厂方法
- 实例工厂方法

### 一、静态工厂方法

```java
package com.southwind.entity;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class Car {
    private long id;
    private String name;
}
```

```java
package com.southwind.factory;

/**
 * 工厂把汽车创建好提供给外部的调用者
 * 静态工厂：不需要实例化这个工厂，直接调用工厂的静态方法就可以获取汽车对象
 * @author lvmc
 */
public class StaticCarFactory {

    /**
     * 作为容器，存储生产好的汽车，一般使用集合
     */
    private static Map<Long, Car> carMap;

    // 静态代码块只要类一被加载就会执行
    static {
        carMap = new HashMap<>();
        carMap.put(1L,new Car(1L,"宝马"));
        carMap.put(2L,new Car(2L,"奔驰"));
    }

    public static Car getCar(long id) {
        return carMap.get(id);
    }
}
```

```java
public class Test2 {
    public static void main(String[] args) {
        Car car = StaticCarFactory.getCar(1L);
        System.out.println(car);
    }
}
```

把静态工厂交给 IOC 管理

```xml
<!-- 配置静态工厂创建 Car -->
<bean id="car" class="com.southwind.factory.StaticCarFactory" factory-method="getCar">
    <constructor-arg value="2"></constructor-arg>
</bean>
```

```java
    public static void main(String[] args) {
        ApplicationContext applicationContext =new ClassPathXmlApplicationContext("spring-factory.xml");
        Car car = (Car) applicationContext.getBean("car");
        System.out.println(car);
    }
```

解析：

1）new ClassPathXmlApplicationContext("spring-factory.xml") 读取配置文件

2）class="com.southwind.factory.StaticCarFactory"  加载此类，不是实例化它的对象

3）立刻执行 static {}  静态代码块，完成 carMap 初始化

4）进入 getCar() 方法，

5）constructor-arg value="2" 把 2 传进来，由于是单例模式，此时 car 对象已经生成

### 二、实例工厂方法

```java
package com.southwind.factory;

import com.southwind.entity.Car;

import java.util.HashMap;
import java.util.Map;

public class InstanceCarFactory {
    private Map<Long, Car> carMap;
    public InstanceCarFactory(){
        carMap = new HashMap<Long, Car>();
        carMap.put(1L,new Car(1L,"宝马"));
        carMap.put(2L,new Car(2L,"奔驰"));
    }

    public Car getCar(long id){
        return carMap.get(id);
    }
}
```

```java
InstanceCarFactory instanceCarFactory = new InstanceCarFactory();
Car car = instanceCarFactory.getCar(1L);
System.out.println(car);
```

把实例工厂交给 IOC 管理

```xml
<!-- 配置实例工厂 bean
 	 调用 InstanceCarFactory 的无参，在无参里实例化 carMap-->
<bean id="carFactory" class="com.southwind.factory.InstanceCarFactory"></bean>

<!-- 配置实例工厂创建 Car -->
<bean id="car2" factory-bean="carFactory" factory-method="getCar">
    <constructor-arg value="1"></constructor-arg>
</bean>
```

```java
    public static void main(String[] args) {
        ApplicationContext applicationContext =new ClassPathXmlApplicationContext("spring-factory.xml");
        Car car = (Car) applicationContext.getBean("car2");
        System.out.println(car);
    }
```

静态工厂只需要配一个\<bean>，因为工厂不需要实例化，只需要实例化目标的 car 就行；

实例工厂需要配置两个 \<bean>，因为工厂本身就需要实例化，先创建工厂对象，再通过工厂对象创建 car 对象

## IoC 自动装载（Autowire）

IoC 负责创建对象，DI 负责完成对象的依赖注入，通过配置 property 标签的 ref 属性来完成。

同时 Spring 提供了另外一种更加简便的依赖注入方式：自动装载，不需要手动配置 property，IoC 容器会自动选择 bean 完成注入。

自动装载有两种方式：

- byName：通过属性名自动装载
- byType：通过属性的数据类型自动装载

```java
@Data
public class Person {
    private long id;
    private String name;
    private Car car;
}
```

### 一、byName

```xml
<bean id="car" class="com.southwind.entity.Car">
    <property name="id" value="1"></property>
    <property name="name" value="宝马"></property>
</bean>

<bean id="person" class="com.southwind.entity.Person" autowire="byName">
    <property name="id" value="11"></property>
    <property name="name" value="张三"></property>
</bean>
```

\<bean id="car"  与属性 car 对应，如果改为 cars，则不能自动装载

### 二、byType

```xml
<bean id="car" class="com.southwind.entity.Car">
    <property name="id" value="2"></property>
    <property name="name" value="奔驰"></property>
</bean>

<bean id="person" class="com.southwind.entity.Person" autowire="byType">
    <property name="id" value="11"></property>
    <property name="name" value="张三"></property>
</bean>
```

byType 需要注意，如果同时存在两个及以上的符合条件的 bean 时，自动装载会抛出异常。

# AOP

AOP：Aspect Oriented Programming 面向切面编程

AOP 的优点：

- 降低模块之间的耦合度。
- 使系统更容易扩展。
- 更好的代码复用。
- 非业务代码更加集中，不分散，便于统一管理。
- 业务代码更加简洁纯粹，不参杂其他代码的影响。

AOP 是对面向对象编程的一个补充，在运行时，动态地将代码切入到类的指定方法、指定位置上的编程思想就是面向切面编程。

将不同方法的同一个位置抽象成一个切面对象，对该切面对象进行编程就是 AOP。

## 如何使用？

- 创建 Maven 工程，pom.xml 添加

```xml
<dependencies>
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-context</artifactId>
        <version>5.0.2.RELEASE</version>
    </dependency>
  
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-aop</artifactId>
        <version>5.0.2.RELEASE</version>
    </dependency>

    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-aspects</artifactId>
        <version>5.0.2.RELEASE</version>
    </dependency>
</dependencies>
```

- 创建一个计算器接口 Cal，定义4个方法。

```java
package com.southwind.utils;

public interface Cal {
    public int add(int num1,int num2);
    public int sub(int num1,int num2);
    public int mul(int num1,int num2);
    public int div(int num1,int num2);
}
```

- 创建接口的实现类 CalImpl。

```java
package com.southwind.utils.impl;

import com.southwind.utils.Cal;

public class CalImpl implements Cal {
    public int add(int num1, int num2) {
        System.out.println("add方法的参数是["+num1+","+num2+"]");
        int result = num1+num2;
        System.out.println("add方法的结果是"+result);
        return result;
    }

    public int sub(int num1, int num2) {
        System.out.println("sub方法的参数是["+num1+","+num2+"]");
        int result = num1-num2;
        System.out.println("sub方法的结果是"+result);
        return result;
    }

    public int mul(int num1, int num2) {
        System.out.println("mul方法的参数是["+num1+","+num2+"]");
        int result = num1*num2;
        System.out.println("mul方法的结果是"+result);
        return result;
    }

    public int div(int num1, int num2) {
        System.out.println("div方法的参数是["+num1+","+num2+"]");
        int result = num1/num2;
        System.out.println("div方法的结果是"+result);
        return result;
    }
}
```

```java
    public static void main(String[] args) {
        Cal cal = new CalImpl();
        cal.add(1, 1);
        cal.sub(2, 1);
        cal.mul(2, 3);
        cal.div(6, 2);
    }
```

上述代码中，日志信息和业务逻辑的耦合性很高，不利于系统的维护，使用 AOP 可以进行优化，如何来实现 AOP？

**使用动态代理的方式来实现。**

给业务代码找一个代理，打印日志信息的工作交个代理来做，这样的话业务代码就只需要关注自身的业务即可。

“代理”是一个对象，创建对象需要用到类，这个“类”是动态产生的，而我们之前写代码，类都是写死的，都是先写类再写对象。

动态代理的“类”，是指没有写这个类，程序启动之后，动态的创建类

```java
package com.southwind.utils;

/**
 * MyInvocationHandler 用来动态创建类，这不是一个代理类，而是帮助创建动态代理类的类
 *
 * @author lvmc
 */
public class MyInvocationHandler implements InvocationHandler {

    /**
     * 接收委托对象,相当于找房子的人，中介就是代理对象
     */
    private Object object = null;


    /**
     *
     * @param object
     * @return 代理对象
     */
    public Object bind(Object object) {
        // 把形参赋给成员变量
        this.object = object;
        return Proxy.newProxyInstance(object.getClass().getClassLoader(), object.getClass().getInterfaces(), this);
    }


    @Override
    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
        System.out.println(method.getName() + "方法的参数是：" + Arrays.toString(args));
        Object result = method.invoke(this.object, args);
        System.out.println(method.getName() + "的结果是" + result);
        return result;
    }
}
```

```java
    public static void main(String[] args) {
        // 委托对象
        Cal cal = new CalImpl();
        // 通过 myInvocationHandler 来创建一个代理对象
        MyInvocationHandler myInvocationHandler = new MyInvocationHandler();
        // 代理对象一定有委托对象的所有功能，所以cal1有了cal的功能
        Cal cal1 = (Cal) myInvocationHandler.bind(cal);
        cal1.add(1, 1);
        cal1.sub(2, 1);
        cal1.mul(2, 3);
        cal1.div(6, 2);
    }
```

以上是通过动态代理实现 AOP 的过程，比较复杂，不好理解，Spring 框架对 AOP 进行了封装，使用 Spring 框架可以用面向对象的思想来实现 AOP。

Spring 框架中不需要创建 InvocationHandler，只需要创建一个切面对象，将所有的非业务代码在切面对象中完成即可，Spring 框架底层会自动根据切面类以及目标类生成一个代理对象。

#### LoggerAspect

```java
package com.southwind.aop;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.*;
import org.springframework.stereotype.Component;

import java.util.Arrays;

/**
 * @author lvmc
 * @Component 把此类交给 IOC，相当于在 spring.xml 中配了一个 bean
 * @Aspect 称为一个切面对象
 */
@Aspect
@Component
public class LoggerAspect {


    /**
     * 切割 CalImpl 里面的所有方法，* 表示所有方法，(..)表示所有参数
     * 在执行业务方法之前会执行 before 里面的方法：打印参数
     *
     * @param joinPoint 连接点：连接此方法与目标方法，把 joinPoint 里面拿到目标方法的信息
     */
    @Before("execution(public int com.southwind.utils.impl.CalImpl.*(..))")
    public void before(JoinPoint joinPoint) {
        // 获取方法名
        String name = joinPoint.getSignature().getName();
        // 获取参数
        String args = Arrays.toString(joinPoint.getArgs());
        System.out.println(name + "方法的参数是：" + args);
    }

    @After(value = "execution(public int com.southwind.utils.impl.CalImpl.*(..))")
    public void after(JoinPoint joinPoint) {
        //获取方法名
        String name = joinPoint.getSignature().getName();
        System.out.println(name + "方法执行完毕");
    }

    @AfterReturning(value = "execution(public int com.southwind.utils.impl.CalImpl.*(..))", returning = "result")
    public void afterReturning(JoinPoint joinPoint, Object result) {
        //获取方法名
        String name = joinPoint.getSignature().getName();
        System.out.println(name + "方法的结果是" + result);
    }

    @AfterThrowing(value = "execution(public int com.southwind.utils.impl.CalImpl.*(..))", throwing = "exception")
    public void afterThrowing(JoinPoint joinPoint, Exception exception) {
        //获取方法名
        String name = joinPoint.getSignature().getName();
        System.out.println(name + "方法抛出异常：" + exception);
    }
}
```

LoggerAspect 类定义处添加的两个注解：

- `@Aspect`：表示该类是切面类。
- `@Component`：将该类的对象注入到 IoC 容器。

具体方法处添加的注解：

`@Before`：表示方法执行的具体位置和时机。

CalImpl 也需要添加 `@Component`，交给 IoC 容器来管理。

```java
package com.southwind.utils.impl;

import com.southwind.utils.Cal;
import org.springframework.stereotype.Component;

@Component
public class CalImpl implements Cal {
    public int add(int num1, int num2) {
        int result = num1+num2;
        return result;
    }

    public int sub(int num1, int num2) {
        int result = num1-num2;
        return result;
    }

    public int mul(int num1, int num2) {
        int result = num1*num2;
        return result;
    }

    public int div(int num1, int num2) {
        int result = num1/num2;
        return result;
    }
}
```

#### spring.xml 中配置 AOP

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xmlns:aop="http://www.springframework.org/schema/aop"
       xmlns:p="http://www.springframework.org/schema/p"
       xsi:schemaLocation="http://www.springframework.org/schema/aop http://www.springframework.org/schema/aop/spring-aop-4.3.xsd
       http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-4.3.xsd
	http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context-4.3.xsd
">

    <!-- 自动扫描 -->
    <context:component-scan base-package="com.southwind"></context:component-scan>

    <!-- 是Aspect注解生效，为目标类自动生成代理对象 -->
    <aop:aspectj-autoproxy></aop:aspectj-autoproxy>

</beans>
```

`context:component-scan` 将 `com.southwind` 包中的所有类进行扫描，如果该类同时添加了 `@Component`，则将该类扫描到 IoC 容器中，即 IoC 管理它的对象。

`aop:aspectj-autoproxy` 让 Spring 框架结合切面类和目标类自动生成动态代理对象。

#### 测试

```java
    public static void main(String[] args) {

        // 加载配置文件
        ApplicationContext applicationContext = new ClassPathXmlApplicationContext("spring-aop.xml");
        // 获取代理对象，参数是目标类的类名且首字母小写
        Cal proxy = (Cal) applicationContext.getBean("calImpl");
        proxy.add(1,2);
    }
```

- 切面：横切关注点被模块化的抽象对象。
- 通知：切面对象完成的工作。
- 目标：被通知的对象，即被横切的对象。
- 代理：切面、通知、目标混合之后的对象。
- 连接点：通知要插入业务代码的具体位置。
- 切点：AOP 通过切点定位到连接点。

## 原理

【看给容器中注册了什么组件，这个组件什么时候工作，这个组件的功能是什么？】

一、给配置类中加 @EnableAspectJAutoProxy，开启基于注解的aop模式，可以看到此注解给容器中导入 AspectJAutoProxyRegistrar

```java
// 利用AspectJAutoProxyRegistrar自定义给容器中注册bean
@Import({AspectJAutoProxyRegistrar.class})
```

利用AspectJAutoProxyRegistrar给容器中注册

> AnnotationAwareAspectJAutoProxyCreator(注解装配模式的AspectJ切面自动代理创建器)

二、AnnotationAwareAspectJAutoProxyCreator -> AspectJAwareAdvisorAutoProxyCreator -> AbstractAutoProxyCreator

实现了**后置处理器、自动装配BeanFactory**

```java
public abstract class AbstractAutoProxyCreator extends ProxyProcessorSupport implements SmartInstantiationAwareBeanPostProcessor, BeanFactoryAware
```

1、AbstractAutoProxyCreator.setBeanFactory

2、AbstractAutoProxyCreator.postProcessBeforeInstantiation

3、AbstractAutoProxyCreator.postProcessAfterInitialization

AbstractAdvisorAutoProxyCreator.setBeanFactory

AbstractAdvisorAutoProxyCreator.initBeanFactory

AspectJAwareAdvisorAutoProxyCreator.AspectJAwareAdvisorAutoProxyCreator

## 切面顺序

切面本身是一个 Bean，Spring 对不同切面增强的执行顺序是由 Bean 优先级决定的

* 入操作（Around 的连接点执行前、Before）：切面优先级越高，越先执行。一个切面的入操作执行完，才轮到下一切面，所有切面操作执行完，才开始执行连接点（方法）
* 出操作（Around 的连接点执行后、After、AfterReturning、AfterThrowing）：切面优先级越低，越先执行。一个切面的出操作执行完，才轮到下一切面，直到返回到调用点
* 同一切面的 Around 比 After、Before 先执行

对于 Bean 可以通过 @Order 设置优先级，默认情况下 Bean 的优先级为最低优先级，其值是 Integer 的最大值。**值越大，优先级越低**

# 注解

* 用于创建对象的

  * 作用：和在 XML 配置文件中编写一个\<bean>标签是实现的功能是一样的
    * ***@Component***
      * 作用：把当前类对象存入 spring 容器中
      * 属性：value：用于指定 bean 的 id，默认值是当前类名，且首字母改小写
    * ***@Controller***：表现层
    * ***@Service***：业务层
    * ***@Repository***：持久层
      * 作用和属性同上，这是 spring 框架为我们明确提供的三层使用的注解，使三层对象更加清晰
* 用于注入数据的

  * 作用：和在 XML 配置文件中的\<bean>标签中写一个\<property>标签是实现的功能是一样的

    * ***@Autowired***
      * 作用：自动按照类型注入。
        * 只要容器中有唯一的 bean 对象类型和要注入的变量类型匹配，就能注入成功；
        * 如果 ioc 容器中没有任何 bean 类型和要注入的变量类型匹配，则报错；
        * 如果有多个类型匹配时，
      * 出现位置：变量或者方法上
      * 细节：在使用注解注入时，set 方法就不是必须的了
    * ***@Qualifier***
      * 作用：在按照类中注入的基础上再按照名称注入，在给 ***类成员*** 注入时，不能单独使用，但在给方法参数注入时，可以
      * 属性：value：用于指定注入 bean 的id
    * ***@Resource***
      * 作用：直接按照 bean 的 id 注入，可以独立使用
      * 属性：name：用于指定注入 bean 的id

    以上三个注入都只能注入其他 bean 类型的数据，而基本类型和 String 类型无法使用上述注解实现。

    集合类型的注入只能通过 XML 来实现。

    * ***@Value***
      * 作用：用于注入基本类型和 String 类型的数据
      * 属性：value：用于指定数据的值。可以使用 spring 中SpEL（也就是 spring 的el表达式）。SpEL 的写法：${表达式}
* 用于改变作用范围的

  * 作用：和在\<bean>标签中写scope属性实现的功能是一样的
    * ***@Scope***
      * 作用：指定 bean 的作用范围
      * 属性：value：指定范围的取值。常用：singleton，prototype
* 和生命周期相关

  * 作用：和在\<bean>标签中写 init-method 和 destory-method 实现的功能是一样的
    * @***PreDestroy***：用于指定销毁方法
    * ***@PostConstruct***：用于指定初始化方法

## 给容器中注册组件

1、@Configuration：此注解是用来告诉spring，这是一个配置类，等同于之前的配置文件

@ComponentScan：指定要扫描的包，只要标注了@Controller、@Service、@Repository、@Component，都会被自动扫描加进容器中

@Repository标注在mapper上，注入ioc的时候是通过接口动态生成一个对象，所以其实可以不加，因为接口不能实例化，只不过不通过构造器注入的时候，会标红。

2、@Bean：导入第三方包里面的组件

等同于bean.xml，给容器中注册一个bean，类型是返回值的类型，id默认是方法名，也可以指定

```java
@Bean("person")
public Person person01() {
    return new Person("lisi", "20");
}
```

3、@Import：快速给容器中导入一个组件（id默认是全类名），传参可以是类名、ImportSelector的实现类、ImportBeanDefinitionRegistrar的实现类

```java
@Import({Color.class, Red.class, MyImportSelector.class, MyImportBeanDefinitionRegistrar.class})
```

4、使用Spring提供的FactoryBean（工厂bean）

1）默认获取到的是工厂Bean调用getObject()创建的对象

2）要获取工厂Bean本身，需要给id前面加一个&

```java
/**
 * 创建一个Spring定义的FactoryBean
 *
 * @author lvmc
 */
public class ColorFactoryBean implements FactoryBean<Color> {

    /**
     * 把返回的对象添加到容器中
     *
     * @return
     * @throws Exception
     */
    @Override
    public Color getObject() throws Exception {
        System.out.println("调用了ColorFactoryBean.......getObject()");
        return new Color();
    }

    @Override
    public Class<?> getObjectType() {
        return Color.class;
    }

    /**
     * 是否单例
     * true：单实例，在容器中保存一份
     * false：多实例，每次获取都会创建一个新的
     *
     * @return
     */
    @Override
    public boolean isSingleton() {
        return true;
    }
}
```

```java
    /**
     * 看起来注册的是ColorFactoryBean，但实际上是Color
     *
     * @return
     */
    @Bean
    public ColorFactoryBean colorFactoryBean() {
        return new ColorFactoryBean();
    }
```

```java
    @Test
    public void testImport() {
        // 工厂Bean获取的是 getObject() 创建的对象
        Object bean2 = applicationContext.getBean("colorFactoryBean");
        Object bean3 = applicationContext.getBean("colorFactoryBean");
        System.out.println("bean2的类型是：" + bean2.getClass());
        System.out.println(bean2==bean3);
        // 注册ColorFactoryBean，&可以拿到工厂Bean本身
        Object bean4 = applicationContext.getBean("&colorFactoryBean");
        System.out.println("bean4的类型是：" + bean4.getClass());
    }
```

## 属性赋值

使用@Value赋值：

1、基本数值

2、SpEL，#{}

3、${}取出配置文件中的值（由于配置文件中的值最终都会放到environment中，所以其实就是运行环境变量里面的值）

## 自动装配

自动装配：
      spring利用依赖注入（DI），完成对IOC容器中各个组件的依赖关系赋值

```java
@Service
public class BookService {
    @Autowired
    private BookDao bookDao;
}
```

 1、@Autowired；自动注入
      1）默认优先按照类型去容器中找对应的组件，相当于测试类中的

```java
applicationContext.getBean(BookDao.class);
```

找到就赋值

    2）如果找到多个相同类型的组件，再将属性的名称作为组件的id去容器中查找

    3）使用@Qualifier("bookDao2")指定需要装配的组件的id，而不是使用属性名

    4）自动装配默认一定要将属性赋值好，没有就会报错

    5）@Primary：让Spring进行自动装配的时候，默认使用首选的bean

2、Spring 还支持使用@Resource(JSR250)和@Inject(JSR300)[Java规范的注解]

@Resource：和@Autowired一样实现自动装配功能，默认按照组件名称进行装配，没有支持@Primary和required=false的功能

@Inject：需要先导入javax.inject的包，和@Autowired一样实现自动装配功能，没有required=false的功能

3、@Autowired标注在方法、构造器、参数，属性上，都是从容器中获取参数组件的值

@Autowired 标注在方法上，spring容器创建当前对象，就会调用方法，完成赋值

```java
/**
 * @param car 自定义类型的值从ioc容器中获取；
 * @Autowired 标注在方法上，spring容器创建当前对象，就会调用方法，完成赋值
 */
@Autowired
public void setCar(Car car) {
    this.car = car;
}
```

@Bean + 方法参数，参数从容器中获取；默认不写@Autowired，都能自动装配

```java
/**
 * @Bean 标注的方法创建对象时，方法参数的值从容器中获取
 * @param car   从容器中获取
 * @return
 */
@Bean
public Color color(Car car){
    Color color = new Color();
    color.setCar(car);
    return color;
}
```

@Autowired 标注在构造器上，如果组件只有一个有参构造器，这个有参构造器的@Autowired可以省略，参数位置的组件还是可以自动从容器中获取

```java
/**
 *
 * @param car   构造器要用的组件，都是从容器中获取
 */
@Autowired
public Boss(Car car) {
    this.car = car;
    System.out.println("这是Boss的有参构造器。。。");
}
```

@Autowired 标注在参数上

4、自定义组件想要使用Spring容器底层的一些组件：

* 自定义组件实现xxxAware：在创建对象时，会调用接口规定的方法注入相关组件
* 把spring底层一些组件注入到自定义的Bean中
* xxxAware：功能使用xxxProcessor

## 容器创建

Spring 容器的创建和刷新：refresh()

* prepareRefresh()：刷新的预处理

  * initPropertySources()：初始化一些属性设置，子类自定义个性化的属性设置方法
  * getEnvironment().validateRequiredProperties()：检验属性是否合法
  * earlyApplicationEvents = new LinkedHashSet()：保存容器中的一些早期事件
* obtainFreshBeanFactory()：获取BeanFactory

  * refreshBeanFactory()：刷新（创建）BeanFactory
    * 创建了一个this.beanFactory = new DefaultListableBeanFactory();
    * 设置序列化idthis.beanFactory.setSerializationId(this.getId());
  * getBeanFactory()：返回刚才GenericApplicationContext创建的Beanfactory对象
  * 将创建的BeanFactory【DefaultListableBeanFactory】返回
* prepareBeanFactory(beanFactory)：BeanFactory的预备工作（对BeanFactory进行设置）

  * 设置BeanFactory的类加载器、支持表达式解析器。。。
  * 添加部分BeanPostProcessor【ApplicationContextAwareProcessor】
  * 设置忽略自动装配的接口：EnvironmentAware、EnvironmentAware
  * 注册可以解析的自动装配：BeanFactory、ResourceLoader、ApplicationEventPublisher、ApplicationContext
