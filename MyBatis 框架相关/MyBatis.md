[TOC]



# 概述

**ORM**apping: Object Relationship Mapping 对象关系映射 

对象指⾯向对象 

关系指关系型数据库 

Java 到 MySQL 的映射，开发者可以以面向对象的思想来管理数据库。

## 优点

1、SQL写在XML里，解除sql与程序代码的耦合，便于统一管理

2、提供XML标签，支持编写动态SQL语句，并可重用

## 缺点

1. SQL 语句编写工作量大
2. SQL 语句依赖数据库，导致数据库移植性差



## MyBatis 核心接口和类

![](..\images\TIM截图20200301162843.png)



## 开发方式

使用原生接口

Mapper 代理实现自定义接口





# 配置

## 一、pom.xml

## 二、新建数据表

```sql
use mybatis;
create table t_account(
 id int primary key auto_increment,
 username varchar(11),
 password varchar(11),
 age int
)
```

## 三、新建数据表对应的实体类 Account

```java
package com.southwind.entity;
import lombok.Data;
@Data
public class Account {
 private long id;
 private String username;
 private String password;
 private int age;
}
```



## 四、创建 MyBatis 的配置⽂件 config.xml

⽂件名可⾃定义

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE configuration PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
    <!-- 配置MyBatis运⾏环境 -->
    <environments default="development">
        <environment id="development">
            <!-- 配置JDBC事务管理 -->
            <transactionManager type="JDBC"></transactionManager>
            <!-- POOLED配置JDBC数据源连接池 -->
            <dataSource type="POOLED">
                <property name="driver" value="com.mysql.jdbc.Driver"></property>
                <property name="url"
                          value="jdbc:mysql://localhost:3306/mybatis?
useUnicode=true&amp;characterEncoding=UTF-8"></property>
                <property name="username" value="root"></property>
                <property name="password" value="root"></property>
            </dataSource>
        </environment>
    </environments>
</configuration>

```

default="development" 表示选用 id="development" 的配置环境





# 常规使用

## 一、原生接口

### 1. 自定义sql语句

MyBatis 框架需要开发者⾃定义 SQL 语句，写在 Mapper.xml ⽂件中，实际开发中，会为每个实体类创建对应的 Mapper.xml ，定义管理该对象数据的 SQL。

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.iteima.jdbc.mapper.AccountMapper">

    <insert id="save" parameterType="com.iteima.jdbc.entity.Account">
        insert into t_account(username,password,age)
        values(#{username},#{password},#{age})
    </insert>

</mapper>
```

* namespace 通常设置为⽂件所在包+⽂件名的形式。

* 以面向对象思想操作数据库的框架，就可以把insert标签看作一个方法，在调用方法的时候，需要传参数：
  
* 用 **parameterType="" 定义参数**
  
* 传过来的**对象Account**里面有username，passsord，age，用**#{}**取出来

  * **#{}和${}的区别是什么？**

    ${}是字符串替换，#{}是预处理；

    Mybatis在处理${}时，就是把${}直接替换成变量的值。而Mybatis在处理#{}时，会对sql语句进行预处理，将sql中的#{}替换为?号，调用PreparedStatement的set方法来赋值；

    使用#{}可以有效的防止SQL注入，提高系统安全性。

* **id** 是实际调⽤ MyBatis ⽅法时需要⽤到的参数



### 2. 注册 AccountMapper.xml 到 config.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE configuration PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
    <!-- 配置MyBatis运⾏环境 -->
    <environments default="development">
        <environment id="development">
            <!-- 配置JDBC事务管理 -->
            <transactionManager type="JDBC"></transactionManager>
            <!-- POOLED配置JDBC数据源连接池 -->
            <dataSource type="POOLED">
                <property name="driver" value="com.mysql.jdbc.Driver"></property>
                <property name="url"
                          value="jdbc:mysql://localhost:3306/mybatis?
useUnicode=true&amp;characterEncoding=UTF-8"></property>
                <property name="username" value="root"></property>
                <property name="password" value="root"></property>
            </dataSource>
        </environment>
    </environments>

    <!--注册AccountMapper.xml-->
    <mappers>
        <mapper resource="com/iteima/jdbc/mapper/AccountMapper.xml"></mapper>
    </mappers>
</configuration>
```



### 3. 调⽤ MyBatis 的原⽣接⼝执⾏添加操作

```java
package com.iteima.jdbc.controller;

