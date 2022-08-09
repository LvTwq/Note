[TOC]



# 一、NoSql简介

## 1、概述

Not Only SQL（不仅仅是SQL），泛指**非关系型数据库**，不依赖**业务逻辑**方式存储，而用简单的**key-value**模式存储，大大增强了数据库的扩展能力

* 不遵循SQL标准
* 不支持ACID
* 远超于SQL性能

## 2、适用场景

* 对数据高并发读写
* 海量数据读写
* 对数据高扩展性

## 3、不适用场景

* 需要事务支持
* 基于SQL结构化查询存储，处理复杂的关系

## 4、为什么要用NoSql

web2.0 时代

![](..\images\redis1.png)

### 1、解决CPU及内存压力

![](..\images\redis2.png)

采用nginx负载均衡，做成分布式，多个请求分发到不同服务器，缓解服务器压力。

但会带来一个问题：

session（存放用户信息）是存在服务器A中，但第二次请求可能会到服务器B中

所以建议采用NOSQL，不需要经过IO操作

### 2、解决IO压力

![](..\images\redis3.png)

## 5、行式数据库

![](..\images\redis4.png)

## 6、列式数据库

![](..\images\redis5.png)

## 7、多样化的数据结构存储持久化数据

![](..\images\redis6.png)

![](..\images\redis7.png)



# 二、安装启动

```shell
cd /opt/
wget https://download.redis.io/releases/redis-6.2.2.tar.gz
gcc --version
tar -zxvf redis-6.2.2.tar.gz
cd redis-6.2.2/
// 编译成C文件
make
// 安装
make install
// 默认安装到此路径
cd /usr/local/bin/
```

![](..\images\redis8.png)

不推荐使用前台启动，因为窗口关闭，服务器停止

把redis-6.2.2下的redis.conf 拷贝到 /etc目录下，并修改/etc下的参数daemonize为yes

```shell
cd /usr/local/bin/
redis-server /etc/redis.conf
// 通过客户端连接redis 
ps -ef|grep redis 
// 看到 redis-server 127.0.0.1:6379
redis-cli

//　关闭
shutdown
```

## 1、基础知识

默认16个数据库，从0开始，默认使用0号库，所有库密码相同

```shell
// 切换
select [index]
```



### 1）单线程+多路IO复用

![](.\images\redis9.png)

# 三、五大数据类型

![](.\images\redis10.png)

## 1、String

### 1）简介

String类型是**二进制安全的**，可以包含任何数据，比如jpg图片或者序列化对象

一个Redis中字符串value最多可以是**512M**

### 2）常用命令

```shell
// 添加键值对
set <key> <value>
// 查询对应键值
get <key>
// 将给定的value追加到原值的末尾
append <key> <value>
// 获得值的长度
strlen <key>
// 只有在key不存在时，设置key的值
setnx <key> <value>
// 将key中储存的数字值增减1.只能对数字值操作，如果为空，新增值为1/-1
incr/decr <key>
// 将key中储存的数字值增减，自定义步长
incrby/decrby <key> <步长>
// 同时设置一个或多个key-value对
mset <key1> <value1> <key2> <value2>...
// 同时获取一个或多个value
mget <key1><key2><key3>
// 同时设置一个或多个key-value对，当且仅当所有给定key都不存在，有一个失败，则都失败
msetnx <key1> <value1> <key2> <value2>...

// 获得值的范围，类似Java中的substring，前包，后包
getrange <key><起始位置><结束位置>

// 用<value>覆写<key>所存储的字符串值，从<起始位置>开始（索引从0开始）
setrange <key> <起始位置> <value>

// 设置键值的同时，设置过期时间，单位秒
setex <key><过期时间><value>

// 以新换旧，设置了新值同时获得旧值
getset <key> <value>

// 查看剩余有效时间
ttl <key>
```



incrby 和 decrby 都是原子性操作

![](..\images\redis12.png)

**案例：**

![](..\images\redis11.png)

### 3）数据结构

