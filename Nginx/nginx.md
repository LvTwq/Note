[toc]

# 常用命令

服务器：

```shell
find / -name nginx.conf
cd /etc/nginx/
vim nginx.conf
```

重启：

```shell
cd /usr/sbin
./nginx -s reload
```

# 常用配置

## 设置超时时间：

```shell
server {
    listen       81 default_server;
    listen       [::]:81 default_server;
    server_name  _;
    client_max_body_size 1024M;
    root         /usr/share/nginx/html;
    keepalive_timeout  100;
    proxy_connect_timeout  100s;
    proxy_read_timeout     100s;
    proxy_send_timeout     100s;
}
```

如果超时时间为60s，但某个接口需要100s，虽然后台还在继续跑程序，但是nginx会504（time out），返回给前台，容易造成误解

可以查看日志：
error_log  /var/log/nginx/error.log warn;

## 文件大小

配置nginx上传文件大小，默认只有1M，

## proxy_pass

用于代理转发，如果在proxy_pass后面的url加/，表示绝对根路径
如果没有/，表示相对路径，把匹配的路径部分也代理走

假设下面四种情况分别用 http://192.168.1.1/proxy/test.html 进行访问

1、代理URL：http://127.0.0.1/test.html

```conf
location /proxy/ {
    proxy_pass http://127.0.0.1/;
}
```

2、代理到URL：http://127.0.0.1/proxy/test.html

```conf
location /proxy/ {
    proxy_pass http://127.0.0.1;
}
```

3、代理到URL：http://127.0.0.1/aaa/test.html

```conf
location /proxy/ {
    proxy_pass http://127.0.0.1/aaa/;
}
```

4、代理到URL：http://127.0.0.1/aaatest.html

```conf
location /proxy/ {
    proxy_pass http://127.0.0.1/aaa;
}
```

## 文件下载限速

在里面的location上添加如下代码

```sh
limit_rate_after 512k;
limit_rate 10k;
```

## 限制连接数

```
limit_conn_zone $host zone=global_conn_limit_zone:10m;
limit_conn global_conn_limit_zone 100;
```

## 设置请求头

* proxy_set_header
  假如Nginx**请求上游服务器**时，添加额外的请求头，就需要使用proxy_set_header
* add_header
  Nginx**响应数据时**，要告诉浏览器一些头信息，就要使用add_header。例如跨域访问

## http 块

七层协议

## stream 块

用来实现四层协议转发、代理或者负载均衡

## upstream

http 块 和 stream 块中都有
利用 proxy_pass 可以把请求代理到后端服务器，但上文配置示例指向同一台服务器，如果需要指向**多台**就要用到 ngx_ http_ upstream_ module。

它为反向代理提供了负载均衡及故障转移等重要功能

# NGINX和Tomcat的区别

Tomcat是Java服务器，它可以单独运行Java 的war包，或者叫做Web容器，他会管理整个Servlet的生命周期，解析http请求

nginx 用来做请求的转发、反向代理，负载均衡

# 反向代理

![](..\images\nginx1.png)

首先把 server 块中的 server_name 修改为该系统的IP地址，listen 改为要监听的端口

然后在 server 块中的 location 块中配置，location 后面跟的是要匹配的uri，proxy_pass 是需要请求转发的路径

最后访问 nginx 地址，server_name:listen

# HTTPS 配置

1、监听的端口 后面加上 ssl（https 默认是 443，也可以设置为其他端口）
2、ssl_certificate 设置为 证书路径
ssl_certificate_key

# 统一错误页面配置

在 server 块中配置 error_page

```shell
    server {
        error_page  400 500 502 503 504  /error.html;
        location = /error.html {
            root  html;
        }
    }  
```

# 通过 url 访问服务器目录

```shell
location /clientlog {
        alias /home/xxxxx/clientlog;
        autoindex on;  # 开启目录文件列表
        autoindex_exact_size on;  # 显示出文件的确切大小，单位是bytes
        autoindex_localtime on;  # 显示的文件时间为文件的服务器时间
        charset utf-8,gbk;  # 避免中文乱码
}
```

# 负载均衡

> 负载均衡（Load Balance），意思是将负载（工作任务，访问请求）进行平衡、分摊到多个操作单元（服务器，组件）上进行执行。是解决高性能，单点故障（高可用），扩展性（水平伸缩）的终极解决方案

分布式系统的问题：每个部署的独立业务还存在单点的问题和访问统一入口的问题。