public class test {
    public static void main(String[] args) {
        // 加载MyBatis配置文件，把config.xml读成流
        InputStream inputStream = test.class.getClassLoader().getResourceAsStream("config.xml");
        SqlSessionFactoryBuilder sqlSessionFactoryBuilder = new SqlSessionFactoryBuilder();
        SqlSessionFactory sqlSessionFactory = sqlSessionFactoryBuilder.build(inputStream);
        SqlSession sqlSession = sqlSessionFactory.openSession();
        String statement = "com.iteima.jdbc.mapper.AccountMapper.save";
        Account account = new Account(1L, "张三", "123123", 22);
        sqlSession.insert(statement,account);
        // 提交事务
        sqlSession.commit();
    }
}
```



## 二、通过 Mapper 代理实现⾃定义接⼝

⾃定义接⼝，定义相关业务⽅法。 

编写与⽅法相对应的 Mapper.xml。

### 1. 自定义接口

```java
package com.iteima.jdbc.repository;

public interface AccountRepository {

    public int save(Account account);
    public int update(Account account);
    public int deleteById(long id);
    public List<Account> findAll();
    public Account findById(long id);
}
```

### 2. 创建接⼝对应的 Mapper.xml

不需要写接口的实现类，只要在对应的xml文件中写接⼝⽅法对应的 SQL 语句。

statement 标签可根据 SQL 执⾏的业务选择 insert、delete、update、select。 MyBatis 框架会根据规则⾃动创建接⼝实现类的代理对象。

#### 规则：

* Mapper.xml 中 namespace 为接⼝的全类名。 
* Mapper.xml 中 statement 的 id 为接⼝中对应的⽅法名。 
* Mapper.xml 中 statement 的 parameterType 和接⼝中对应⽅法的参数类型⼀致。 
* Mapper.xml 中 statement 的 resultType 和接⼝中对应⽅法的返回值类型⼀致。

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.iteima.jdbc.repository.AccountRepository">

    <insert id="save" parameterType="com.iteima.jdbc.entity.Account">
        insert into t_account(username,password,age)
        values(#{username},#{password},#{age})
    </insert>

    <update id="update" parameterType="com.iteima.jdbc.entity.Account">
        update t_account
        set username=#{username},password=#{password},age=#{age}
        where id=#{id}
    </update>

    <delete id="deleteById" parameterType="long">
        delete from t_account
        where id=#{id}
    </delete>

    <select id="findAll" resultType="com.iteima.jdbc.entity.Account">
        select * from t_account
    </select>

    <select id="findById" parameterType="long" resultType="com.iteima.jdbc.entity.Account">
        select * from t_accout
        where id=#{id}
    </select>

</mapper>
```

因为insert，update在数据库里面执行的结果是int类型，返回值是影响的行数，既然已经知道是int类型，所以没必要写 resultType 

### 3. 在 config.xml 中注册 AccountRepository.xml

```xml
    <!--注册AccountMapper.xml-->
    <mappers>
        <mapper resource="com/iteima/jdbc/mapper/AccountMapper.xml"></mapper>
        <mapper resource="com/iteima/jdbc/repository/xml/AccountRepository.xml"></mapper>
    </mappers>
```

### 4. 调⽤接⼝的代理对象完成相关的业务操作

```java
package com.iteima.jdbc.controller;

public class test2 {

    public static void main(String[] args) {
        InputStream inputStream = test2.class.getClassLoader().getResourceAsStream("config.xml");
        SqlSessionFactoryBuilder sqlSessionFactoryBuilder = new SqlSessionFactoryBuilder();
        SqlSessionFactory sqlSessionFactory = sqlSessionFactoryBuilder.build(inputStream);
        SqlSession sqlSession = sqlSessionFactory.openSession();
        // 获取接口的代理对象
        AccountRepository accountRepository = sqlSession.getMapper(AccountRepository.class);
        // 添加对象
//        Account account = new Account(2L, "吕茂陈", "11111", 23);
//        int result = accountRepository.save(account);


        // 查询所有对象（只有查询不用提交事务，其他都需要）
//        List<Account> list = accountRepository.findAll();
//        for (Account account:list) {
//            System.out.println(account);
//        }

//        // 通过id查询
//        Account account = accountRepository.findById(2L);
//        System.out.println(account);

        // 修改对象
//        Account account1 = accountRepository.findById(1L);
//        account1.setUsername("汤卫勤");
//        account1.setPassword("1997");
//        account1.setAge(18);
//        int update = accountRepository.update(account1);

        // 删除对象
        int i = accountRepository.deleteById(2L);
        System.out.println(i);

        // 提交事务
        sqlSession.commit();
        sqlSession.close();
    }
}
```

***注意：***

sql执行完，数据有变化，需要提交事务，其他都不用

如果没有提交事务就执行增加操作，此时id由于自增，已经+1了，虽然没能体现在数据库，但此时如果再来一次增加操作并提交事务，会发现id跳了一位数







## 三、Mapper.xml

### 1. statement 标签

select、update、delete、insert 分别对应查询、修改、删除、添加操作。 

### 2. parameterType：参数数据类型

#### 1）基本数据类型，通过id查询 Account

```xml
<select id="findById" parameterType="long"
resultType="com.southwind.entity.Account">
 select * from t_account where id = #{id}
</select>
```

