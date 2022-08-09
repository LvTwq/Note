[TOC]

# 系统
```shell
# 查看内核
uname -r

# 查看Linux发行版本
cat /etc/redhat-release

# 查看物理 CPU 颗数
cat /proc/cpuinfo | grep 'physical id' | sort | uniq | wc -l

# 查看逻辑 CPU 核数
cat /proc/cpuinfo |grep "processor"|wc -l

```


## 包管理

* yum

```shell
[root@localhost ~]# yum install lsof
[root@localhost ~]# yum -y remove lsof
```

* rpm

```shell
[root@localhost share]# rpm -ivh vsftpd-2.2.2-11.el6_4.1.x86_64.rpm
[root@localhost share]# rpm -qa|grep vsftpd
[root@localhost share]# rpm -e vsftpd-2.2.2-11.el6_4.1.x86_64
```

## 环境变量

```shell
# 显示系统中已存在的环境变量
env
```

```shell
# 将shell变量输出为环境变量，或者将shell函数输出为环境变量
export
```

```shell
# 在shell中打印shell变量的值，或者直接输出指定的字符串
echo -e 
```


# 网络

## 查询ip

* ifconfig

```shell
[root@localhost ~]# yum install net-tools
[root@localhost /]# ifconfig
```

* ip

```shell
[root@localhost /]# ip addr
```

## 重启虚拟机网络

```shell
service network restart
```



## 防火墙

```shell
#关闭防火墙
systemctl stop firewalld.service
#查看防火墙状态
systemctl status firewalld
```

## curl
```shell
curl -H 'Content-Type: text/xml; charset=utf-8' -d '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ser="http://service.fgw.bm.com/"><soapenv:Header /><soapenv:Body><ser:qryMPSqlByKey><ser:key>f964a5718b3b400aaf54d0baecbca609</ser:key><ser:inParams>updateTime=2021-10-27</ser:inParams></ser:qryMPSqlByKey></soapenv:Body></soapenv:Envelope>' http://2.208.64.254:8090/channel/gG2foEk5lz/services/FgwServices?wsdl
```


## 如何查看应用占用的端口
可以是 pid、端口号
> [root@172-23-28-106 jsxzfy]# ss -tnlp |grep 498
LISTEN     0      50          :::8090                    :::*                   users:(("java",pid=498,fd=30))
LISTEN     0      128       ::ffff:172.23.28.106:9093                    :::*                   users:(("java",pid=498,fd=7))




## tcpdump
```sh
# 先查网卡
ip addr

tcpdump -i eth0 -nn -s0 -v port 80
```

* -i : 选择要捕获的接口，通常是以太网卡或无线网卡，也可以是 vlan 或其他特殊接口。如果该系统上只有一个网络接口，则无需指定。 
* -nn : 单个 n 表示不解析域名，直接显示 IP；两个 n 表示不解析域名和端口。这样不仅方便查看 IP 和端口号，而且在抓取大量数据时非常高效，因为域名解析会降低抓取速度。 
* -s0 : tcpdump 默认只会截取前 96 字节的内容，要想截取所有的报文内容，可以使用 -s number， number 就是你要截取的报文字节数，如果是 0 的话，表示截取报文全部内容。 
* -v : 使用 -v，-vv 和 -vvv 来显示更多的详细信息，通常会显示更多与特定协议相关的信息。 
* port 80 : 这是一个常见的端口过滤器，表示仅抓取 80 端口上的流量，通常是 HTTP。


## iptables
```sh
iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport 443 -j ACCEPT
```


# 进程

## 查询进程

* 按程序名称模糊查询，查到的第一个数字是进程

```shell
[root@localhost ~]# ps aux|grep TAS
```

* 按端口号查询

```shell
[root@localhost share]# yum install lsof
[root@localhost share]# lsof -i :80175

// 或者
[root@172-23-28-106 jsxzfy]# lsof -i tcp:8090
COMMAND PID USER   FD   TYPE  DEVICE SIZE/OFF NODE NAME
java    498 root   30u  IPv6 8203452      0t0  TCP *:8090 (LISTEN)
```

lsof：查看文件的进程信息（list open files）

|参数|含义|举例|
|--|--|--|
|+d 目录|列出目录下被打开的文件|lsof +d /root|
|-i 条件|列出符合条件的进程||
|-p 进程id|列出指定进程号所打开的文件||



## 查询某进程所在路径
```shell
ll /proc/进程id
```


每个ip都有那么多端口，无法从外部端口直接访问内部应用的，所以要做映射，
在url上输入 ip:port（外部端口），映射成内部应用提供的端口才能访问该应用
CONTAINER ID   IMAGE               COMMAND                  CREATED             STATUS                          PORTS                                       NAMES

82b04f0e890e   isc-eureka-server   "sh -c 'java $PARAMS…"   About an hour ago   Up About an hour                0.0.0.0:9861->8761/tcp, :::9861->8761/tcp   docker-compose_isc-eureka-server_1


## Java 进程

```shell
[root@localhost share]# jps -l
```

-q：只输出进程 ID
-m：输出传入 main 方法的参数
-l：输出完全的包名，应用主类名，jar的完全路径名
-v：输出jvm参数
-V：输出通过flag文件传递到JVM中的参数


## top
```sh
# 看这个进程里所有线程的cpu消耗情况
top -Hp <pid>
```
按CPU使用率排序：shift+p
按内存使用率排序：shift+m




# 文本

* vim

```shell
[root@localhost share]# yum install vim
[root@localhost share]# vim test.txt
[root@localhost share]# yum install zip
[root@localhost share]# vim test.war
[root@localhost share]# yum install unzip
[root@localhost share]# vim test.war
```



# 文件


## 复制拷贝

```shell
cp dir1/a.doc dir2  # 表示将dir1下的a.doc文件复制到dir2目录下
cp -r dir1 dir2 # 表示将dir1及其dir1下所包含的文件复制到dir2下
mv AAA BBB #表示将AAA改名成BBB
```



## 全盘搜索

```shell
find / -name  xxxxx	# 通过文件名搜索
```




## 远程拷贝

```shell
# 然后输入被拷贝方的密码
scp jar_ajslbl_2012/ajslbl.jar root@172.23.26.155:/home/ba/out/
```



## 解压缩

```shell
[root@localhost share]# tar -xvzf arterybase-server-linux-3.6.2.tar.gz
[root@localhost share]# tar -czvf FileName.tar test/
```





## 挂载

```shell
[root@localhost /]# mkdir /dvd
[root@localhost /]# mount dev/cdrom /dvd
mount: /dev/sr0 写保护，将以只读方式挂载
[root@localhost /]# mkdir /dvdrom
[root@localhost /]# cp -r /dvd /dvdrom/
[root@localhost dvd]# umount /dvd
```


## 压缩

```shell
[root@localhost share]# yum install zip
[root@localhost share]# zip test.zip
[root@localhost share]# yum install unzip
[root@localhost share]# unzip test.zip test/
```