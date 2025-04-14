[TOC]

# 集群概述和架构介绍

Tomcat集群能够带来什么：

* 提高服务的性能，例如计算处理能力，并发能力，以及实现服务的高可用性
* 提供项目架构的横向扩展能力，增加集群中的机器就能提高集群的性能

Tomcat集群实现方式：

* Tomcat集群的实现方式有多种，最简单的就是通过Nginx负载进行请求转发来实现

常见的Tomcat集群解决方案：

* 采用 nginx 中的 ip hash policy 来保持某个ip始终连接在某一个机器上
  * 优点：可以不改变现有的技术架构，直接实现横向扩展，省事。但是缺陷也很明显，在实际的生产环境中，极少使用这种方式
  * 缺点：1.单止服务器请求（负载）不均衡，这是完全依赖 ip hash 的结果。2.客户机ip动态变化频繁的情况下，无法进行服务，因为可能每次的ip hash都不一样，就无法始终保持只连接在同一台机器上。

* 采用redis或memchche等nosql数据库，实现一个缓存session的服务器，当请求过来的时候，所有的Tomcat Server都统一往这个服务器里读取session信息。这是企业中比较常用的一种解决方案





# Nginx负载均衡配置，常用策略，场景及特点简介

### Nginx负载均衡配置及策略：

- 轮询（默认）

  - 优点：实现简单

  - 缺点：不考虑每台服务器的处理能力

  - 配置示例如下：

    ```shell
    upstream www.xxx.com {
    # 需要负载的server列表
    server www.xxx.com:8080;
    server www.xxx.com:9080;
    }
    ```



* 权重，使用的较多的策略
  * 优点：考虑了每台服务器处理能力的不同，哪台机器性能高就给哪台机器的权重高一些

  * 配置示例如下：

    ```shell
    upstream www.xxx.com {
    # 需要负载的server列表，weight表示权重，weight默认为1，如果多个配置权重的节点，比较相对值
    server www.xxx.com:8080 weight=15;
    server www.xxx.com:9080 weight=10;
    }
    ```

    

### 一些负载均衡参数简介：

```shell
upstream www.xxx.com {
    ip_hash;
    # 需要负载的server列表
    server www.xxx.com:8080 down;  # down表示当前的server暂时不参与负载
    server www.xxx.com:9080 weight=2;  # weight默认值为1，weight的值越大，负载的权重就越大  
    server www.xxx.com:7080 backup;  # 其他所有的非backup机器，在down掉或者很忙的时候，才请求backup机器，也就是一个备用机器
    server www.xxx.com:6080;
}
```









# 搭建过程

## Java环境

1、检查系统是否已经有JDK

```shell
java -version
```

2、如果有低版本的jdk，先删除

```shell
[root@localhost opt]# rpm -qa|grep jdk
jdk-1.7.0_71-fcs.x86_64
[root@localhost opt]# rpm -e --nodeps jdk-1.7.0_71-fcs.x86_64
```

3、将下载好的 jdk-8u181-linux-x64.tar.gz 复制到 /usr/local 

```shell
tar -zxvf /usr/local/jdk-8u181-linux-x64.tar.gz
# 修改一下文件名，将jdk1.8.0_181改成java，方便后面配置环境变量
mv /usr/local/jdk1.8.0_181 /usr/local/java
```

4、修改配置文件，配置环境变量

```shell
vi /etc/profile
# 在最后一行添加：
export JAVA_HOME=/usr/local/java
export PATH=$PATH:$JAVA_HOME/bin
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
export JRE_HOME=$JAVA_HOME/jre
```

5、让配置文件生效

```shell
source /etc/profile
```

6、查看安装情况

```shell
[root@master100 ~]# java -version
java version "1.8.0_181"
Java(TM) SE Runtime Environment (build 1.8.0_181-b13)
Java HotSpot(TM) 64-Bit Server VM (build 25.181-b13, mixed mode)
```





## 单机部署多个Tomcat实例：

1、下载Tomcat并解压到对应的目录：

```shell
tar -zxvf apache-tomcat-9.0.7.tar.gz -C/usr/local/src
```

2、将 Tomcat 目录拷贝多份，并修改目录名称：

```shell
cp -r apache-tomcat-9.0.7 ./tomcat9-02
cp -r apache-tomcat-9.0.7 ./tomcat9-01
```

3、配置环境变量

