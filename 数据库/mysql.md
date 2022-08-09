[TOC]

# 命令
```shell
# 登录
mysql -u root -p Enlink@123

# 授权
grant all privileges on *.* to 'enlink'@'%' identified by 'Enlink@123' with grant option;

flush privileges
```