这个时候可以增加负载均衡设备，实现流量分发。

## 配置

### 配置服务器地址

```bash
# 定义一个HTTP服务组
upstream myserver {
	server xxx.xx.xx.14:8080;
	server xxx.xx.xx.14:8081;
}
```

```bash
server {
	listen    80;
	server_name xxx.xx.xx.14
	\#charset koi8-r;
	\#access_log logs/host.access.log main;
	location / {
        # 通过代理将请求发送给 upstream 命名的 HTTP 服务
		proxy_pass  http://myserver; 
		root  html;
		index index.html index.htm;
  }
}
```

## 负载均衡分类

### 几层负载

* 四层负载(tcp)：ip:port
* 七层负载(http)：url

### DNS 负载均衡

在DNS服务器配置多个

### IP负载均衡

在网络层修改请求目标地址

请求到达负载均衡服务器后，根据负载均衡算法把请求的目的地址修改为真实的IP地址

缺点是：所有请求都要经过负载均衡服务器，集群最大吞吐量受限于负载均衡服务器网卡带宽

### 链路层负载均衡

在通信协议的数据链路层修改mac地址，进行负载均衡

## 负载均衡算法

### 轮询法

将请求按顺序轮流分配到后端服务器，均衡的对待后端每一台服务器，不关心服务器的实际连接数和当前系统负载，如果后端服务器down掉，能自动剔除。

### 加权轮询法

不同的后端服务器可能因为机器的配置，当前的抗压能力也不相同，给配置高的服务器更高的权重，让它能够处理更多的请求

指定轮询几率，weight和访问比率成正比，用于后端服务器性能不均的情况

```bash
upstream bakend {  
  server 192.168.0.14 weight=10;  
  server 192.168.0.15 weight=10;  
}
```

### 源地址哈希法-ip_hash

每个请求按访问ip的哈希结果分配，也就是说同一ip访问nginx会一直讲请求发送给同一台服务器，可以解决session的问题

```shell
upstream bakend {  
  ip_hash;  
  server 192.168.0.14:88;  
  server 192.168.0.15:80;  
}
```

# 高可用

![](..\images\高可用架构图.png)

## nginx（反向代理）+ keepalived（IP漂移）

### Keepalived 简介

Keepalived是一个基于VRRP协议（第三层-网络层）来实现的服务高可用方案。
VRRP全称 Virtual Router Redundancy Protocol，即 虚拟路由冗余协议。可以认为它是实现路由器高可用的容错协议，即将N台提供相同功能的路由器组成一个路由器组(Router Group)，这个组里面有**一个master和多个backup**，但在外界看来就像一台一样，构成虚拟路由器，拥有一个虚拟IP（vip，也就是路由器所在局域网内其他机器的默认路由），**占有这个IP的master实际负责ARP相应和转发IP数据包，组中的其它路由器作为备份的角色处于待命状态**。master会发组播消息，当backup在超时时间内收不到vrrp包时就认为master宕掉了，这时就需要根据VRRP的优先级来选举一个backup当master，保证路由器的高可用

### 主从模式

![](..\images\1210730-20190410111156636-1982430025.png)

![](..\images\1210730-20190410105029949-1864664169.png)

在 LB-01 和 LB-02 上安装nginx、**keepalived**，然后配置：

配置主节点

```sh
[root@LB-01 ~]# vim /etc/keepalived/keepalived.conf
! Configuration File for keepalived


vrrp_instance VI_1 {
    state MASTER            // 主从划分，主服务器为MASTER，从服务器为BACKUP
    interface ens33         // 指定绑定虚拟 IP 的网卡
    virtual_router_id 51    // VRRP 路由器组 ID（同一组中 MASTER 和 BACKUP 要一致）
    priority 150            // 权重大的是主
    advert_int 1	    // 心跳包的间隔时间（单位：秒）
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        //虚拟地址，浏览器通过该地址访问，主从配置相同
        192.168.1.110/24 dev ens33 label ens33:1
    }
}
```

在**主**上查看IP，会发现多出了VIP 192.168.1.110

配置从节点

```sh
[root@LB-02 ~]# vim /etc/keepalived/keepalived.conf 
! Configuration File for keepalived

vrrp_instance VI_1 {
    state BACKUP
    interface ens33
    virtual_router_id 51
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
    192.168.1.110/24 dev ens33 label ens33:1
    }
}
```

