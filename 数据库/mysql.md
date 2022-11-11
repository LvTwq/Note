[TOC]

# 命令
```shell
# 登录
mysql -u root -p

# 查看权限
show grants for [用户名];

# 授权
grant all privileges on *.* to '用户名'@'%' identified by '密码' with grant option;

flush privileges;
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