#### 2）String 类型，通过 name 查询 Account

```xml
    <select id="findByName" parameterType="string" resultType="com.iteima.jdbc.entity.Account">
        select * from t_account
        where username=#{username}
    </select>
```

#### 3）包装类，通过 id 查询 Account

```xml
    <select id="findById2" parameterType="Long" resultType="com.iteima.jdbc.entity.Account">
        select * from t_account
        where id=#{id}
    </select>
```

基本数据类型不能接受 **null**，会抛异常，而包装类不会抛

```java
        long id = Long.parseLong("1");
		// 或者直接传 1，不传 1L
        Account account = accountRepository.findById2(id);
        System.out.println(account);
```



#### 4）多个参数，通过 name 和 age 查询 Account

```java
public Account findByNameAndAge(String name,int age);
```

多个参数就不用写parameterType

```xml
    <select id="findByNameAndAge" resultType="com.iteima.jdbc.entity.Account">
        select * from t_account
        where username=#{arg0} and age=#{arg1}
    </select>
```

或者写 param1，param2

#### 5）Java Bean

```xml
    <update id="update" parameterType="com.iteima.jdbc.entity.Account">
        update t_account
        set username=#{username},password=#{password},age=#{age}
        where id=#{id}
    </update>
```



### 3. resultType：结果类型 

#### 1）基本数据类型，统计 Account 总数

```java
public int count();
```

```xml
    <select id="count" resultType="int">
        select count(id) from t_account
    </select>
```

```java
System.out.println(accountRepository.count());
```

#### 2）包装类，统计 Account 总数

```java
public Integer count2();
```

```xml
    <select id="count2" resultType="java.lang.Integer">
        select count(id) from t_account
    </select>
```

#### 3）String 类型，通过 id 查询 Account 的 name

```java
public String findNameById(long id);
```

```xml
    <select id="findNameById" resultType="java.lang.String">
        select username from t_account
        where id=#{id}
    </select>
```

#### 4）Java Bean

```xml
    <select id="findById" parameterType="long" resultType="com.iteima.jdbc.entity.Account">
        select * from t_account
        where id=#{id}
    </select>
```



## 四、及联查询

### 1. 一对多

#### 1.1 查询 students表，及联 classes 表

##### 1）数据库

数据表 classes 中字段 id，name

数据表 students 中字段 id，name，cid（外键关联 classes 表的id字段）

![](F:\Note\images\TIM截图20200302170606.png)

##### 2）实体类和接口

```java
package com.iteima.jdbc.entity;

@Data
public class Student {
    private long id;
    private String name;
    private Classes classes;
}
```

```java
package com.iteima.jdbc.entity;

@Data
public class Classes {
    private long id;
    private String name;
    private List<Student> students;
}
```

```java
package com.iteima.jdbc.repository;

public interface StudentRepository {
    public Student findById(long id);
}
```

##### 3）xml文件

如果直接这样写只能查出id和name

```xml
    <select id="findById" parameterType="long" resultType="com.iteima.jdbc.entity.Student">
        SELECT
	        s.id,s.name,c.id as cid,c.name as cname
        FROM
	        students s,classes c
        WHERE
	        s.id = #{id}
	    AND
	        s.cid = c.id
    </select>
```

因为 mybatis 不关注表和类的结构，只关注结果集（sql语句执行的结果）的字段名称和**Student属性名称**的映射。

所以只有id和name和Student的属性是对应的，才能查出来，classes没有对应的查不出。

现在要把 cid，cname 整到 Student 中要求的 classes属性，所以不能直接映射，要用 \<resultMap> 来间接映射

```xml
    <resultMap id="studentMap" type="com.iteima.jdbc.entity.Student">
        <id column="id" property="id"></id>
        <result column="name" property="name"></result>
        <association property="classes" javaType="com.iteima.jdbc.entity.Classes">
            <id column="cid" property="id"></id>
            <result column="cname" property="name"></result>
        </association>
    </resultMap>

    <select id="findById" parameterType="long" resultMap="studentMap">
        SELECT
	        s.id,s.name,c.id as cid,c.name as cname
        FROM
	        students s,classes c
        WHERE
	        s.id = #{id}
	    AND
	        s.cid = c.id
    </select>
```

***解析：***

* \<resultMap> 中的 id 是自定义名称，type是映射之后的结果

* \<id> 标签是专门用来映射主键，column表示取出结果集里面的某个字段，property表示把id映射给实体类的某一个属性，意思是：
  * 把column字段取出作为主键，映射给实体类Student中的id属性

```xml
<id column="id" property="id"></id>
```

* 除了主键以外的其它字段全都使用 \<result> 标签
  * 把column字段取出，映射给实体类Student中的name属性

```xml
<result column="name" property="name"></result>
```