```shell
[root@study-01 ~]# vim /etc/profile  # 在文件末尾增加如下内容
export CATALINA_BASE=/usr/local/tomcat9-01
export CATALINA_HOME=/usr/local/tomcat9-01
export TOMCAT_HOME=/usr/local/tomcat9-01

export CATALINA_2_BASE=/usr/local/tomcat9-02
export CATALINA_2_HOME=/usr/local/tomcat9-02
export TOMCAT_2_HOME=/usr/local/tomcat9-02
[root@study-01 ~]# source /etc/profile  # 使配置文件生效
```

4、修改第二个tomcat的相关配置

```shell
[root@study-01 ~]# cd /usr/local/tomcat9-02/bin/
[root@study-01 /usr/local/tomcat9-02/bin]# vim catalina.sh  # 找到如下那行注释，在该注释下，增加两行配置
# OS specific support.  $var _must_ be set to either true or false.
export CATALINA_BASE=$CATALINA_2_BASE
export CATALINA_HOME=$CATALINA_2_HOME
```

5、编辑第二个Tomcat安装目录中conf目录下的server.xml文件，在该文件中需要修改三个端口

```shell
[root@study-01 /usr/local/tomcat9-02/bin]# cd ../conf/
[root@study-01 /usr/local/tomcat9-02/conf]# vim server.xml
# 第一个端口，Server port节点端口
<Server port="9005" shutdown="SHUTDOWN">

# 第二个端口，Connector port节点端口，也即是Tomcat访问端口
<Connector port="9080" protocol="HTTP/1.1"
               connectionTimeout="20000"
               redirectPort="8443" URIEncoding="UTF-8" />

# 第三个端口，Connector port节点端口
<Connector port="9009" protocol="AJP/1.3" redirectPort="8443" />  
```

6、修改完成后，分别进入两个Tomcat的bin目录，执行脚本启动Tomcat

```shell
# 启动Tomcat02
[root@study-01 /usr/local/tomcat9-02/conf]# cd ../bin/
[root@study-01 /usr/local/tomcat9-02/bin]# ./startup.sh 
Using CATALINA_BASE:   /usr/local/tomcat9-02
Using CATALINA_HOME:   /usr/local/tomcat9-02
Using CATALINA_TMPDIR: /usr/local/tomcat9-02/temp
Using JRE_HOME:        /usr/local/jdk1.8
Using CLASSPATH:       /usr/local/tomcat9-02/bin/bootstrap.jar:/usr/local/tomcat9-02/bin/tomcat-juli.jar
Tomcat started.
# 启动Tomcat01
[root@study-01 /usr/local/tomcat9-02/bin]# cd ../../tomcat9-01/bin/
[root@study-01 /usr/local/tomcat9-01/bin]# ./startup.sh 
Using CATALINA_BASE:   /usr/local/tomcat9-01
Using CATALINA_HOME:   /usr/local/tomcat9-01
Using CATALINA_TMPDIR: /usr/local/tomcat9-01/temp
Using JRE_HOME:        /usr/local/jdk1.8
Using CLASSPATH:       /usr/local/tomcat9-01/bin/bootstrap.jar:/usr/local/tomcat9-01/bin/tomcat-juli.jar
Tomcat started.
```

启动完成后，检查监听的端口号及进程：

