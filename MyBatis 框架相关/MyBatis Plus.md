[TOC]





# 一、简介

[MyBatis-Plus](https://github.com/baomidou/mybatis-plus)（简称 MP）是一个 [MyBatis](http://www.mybatis.org/mybatis-3/) 的增强工具，在 MyBatis 的基础上只做增强不做改变，为简化开发、提高效率而生。

官网：http://mp.baomidou.com/

参考教程：http://mp.baomidou.com/guide/



# 二、特性

- **无侵入**：只做增强不做改变，引入它不会对现有工程产生影响，如丝般顺滑
- **损耗小**：启动即会自动注入基本 CURD，性能基本无损耗，直接面向对象操作
- **强大的 CRUD 操作**：内置通用 Mapper、通用 Service，仅仅通过少量配置即可实现单表大部分 CRUD 操作，更有强大的条件构造器，满足各类使用需求
- **支持 Lambda 形式调用**：通过 Lambda 表达式，方便的编写各类查询条件，无需再担心字段写错
- **支持多种数据库**：支持 MySQL、MariaDB、Oracle、DB2、H2、HSQL、SQLite、Postgre、SQLServer2005、SQLServer 等多种数据库
- **支持主键自动生成**：支持多达 4 种主键策略（内含分布式唯一 ID 生成器 - Sequence），可自由配置，完美解决主键问题
- **支持 XML 热加载**：Mapper 对应的 XML 支持热加载，对于简单的 CRUD 操作，甚至可以无 XML 启动
- **支持 ActiveRecord 模式**：支持 ActiveRecord 形式调用，实体类只需继承 Model 类即可进行强大的 CRUD 操作
- **支持自定义全局通用操作**：支持全局通用方法注入（ Write once, use anywhere ）
- **支持关键词自动转义**：支持数据库关键词（order、key......）自动转义，还可自定义关键词
- **内置代码生成器**：采用代码或者 Maven 插件可快速生成 Mapper 、 Model 、 Service 、 Controller 层代码，支持模板引擎，更有超多自定义配置等您来使用
- **内置分页插件**：基于 MyBatis 物理分页，开发者无需关心具体操作，配置好插件之后，写分页等同于普通 List 查询
- **内置性能分析插件**：可输出 Sql 语句以及其执行时间，建议开发测试时启用该功能，能快速揪出慢查询
- **内置全局拦截插件**：提供全表 delete 、 update 操作智能分析阻断，也可自定义拦截规则，预防误操作
- **内置 Sql 注入剥离器**：支持 Sql 注入剥离，有效预防 Sql 注入攻击



# 三、准备工作

## 1、创建数据库：

mybatis_plus

## 2、创建 `User` 表

其表结构如下：

| id   | name   | age  | email              |
| ---- | ------ | ---- | ------------------ |
| 1    | Jone   | 18   | test1@baomidou.com |
| 2    | Jack   | 20   | test2@baomidou.com |
| 3    | Tom    | 28   | test3@baomidou.com |
| 4    | Sandy  | 21   | test4@baomidou.com |
| 5    | Billie | 24   | test5@baomidou.com |

其对应的数据库 Schema 脚本如下： 

```sql
DROP TABLE IF EXISTS user;

CREATE TABLE user
(
    id BIGINT(20) NOT NULL COMMENT '主键ID',
    name VARCHAR(30) NULL DEFAULT NULL COMMENT '姓名',
    age INT(11) NULL DEFAULT NULL COMMENT '年龄',
    email VARCHAR(50) NULL DEFAULT NULL COMMENT '邮箱',
    PRIMARY KEY (id)
);
```

其对应的数据库 Data 脚本如下：

```sql
DELETE FROM user;

INSERT INTO user (id, name, age, email) VALUES
(1, 'Jone', 18, 'test1@baomidou.com'),
(2, 'Jack', 20, 'test2@baomidou.com'),
(3, 'Tom', 28, 'test3@baomidou.com'),
(4, 'Sandy', 21, 'test4@baomidou.com'),
(5, 'Billie', 24, 'test5@baomidou.com');
```

## 3、初始化工程

使用 Spring Initializr 快速初始化一个 Spring Boot 工程

Group：com.atguigu

Artifact：mybatis-plus

版本：**2.0.7.RELEASE**

## 4、数据库配置

mysql5

```properties
#mysql数据库连接
spring.datasource.driver-class-name=com.mysql.jdbc.Driver
spring.datasource.url=jdbc:mysql://localhost:3306/mybatis_plus
spring.datasource.username=root
spring.datasource.password=root
```

mysql8以上（spring boot 2.1）

**注意：**driver和url的变化

```properties
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
spring.datasource.url=jdbc:mysql://localhost:3306/mybatis_plus?serverTimezone=GMT%2B8
spring.datasource.username=root
spring.datasource.password=root
```

**注意：**

1、这里的 url 使用了 ?serverTimezone=GMT%2B8 后缀，因为Spring Boot 2.1 集成了 8.0版本的jdbc驱动，这个版本的 jdbc 驱动需要添加这个后缀，否则运行测试用例报告如下错误：

java.sql.SQLException: The server time zone value 'ÖÐ¹ú±ê×¼Ê±¼ä' is unrecognized or represents more 

2、这里的 driver-class-name 使用了 com.mysql.cj.jdbc.Driver ，在 jdbc 8 中 建议使用这个驱动，之前的 com.mysql.jdbc.Driver 已经被废弃，否则运行测试用例的时候会有 WARN 信息

3、springboot2.0.X 和 springboot2.1.X区别

（1）springboot2.1.x版本时候，使用数据驱动和数据库地址时候不同

（2）springboot1.5.x和springboot2.X版本区别：

​			springboot1.5.x底层使用spring4.x

​            springboot2.x底层使用spring5.x

spring5.x 比 spring4.x 提供了更多的注解



# 四、编写代码

## 1、主类

在 Spring Boot 启动类中添加 `@MapperScan` 注解，扫描 Mapper 文件夹

**注意：**扫描的包名根据实际情况修改 

```java
@SpringBootApplication
@MapperScan("com.atguigu.mybatisplus.mapper")
public class MybatisPlusApplication {
    ......
}
```

到了后面，此注解可以放到配置类上。

## 2、实体

创建包 entity 编写实体类 `User.java`（此处使用了 [Lombok](https://www.projectlombok.org/) 简化代码）

Long 对应 BIGINT

String 对应 VARCHAR  

```java
@Data
public class User {
    private Long id;
    private String name;
    private Integer age;
    private String email;
}
```

查看编译结果

![img](..\images\TIM截图20200210200757.png)

Lombok使用参考：

https://blog.csdn.net/motui/article/details/79012846 

## 3、mapper

创建包 mapper 编写Mapper 接口： `UserMapper.java` 

```java
@Component
public interface UserMapper extends BaseMapper<User> {
    
}
```



# 五、开始使用 

添加测试类，进行功能测试： 

```java
@RunWith(SpringRunner.class)
@SpringBootTest
public class MybatisPlusApplicationTests {

    @Autowired
    private UserMapper userMapper;

    @Test
    public void testSelectList() {
        System.out.println(("----- selectAll method test ------"));
        // UserMapper 中的 selectList() 方法的参数为 MP 内置的条件封装器 Wrapper
        // 所以不填写就是无任何条件
        List<User> users = userMapper.selectList(null);
        users.forEach(System.out::println);
    }
}
```

**注意：**

IDEA在 userMapper 处报错，因为找不到注入的对象，因为类是动态创建的，但是程序可以正确的执行。

为了避免报错，可以在 dao 层 的接口上添加 @Repository 或 @Component 注解

控制台输出：

```shell
User(id=1, name=Jone, age=18, email=test1@baomidou.com)
User(id=2, name=Jack, age=20, email=test2@baomidou.com)
User(id=3, name=Tom, age=28, email=test3@baomidou.com)
User(id=4, name=Sandy, age=21, email=test4@baomidou.com)
User(id=5, name=Billie, age=24, email=test5@baomidou.com)
```

通过以上几个简单的步骤，我们就实现了 User 表的 CRUD 功能，甚至连 XML 文件都不用编写！



# 六、配置日志

查看sql输出日志 

```properties
#mybatis日志
mybatis-plus.configuration.log-impl=org.apache.ibatis.logging.stdout.StdOutImpl
```

执行日志

```shell
Creating a new SqlSession
SqlSession [org.apache.ibatis.session.defaults.DefaultSqlSession@3887cf88] was not registered for synchronization because synchronization is not active
JDBC Connection [HikariProxyConnection@1164241227 wrapping com.mysql.jdbc.JDBC4Connection@54534abf] will not be managed by Spring
==> Preparing: SELECT id,name,age,email FROM user 
==> Parameters: 
<== Columns: id, name, age, email
<== Row: 2, lvmc, 23, 1106927846@qq.com
<== Row: 4, tangwq, 22, 23456@163.com
<== Row: 10086, 姜子牙, 9999, 234567@126.com
<== Total: 3
```

**SqlSession**：mybatis 里的一个对象

底层 sql 语句：

```sql
SELECT id,name,age,email FROM user 
```





# 七、CRUD接口

## 1、insert

### 1.1 插入操作

```java
    @Test
    public void testInsert(){

        User user = new User();
        user.setName("Helen");
        user.setAge(18);
        user.setEmail("55317332@qq.com");

        int result = userMapper.insert(user);
        System.out.println(result); //影响的行数
        System.out.println(user); 	//id自动回填
    }
```

**注意：**数据库插入id值默认为：全局唯一id

![](..\images\image-20200210172753232.png)



### 1.2 主键策略

数据库做分库分表操作时，若使用自动增长（AUTO_INCREMENT），需要在最后一张表中得到最后一条记录的id，在id基础之上+1，这样就比较麻烦。

![](..\images\TIM截图20200210173559.png)

**补充：**

> 集群：在很多台服务器中部署同一项目
>
> 分布式：把项目中的不同模块放到不同服务器上

所以采用

**（1）ID_WORKER**

MyBatis-Plus默认的主键策略是：ID_WORKER  *全局唯一ID*

> **参考资料：分布式系统唯一ID生成方案汇总：**https://www.cnblogs.com/haoxinyue/p/5208136.html
>
> 分布式主键id生成策略
>
> （1）redis生成id，使用原子操作incr
>
> （2）使用mp自带（默认）策略，底层算法是snowflake算法



使用IdWorker工具类测试id的生成，了解id生成原理

- 添加工具类：IdWorker.java
- 编写测试用例：

```java
@Test
public void testIdWorker(){
    long id = new IdWorker().nextId();
    System.out.println(id);
}
```

**（2）自增策略**

- 要想主键自增需要配置如下主键策略
  - 需要在创建数据表的时候设置主键自增
  - 实体字段中配置 @TableId(type = IdType.AUTO)

```java
@TableId(type = IdType.AUTO)
private Long id;
```

要想影响所有实体的配置，可以设置全局主键配置

```properties
#全局设置主键生成策略
mybatis-plus.global-config.db-config.id-type=auto
```

其它主键策略：分析 IdType 源码可知

```java
@Getter
public enum IdType {
    /**
     * 数据库ID自增
     */
    AUTO(0),
    /**
     * 该类型为未设置主键类型
     */
    NONE(1),
    /**
     * 用户输入ID
     * 该类型可以通过自己注册自动填充插件进行填充
     */
    INPUT(2),

    /* 以下3种类型、只有当插入对象ID 为空，才自动填充。 */
    /**
     * 全局唯一ID (idWorker)
     */
    ID_WORKER(3),
    /**
     * 全局唯一ID (UUID)
     */
    UUID(4),
    /**
     * 字符串全局唯一ID (idWorker 的字符串表示)
     */
    ID_WORKER_STR(5);

    private int key;

    IdType(int key) {
        this.key = key;
    }
}
```





## 2、update

### 2.1 根据id更新操作

**注意：**update时生成的sql自动是动态sql：

```sql
UPDATE user SET age=? WHERE id=? 
```



```java
    @Test
    public void testUpdateById(){

        User user = new User();
        user.setId(1L);
        user.setAge(28);

        int result = userMapper.updateById(user);
        System.out.println(result);//影响的行数

    }
```

### 2.2 自动填充

项目中经常会遇到一些数据，每次都使用相同的方式填充，例如记录的创建时间，更新时间等。

我们可以使用MyBatis Plus的自动填充功能，完成这些字段的赋值工作：

**（1）数据库表中添加自动填充字段**

在User表中添加datetime类型的新的字段 create_time、update_time

**（2）实体上添加注解**

```java
@Data
public class User {
    ......
        
    @TableField(fill = FieldFill.INSERT)
    private Date createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private Date updateTime;
}
```

**注意：在类里面使用驼峰命名，表中使用下划线命名，这样才能对应**

**（3）实现元对象处理器接口**

**注意：**

@Component确保mp在运行时执行这两个方法，这是一个普通类，在spring里面要进行实例化

```java
@Component
public class MyMetaObjectHandler implements MetaObjectHandler {

    private static final Logger LOGGER = LoggerFactory.getLogger(MyMetaObjectHandler.class);

    // 在mp执行添加操作时运行
    @Override
    public void insertFill(MetaObject metaObject) {
        LOGGER.info("start insert fill ....");
        // 把new Date()添加到"createTime"，
        this.setFieldValByName("createTime", new Date(), metaObject);
        this.setFieldValByName("updateTime", new Date(), metaObject);
    }

    // 在mp执行修改操作时运行
    @Override
    public void updateFill(MetaObject metaObject) {
        LOGGER.info("start update fill ....");
        this.setFieldValByName("updateTime", new Date(), metaObject);
    }
}
```



### 2.3 乐观锁

![](..\images\TIM截图20200210174148.png)

**主要适用场景：**当要更新一条记录的时候，希望这条记录没有被别人更新，也就是说实现线程安全的数据更新

**乐观锁实现方式：**

- 取出记录时，获取当前 version
- 更新时，带上这个 version
- 执行更新时， set version = newVersion where version = oldVersion
- 如果 version 不对，就更新失败

**（1）数据库中添加version字段**

```sql
ALTER TABLE `user` ADD COLUMN `version` INT
```

**（2）实体类添加version字段**

并添加 @Version 注解

```java
@Version
@TableField(fill = FieldFill.INSERT)
private Integer version;
```

**（3）元对象处理器接口添加version的insert默认值 **

```java
@Override
public void insertFill(MetaObject metaObject) {
    ......
    this.setFieldValByName("version", 1, metaObject);
}
```

**特别说明:**

* 支持的数据类型只有 int,Integer,long,Long,Date,Timestamp,LocalDateTime
* 整数类型下 `newVersion = oldVersion + 1`
* `newVersion` 会回写到 `entity` 中
* 仅支持 `updateById(id)` 与 `update(entity, wrapper)` 方法
* 在 `update(entity, wrapper)` 方法下, `wrapper` 不能复用!!!



**（4）在MybatisPlusConfig 中注册 Bean**

创建配置类

```java
@EnableTransactionManagement
@Configuration
@MapperScan("com.atguigu.mybatis_plus.mapper")
public class MybatisPlusConfig {

    /**
     * 乐观锁插件
     */
    @Bean
    public OptimisticLockerInterceptor optimisticLockerInterceptor() {
        return new OptimisticLockerInterceptor();
    }
}
```

**（5）测试乐观锁可以修改成功**

测试后分析打印的sql语句，将version的数值进行了加1操作

```java
/**
 * 测试 乐观锁插件
 */
@Test
public void testOptimisticLocker() {

    //查询
    User user = userMapper.selectById(1L);
    //修改数据
    user.setName("Helen Yao");
    user.setEmail("helen@qq.com");
    //执行更新
    userMapper.updateById(user);
}
```

**（6）测试乐观锁修改失败**

```java
/**
 * 测试乐观锁插件 失败
 */
@Test
public void testOptimisticLockerFail() {

    //查询
    User user = userMapper.selectById(1L);
    //修改数据
    user.setName("Helen Yao1");
    user.setEmail("helen@qq.com1");

    //模拟取出数据后，数据库中version实际数据比取出的值大，即已被其它线程修改并更新了version
    user.setVersion(user.getVersion() - 1);

    //执行更新
    userMapper.updateById(user);
}
```





## 3、select

### 2.1 根据id查询记录

```java
@Test
public void testSelectById(){

    User user = userMapper.selectById(1L);
    System.out.println(user);
}
```

### 2.2 通过多个id批量查询

完成了动态sql的foreach的功能

```java
@Test
public void testSelectBatchIds(){

    List<User> users = userMapper.selectBatchIds(Arrays.asList(1, 2, 3));
    users.forEach(System.out::println);
}
```

### 2.3 简单的条件查询

通过map封装查询条件

```java
@Test
public void testSelectByMap(){

    HashMap<String, Object> map = new HashMap<>();
    map.put("name", "Helen");
    map.put("age", 18);
    List<User> users = userMapper.selectByMap(map);

    users.forEach(System.out::println);
}
```

**注意：**map中的key对应的是数据库中的列名。例如数据库user_id，实体类是userId，这时map的key需要填写user_id



### 2.4 分页

MyBatis Plus自带分页插件，只要简单的配置即可实现分页功能

**（1）创建配置类**

```java
/**
 * 分页插件
 */
@Bean
public PaginationInterceptor paginationInterceptor() {
    return new PaginationInterceptor();
}
```

**（2）测试selectPage分页**

**测试：**最终通过page对象获取相关数据

```java
@Test
public void testSelectPage() {
	// 两个参数：当前页，每页记录数
    Page<User> page = new Page<>(1,5);
    userMapper.selectPage(page, null);

    page.getRecords().forEach(System.out::println);
/**
 * 或者写作：
 * List<User> records = page.getRecords();
 * System.out.println(records);
 */
    
    System.out.println(page.getCurrent());
    System.out.println(page.getPages());
    System.out.println(page.getSize());
    System.out.println(page.getTotal());
    System.out.println(page.hasNext());
    System.out.println(page.hasPrevious());
}
```

SELECT COUNT(1) FROM user 查询表中数量

控制台sql语句打印：

```sql
SELECT id,name,age,email,create_time,update_time FROM user LIMIT 0,5 
```

**（3）测试selectMapsPage分页：结果集是Map**

```java
@Test
public void testSelectMapsPage() {

    Page<User> page = new Page<>(1, 5);

    IPage<Map<String, Object>> mapIPage = userMapper.selectMapsPage(page, null);

    //注意：此行必须使用 mapIPage 获取记录列表，否则会有数据类型转换错误
    mapIPage.getRecords().forEach(System.out::println);
    System.out.println(page.getCurrent());
    System.out.println(page.getPages());
    System.out.println(page.getSize());
    System.out.println(page.getTotal());
    System.out.println(page.hasNext());
    System.out.println(page.hasPrevious());
}
```



## 4、delete

### 4.1 根据id删除记录

```java
// 物理删除
@Test
public void testDeleteById(){

    int result = userMapper.deleteById(8L);
    System.out.println(result);
}
```

### 4.2 批量删除

```java
@Test
public void testDeleteBatchIds() {

    int result = userMapper.deleteBatchIds(Arrays.asList(8, 9, 10));
    System.out.println(result);
}
```

### 4.3 简单的条件查询

```java
@Test
public void testDeleteByMap() {

    HashMap<String, Object> map = new HashMap<>();
    map.put("name", "Helen");
    map.put("age", 18);

    int result = userMapper.deleteByMap(map);
    System.out.println(result);
}
```



### 4.4 逻辑删除

- 物理删除：真实删除，**将对应数据从数据库中删除**，**之后查询不到此条被删除数据**
- 逻辑删除：假删除，**将对应数据中代表是否被删除字段状态修改为“被删除状态”，之后在数据库中仍旧能看到此条数据记录**

**（1）数据库中添加 deleted 字段**

```sql
ALTER TABLE `user` ADD COLUMN `deleted` boolean
```

**（2）实体类添加 deleted 字段**

并加上 @TableLogic 注解 和 @TableField(fill = FieldFill.INSERT) 注解

```java
@TableLogic
@TableField(fill = FieldFill.INSERT)
private Integer deleted;
```

**（3）元对象处理器接口添加deleted的insert默认值**

```java
@Override
public void insertFill(MetaObject metaObject) {
    ......
    this.setFieldValByName("deleted", 0, metaObject);
}
```

**（4）application.properties 加入配置**

此为默认值，如果你的默认值和mp默认的一样,该配置可无

```properties
# 0是不删除，1是删除
mybatis-plus.global-config.db-config.logic-delete-value=1
mybatis-plus.global-config.db-config.logic-not-delete-value=0
```

**（5）在 MybatisPlusConfig 中注册 Bean**

```java
/**
 * 逻辑删除插件
 * @return
 */
@Bean
public ISqlInjector sqlInjector() {
    return new LogicSqlInjector();
}
```

**（6）测试逻辑删除**

- 测试后发现，数据并没有被删除，deleted字段的值由0变成了1
- 测试后分析打印的sql语句，是一条**update**
- **注意：**被删除数据的 deleted 字段的值必须是 0，才能被选取出来执行逻辑删除的操作

```java
/**
 * 测试 逻辑删除
 */
@Test
public void testLogicDelete() {

    int result = userMapper.deleteById(1L);
    System.out.println(result);
}
```

执行的sql语句是：

```sql
UPDATE user SET deleted=1 WHERE id=? AND deleted=0 
```

**（7）测试逻辑删除后的查询**

MyBatis Plus中查询操作也会自动添加逻辑删除字段的判断

这时默认只能查删除后的，要查 deleted=1 要自己写

```java
/**
 * 测试 逻辑删除后的查询：
 * 不包括被逻辑删除的记录
 */
@Test
public void testLogicDeleteSelect() {
    User user = new User();
    List<User> users = userMapper.selectList(null);
    users.forEach(System.out::println);
}
```

测试后分析打印的sql语句，包含 WHERE deleted=0 

```sql
SELECT id,name,age,email,create_time,update_time,deleted FROM user WHERE deleted=0
```





## 5、性能分析

性能分析拦截器，用于输出每条 SQL 语句及其执行时间

SQL 性能执行分析,开发环境使用，超过指定时间，停止运行。有助于发现问题

### 5.1 配置插件

**（1）参数说明**

参数：maxTime： SQL 执行最大时长，超过自动停止运行，有助于发现问题。

参数：format： SQL是否格式化，默认false。

**（2）在 MybatisPlusConfig 中配置**

```java
/**
 * SQL 执行性能分析插件
 * 开发环境使用，线上不推荐。 maxTime 指的是 sql 最大执行时长
 */
@Bean
@Profile({"dev","test"})// 设置 dev test 环境开启
public PerformanceInterceptor performanceInterceptor() {
    PerformanceInterceptor performanceInterceptor = new PerformanceInterceptor();
    performanceInterceptor.setMaxTime(100);//ms，超过此处设置的ms则sql不执行
    performanceInterceptor.setFormat(true);
    return performanceInterceptor;
}
```

**3）Spring Boot 中设置dev环境** 

```properties
#环境设置：dev、test、prod
spring.profiles.active=dev
```

可以针对各环境新建不同的配置文件`application-dev.properties`、`application-test.properties`、`application-prod.properties`

也可以自定义环境名称：如test1、test2



### 5.2 测试

```java
/**
 * 测试 性能分析插件
 */
@Test
public void testPerformance() {
    User user = new User();
    user.setName("我是Helen");
    user.setEmail("helen@sina.com");
    user.setAge(18);
    userMapper.insert(user);
}
```

**将maxTime 改小之后再次进行测试**

```java
performanceInterceptor.setMaxTime(5); //ms，超过此处设置的ms不执行
```

如果执行时间过长，则抛出异常：The SQL execution time is too large



# 八、wapper介绍

条件构造器

![](..\images\27b56b5e-39a6-42ba-b7ed-4f109b6ad7bf.png)

Wrapper ： 条件构造抽象类，最顶端父类
*  AbstractWrapper ： 用于查询条件封装，生成 sql 的 where 条件
  * QueryWrapper ： Entity 对象封装操作类，不是用lambda语法
  * UpdateWrapper ： Update 条件封装，用于Entity对象更新操作
  * AbstractLambdaWrapper ： Lambda 语法使用 Wrapper统一处理解析 lambda 获取 column。
    * LambdaQueryWrapper ：看名称也能明白就是用于Lambda语法使用的查询Wrapper
    * LambdaUpdateWrapper ： Lambda 更新封装Wrapper

```java
@RunWith(SpringRunner.class)
@SpringBootTest
public class QueryWrapperTests {
    
    @Autowired
    private UserMapper userMapper;
}
```



## 1、AbstractWrapper

**注意：**以下条件构造器的方法入参中的 `column ` 均表示数据库字段

### 1.1 ge、gt、le、lt、isNull、isNotNull

gt大于， lt小于，ge大于等于，le小于等于

```java
@Test
public void testDelete() {
	// 构建条件
    QueryWrapper<User> queryWrapper = new QueryWrapper<>();
    // 这里是表中的字段名称，而不是属性名称
    queryWrapper
        .isNull("name")
        .ge("age", 12)
        .isNotNull("email");
    int result = userMapper.delete(queryWrapper);
    System.out.println("delete return count = " + result);
}
```

```sql
UPDATE user SET deleted=1 WHERE deleted=0 AND name IS NULL AND age >= ? AND email IS NOT NULL
```



### 1.2 eq、ne

**注意：**seletOne返回的是一条实体记录，当出现多条时会报错

```java
@Test
public void testSelectOne() {

    QueryWrapper<User> queryWrapper = new QueryWrapper<>();
    queryWrapper.eq("name", "Tom");

    User user = userMapper.selectOne(queryWrapper);
    System.out.println(user);
}
```

```sql
SELECT id,name,age,email,create_time,update_time,deleted,version FROM user WHERE deleted=0 AND name = ? 
```



### 1.3 between、notBetween

包含大小边界

```java
@Test
public void testSelectCount() {

    QueryWrapper<User> queryWrapper = new QueryWrapper<>();
    // 查询年龄在20~30
    queryWrapper.between("age", 20, 30);

    Integer count = userMapper.selectCount(queryWrapper);
    System.out.println(count);
}
```

```sql
SELECT COUNT(1) FROM user WHERE deleted=0 AND age BETWEEN ? AND ? 
```



### 1.4 allEq

```java
@Test
public void testSelectList() {

    QueryWrapper<User> queryWrapper = new QueryWrapper<>();
    Map<String, Object> map = new HashMap<>();
    map.put("id", 2);
    map.put("name", "Jack");
    map.put("age", 20);

    queryWrapper.allEq(map);
    List<User> users = userMapper.selectList(queryWrapper);

    users.forEach(System.out::println);
}
```

```sql
SELECT id,name,age,email,create_time,update_time,deleted,version 
FROM user WHERE deleted=0 AND name = ? AND id = ? AND age = ? 
```



### 1.5 like、notLike、likeLeft、likeRight

selectMaps返回Map集合列表

```java
@Test
public void testSelectMaps() {

    QueryWrapper<User> queryWrapper = new QueryWrapper<>();
    queryWrapper
        .notLike("name", "e")
        .likeRight("email", "t");

    List<Map<String, Object>> maps = userMapper.selectMaps(queryWrapper);//返回值是Map列表
    maps.forEach(System.out::println);
}
```

```sql
SELECT id,name,age,email,create_time,update_time,deleted,version 
FROM user WHERE deleted=0 AND name NOT LIKE ? AND email LIKE ? 
```



### 1.6 in、notIn、inSql、notinSql、exists、notExists

**in、notIn：**

* notIn("age",{1,2,3})--->age not in (1,2,3)
* notIn("age", 1, 2, 3)--->age not in (1,2,3)

**inSql、notinSql：可以实现子查询**

- 例: `inSql("age", "1,2,3,4,5,6")`--->`age in (1,2,3,4,5,6)`
- 例: `inSql("id", "select id from table where id < 3")`--->`id in (select id from table where id < 3)`

```java
@Test
public void testSelectObjs() {

    QueryWrapper<User> queryWrapper = new QueryWrapper<>();
    //queryWrapper.in("id", 1, 2, 3);
    queryWrapper.inSql("id", "select id from user where id < 3");

    List<Object> objects = userMapper.selectObjs(queryWrapper);//返回值是Object列表
    objects.forEach(System.out::println);
}
```

```sql
SELECT id,name,age,email,create_time,update_time,deleted,version 
FROM user WHERE deleted=0 AND id IN (select id from user where id < 3) 

```



### 1.7 or、and

**注意：**这里使用的是 UpdateWrapper 

不调用`or`则默认为使用 `and `连

```java
@Test
public void testUpdate1() {

    //修改值
    User user = new User();
    user.setAge(99);
    user.setName("Andy");

    //修改条件
    UpdateWrapper<User> userUpdateWrapper = new UpdateWrapper<>();
    userUpdateWrapper
        .like("name", "h")
        .or()
        .between("age", 20, 30);

    int result = userMapper.update(user, userUpdateWrapper);

    System.out.println(result);
}
```

```sql
UPDATE user SET name=?, age=?, update_time=? WHERE deleted=0 AND name LIKE ? OR age BETWEEN ? AND ?
```



### 1.8 嵌套or、嵌套and

这里使用了lambda表达式，or中的表达式最后翻译成sql时会被加上圆括号

```java
@Test
public void testUpdate2() {


    //修改值
    User user = new User();
    user.setAge(99);
    user.setName("Andy");

    //修改条件
    UpdateWrapper<User> userUpdateWrapper = new UpdateWrapper<>();
    userUpdateWrapper
        .like("name", "h")
        .or(i -> i.eq("name", "李白").ne("age", 20));

    int result = userMapper.update(user, userUpdateWrapper);

    System.out.println(result);
}
```

```sql
UPDATE user SET name=?, age=?, update_time=? 
WHERE deleted=0 AND name LIKE ? 
OR ( name = ? AND age <> ? ) 
```



### 1.9 orderBy、orderByDesc、orderByAsc

```java
@Test
public void testSelectListOrderBy() {

    QueryWrapper<User> queryWrapper = new QueryWrapper<>();
    queryWrapper.orderByDesc("id");

    List<User> users = userMapper.selectList(queryWrapper);
    users.forEach(System.out::println);
}
```

```sql
SELECT id,name,age,email,create_time,update_time,deleted,version 
FROM user WHERE deleted=0 ORDER BY id DESC 
```





### 1.10 last

直接拼接到 sql 的最后

**注意：**只能调用一次,多次调用以最后一次为准 有sql注入的风险,请谨慎使用

```java
@Test
public void testSelectListLast() {

    QueryWrapper<User> queryWrapper = new QueryWrapper<>();
    queryWrapper.last("limit 1");

    List<User> users = userMapper.selectList(queryWrapper);
    users.forEach(System.out::println);
}
```

```sql
SELECT id,name,age,email,create_time,update_time,deleted,version 
FROM user WHERE deleted=0 limit 1 
```



### 1.11 指定要查询的列

```java
@Test
public void testSelectListColumn() {

    QueryWrapper<User> queryWrapper = new QueryWrapper<>();
    queryWrapper.select("id", "name", "age");

    List<User> users = userMapper.selectList(queryWrapper);
    users.forEach(System.out::println);
}
```



### 1.12 set、setSql

最终的sql会合并 user.setAge()，以及 userUpdateWrapper.set()  和 setSql() 中 的字段

```java
@Test
public void testUpdateSet() {

    //修改值
    User user = new User();
    user.setAge(99);

    //修改条件
    UpdateWrapper<User> userUpdateWrapper = new UpdateWrapper<>();
    userUpdateWrapper
        .like("name", "h")
        .set("name", "老李头")//除了可以查询还可以使用set设置修改的字段
        .setSql(" email = '123@qq.com'");//可以有子查询

    int result = userMapper.update(user, userUpdateWrapper);
}
```

```sql
UPDATE user SET age=?, update_time=?, name=?, email = '123@qq.com' WHERE deleted=0 AND name LIKE ? 
```