* 要把cid，cname整合整合成一个对象，用\<association> 标签
  * property="classes" 表示和属性 classes 映射，
  * javaType是property的数据类型
  * 因为 classes 来自于cid，cname，所以在 \<association> 标签里面写标签：
    * 因为cid作为classes的主键，所以还用 \<id> 标签

* 最后就不能resultType了，要用 resultMap 进行关联



#### 1.2 查询 classes 表，及联 students 表

![](F:\Note\images\TIM截图20200302183005.png)

```java
package com.iteima.jdbc.repository;

public interface ClassesRepository {
    public Classes findById(long id);
}
```

```xml
    <resultMap id="classesMap" type="com.iteima.jdbc.entity.Classes">
        <id column="cid" property="id"></id>
        <result column="cname" property="name"></result>
        <collection property="students" ofType="com.iteima.jdbc.entity.Student">
            <id column="id" property="id"></id>
            <result column="name" property="name"></result>
        </collection>
    </resultMap>

    <select id="findById" parameterType="long" resultMap="classesMap">
        SELECT
	        s.id,s.name,c.id as cid,c.name as cname
        FROM
	        students s,classes c
        WHERE
	        c.id = #{id}
	    AND
	        s.cid = c.id
    </select>
```

* 实体类里面是一个集合，所以用\<collection>标签
  * ofType 是集合里的泛型

运行结果：

Classes(

id=2, name=6班, students=[

Student(id=1, name=张三, classes=null), 

Student(id=2, name=李四, classes=null), 

Student(id=3, name=王五, classes=null)

])



### 2. 多对多

#### 2.1 查询 goods 表，及联 customer 表

##### 1）数据库

数据表 goods 中字段 id，name

数据表 customer 中字段 id，name

数据表 customer_goods 中字段 id，cid（外键关联 customer 表的id字段），gid（外键关联 goods 表的id字段）

![](F:\Note\images\TIM截图20200303104724.png)

##### 2）实体类和接口

```java
package com.iteima.jdbc.repository;

public interface GoodsRepository {
    public Goods findById(long id);
}
```

```xml
    <resultMap id="goodsMap" type="com.iteima.jdbc.entity.Goods">
        <id column="gid" property="id"></id>
        <result column="gname" property="name"></result>
        <collection property="customers" ofType="com.iteima.jdbc.entity.Customer">
            <id column="cid" property="id"></id>
            <result column="cname" property="name"></result>
        </collection>
    </resultMap>

    <select id="findById" parameterType="long" resultMap="goodsMap">
        SELECT
	        c.id cid,
	        c.NAME cname,
	        g.id gid,
	        g.NAME gname
        FROM
	        customer c,
	        goods g,
	        customer_goods cg
        WHERE
	        g.id = #{id}
	        AND cg.cid = c.id
	        AND cg.gid = g.id
    </select>
```

***查询结果***：

Goods(

id=1, name=电视, customers=[

Customer(id=1, name=张三, goods=null), 

Customer(id=3, name=小红, goods=null)

])

#### 2.2 查询 customer 表，及联 goods 表

```xml
    <resultMap id="customerMap" type="com.iteima.jdbc.entity.Customer">
        <id column="cid" property="id"></id>
        <result column="cname" property="name"></result>
        <collection property="goods" ofType="com.iteima.jdbc.entity.Goods">
            <id column="gid" property="id"></id>
            <result column="gname" property="name"></result>
        </collection>
    </resultMap>

    <select id="findById" parameterType="long" resultMap="customerMap">
        SELECT
	        c.id cid,
	        c.NAME cname,
	        g.id gid,
	        g.NAME gname
        FROM
	        customer c,
	        goods g,
	        customer_goods cg
        WHERE
	        c.id = #{id}
	        AND cg.cid = c.id
	        AND cg.gid = g.id
    </select>
```



# 逆向工程

MyBatis 框架需要：实体类、⾃定义 Mapper 接⼝、Mapper.xml 

传统的开发中上述的三个组件需要开发者⼿动创建，逆向⼯程可以帮助开发者来⾃动创建三个组件，减轻开发者的⼯作量，提⾼⼯作效率。

## 缺点

只能执行一次；

根据数据表来建立实体类、接口、xml，如果把表结构改了就要删除已经生成的资源，重新执行逆向工程

## 使用

MyBatis Generator，简称 MBG，是⼀个专⻔为 MyBatis 框架开发者定制的代码⽣成器，可⾃动⽣成 MyBatis 框架所需的实体类、Mapper 接⼝、Mapper.xml，⽀持基本的 CRUD 操作，但是⼀些相对复杂的 SQL 需要开发者⾃⼰来完成。

* pom.xml

