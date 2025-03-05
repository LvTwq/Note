[toc]

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

# 查看磁盘大小
fdisk -l

# 查看当前用户的计划任务服务
crontab -l 

# 列出所有系统服务
chkconfig –list 

# 列出所有启动的系统服务程序
chkconfig –list | grep on 

# 查看所有安装的软件包
rpm -qa 

# 列出加载的内核模块
lsmod 

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

## 配置系统内核参数

```bash
# sysctl [参数] [对象]

# 查看参数
sysctl net.ipv4.ip_forward

# 等同于
cat /proc/sys/net/ipv4/ip_forward

# 设置参数
sysctl net.ipv4.ip_forwar=1
```

# 网络

## 查询ip

* ifconfig

```shell
[root@localhost ~]# yum install net-tools
[root@localhost /]# ifconfig
# eth0 是本地网卡，lo是
```

* ip

```shell
[root@localhost /]# ip addr
```

## 重启虚拟机网络

```shell
service network restart
```

## 查看路由表

```sh
route -n
```

## 防火墙

```shell
#关闭防火墙
systemctl stop firewalld.service
#查看防火墙状态
systemctl status firewalld
#开放指定端口 
firewall-cmd --zone=public --add-port=18080/tcp --permanent
#重新载入开放端口 
firewall-cmd --reload
#移除指定端口 
firewall-cmd --permanent --remove-port=3306/tcp
```

## curl

```shell
curl -H 'Content-Type: text/xml; charset=utf-8' -d '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ser="http://service.fgw.bm.com/"><soapenv:Header /><soapenv:Body><ser:qryMPSqlByKey><ser:key>f964a5718b3b400aaf54d0baecbca609</ser:key><ser:inParams>updateTime=2021-10-27</ser:inParams></ser:qryMPSqlByKey></soapenv:Body></soapenv:Envelope>' http://2.208.64.254:8090/channel/gG2foEk5lz/services/FgwServices?wsdl
```

### 如何查看接口耗时

向 curl-format.txt 写入以下内容：
    time_namelookup:  %{time_namelookup}\n
       time_connect:  %{time_connect}\n
    time_appconnect:  %{time_appconnect}\n
      time_redirect:  %{time_redirect}\n
   time_pretransfer:  %{time_pretransfer}\n
 time_starttransfer:  %{time_starttransfer}\n
                    ----------\n
         time_total:  %{time_total}\n

```shell
curl -w "@curl-format.txt" -o /dev/null -s -L "http://cizixs.com"

# 简单写法
curl -w "Total time: %{time_total}\n" http://cizixs.com

# 查看调用过程，可以看到是通过ipv4/ipv6来访问的，如果v6不通，就需要禁用v6
curl -v www.baidu.com
```

## 如何查看应用占用的端口

可以是 pid、端口号

```sh
[root@172-23-28-106 jsxzfy]# ss -tnlp |grep 498
LISTEN     0      50          :::8090                    :::*                   users:(("java",pid=498,fd=30))
LISTEN     0      128       ::ffff:172.23.28.106:9093                    :::*                   users:(("java",pid=498,fd=7))
```

## 查看网络统计信息进程

```sh
netstat -s

netstat -antp | grep 6378

netstat -antp | grep 6378 | wc -l
```

## tcpdump

```sh
# 先查网卡
ip addr

tcpdump -i eth0 -nn -s0 -v port 80
tcpdump -i any host 
tcpdump -i any -nn -s0 -v host 1.1.0.9

tcpdump -i any port 8400 -w upload.cap

tcpdump -nni any port 53 and src 源IP -w aaa.pcap
```

* -i : 选择要捕获的接口，通常是以太网卡或无线网卡，也可以是 vlan 或其他特殊接口。如果该系统上只有一个网络接口，则无需指定。
* -nn : 单个 n 表示不解析域名，直接显示 IP；两个 n 表示不解析域名和端口。这样不仅方便查看 IP 和端口号，而且在抓取大量数据时非常高效，因为域名解析会降低抓取速度。
* -s0 : tcpdump 默认只会截取前 96 字节的内容，要想截取所有的报文内容，可以使用 -s number， number 就是你要截取的报文字节数，如果是 0 的话，表示截取报文全部内容。
* -v : 使用 -v，-vv 和 -vvv 来显示更多的详细信息，通常会显示更多与特定协议相关的信息。
* port 80 : 这是一个常见的端口过滤器，表示仅抓取 80 端口上的流量，通常是 HTTP。
* host : 特定ip
  * src host : 特定来源ip
  * dst host : 特定目标ip

可以调一个接口，然后抓这个接口使用的端口

## 添加虚拟网卡

```sh
ip tuntap add dev tundns1 mod tun
ip addr add 127.0.0.3/24 dev tundns1
ifconfig tundns1 up
```

## iptables

```sh
# 查看已有规则
iptables -nvL
iptables -L INPUT -vn


# 开放443端口
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport 443 -j ACCEPT

# 对源ip开放 53 udp
iptables -A INPUT -s 源ip -p udp -m state --state NEW -m udp --dport 53 -j ACCEPT

# 删除规则
iptables -D INPUT -s 源ip -p udp -m udp --dport 53 -j ACCEPT

# 对源ip禁用 53 tcp
iptables -I INPUT -s 源ip -p tcp --dport 53 -j DROP
# 对某ip放开
iptables -t filter -I INPUT -s 192.168.72.118  -j ACCEPT

iptables -D INPUT -s 192.168.72.118 -j ACCEPT

# 保存规则
service iptables save
```

## nslookup

