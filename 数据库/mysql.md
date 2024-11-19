[toc]

# 常用命令

```shell
# 登录
mysql -u root -p

# 查看权限
show grants for [用户名];

# 授权
grant all privileges on *.* to 'user'@'%' identified by 'password' with grant option;

flush privileges;


set global time_zone='+08:00';
set time_zone='+08:00';
flush privileges;

# 查看schema
show databases;
use xxxx;
show tables like '%dns%';


# 查看表结构
desc tablename;

# 导出数据
mysqldump -u root -p密码 --compact --skip-comments --skip-add-drop-table --no-create-info --no-create-db --extended-insert=FALSE 数据库名 表1 表2 > user_data.sql

# 导入数据
mysql -uroot -p密码 -D数据库名 < update.sql
```

# 性能优化

## 查看执行频率

```sql
show [session|global]  status like ‘com_____’;
```

**session: 查看当前会话；**

**global: 查看全局数据；**

**com insert: 插入次数；**

**com select: 查询次数；**

**com delete: 删除次数；**

**com update: 更新次数；**

通过查看当前数据库是以查询为主，还是以增删改为主，从而为数据库优化提供参考依据，如果以增删改为主，可以考虑不对其进行索引的优化；如果以查询为主，就要考虑对数据库的索引进行优化。

## 查看是否有慢查询

先查询进程的IO情况，如果mysql占用资源多的话，可能是mysql有慢查询或死锁

```sh
# -d选项表示展示进程的I/O情况
$ pidstat -d 1
```

查看MySQL中的InnoDB锁定信息。该视图提供了有关当前正在使用的锁定资源和锁定的事务的详细信息。

```sql
-- 开启mysql慢日志查询开关
slow_query_log=1
-- 设置慢日志的时间，假设为2秒，超过2秒就会被视为慢查询，记录慢查询日志
long_query_time=2

systemctl restart mysqld

select * from information_schema.INNODB_LOCKS;

-- 监控
show full processlist;

-- 慢查询是否开启
SHOW VARIABLES LIKE 'slow_query_log';

-- 查看慢日志（/var/lib/mysql/localhost-slow.log）

```

## 如何使用 binlog

```sql
-- 查看binlog是否启用，以及查看日志文件位置
mysql> show variables like '%log_bin%';
+---------------------------------+---------------------------------+
| Variable_name                   | Value                           |
+---------------------------------+---------------------------------+
| log_bin                         | ON                              |
| log_bin_basename                | /var/lib/mysql/mysqld-bin       |
| log_bin_index                   | /var/lib/mysql/mysqld-bin.index |
| log_bin_trust_function_creators | OFF                             |
| log_bin_use_v1_row_events       | OFF                             |
| sql_log_bin                     | ON                              |
+---------------------------------+---------------------------------+


-- 记录下当前日志的文件名和偏移位置，在后续查看日志过程中可以准确定位
mysql> show master status;
+-------------------+----------+--------------+------------------+-------------------+
| File              | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+-------------------+----------+--------------+------------------+-------------------+
| mysqld-bin.000001 |     2425 |              |                  |                   |
+-------------------+----------+--------------+------------------+-------------------+

-- 也可以通过指定起始时间来查看日志，所以也记录一下当前时间
mysql> select now();
+---------------------+
| now()               |
+---------------------+
| 2018-08-02 09:59:43 |
+---------------------+
```

```sh
mysqlbinlog --no-defaults  /var/lib/mysql/mysqld-bin.000001 --start-position=2425 > 1.sql
```

## explain 详情

![img]()

# 集群

## 主从复制

A：主机
B：从机

```shell
# 主机
grant replication slave on *.* to '用户'@'A' identified by '密码';
flush privileges;
show master status\G

# 从机
change master to master_host='A',master_user='用户名',master_password='密码',master_log_file='mysql-bin.000002',master_log_pos=0;
start slave;
show master status\G
```