```xml
    <dependencies>

        <dependency>
            <groupId>org.mybatis</groupId>
            <artifactId>mybatis</artifactId>
            <version>3.4.5</version>
        </dependency>
        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <version>5.1.47</version>
        </dependency>
        <dependency>
            <groupId>org.mybatis.generator</groupId>
            <artifactId>mybatis-generator-core</artifactId>
            <version>1.3.2</version>
        </dependency>

    </dependencies>
```

* 创建 MBG 配置⽂件 generatorConfig.xml 

  1、jdbcConnection 配置数据库连接信息。 

  2、javaModelGenerator 配置 JavaBean 的⽣成策略。 

  3、sqlMapGenerator 配置 SQL 映射⽂件⽣成策略。 

  4、javaClientGenerator 配置 Mapper 接⼝的⽣成策略。 

  5、table 配置⽬标数据表（tableName：表名，domainObjectName：JavaBean 类名）。

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE generatorConfiguration
        PUBLIC "-//mybatis.org//DTD MyBatis Generator Configuration 1.0//EN"
        "http://mybatis.org/dtd/mybatis-generator-config_1_0.dtd">
<generatorConfiguration>
    <context id="testTables" targetRuntime="MyBatis3">
        <jdbcConnection
                driverClass="com.mysql.jdbc.Driver"
                connectionURL="jdbc:mysql://localhost:3306/mybatis?
useUnicode=true&amp;characterEncoding=UTF-8"
                userId="root"
                password="root"
        ></jdbcConnection>
        <javaModelGenerator targetPackage="com.southwind.entity"
                            targetProject="./src/main/java"></javaModelGenerator>
        <sqlMapGenerator targetPackage="com.southwind.repository"
                         targetProject="./src/main/java"></sqlMapGenerator>
        <javaClientGenerator type="XMLMAPPER"
                             targetPackage="com.southwind.repository" targetProject="./src/main/java">
        </javaClientGenerator>
        <table tableName="t_user" domainObjectName="User"></table>
    </context>
</generatorConfiguration>
```

domainObjectName 根据表名生成实体类的名字

* 创建 Generator 执⾏类

```java
package com.southwind;

import org.mybatis.generator.api.MyBatisGenerator;
import org.mybatis.generator.config.Configuration;
import org.mybatis.generator.config.xml.ConfigurationParser;
import org.mybatis.generator.exception.InvalidConfigurationException;
import org.mybatis.generator.exception.XMLParserException;
import org.mybatis.generator.internal.DefaultShellCallback;