查看**从**节点，不会多出VIP（只有当主挂了的时候，VIP才会飘到备节点）

**在测试机器上面访问 Keepalived上面配置的VIP 192.168.1.110**

```sh
[root@node01 ~]# curl 192.168.1.110
web01 192.168.1.33  
[root@node01 ~]# curl 192.168.1.110
web02 192.168.1.34  
[root@node01 ~]# curl 192.168.1.110
web01 192.168.1.33  
[root@node01 ~]# curl 192.168.1.110
web02 192.168.1.34
//关闭LB-01 节点上面keepalived主节点。再次访问，发现依然可以访问
[root@LB-01 ~]# systemctl stop keepalived
[root@node01 ~]# 
[root@node01 ~]# curl 192.168.1.110
web01 192.168.1.33  
[root@node01 ~]# curl 192.168.1.110
web02 192.168.1.34  
[root@node01 ~]# curl 192.168.1.110
web01 192.168.1.33  
[root@node01 ~]# curl 192.168.1.110
web02 192.168.1.34
```

此时查看LB-01 主节点上面的IP ，发现已经没有了 VIP;

查看LB-02 备节点上面的IP，发现 VIP已经成功飘过来了

### 双主模式

将keepalived做成双主模式，其实很简单，就是再配置一段新的vrrp_instance（实例）规则，主上面加配置一个从的实例规则，从上面加配置一个主的实例规则

![](..\images\双主模式.png)

此时LB-01节点即为Keepalived的主节点也为备节点，LB-02节点同样即为Keepalived的主节点也为备节点。LB-01节点默认的主节点VIP（192.168.1.110），LB-02节点默认的主节点VIP（192.168.1.210）

```sh
[root@LB-01 ~]# vim /etc/keepalived/keepalived.conf   //编辑配置文件，增加一段新的vrrp_instance规则
! Configuration File for keepalived

global_defs {
   notification_email {
    381347268@qq.com
   }
   smtp_server 192.168.200.1
   smtp_connect_timeout 30
   router_id LVS_DEVEL
}

vrrp_instance VI_1 {
    state MASTER
    interface ens33
    virtual_router_id 51
    priority 150
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
    192.168.1.110/24 dev ens33 label ens33:1
    }
}

# 新增的实例，代表从
vrrp_instance VI_2 {
    state BACKUP
    interface ens33
    virtual_router_id 52
    priority 100
    advert_int 1
    authentication {
    auth_type PASS
    auth_pass 2222
    }
    virtual_ipaddress {
    192.168.1.210/24 dev ens33 label ens33:2
    }
}
```

查看LB-01节点的IP地址，发现VIP（192.168.1.110）同样还是默认在该节点

```sh
[root@LB-02 ~]# vim /etc/keepalived/keepalived.conf    //编辑配置文件，增加一段新的vrrp_instance规则
! Configuration File for keepalived

global_defs {
   notification_email {
    381347268@qq.com
   }
   smtp_server 192.168.200.1
   smtp_connect_timeout 30
   router_id LVS_DEVEL
}

vrrp_instance VI_1 {
    state BACKUP
    interface ens33
    virtual_router_id 51
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
    192.168.1.110/24 dev ens33 label ens33:1
    }
}

# 新增的实例，代表主
vrrp_instance VI_2 {
    state MASTER
    interface ens33
    virtual_router_id 52
    priority 150
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 2222
    }
    virtual_ipaddress {
        192.168.1.210/24 dev ens33 label ens33:2
    }   
}
```

查看LB-02节点IP，会发现也多了一个VIP（192.168.1.210），此时该节点也就是一个主了

测试：

```sh
[root@node01 ~]# curl 192.168.1.110
web01 192.168.1.33  
[root@node01 ~]# curl 192.168.1.110
web02 192.168.1.34  
[root@node01 ~]# curl 192.168.1.210
web01 192.168.1.33  
[root@node01 ~]# curl 192.168.1.210
web02 192.168.1.34

// 停止LB-01节点的keepalived再次测试
[root@LB-01 ~]# systemctl stop keepalived
[root@node01 ~]# curl 192.168.1.110
web01 192.168.1.33  
[root@node01 ~]# curl 192.168.1.110
web02 192.168.1.34  
[root@node01 ~]# curl 192.168.1.210
web01 192.168.1.33  
[root@node01 ~]# curl 192.168.1.210
web02 192.168.1.34
```