```shell
[root@study-01 ~]# netstat -lntp |grep java
tcp6       0      0 :::8009                 :::*                    LISTEN      2846/java           
tcp6       0      0 127.0.0.1:9005          :::*                    LISTEN      2784/java           
tcp6       0      0 :::8080                 :::*                    LISTEN      2846/java           
tcp6       0      0 :::9009                 :::*                    LISTEN      2784/java           
tcp6       0      0 :::9080                 :::*                    LISTEN      2784/java           
tcp6       0      0 127.0.0.1:8005          :::*                    LISTEN      2846/java           
[root@study-01 ~]# ps aux |grep java
root       2784  5.6  1.5 7105356 123956 pts/0  Sl   06:24   0:06 /usr/local/jdk1.8/bin/java -Djava.util.logging.config.file=/usr/local/tomcat9-02/conf/logging.properties -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Djdk.tls.ephemeralDHKeySize=2048 -Djava.protocol.handler.pkgs=org.apache.catalina.webresources -Dorg.apache.catalina.security.SecurityListener.UMASK=0027 -Dignore.endorsed.dirs= -classpath /usr/local/tomcat9-02/bin/bootstrap.jar:/usr/local/tomcat9-02/bin/tomcat-juli.jar -Dcatalina.base=/usr/local/tomcat9-02 -Dcatalina.home=/usr/local/tomcat9-02 -Djava.io.tmpdir=/usr/local/tomcat9-02/temp org.apache.catalina.startup.Bootstrap start
root       2846  6.5  1.4 7105356 119712 pts/0  Sl   06:24   0:05 /usr/local/jdk1.8/bin/java -Djava.util.logging.config.file=/usr/local/tomcat9-01/conf/logging.properties -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Djdk.tls.ephemeralDHKeySize=2048 -Djava.protocol.handler.pkgs=org.apache.catalina.webresources -Dorg.apache.catalina.security.SecurityListener.UMASK=0027 -Dignore.endorsed.dirs= -classpath /usr/local/tomcat9-01/bin/bootstrap.jar:/usr/local/tomcat9-01/bin/tomcat-juli.jar -Dcatalina.base=/usr/local/tomcat9-01 -Dcatalina.home=/usr/local/tomcat9-01 -Djava.io.tmpdir=/usr/local/tomcat9-01/temp org.apache.catalina.startup.Bootstrap start
root       2904  0.0  0.0 112680   976 pts/0    S+   06:25   0:00 grep --color=auto java
```

在浏览器上访问两个不同的端口，本机IP为：192.168.219.128

http://192.168.219.128:9080/，http://192.168.219.128:9080/，均能访问到tomcat首页。

注：不同的Tomcat实例使用的端口号在系统中必须不能重复，必须是系统没有使用的端口才行，不然会产生端口冲突。





## Nginx+Tomcat搭建集群

1、下载并解压编译nginx

```shell
[root@study-01 ~]# cd /usr/local/src/
[root@study-01 /usr/local/src]# wget http://nginx.org/download/nginx-1.14.0.tar.gz
[root@study-01 /usr/local/src]# tar -zxvf nginx-1.14.0.tar.gz
[root@study-01 /usr/local/src]# cd nginx-1.14.0
[root@study-01 /usr/local/src/nginx-1.14.0]# ./configure --prefix=/usr/local/nginx
[root@study-01 /usr/local/src/nginx-1.14.0]# echo $?
0
[root@study-01 /usr/local/src/nginx-1.14.0]# make && make install
[root@study-01 /usr/local/src/nginx-1.14.0]# echo $?
0
[root@study-01 /usr/local/src/nginx-1.14.0]# cd ../../nginx/
[root@study-01 /usr/local/nginx]# ls  # 安装完成
conf  html  logs  sbin
```

2、创建nginx的主配置文件，不使用nginx自带的配置文件：

```shell
[root@study-01 /usr/local/nginx/conf]# mv nginx.conf nginx.conf.bak
[root@study-01 /usr/local/nginx/conf]# vim nginx.conf  # 内容如下
user nobody nobody;
worker_processes 2;
error_log /usr/local/nginx/logs/nginx_error.log crit;
pid /usr/local/nginx/logs/nginx.pid;
worker_rlimit_nofile 51200;
events
{
    use epoll;
    worker_connections 6000;
}
http
{
    include mime.types;
    default_type application/octet-stream;
    server_names_hash_bucket_size 3526;
    server_names_hash_max_size 4096;
    log_format combined_realip '$remote_addr $http_x_forwarded_for [$time_local]'
    ' $host "$request_uri" $status'
    ' "$http_referer" "$http_user_agent"';
    sendfile on;
    tcp_nopush on;
    keepalive_timeout 30;
    client_header_timeout 3m;
    client_body_timeout 3m;
    send_timeout 3m;
    connection_pool_size 256;
    client_header_buffer_size 1k;
    large_client_header_buffers 8 4k;
    request_pool_size 4k;
    output_buffers 4 32k;
    postpone_output 1460;
    client_max_body_size 10m;
    client_body_buffer_size 256k;
    client_body_temp_path /usr/local/nginx/client_body_temp;
    proxy_temp_path /usr/local/nginx/proxy_temp;
    fastcgi_temp_path /usr/local/nginx/fastcgi_temp;
    fastcgi_intercept_errors on;
    tcp_nodelay on;
    gzip on;
    gzip_min_length 1k;
    gzip_buffers 4 8k;
    gzip_comp_level 5;
    gzip_http_version 1.1;
    gzip_types text/plain application/x-javascript text/css text/htm 
    application/xml;
    add_header Access-Control-Allow-Origin *;
    include vhost/*.conf;
}
[root@study-01 /usr/local/nginx/conf]# mkdir ./vhost  # 创建虚拟主机配置文件的存放目录
[root@study-01 /usr/local/nginx/conf]# cd vhost/
[root@study-01 /usr/local/nginx/conf/vhost]# vim www.xxx.com.conf  # 创建虚拟主机配置文件，内容如下：
upstream 192.168.219.128 {
        # 需要负载的server列表，可以直接使用ip
        server 192.168.219.128:8080 weight=1;
        server 192.168.219.128:9080 weight=3;
        # server www.xxx.com:8080 weight=1;
        # server www.xxx.com:9080 weight=3;
}

server{
  listen 80;
  autoindex on;
  server_name 192.168.219;
  access_log /usr/local/nginx/logs/access.log combined;
  index index.html index.htm index.jsp;

  location / {
        proxy_pass http://192.168.219.128;
        add_header Access-Control-Allow-Origin *;
  }
}
```

