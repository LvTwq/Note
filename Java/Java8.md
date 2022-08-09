[TOC]

# 默认方法

接口可以有实现方法，不需要实现类去实现。

通过在方法名前增加**default**关键字即可实现默认方法。

### 为什么要有这个特性？

*首先，之前的接口是个双刃剑，好处是面向抽象而不是面向具体编程，缺陷是，当需要修改接口时候，需要修改全部实现该接口的类，目前的 java 8 之前的集合框架没有 foreach 方法，通常能想到的解决办法是在JDK里给相关的接口添加新的方法及实现。然而，对于已经发布的版本，是没法在给接口添加新方法的同时不影响已有的实现。所以引进的默认方法。他们的目的是为了解决接口的修改与现有的实现不兼容的问题。*

### 语法

```java
public interface Vehicle {
   default void print(){
      System.out.println("我是一辆车!");
   }
}
```

### 多个默认方法

一个类实现了多个接口，多个接口都有默认相同的方法

```java
public interface Vehicle {
   default void print(){
      System.out.println("我是一辆车!");
   }
}
 
public interface FourWheeler {
   default void print(){
      System.out.println("我是一辆四轮车!");
   }
}
```



1）创建自己的默认方法，覆盖重写接口的默认方法

```java
public class Car implements Vehicle, FourWheeler {

  @Override
  public void print() {
    Vehicle.super.print();
  }
}
```

2）使用super调用指定接口的默认方法

```java
public class Car implements Vehicle, FourWheeler {

  @Override
  public void print(){
    System.out.println("我是一辆四轮汽车!");
  }
}
```

### 静态默认方法

声明（并且可以提供实现）静态方法

```java
public interface Bike {
  default void print() {
    System.out.println("我是一辆车!");
  }

  // 静态方法
  static void blowHorn() {
    System.out.println("按喇叭!!!");
  }
}
```



### 默认方法实例

```java
public class Java8Tester {
   public static void main(String args[]){
      Vehicle vehicle = new Car();
      vehicle.print();
   }
}
 
interface Vehicle {
   default void print(){
      System.out.println("我是一辆车!");
   }
    
   static void blowHorn(){
      System.out.println("按喇叭!!!");
   }
}
 
interface FourWheeler {
   default void print(){
      System.out.println("我是一辆四轮车!");
   }
}
 
class Car implements Vehicle, FourWheeler {
   public void print(){
      Vehicle.super.print();
      FourWheeler.super.print();
      Vehicle.blowHorn();
      System.out.println("我是一辆汽车!");
   }
}
```

>我是一辆车!
>我是一辆四轮车!
>按喇叭!!!
>我是一辆汽车!



# Stream流







# Optional

**定义：**Optional 类 (java.util.Optional) 是一个容器类，代表一个值存在或不存在，原来用 null 表示一个值不存在，现在用 Optional 可以更好的表达这个概念；并且可以避免空指针异常

常用方法：

- Optional.of(T t)：创建一个 Optional 实例
- Optional.empty(T t)：创建一个空的 Optional 实例
- Optional.ofNullable(T t)：若 t 不为 null，创建 Optional 实例，否则空实例
- isPresent()：判断是否包含某值
- orElse(T t)：如果调用对象包含值，返回该值，否则返回 t
- orElseGet(Supplier s)：如果调用对象包含值，返回该值，否则返回 s 获取的值
- map(Function f)：如果有值对其处理，并返回处理后的 Optional，否则返回 Optional.empty()
- flatmap(Function mapper)：与 map 相似，要求返回值必须是 Optional



Optional.of(T t)：

```java
@Test
public void test1() {
    // 通过of()方法创建实例
    Optional<Employee> op = Optional.of(new Employee());
    Employee emp = op.get();
    // 没传任何参数，输出的都是默认值
    System.out.println(emp);
}
```

输出：

> Employee(id=null, name=null, age=null, salary=null)



Optional.empty(T t)：

```java
@Test
public void test2() {
    Optional<Employee> op = Optional.empty();
    System.out.println(op.get());
}
```



Optional.ofNullable(T t)，isPresent()：

```java
@Test
public void test3() {
    Optional<Employee> op = Optional.ofNullable(new Employee());
    if (op.isPresent()) {
        Employee emp = op.get();
        System.out.println(emp);
    }
}
```

可以看到 Optional.ofNullable(T t) 的源码：

```java
    public static <T> Optional<T> ofNullable(T value) {
        return value == null ? empty() : of(value);
    }
```



orElse(T t)：

```java
    @Test
    public void test3() {
        Optional<Employee> op = Optional.ofNullable(null);
        Employee employee = op.orElse(new Employee(1, "aaa", 1, 1.0));
        System.out.println(employee);
    }
```



orElseGet(Supplier s)：

```java
@Test
public void test3() {
    Optional<Employee> op = Optional.ofNullable(null);
    Employee employee = op.orElseGet(Employee::new);
    System.out.println(employee);
}
```



map(Function f)：

```java
@Test
public void test4() {
    Optional<Employee> op = Optional.ofNullable(new Employee(1, "aaa", 1, 1.0));
    // 把容器中的对象应用到map()上
    Optional<String> s = op.map(e -> e.getName());
    System.out.println(s);
}
```

