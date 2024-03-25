[TOC]

# 命令
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
```


# 主从复制
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


# 排错
查看MySQL中的InnoDB锁定信息。该视图提供了有关当前正在使用的锁定资源和锁定的事务的详细信息。
```sql
select * from information_schema.INNODB_LOCKS;

-- 监控
show processlist;

-- 慢查询是否开启
SHOW VARIABLES LIKE 'slow_query_log';
```