![](.\images\redis13.png)

![](..\images\redis14.png)



## 2、List

### 1）简介

![](..\images\redis15.png)

### 2）常用命令

![](..\images\redis16.pn)

![](..\images\redis17.png)

### 3）数据结构

![](..\images\redis18.png)



## 3、Set

### 1）简介

![](..\images\redis19.png)

![](..\images\redis20.png)

### 2）常用命令

![](..\images\redis21.png)

![](..\images\redis22.png)

## 4、Hash

### 1）简介

![](..\images\redis23.png)

![](..\images\redis24.png)

### 2）常用命令

![](..\images\redis25.png)

### 3）数据结构

![](..\images\redis26.png)



## 5、Zset

### 1）简介

![](..\images\redis27.png)

### 2）常用命令

![](..\images\redis28.png)

![](..\images\redis29.png)

### 3）数据结构

![](..\images\redis30.png)



## 6、新数据类型-Bitmaps



# 四、配置文件

配置大小单位，开头定义了一些基本的度量单位，只支持bytes，不支持bit，大小写不敏感

```shell
vim /etc/redis.conf
```



## 1、Units 单位

![](..\images\redis31.png)

## 2、NETWORK 网络

### 1）bind 127.0.0.1 -::1

将此行注释掉，表示允许访问的端口

### 2）protected-mode yes

改为no，表示禁用***本机访问保护模式***

### 3）tcp-backlog

![](..\images\redis32.png)



# 五、发布和订阅

## 1、定义

Redis 发布订阅（pub/sub）是一种消息通信模式：发送者（pub）发送消息，订阅者（sub）接收消息

Redis 客户端可以定义任意数量的频道

![](..\images\redis33.png)

## 2、命令行

1）打开一个客户端订阅channel1

![](..\images\redis34.png)

2）打开**另一个客户端**，给channel1发布消息 hello，返回的1是订阅者数量

![](..\images\redis35.png)

3）打开第一个客户端可以看到发送的消息

![](..\images\redis36.png)

# 六、Jedis

## 1、常用操作

```java
        // 创建Jedis对象
        String value;
        try (Jedis jedis = new Jedis("172.16.15.160", 6379)) {
            // 测试是否能拼通
            value = jedis.ping();
        }
        System.out.println(value);
```

## 2、实例：手机验证码

![](..\images\redis37.png)



# 七、事务与锁

## 1、基本概念

![](..\images\redis38.png)

![](..\images\redis39.png)

![](..\images\redis40.png)

![](..\images\redis41.png)

![](..\images\redis42.png)

![](..\images\redis43.png)