3、检查nginx配置文件，显示没问题则启动nginx服务：

```shell
[root@study-01 /usr/local/nginx/conf/vhost]# cd ../../sbin/
[root@study-01 /usr/local/nginx/sbin]# ./nginx -t  # 检查nginx配置文件
nginx: the configuration file /usr/local/nginx/conf/nginx.conf syntax is ok
nginx: configuration file /usr/local/nginx/conf/nginx.conf test is successful
[root@study-01 /usr/local/nginx/sbin]# ./nginx -c /usr/local/nginx/conf/nginx.conf  # 启动nginx服务
[root@study-01 /usr/local/nginx/sbin]# netstat -lntp | grep nginx  # 检查端口是否已监听
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      5676/nginx: master  
[root@study-01 /usr/local/nginx/sbin]# ps aux |grep nginx  # 检查nginx进程是否正常
root       5676  0.0  0.0  20492   624 ?        Ss   19:57   0:00 nginx: master process ./nginx -c /usr/local/nginx/conf/nginx.conf
nobody     5677  0.0  0.0  22936  3220 ?        S    19:57   0:00 nginx: worker process
nobody     5678  0.0  0.0  22936  3220 ?        S    19:57   0:00 nginx: worker process
root       5683  0.0  0.0 112680   976 pts/0    S+   19:58   0:00 grep --color=auto nginx
```

4、启动两个Tomcat实例：

```shell
[root@study-01 ~]# cd /usr/local/tomcat9-01/bin/
[root@study-01 /usr/local/tomcat9-01/bin]# ./startup.sh 
Using CATALINA_BASE:   /usr/local/tomcat9-01
Using CATALINA_HOME:   /usr/local/tomcat9-01
Using CATALINA_TMPDIR: /usr/local/tomcat9-01/temp
Using JRE_HOME:        /usr/local/jdk1.8
Using CLASSPATH:       /usr/local/tomcat9-01/bin/bootstrap.jar:/usr/local/tomcat9-01/bin/tomcat-juli.jar
Tomcat started.
[root@study-01 /usr/local/tomcat9-01/bin]# cd /usr/local/tomcat9-02/bin/
[root@study-01 /usr/local/tomcat9-02/bin]# ./startup.sh 
Using CATALINA_BASE:   /usr/local/tomcat9-02
Using CATALINA_HOME:   /usr/local/tomcat9-02
Using CATALINA_TMPDIR: /usr/local/tomcat9-02/temp
Using JRE_HOME:        /usr/local/jdk1.8
Using CLASSPATH:       /usr/local/tomcat9-02/bin/bootstrap.jar:/usr/local/tomcat9-02/bin/tomcat-juli.jar
Tomcat started.
```

5、修改第二个Tomcat实例index.jsp文件内容，以作为两个Tomcat实例的区别，方便一会验证负载均衡是否已成功生效：

```shell
[root@study-01 ~]# vim /usr/local/tomcat9-02/webapps/ROOT/index.jsp 
<div id="congrats" class="curved container">
    <h2>tomcat2  验证负载均衡是否已成功生效!</h2>
</div>
```

6、设置防火墙规则，开放80端口

```shell
[root@study-01 ~]# firewall-cmd --zone=public --add-port=80/tcp --permanent
success
[root@study-01 ~]# firewall-cmd --reload
success
```

7、使用浏览器进行访问，验证nginx的负载均衡是否已成功生效