import java.io.File;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class test {
    public static void main(String[] args) {
        List<String> warings = new ArrayList<String>();
        boolean overwrite = true;
        String genCig = "/generatorConfig.xml";
        File configFile = new File(test.class.getResource(genCig).getFile());
        ConfigurationParser configurationParser = new
                ConfigurationParser(warings);
        Configuration configuration = null;
        try {
            configuration = configurationParser.parseConfiguration(configFile);
        } catch (IOException e) {
            e.printStackTrace();
        } catch (XMLParserException e) {
            e.printStackTrace();
        }
        DefaultShellCallback callback = new DefaultShellCallback(overwrite);
        MyBatisGenerator myBatisGenerator = null;
        try {
            myBatisGenerator = new
                    MyBatisGenerator(configuration, callback, warings);
        } catch (InvalidConfigurationException e) {
            e.printStackTrace();
        }
        try {
            myBatisGenerator.generate(null);
        } catch (SQLException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}
```



# MyBatis 延迟加载 

* 什么是延迟加载？ 

延迟加载也叫懒加载、惰性加载，使⽤延迟加载可以提⾼程序的运⾏效率，针对于数据持久层的操作， **在某些特定的情况下去访问特定的数据库，在其他情况下可以不访问某些表，从⼀定程度上减少了 Java 应⽤与数据库的交互次数**。 

举例：

查询学⽣和班级的时，学⽣和班级是两张不同的表，如果当前需求只需要获取学⽣的信息，那么查询学⽣单表即可，如果需要通过学⽣获取对应的班级信息，则必须查询两张表。 

不同的业务需求，需要查询不同的表，根据具体的业务需求来动态减少数据表查询的⼯作就是延迟加 载。 

* 在 config.xml 中开启延迟加载

```xml
<settings>
 <!-- 打印SQL-->
 <setting name="logImpl" value="STDOUT_LOGGING" />
 <!-- 开启延迟加载 -->
 <setting name="lazyLoadingEnabled" value="true"/>
</settings>
```

* 将多表关联查询拆分成多个单表查询 

ClassesRepository

```java
public Classes findByIdLazy(long id);
```

ClassesRepository.xml

```xml
    <select id="findByIdLazy" parameterType="long" resultType="com.iteima.jdbc.entity.Classes">
        select * from classes where id = #{id}
    </select>
```

StudentRepository

```java
public Student findByIdLazy(long id);
```

***StudentRepository.xml***

```xml
    <resultMap id="studentMapLazy" type="com.iteima.jdbc.entity.Student">
        <id column="id" property="id"></id>
        <result column="name" property="name"></result>
        <association property="classes" javaType="com.iteima.jdbc.entity.Classes"
                     select="com.iteima.jdbc.repository.ClassesRepository.findByIdLazy" column="cid">
        </association>
    </resultMap>
    <select id="findByIdLazy" parameterType="long" resultMap="studentMapLazy">
        select * from students where id = #{id}
    </select>
```

在 StudentRepository.xml 中，需要调用 ClassesRepository 的 findByIdLazy() 方法，所以直接把这个方法的全类名写到 **select 属性**中，这个方法的**参数**就是 column 指定的 cid，

这个 cid 是 StudentRepository 中的 findByIdLazy() 方法的结果集中的 cid，运行最后会执行两次 SQL

![](F:\Note\images\TIM截图20200303151936.png)

不开启延迟加载：

![](F:\Note\images\TIM截图20200303152611.png)

开启后：

![](F:\Note\images\TIM截图20200303152903.png)



# MyBatis 缓存 

## 一、什么是 MyBatis 缓存 

使⽤缓存可以减少 Java 应⽤与数据库的交互次数，从⽽提升程序的运⾏效率。

⽐如查询出 id = 1 的对象，第⼀次查询出之后会⾃动将该对象保存到缓存中，当下⼀次查询时，直接从缓存中取出对象即可， ⽆需再次访问数据库。 

## 二、MyBatis 缓存分类 

### 1. ⼀级缓存

SqlSession 级别，默认开启，并且不能关闭。 

操作数据库时需要创建 SqlSession 对象，在对象中有⼀个 **HashMap ⽤于存储缓存数据**，不同的 SqlSession 之间**缓存数据区域是互不影响**的。 

⼀级缓存的作⽤域是 SqlSession 范围的，当在同⼀个 SqlSession 中执⾏两次相同的 SQL 语句时，**第⼀次执⾏完毕会将结果保存到缓存中**，第⼆次查询时直接从缓存中获取。 

需要注意的是，如果 SqlSession 执⾏了 DML 操作（insert、update、delete），MyBatis 必须**将缓存清空**以保证数据的准确性。 

```java
package com.iteima.jdbc.controller;

public class test4 {
    public static void main(String[] args) {
        InputStream inputStream = test2.class.getClassLoader().getResourceAsStream("config.xml");
        SqlSessionFactoryBuilder sqlSessionFactoryBuilder = new SqlSessionFactoryBuilder();
        SqlSessionFactory sqlSessionFactory = sqlSessionFactoryBuilder.build(inputStream);
        SqlSession sqlSession = sqlSessionFactory.openSession();
        AccountRepository accountRepository = sqlSession.getMapper(AccountRepository.class);
        Account account = accountRepository.findById(1L);
        System.out.println(account);
    }
}
```

这时执行了一次SQL语句，已有缓存，再加两行代码

![](F:\Note\images\TIM截图20200303160341.png)

输出两行结果，但只执行了一次 SQL



### 2. ⼆级缓存

Mapper 级别，默认关闭，可以开启。 

使⽤⼆级缓存时，多个 SqlSession 使⽤同⼀个 Mapper 的 SQL 语句操作数据库，得到的数据会存在⼆级缓存区，同样是使⽤ HashMap 进⾏数据存储，相⽐较于⼀级缓存，⼆级缓存的范围更⼤，**多个 SqlSession 可以共⽤⼆级缓存**，⼆级缓存是跨 SqlSession 的。 

⼆级缓存是多个 SqlSession 共享的，其作⽤域是 Mapper 的同⼀个 namespace，不同的 SqlSession 两次执⾏相同的 namespace 下的 SQL 语句，参数也相等，则第⼀次执⾏成功之后会将数据保存到⼆级缓存中，第⼆次可直接从⼆级缓存中取出数据。

#### 2.1 MyBatis 自带的二级缓存

* config.xml 配置开启⼆级缓存

```xml
    <settings>
        <!-- 打印SQL-->
        <setting name="logImpl" value="STDOUT_LOGGING" />
        <!-- 开启延迟加载 -->
        <setting name="lazyLoadingEnabled" value="true"/>
        <!-- 开启⼆级缓存 -->
        <setting name="cacheEnabled" value="true"/>
    </settings>
```

* Mapper.xml 中配置⼆级缓存

```xml
    <cache></cache>
```

* 实体类实现序列化接⼝

```java
package com.iteima.jdbc.entity;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class Account implements Serializable {

    private long id;
    private String username;
    private String password;
    private int age;
}
```

* 关闭一级缓存，查看二级缓存：

![](F:\Note\images\TIM截图20200303161758.png)



#### 2.2 ehcache自带的二级缓存

* pom.xml 添加相关依赖

```xml
<dependency>
 <groupId>org.mybatis</groupId>
 <artifactId>mybatis-ehcache</artifactId>
 <version>1.0.0</version>
</dependency>
<dependency>
 <groupId>net.sf.ehcache</groupId>
 <artifactId>ehcache-core</artifactId>
 <version>2.4.3</version>
</dependency>
```

* 添加 ehcache.xml

```xml
<ehcache xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xsi:noNamespaceSchemaLocation="../config/ehcache.xsd">
 <diskStore/>
 <defaultCache
 maxElementsInMemory="1000"
 maxElementsOnDisk="10000000"
 eternal="false"
 overflowToDisk="false"
 timeToIdleSeconds="120"
 timeToLiveSeconds="120"
 diskExpiryThreadIntervalSeconds="120"
 memoryStoreEvictionPolicy="LRU">
 </defaultCache>
</ehcache>
```

* config.xml 配置开启⼆级缓存

```xml
<settings>
 <!-- 打印SQL-->
 <setting name="logImpl" value="STDOUT_LOGGING" />
 <!-- 开启延迟加载 -->
 <setting name="lazyLoadingEnabled" value="true"/>
 <!-- 开启⼆级缓存 -->
 <setting name="cacheEnabled" value="true"/>
</settings>
```

* Mapper.xml 中配置⼆级缓存

```xml
<cache type="org.mybatis.caches.ehcache.EhcacheCache">
 <!-- 缓存创建之后，最后⼀次访问缓存的时间⾄缓存失效的时间间隔 -->
 <property name="timeToIdleSeconds" value="3600"/>
 <!-- 缓存⾃创建时间起⾄失效的时间间隔 -->
 <property name="timeToLiveSeconds" value="3600"/>
 <!-- 缓存回收策略，LRU表示移除近期使⽤最少的对象 -->
 <property name="memoryStoreEvictionPolicy" value="LRU"/>
</cache>
```

* 实体类不需要实现序列化接⼝





# MyBatis 

动态 SQL 使⽤动态 SQL 可简化代码的开发，减少开发者的⼯作量，程序可以⾃动根据业务参数来决定 SQL 的组成。 

## 示例：

* 接口

```java
public Account findByAccount(Account account);
```

* AccountRepository.xml

```xml
    <select id="findByAccount" parameterType="com.iteima.jdbc.entity.Account" resultType="com.iteima.jdbc.entity.Account">
        select * from t_account
        where id=#{id}
        and username=#{username}
        and age=#{age}
        and password =#{password}
    </select>
```

![](F:\Note\images\TIM截图20200303164244.png)

此时四个条件都是满足的，所以能查出来，但如果有一个条件不满足，就查不出来了

![](F:\Note\images\TIM截图20200303164410.png)

因为 **and** 是***与关系***



## if 标签

if 标签可以⾃动根据表达式的结果来决定是否将对应的语句添加到 SQL 中，如果条件不成⽴则不添加， 如果条件成⽴则添加。

```xml
    <select id="findByAccount" parameterType="com.iteima.jdbc.entity.Account" resultType="com.iteima.jdbc.entity.Account">
        select * from t_account
        where
        <if test="id != 0">
            id=#{id}
        </if>
        <if test="username != null">
            and username=#{username}
        </if>
        <if test="password != null">
            and password =#{password}
        </if>
        <if test="age != 0">
            and age=#{age}
        </if>
    </select>
```

此时password=null，就可以不加这个条件，但还是查询成功：

![](F:\Note\images\TIM截图20200303165235.png)



## where 标签

where 标签可以⾃动判断是否要删除语句块中的 and 关键字，如果检测到 where 直接跟 and 拼接，则 ⾃动删除 and，通常情况下 if 和 where 结合起来使⽤。

```xml
    <select id="findByAccount" parameterType="com.iteima.jdbc.entity.Account" resultType="com.iteima.jdbc.entity.Account">
        select * from t_account
        <where>
            <if test="id!=0">
                id = #{id}
            </if>
            <if test="username!=null">
                and username = #{username}
            </if>
            <if test="password!=null">
                and password = #{password}
            </if>
            <if test="age!=0">
                and age = #{age}
            </if>
        </where>
    </select>
```

![](F:\Note\images\TIM截图20200303170432.png)



## choose 、when 标签

效果同 if、where

```xml
    <select id="findByAccount" parameterType="com.iteima.jdbc.entity.Account" resultType="com.iteima.jdbc.entity.Account">
        select * from t_account
        <where>
            <choose>
                <when test="id!=0">
                    id = #{id}
                </when>
                <when test="username!=null">
                    and username = #{username}
                </when>
                <when test="password!=null">
                    and password = #{password}
                </when>
                <when test="age!=0">
                    and age = #{age}
                </when>
            </choose>
        </where>
    </select>
```



## trim 标签 

trim 标签中的 prefix 和 suffix 属性会被⽤于⽣成实际的 SQL 语句，会和标签内部的语句进⾏拼接，如 果语句前后出现了 prefixOverrides 或者 suffixOverrides 属性中指定的值，MyBatis 框架会⾃动将其删除。

```xml
    <select id="findByAccount" parameterType="com.iteima.jdbc.entity.Account" resultType="com.iteima.jdbc.entity.Account">
        select * from t_account
        <trim prefix="where" prefixOverrides="and">
            <if test="id !=0">
                id=#{id}
            </if>
            <if test="username!=null">
                and username = #{username}
            </if>
            <if test="password!=null">
                and password = #{password}
            </if>
            <if test="age!=0">
                and age = #{age}
            </if>
        </trim>
    </select>
```

where 直接和 and 连接，就会把 and 删除



## set 标签 

set 标签⽤于 update 操作，会⾃动根据参数选择⽣成 SQL 语句。

```xml
    <update id="update" parameterType="com.iteima.jdbc.entity.Account">
        update t_account
        <set>
            <if test="username != null">
                username=#{username},
            </if>
            <if test="password != null">
                password=#{password},
            </if>
            <if test="age !=0">
                age=#{age}
            </if>
        </set>
        where id=#{id}
    </update>
```

![](F:\Note\images\TIM截图20200303173352.png)



## foreach 标签 

foreach 标签可以迭代⽣成⼀系列值，这个标签主要⽤于 SQL 的 in 语句。

```sql
# 目标sql
SELECT * FROM `t_account`
WHERE id IN (1,4,5)
```

* 实体类中添加属性

```java
package com.iteima.jdbc.entity;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class Account implements Serializable {

    private long id;
    private String username;
    private String password;
    private int age;
    private List<Long> ids;
}
```

* 接口

```java
public List<Account> findByIds(Account account);
```

* xml

```xml
    <select id="findByIds" parameterType="com.iteima.jdbc.entity.Account" resultType="com.iteima.jdbc.entity.Account">
        select * from t_account
        <where>
            <foreach collection="ids" open="id in (" close=")" item="id" separator=",">
                #{id}
            </foreach>
        </where>
    </select>
```

open 表示之前，close 表示之后

![](..\images\TIM截图20200303175542.png)









# 补充

```xml
<!--
根据课程id查询课程信息
课程名称，课程价格，课程封面
课程描述
课程所属讲师名称
课程一级分类和二级分类

1.查询条件
2.查询出来的数据
3.根据查询数据看使用到哪些表 四张表

左外连接：左表的所有数据都查出来，右表只显示符合搜索条件的记录，右表记录不足的地方均为NULL
课程可以没有描述，可以没有讲师，可以没有分类-->

    <select id="getCourseInfoAll" resultType="com.online.edu.entity.dto.CourseInfoDto">
        SELECT
            c.id,c.title,c.price,c.cover,cd.description,et.`name` teacherName,s1.title oneLevel,s2.title twoLevel
        FROM
	        edu_course c
	    LEFT OUTER JOIN edu_course_description cd ON c.id = cd.id
	    LEFT OUTER JOIN edu_teacher et ON c.teacher_id = et.id
	    LEFT OUTER JOIN edu_subject s1 ON c.subject_parent_id = s1.id
	    LEFT OUTER JOIN edu_subject s2 ON c.subject_id = s2.id
        WHERE
	        c.id = #{courseId}
    </select>
```

```java
CourseInfoDto getCourseInfoAll(String courseId);
```



id：方法名称

parameterType：传入的参数，String类型可以不配置

resultType：返回类型的全路径

如果是一个参数，#{}这里面随便写什么。

但如果是多个参数，使用@RequestParam取别名，如下所示，可以通过**“a”**取值

```java
CourseInfoDto getCourseInfoAll(@RequestParam("a") String a,@RequestParam("b") String b);
```



出现异常：AbstractHandlerExceptionResolver.java:194 |org.springframework.web.servlet.mvc.method.annotation.ExceptionHandlerExceptionResolver |Resolved exception caused by handler execution: org.apache.ibatis.binding.BindingException: Invalid bound statement (not found): com.guli.edu.mapper.CourseMapper.getCoursePublishVoById为什么会出现这个异常：

dao层编译后只有class文件，没有mapper.xml，因为maven工程在默认情况下src/main/java目录下的所有资源文件是不发布到target目录下的，

解决：

1. 把xml文件全都放到resources目录下
2. 配置pom.xml和application.properites

```xml
<build>
    <resources>
        <resource>
            <directory>src/main/java</directory>
            <includes>
                <include>**/*.xml</include>
            </includes>
            <filtering>false</filtering>
        </resource>
    </resources>
</build>
```

```properties
#配置mapper xml文件的路径
mybatis-plus.mapper-locations=classpath:com/online/edu/mapper/xml/*.xml
```