```shell
# 用某DNS查询域名信息
nslookup 域名 dns服务器
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

// 查看已删除，空间却没有释放的进程
lsof |grep deleted
```

lsof：查看文件的进程信息（list open files）

| 参数      | 含义                       | 举例          |
| --------- | -------------------------- | ------------- |
| +d 目录   | 列出目录下被打开的文件     | lsof +d /root |
| -i 条件   | 列出符合条件的进程         |               |
| -p 进程id | 列出指定进程号所打开的文件 | lsof -p pid   |

## 查询某进程所在路径

```shell
ll /proc/进程id

ll /proc/进程id/fd/
```

## top

```sh
# 看这个进程里所有线程的cpu消耗情况
top -Hp <pid>
```

按CPU使用率排序：shift+p
按内存使用率排序：shift+m

## 查看某个进程的父进程

```sh
cat /proc/pid/status
```

# 文本

## vim

```shell
[root@localhost share]# yum install vim
[root@localhost share]# vim test.txt
[root@localhost share]# yum install zip
[root@localhost share]# vim test.war
[root@localhost share]# yum install unzip
[root@localhost share]# vim test.war
```

## wc

wc [参数] 文件
统计文件的行数、单词数
-w	统计单词数
-c	统计字节数
-l	统计行数
-m	统计字符数

## awk

常用参数：
-F	指定输入时用到的字段分隔符
-v	自定义变量
-f	从脚本中读取awk命令
-m	对val值设置内在限制

内建变量：
`NR`: NR表示从awk开始执行后，按照记录分隔符读取的数据次数，默认的记录分隔符为换行符，因此默认的就是读取的数据行数，NR可以理解为Number of Record的缩写。

`FNR`: 在awk处理多个输入文件的时候，在处理完第一个文件后，NR并不会从1开始，而是继续累加，因此就出现了FNR，每当处理一个新文件的时候，FNR就从1开始计数，FNR可以理解为File Number of Record。

`NF`: NF表示目前的记录被分割的字段的数目，NF可以理解为Number of Field。

仅显示指定文件中第1、2**列**的内容（默认以空格为间隔符）

```sh
[root@linuxcool ~]# awk ' {print $1,$2} ' anaconda-ks.cfg
#version=RHEL8 
ignoredisk --only-use=sda
autopart --type=lvm
# Partition
clearpart --none
```

以冒号为间隔符，仅显示指定文件中第1列的内容：

```sh
[root@linuxcool ~]# awk -F : '{print $1}' /etc/passwd
root
bin
daemon
adm
lp
sync
shutdown
```

以冒号为间隔符，显示系统中所有UID号码大于500的用户信息（第3列）：

```sh
[root@linuxcool ~]# awk -F : '$3>=500' /etc/passwd
nobody:x:65534:65534:Kernel Overflow User:/:/sbin/nologin
systemd-coredump:x:999:997:systemd Core Dumper:/:/sbin/nologin
polkitd:x:998:996:User for polkitd:/:/sbin/nologin
geoclue:x:997:995:User for geoclue:/var/lib/geoclue:/sbin/nologin
```

仅显示指定文件中含有指定关键词root的内容：

```sh
awk '/root/{print}' /etc/passwd
root:x:0:0:root:/root:/bin/bash
operator:x:11:0:operator:/root:/sbin/nologin
```

以冒号为间隔符，仅显示指定文件中最后一个字段的内容：

```sh
awk -F: '{print $NF}' /etc/passwd
```

## sed

```sh
sed -n '/root/p' xxx.log #显示包含root的行

sed -i 's/root/world/g' xxx.log # 用world 替换xxx.log文件中的root; s==search  查找并替换, g==global  全部替换, -i: implace

sed -i -e '1i happy' -e '$a new year' xxx.log #【真实写入文件】在文件第一行添加happy,文件结尾添加new year


sed -i '/it is a test/d' myfile # 删除这行


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

zip -r backup1.zip /etc
```

## 权限

```sh
#查看Linux文件的权限
ls -l 文件名
#查看linux文件夹的权限
ls -ld 文件夹名称
```

![](..\images\file-permissions-rwx.jpg)
-R : 对目前目录下的所有文件与子目录进行相同的权限变更(即以递归的方式逐个变更)

![](..\images\八进制语法.png)

```shell
# 仅读权限
chmod -R 444 /etc/resolv.conf

# 读写权限
chmod -R 644 /etc/resolv.conf
```

# 磁盘和内存

## 查看内存使用

```sh
free -h
```

## 查看各分区使用

```sh
# 此命令可用于显示已挂载文件系统的磁盘使用情况
df -h
# 查看文件系统的inode使用情况
df -i


find /home -type f -size +100M
```

## 查看指定目录的大小

```sh
du -sh /*

yum install epel-release
yum provides ncdu
yum -y install ncdu
ncdu -x /
```

## 查看硬盘大小

```sh
# 查看磁盘的分区布局和详细信息
fdisk -l |grep Disk
```

## 列出系统上的块设备（包括磁盘和分区）

它会显示每个设备的名称、大小和挂载点等信息

```sh
lsblk
```

## 查看磁盘压力

```sh
# 每秒输出一次I/O统计信息
iostat -x 1

yum install iotop

```

# 用户/用户组

```bash
# 查看活动用户
w

# 查看指定用户信息
id

# 查看用户登录日志
last

# 查看系统所有用户
cut -d: -f1 /etc/passwd

# 查看系统所有组

```

# 定时任务

```sh
# 打开定时任务编辑器
crontab -e

# 添加
10 15 * * * sh test.sh
```
