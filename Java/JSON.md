[TOC]



# 一、什么是 JSON

JSON是一种取代XML的数据结构,和xml相比,它更小巧但描述能力却不差,由于它的小巧所以网络传输数据将减少更多流量从而加快速度。

JSON就是一串字符串 只不过元素会使用特定的符号标注。

{} 双括号表示对象
[] 中括号表示数组
"" 双引号内是属性或值
: 冒号表示后者是前者的值(这个值可以是字符串、数字、也可以是另一个数组或对象)

所以 {"name": "Michael"} 可以理解为是一个包含name为Michael的对象

而[{"name": "Michael"},{"name": "Jerry"}]就表示包含两个对象的数组

当然了,你也可以使用{"name":["Michael","Jerry"]}来简化上面一部,这是一个拥有一个name数组的对象



# 二、使用

## 1、JSON 对象和字符串的相互转化

| 方法                         | 作用                                 |
| ---------------------------- | ------------------------------------ |
| JSON.parseObject()           | 从字符串解析 JSON 对象               |
| JSON.parseArray()            | 从字符串解析 JSON 数组               |
| JSON.toJSONString(obj/array) | 将 JSON 对象或 JSON 数组转化为字符串 |

```java
//从字符串解析JSON对象
JSONObject obj = JSON.parseObject("{\"runoob\":\"菜鸟教程\"}");
//从字符串解析JSON数组
JSONArray arr = JSON.parseArray("[\"菜鸟教程\",\"RUNOOB\"]\n");
//将JSON对象转化为字符串
String objStr = JSON.toJSONString(obj);
//将JSON数组转化为字符串
String arrStr = JSON.toJSONString(arr);
```



## 2、编码

```java
  /** 编码 从 Java 变量到 JSON 格式的 */
  public static void testJson() {
    // 首先建立一个JSON对象，然后依次添加字符串、整数、布尔值以及数组，最后将其打印为字符串。
    JSONObject object = new JSONObject();
    object.put("string", "qwertyuiop");

    object.put("int", 2);

    object.put("boolean", true);

    List<Integer> integers = Arrays.asList(1, 2, 3);
    object.put("list", integers);

    object.put("null", null);

    System.out.println(object);
  }
```



## 3、解码

```java
  /**
   * 解码
   *
   * 从 JSON 对象到 Java 变量
   */
  public static void testJson2() {
    // 首先从 JSON 格式的字符串中构造一个 JSON 对象，之后依次读取字符串、整数、布尔值以及数组，最后分别打印
    JSONObject object =
        JSONObject.parseObject(
            "{\"boolean\":true,\"string\":\"qwertyuiop\",\"list\":[1,2,3],\"int\":2}");
    String string = object.getString("string");
    System.out.println(string);

    int i = object.getIntValue("int");
    System.out.println(i);

    boolean b = object.getBooleanValue("boolean");
    System.out.println(b);

    List<Integer> integerList =
        JSON.parseArray(object.getJSONArray("list").toJSONString(), Integer.class);
    System.out.println(integerList);

    System.out.println(object.getString("null"));
  }
```





## 4、实体类

```java
@Getter
@Setter
public class Staff {
    private String name;
    private Integer age;
    private String sex;
    private Date birthday;

    @Override
    public String toString() {
        return "Staff{" +
                "name='" + name + '\'' +
                ", age=" + age +
                ", sex='" + sex + '\'' +
                ", birthday=" + birthday +
                '}';
    }
}
```



```java
public class jsonTest {

  public static void main(String[] args) {

    /** json字符串转化为对象
     *
     * 故意在Json字符串中多了一个telephone，少了一个Staff中的birthday
     * */
    String jsonString = "{name:'Antony',age:'12',sex:'male',telephone:'88888'}";
    Staff staff = JSON.parseObject(jsonString, Staff.class);
    System.out.println(staff.toString());

    /** 对象转化为json字符串 */
    String s = JSON.toJSONString(staff);
    System.out.println(s);
  }
}
```

输出结果：

```json
Staff{name='Antony', age=12, sex='male', birthday=null}
{"age":12,"name":"Antony","sex":"male"}
```

* JSON.parseObject

会去填充名称相同的属性。对于Json字符串中没有，而model类有的属性，会为null；对于model类没有，而Json字符串有的属性，不做任何处理。

如果age是String类型，那么输出结果变为

```json
{"age":"12","name":"Antony","sex":"male"}
```



![](..\images\json.png) 

 

![](..\images\json01.png)



# 三、相关注解

### @JsonIgnore

1. 属于 jackson
2. 作用：在json序列化时将java bean中的一些属性忽略掉，序列化和反序列化都受影响。
3. 使用方法：一般标记在属性或者方法上，返回的json数据即不包含该属性。

```java
@Getter(onMethod_ = @JsonIgnore)
private List<String> cBhList;
// 或者
@JsonIgnore
private String goodsInfo;
```

### @JSONField

1. 属于 fastjson
2. 作用同上
3. 用法

```java
    @JSONField(serialize = false)
    private List<String> cBhList;
```



### @JsonProperty

1. 属于jackson
2. 作用：作用于属性上，把该属性的名称序列化成另一个自己想要的名称
3. 用法

```java
    @Getter(onMethod_ = { @JsonProperty("cBh") })
    private String cBh;
```

所以上次遇到的xsdj的cSfxsjbg变成小写，是走的模板引擎，默认使用jackson；

查看页面加载的数据，用的是ajax请求，用的是 fastjson

# 四、JavaBean属性命名规范

javaBean 的成员变量  前两个字母要么全大写,要么全小写,否则会出现意外,甚至程序会报错

```java
    private String Name;
    private String name;
// 这两个字段只会生成一个get方法
    public String getName() {
        return name;
    }
```

