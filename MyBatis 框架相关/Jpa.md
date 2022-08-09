[TOC]





#### 1. yml配置

* 驱动类名 ***com.mysql.cj.jdbc.Driver***

* 用来输出sql语句以及格式化打印

```yml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/library?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Shanghai
    username: root
    password: root
    driver-class-name: com.mysql.cj.jdbc.Driver
  jpa:
    show-sql: true
    properties:
      hibernate:
        format_sql: true
server:
  port: 8181
```



#### 2. 实体类 entity.Book

***@Entity*** 用来绑定此类和表，默认把类名首字母小写就是表名；

***@Id*** 标注主键；

***@GeneratedValue(strategy = GenerationType.IDENTITY)*** 表示自增，和数据库对应

类中属性的类型要和表中一一对应。

```java
@Entity
@Data
public class Book {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    private String name;
    private String author;
}
```



#### 3. 接口 repository.BookRepository

继承 JpaRepository，泛型：实体类类型 + 主键类型

```java
public interface BookRepository extends JpaRepository<Book,Integer> {
}
```



#### 4. 写一个测试类

右键 BookRepository ，选择 Go To——Test，选择 🆗

@SpringBootTest 表名这是一个测试类

```java
@SpringBootTest
class BookRepositoryTest {

    @Autowired
    private BookRepository bookRepository;

    @Test
    void findAll(){
        System.out.println(bookRepository.findAll());
    }

}
```



#### 5. 控制类 controller.BookHandler

```java
@RestController
@RequestMapping("/book")
public class BookHandler {

    @Autowired
    private BookRepository bookRepository;

    @GetMapping("/findAll")
    public List<Book> findAll(){
        return bookRepository.findAll();
    }
}
```

