[TOC]

# 一、为什么要使用Lombok

当属性多时会出现大量的 getter/setter 方法，冗余，且一旦修改属性，就需要修改对应的方法。

Lombok 可以提高开发效率。



# 二、Lombok原理

* 运行时解析

运行时能够解析的注解，必须将 ***@Retention*** 设置为 RUNTIME，这样就可以通过**反射**拿到该注解。java.lang.reflect 反射包中提供了一个接口 AnnotatedElement，该接口定义了获取注解的几个方法：Class，Constructor，Field，Method 等，都实现了该接口。

```java
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Inherited
@SpringBootConfiguration
@EnableAutoConfiguration
@ComponentScan(excludeFilters = {
		@Filter(type = FilterType.CUSTOM, classes = TypeExcludeFilter.class),
		@Filter(type = FilterType.CUSTOM, classes = AutoConfigurationExcludeFilter.class) })
public @interface SpringBootApplication {
}
```

* 编译时解析

javac 执行过程如下：


Lombok 本质上是实现了 ["JSR 269 API"]( https://jcp.org/en/jsr/detail?id=269 ) 的程序。在使用 javac 的过程中，它产生作用具体流程如下：

1）javac 对源码进行分析，生成了一个抽象的语法树（AST）

2） 运行过程中调用实现 "JSR 269 API" 的Lombok 程序

3）对得到的 AST 进行处理，找到 @Data 注解所在类对应的语法树并修改，增加 getter/setter 方法定义的相应树节点

4）javac 使用修改后的抽象语法树（AST）生成字节码文件，即给 class 增加新的结点（代码块）

在 Lombok 源码中，对应注解的实现都在 ***HandleXXX*** 中，比如 @Getter 注解的实现时 HandleGetter.handle()。

```java
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.SOURCE)
public @interface Data {
	String staticConstructor() default "";
}
```



# 三、用法

添加依赖并安装插件：

```xml
<dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
    <version>1.18.10</version>
    <scope>provided</scope>
</dependency>
```



## @Getter/@Setter

此注解在**属性**或**类**上，可以为相应的属性自动生成 Getter/Setter 方法，还可以指定访问范围 

1、注解在属性上

```java
public class User1 {
    @Getter @Setter
    private Long id;
    @Getter(AccessLevel.PROTECTED)
    private String phone;
    private String password;
}
```

编译结果：

```java
public class User1 {
    private Long id;
    private String phone;
    private String password;

    public User1() {
    }

    public Long getId() {
        return this.id;
    }

    public void setId(final Long id) {
        this.id = id;
    }

    protected String getPhone() {
        return this.phone;
    }
}
```

2、注解在类上，表示为类中的所有字段生成Getter&Setter方法

```java
@Getter
@Setter
public class User1 {

    private Long id;
    @Getter(AccessLevel.PROTECTED)
    private String phone;
    @Setter(AccessLevel.NONE)
    private String password;
}
```

编译后：

```java
public class User1 {
    private Long id;
    private String phone;
    private String password;

    public User1() {
    }

    public Long getId() {
        return this.id;
    }

    public String getPassword() {
        return this.password;
    }

    public void setId(final Long id) {
        this.id = id;
    }

    public void setPhone(final String phone) {
        this.phone = phone;
    }

    protected String getPhone() {
        return this.phone;
    }
}
```



### @Getter(lazy = true)

标注字段为懒加载字段，懒加载字段在创建对象时不会进行初始化，而是在第一次访问的时候才会初始化，后面再次访问也不会重复初始化

```java
public class User1 {

    private final List<String> cityList = getCityFromCache();

    private List<String> getCityFromCache() {
        System.out.println("get city from cache ...");
        return new ArrayList<>();
    }

    public static void main(String[] args) {
        // 初始化对象时会执行getCityFromCache()方法
        User1 user = new User1();
    }
}
```

```java
    @Getter(lazy = true)
    private final List<String> cityList = getCityFromCache();

    private List<String> getCityFromCache() {
        System.out.println("get city from cache ...");
        return new ArrayList<>();
    }

    public static void main(String[] args) {
        // 不会执行getCityFromCache()方法
        User1 user = new User1();
    }
```



### @Getter(onMethod_ = )

生成setter方法时，在setter方法上添加annotation

```java
    @Getter(onMethod_ = @JsonIgnore)
    private List<String> cBhList;
```

```java
    @JsonIgnore
    public List<String> getCBhList() {
        return this.cBhList;
    }
```





## @ToString

**类**使用此注解，生成toString()方法，默认情况下它会按顺序（以逗号分隔）打印你的类名称以及每个字段。可以这样设置不包含哪些字段,可以指定一个也可以指定多个@ToString(exclude = “id”) / @ToString(exclude = {“id”,“name”})

```java
@ToString(of = {"s"})
public class User1 {

    static String s = "";
    private Long id;
    private String phone;
    private String password;
    private String salt;
}
```

编译后：

```java
public class User1 {
    static String s = "";
    private Long id;
    private String phone;
    private String password;
    private String salt;

    public User1() {
    }

    public String toString() {
        return "User1(s=" + s + ")";
    }
}
```

如果继承的有父类的话，可以设置callSuper 让其调用父类的toString()方法，例如：@ToString(callSuper = true)

```java
public class superUser {
    private String phone;
}

@ToString(callSuper = true)
public class User1 extends superUser {

    static String s = "";
    private Long id;
    private String password;
    private String salt;
}
```

编译后：

```java
public class User1 extends superUser {
    static String s = "";
    private Long id;
    private String password;
    private String salt;

    public User1() {
    }

    public String toString() {
        String var10000 = super.toString();
        return "User1(super=" + var10000 + ", id=" + this.id + ", password=" + this.password + ", salt=" + this.salt + ")";
    }
}
```



## @EqualsAndHashCode

通过判断两个对象的成员变量值是否相等，来判断这两个对象是否相等，要重写hashCode()和equals()方法。

用在**类**上，生成hashCode()和equals()方法，默认情况下，它将使用所有非静态，非transient字段。但可以通过在可选的 exclude 参数中来排除更多字段。或者，通过在of参数中命名它们来准确指定希望使用哪些字段。 

```java
@EqualsAndHashCode
public class User implements Serializable{

    private static final long serialVersionUID = 6569081236403751407L;

    private Long id;

    private String phone;

    private transient int status;
}
```

编译后：

```java
public class User implements Serializable {
    private static final long serialVersionUID = 6569081236403751407L;
    private Long id;
    private String phone;
    private transient int status;

    public User() {
    }

    public boolean equals(Object o) {
        // 判断两个对象是不是同一个对象
        if(o == this) {
            return true;
            // 判断 o 是不是 User 的一个实例
        } else if(!(o instanceof User)) {
            return false;
        } else {
            User other = (User)o;
            // 判断两个对象是否可以比较
            if(!other.canEqual(this)) {
                return false;
            } else {
                Long this$id = this.id;
                Long other$id = other.id;
                if(this$id == null) {
                    if(other$id != null) {
                        return false;
                    }
                } else if(!this$id.equals(other$id)) {
                    return false;
                }

                String this$phone = this.phone;
                String other$phone = other.phone;
                if(this$phone == null) {
                    if(other$phone != null) {
                        return false;
                    }
                } else if(!this$phone.equals(other$phone)) {
                    return false;
                }

                return true;
            }
        }
    }

/**
 * 判断这个对象是不是 User 的实例
 */
    protected boolean canEqual(Object other) {
        return other instanceof User;
    }

    public int hashCode() {
        boolean PRIME = true;
        byte result = 1;
        Long $id = this.id;
        int result1 = result * 59 + ($id == null?43:$id.hashCode());
        String $phone = this.phone;
        result1 = result1 * 59 + ($phone == null?43:$phone.hashCode());
        return result1;
    }
}
```



## @Data

@Data 注解在**类**上， 相当于同时使用了@ToString、@EqualsAndHashCode、@Getter、@Setter和@RequiredArgsConstrutor这些注解，会为类的所有属性自动生成 getter/setter，equals，canEqual，hashCode，toString 方法，如为 final 属性，则不会生成 setter 方法

```java
@Data
public class User {
    /**
     * @Data 只对成员变量起作用，
     */
    static String s = "";
    /**
     * 由于是final修饰的成员变量，不可更改，只会生成get，不会有set
     */
    final int id2;
    @NonNull
    private Integer id;
    private String userName;
}
```



## @NonNull

用在**属性**或**构造器上**，为字段赋值时(即调用字段的setter方法时)，如果传的参数为null，则会抛出空异常NullPointerException，生成setter方法时会对参数是否为空检查 

```java
public class NonNullExample extends Something {
  private String name;
  
  public NonNullExample(@NonNull Person person) {
    super("Hello");
    this.name = person.getName();
  }
}
```

编译后：

```java
public class NonNullExample extends Something {
  private String name;
  
  public NonNullExample(@NonNull Person person) {
    super("Hello");
    if (person == null) {
      throw new NullPointerException("person");
    }
    this.name = person.getName();
  }
}
```





## @NoArgsConstructor

生成一个**无参构造方法**。当类中有final字段没有被初始化时，编译器会报错，此时可用@NoArgsConstructor(force = true)，然后就会为没有初始化的final字段设置默认值 0 / false / null, 这样编译器就不会报错。对于具有约束的字段（例如@NonNull字段），不会生成检查或分配，因此请注意，正确初始化这些字段之前，这些约束无效。

```java
@NoArgsConstructor(force = true)
public class User {
    private Long id;
    @NonNull
    private String phone;
    private final Integer age;
}
```

编译后：

```java
public class User {
    private Long id;
    @NonNull
    private String phone;
    private final Integer age = null;

    public User() {
    }
}
```





## @RequiredArgsConstructor

对指定的参数生成构造方法，（可能带参数也可能不带参数），如果带参数，这参数只能是

* 以final修饰的未经初始化的字段，若用final修饰还初始化了，就不会再改变，生成构造方法就没意义
* 以@NonNull注解的未经初始化的字段。

```java
@RequiredArgsConstructor
public class User1  {
    private Long id;
    @NonNull
    private String phone;
    @NotNull
    private Integer status = 0;
    private final Integer age;
    private final String country = "china";
}
```

编译后：

```java
public class User1 {
    private Long id;
    @NonNull
    private String phone;
    @NotNull
    private Integer status = 0;
    private final Integer age;
    private final String country = "china";

    public User1(@NonNull final String phone, final Integer age) {
        if (phone == null) {
            throw new NullPointerException("phone is marked non-null but is null");
        } else {
            this.phone = phone;
            this.age = age;
        }
    }
}
```



@RequiredArgsConstructor(staticName = “of”) 会生成一个 of() 的静态方法，并把构造方法设置为私有的

```java
@RequiredArgsConstructor(staticName = "of")
public class User1 {
    private Long id;

    @NonNull
    private String phone;

    @NotNull
    private Integer status = 0;

    private final Integer age;
    private final String country = "china";
}
```

编译后：

```java
public class User1 {
    private Long id;
    @NonNull
    private String phone;
    @NotNull
    private Integer status = 0;
    private final Integer age;
    private final String country = "china";

    private User1(@NonNull final String phone, final Integer age) {
        if (phone == null) {
            throw new NullPointerException("phone is marked non-null but is null");
        } else {
            this.phone = phone;
            this.age = age;
        }
    }

    public static User1 of(@NonNull final String phone, final Integer age) {
        return new User1(phone, age);
    }
}
```

### 构造器注入

Java语法规定，final修饰的成员变量（类变量+实例变量）必须显式指定初始值；

final修饰的实例变量，要么在定义该实例变量时指定初始值，要么在普通初始化块或构造器中为该实例变量指定初始值

```java
@RequiredArgsConstructor(onConstructor_ = @Autowired)
public class AccountServiceImpl implements AccountService {
    private final AccountMapper accountMapper;
}
```

编译后：

```java
public class AccountServiceImpl implements AccountService {
    private final AccountMapper accountMapper;
    
    // 这里的入参会用final修饰，表示不会改变它的引用，AccountMapper accountMapper是spring注入的，赋值给成员变量
    @Autowired
    public AccountServiceImpl(final AccountMapper accountMapper) {
        this.accountMapper = accountMapper;
    }
}
```





## @AllArgsConstructor

用在**类**上，生成一个全参数的构造方法 

```java
@AllArgsConstructor
public class User {
    private Long id;

    @NonNull
    private String phone;

    @NotNull
    private Integer status = 0;

    private final Integer age;
    private final String country = "china";
}
```

编译后：

```java
public class User1 {
    private Long id;
    @NonNull
    private String phone;
    @NotNull
    private Integer status = 0;
    private final Integer age;
    private final String country = "china";

    public User1(final Long id, @NonNull final String phone, final Integer status, final Integer age) {
        if (phone == null) {
            throw new NullPointerException("phone is marked non-null but is null");
        } else {
            this.id = id;
            this.phone = phone;
            this.status = status;
            this.age = age;
        }
    }
}
```



## @Value

用在**类**上，是@Data的不可变形式，相当于为属性添加final声明，只提供getter方法，而不提供setter方法 

```java
@Value
publicclassLombokDemo{
	@NonNull
    private int id;
}
```

编译后：

```java
publicclassLombokDemo {    
    private final int id;
    public int getId() {
        return this.id;
    }
}
```



## @Builder

Builder 使用创建者模式又叫生成器模式（Builder Pattern）。简单来说，就是一步步创建一个对象，它对用户屏蔽了里面构建的细节，但却可以精细地控制对象的构造过程。

### 原理：

```java
public class User1 {
    private Integer id;
    private String name;

    User1(final Integer id, final String name) {
        this.id = id;
        this.name = name;
    }
// 在实体类中：会创建一个builder()方法，它的目的是用来创建构建器。
    public static User1.User1Builder builder() {
        return new User1.User1Builder();
    }
    
// 内部静态类，具有和实体类相同的属性（成为构建器）
    public static class User1Builder {
        // 在构建器中：对于目标类中的所有的属性和未初始化的final字段，都会在构建器中创建对应属性。
        private Integer id;
        private String name;
		// 创建一个无参的default构造函数。
        User1Builder() {
        }

        // 对于实体类中的每个参数，都会对应创建类似于setter的方法，只不过方法名与该参数名相同。 
        // 并且返回值是构建器本身（便于链式调用）
        public User1.User1Builder id(final Integer id) {
            this.id = id;
            return this;
        }

        public User1.User1Builder name(final String name) {
            this.name = name;
            return this;
        }

        // 调用此方法，就会根据设置的值进行创建实体对象
        public User1 build() {
            return new User1(this.id, this.name);
        }

        public String toString() {
            return "User1.User1Builder(id=" + this.id + ", name=" + this.name + ")";
        }
    }
}
```



### 常规用法：

```java
@Data
public class User1 {
    private Integer id;
    private String name;
    private String address;

    public static void main(String[] args) {
        User1 user1 = new User1(1, "java", "china");
        user1.setId(1);
        user1.setName("11");
        user1.setAddress("111");
        System.out.println(user1);
    }
}
```

使用 @Builder：

```java
@Builder
@Data
public class User1 {
    private Integer id;
    private String name;
    private String address;

    public static void main(String[] args) {
        User1 user1 = User1.builder().id(1).address("11").name("111").build();
        System.out.println(user1);
    }
}
```

### 使用@Builder时如何解决继承关系？

1）在父类上，使用**@AllArgsConstructor**注解。

2）在子类上，手动编写全参数构造器，内部调用父类全参数构造器，在子类全参数构造器上使用@Builder注解。

```java
@ToString
@AllArgsConstructor
public class SuperUser {
    private String phone;
}

@ToString(callSuper = true)
public class User1 extends SuperUser{

    private Integer id;

    private String name;

    private String address;


    @Builder
    public User1(String phone, Integer id, String name, String address) {
        super(phone);
        this.id = id;
        this.name = name;
        this.address = address;
    }

    public static void main(String[] args) {
        User1 user1 = User1.builder().phone("12346").id(1).address("11").name("111").build();
        System.out.println(user1);
    }
}
```

输出：

> User1(super=SuperUser(phone=12346), id=1, name=111, address=11)

**副作用：**

- 因为使用`@AllArgsConstructor`注解，父类构造函数字段的顺序由声明字段的顺序决定，如果子类构造函数传参的时候顺序不一致，字段类型还一样的话，出了错不好发现
- 如果父类字段有增减，所有子类的构造器都要修改





### @Builder.Default

默认赋值

```java
@Builder
@ToString
public class User1 {

    private Integer id;
    private String name;

    @Builder.Default
    private String address = "南京";

    public static void main(String[] args) {
        User1 user1 = User1.builder().id(1).name("jack").build();
        System.out.println(user1);
    }
}

// 输出：User1(id=1, name=jack, address=南京)
```

当然，如果再对这两个字段进行设值的话，那么默认定义的值将会被覆盖掉



## @Log

生成log对象，用于记录日志，可以通过topic属性来设置getLogger(String name)方法的参数 例如 @Log4j(topic = “com.xxx.entity.User”)，默认是类的全限定名，即 类名.class，log支持以下几种： 

* @Log java.util.logging.Logger
* @Log4j org.apache.log4j.Logger
* @Log4j2 org.apache.logging.log4j.Logger
* @Slf4j org.slf4j.Logger
* @XSlf4j org.slf4j.ext.XLogger
* @CommonsLog org.apache.commons.logging.Log
* @JBossLog org.jboss.logging.Logger

```java
@Data
@Builder
@Log
public class User1 {

    private Integer id;
    private String name;
    private String address;

    public void test(@NonNull String s) {
        log.info("test");
        System.out.println(s);
    }

    public static void main(String[] args) {
        User1 user1 = User1.builder().id(1).address("11").name("111").build();
        user1.test("ssfsdfj");
    }
}
```

补充：日志打印规范

```java
// 要么不填充变量(只有异常，就不能使用占位符)
log.error("xxxx",e)
// 要么填充业务字段
log.error("xxxx{}",var,e)
    
// 建议包含当前处理的参数id（定位问题时确认是哪条数据），同时带上异常堆栈，用slf4j，例如：
log.error("编号[{}]的数据处理失败！",ywbh,e);    
```







## @Clenaup

用在**局部变量**之前，在当前变量范围内即将执行完毕退出之前会自动清理资源，自动生成try-finally这样的代码来关闭流

```java
    public static void main(String[] args) throws IOException {
        @Cleanup InputStream in = new FileInputStream("E:\\filepath.txt");
        @Cleanup OutputStream out = new FileOutputStream("E:\\path2.txt");
        byte[] b = new byte[1000];
        while (true) {
            int r = in.read(b);
            if (r == -1) {
                break;
            }
            out.write(b, 0, r);
        }
    }
```

编译后：

```java
public static void main(String[] args) throws IOException {
    FileInputStream in = new FileInputStream("E:\\filepath.txt");
    try {
        FileOutputStream out = new FileOutputStream("E:\\path2.txt");
        try {
            byte[] b = new byte[1000];
            while(true) {
                int r = in.read(b);
                if (r == -1) {
                    return;
                }
                out.write(b, 0, r);
            }
        } finally {
            if (Collections.singletonList(out).get(0) != null) {
                out.close();
            }
        }
    } finally {
        if (Collections.singletonList(in).get(0) != null) {
            in.close();
        }
    }
}
```

或者使用 try-with-resources



## @UtilityClass

* 将类使用final修饰
* 构建了一个私有构造方法
* 将所有成员变量变成static

```java
@UtilityClass
public class FileHandler {
    public void test(){}
} 
```

编译后：

```java
public final class FileHandler {
    public static void test() {
    }

    private FileHandler() {
        throw new UnsupportedOperationException("This is a utility class and cannot be instantiated");
    }
}
```



## others(**不推荐**)

### @Delegate

为List类型的字段生成一大堆常用的方法，其实这些方法都是List中的方法

```java
public class User {
    @Delegate
    private List<String> address;
}
```

### @Wither

提供了给final字段赋值的一种方法(@Deprecated)

### @SneakyThrows

使用try catch 来捕获异常, 默认捕获的是Throwable异常，也可以设置要捕获的异常 (**不易读**)

```java
    @SneakyThrows
    public void sleep(){
        Thread.sleep(1000);
    }

    @SneakyThrows(InterruptedException.class)
    public void sleep2()  {
        Thread.sleep(1000);
    }
```

编译后：

```java
    public void sleep() {
        try {
            Thread.sleep(1000L);
        } catch (Throwable var2) {
            throw var2;
        }
    }

    public void sleep2() {
        try {
            Thread.sleep(1000L);
        } catch (InterruptedException var2) {
            throw var2;
        }
    }
```



### val/var

作为**局部变量**声明的类型，而不必编写实际类型。val/var 将从初始化程序表达式中推断类型。

var和val的差别在于，val修饰的局部变量没有被标记为final。

```java
final String address = "123";
address = "34";	// 标红

val address1 = "123";
address1 = "34";	// 编译时才会报错
```

> 补充：从 Java10 开始支持使用 var 定义局部变量：var相当于一个动态类型，使用 var 定义的局部变量的类型由编译器自动推断。
>
> 注：Java 的 var 与 JavaScript 的 var 截然不同，JavaScript 本质上是弱类型语言，因此JavaScript使用 var 定义的变量并没有明确的类型，但 Java 是强类型语言，即便使用 var 定义变量，但依然有明确的类型——为局部变量指定初始值时，该变量的类型就确定了。