![](..\images\redis44.png" style="zoom: 50%;" />

![](..\images\redis45.png)

![](..\images\redis46.png)

在执行multi之前，先执行watch key1 [key2]，可以监视一个（或多个）key，如果在事务执行这个（或这些）key被其他命令所改动，那么事务将被打断

![](..\images\redis48.png)

unwatch：取消watch命令对所有key的监视

![](..\images\redis47.png)

## 2、并发模拟

```shell
yum install httpd-tools
ab --help
# 1000个请求中有100个是并发操作
ab -n 1000 -c 100 http://172.23.23.234:8080/redisTest/miaosha
```

## 3、超卖问题

![](..\images\redis49.png)

## 4、库存遗留

![](..\images\redis50.png)

![](..\images\redis51.png)

# 八、持久化操作

## 1、RDB

在指定**时间间隔内**将内存中的数据集**快照**写入磁盘

配置文件，设置持久化规则：

```shell
vim /etc/redis.conf
```

在 /usr/local/bin 中可以查看 dump.rdb 大小

save：只管保存，其他不管，全部阻塞。手动保存。不建议

bgsave：Redis 会在后台异步进行快照操作，快照同时还可以响应客户端请求

![](..\images\redis52.png)

## 2、AOF

### Append Only File

**以日志的形式来记录每个写操作（增量保存）**，将redis执行过的所有写指令记录下来**（读操作不记录），只许追加文件但不可以改写文件**，redis启动之初会读取该文件重新构建数据，换言之，redis重启的话就可以根据日志文件的内容将写指令从前到后执行一次完成数据恢复的工作。

![](..\images\redis54.png)

### aof 默认不开启

可以在redis.conf 中配置文件名称，默认为 appendonly.aof

保存路径和RDB一致

**AOF和RDB同时开启，系统默认取AOF的数据（数据不会丢失）**

### 异常恢复

1）修改默认的appendonly no，改为 yes

2）如遇到AOF文件损坏，通过命令恢复

```shell
/usr/local/bin/redis-check-aof--fix appendonly.aof
```

3）备份被损坏的aof文件

4）重启redis

### 同步频率设置

![](..\images\redis53.png)

### 优劣势

![](..\images\redis55.png)

# 九、主从复制

主机数据更新后根据配置和策略，自动同步到备机的**master/slaver机制，Master以写为主，Slave以读为主**

注：主服务器只能有一台，如果有两台，第一台 set a1 v1 ，第二台  set a1 v11，那么从服务器复制时，到底听谁的？

![](..\images\redis56.png)

如果之前是从第一台服务器读数据，但突然第一台挂了，可以切换到读第二台的数据

## 1、搭建

![](..\images\redis57.png)



```shell
# 启动redis
redis-server redis63**.conf
# 指定端口打开redis客户端
redis-cli -p port
# 设置为 目标 服务器的从
slaveof [目标]ip port
# 查看主从信息
info replication
```



如果**从服务器**挂了，重启并不会自动加入原有的主从关系，需要手动加入，然后会自动复制主服务器的所有数据

如果主服务器挂了，小弟并不会上位，会显示大哥挂了

## 2、原理

![](..\images\redis58.png)

 ![](..\images\redis59.png)

## 3、反客为主

当一个master宕机后，后面的slave可以立刻升为master

把从机变成主机：

```shell
slaveof no one
```

## 4、哨兵模式

反客为主的自动版

```sh
cd myredis/
# 创建配置文件
vim sentinel.conf
# 启动
redis-sentinel sentinel.conf
```

![](..\images\redis60.png) 

![](..\images\redis62.png)

当主机挂掉，从机选举中产生新的主机，大概10秒左右可以看到哨兵窗口日志，切换了新的主机

根据优先级别：slave-priority（高版本为replica-priority），来选择新主机

**原主机重启后会变成从机**

原主机挂掉后，哨兵输出日志：

![](..\images\redis61.png)

# 十、集群

## 1、无中心化

![](..\images\redis63.png)

![](..\images\redis64.png)

## 2、优缺点

![](..\images\redis65.png)



# 十一、应用问题

## 1、缓存穿透

![](..\images\redis70.png)

产生原因：应用服务器压力变大，正常应该是先查缓存，查到就返回，查不到再查数据库，放到缓存中，但由于大量数据在redis中查不到，数据库不断进行IO操作，导致缓存穿透

解决方案：

![](..\images\redis66.png)

![](..\images\redis67.png)

## 2、缓存击穿

![](..\images\redis68.png)

![](..\images\redis69.png)

![](..\images\redis72.png)

![](..\images\redis71.png)

## 3、缓存雪崩

![](..\images\redis73.png)

![](..\images\redis74.png)

![](..\images\redis75.png)

![](..\images\redis76.png)

# 十二、分布式锁

分布式中，一台机器上锁，其他机器不知道这台机器上了锁

![](..\images\redis77.png)

![](..\images\redis78.png)

释放锁：del lock

![](..\images\redis79.png)



有一条数据有3个操作：a、b、c

可能造成：a释放b的锁

![](..\images\redis80.png)

# 十三、acl

## 1、规则

![](..\images\redis81.png)

![](..\images\redis82.png)

```shell
# 展现用户权限列表
acl list
# 添加用户
acl setuser lucy
# 查看当前用户
acl whoami
```

