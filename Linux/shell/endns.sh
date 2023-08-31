#!/bin/sh

#dns增删改查
#总体思路：操作/etc/resolv.conf文件
#遍历参数
#根据参数拼接成一个string
#新增 echo > ifc-devicename
#删除 sed -i '/xxx/d' /etc/resolv.conf
#修改  先删除再新增

# A新增 D删除
TYPE=""
DNS=""

for args in $*;do

  #echo $args
  key=${args%=*}
  value=${args#*=}
  #echo key=$key
  #echo value=$value
  
  case "$key" in
  --help|-h)
        usage
    exit 0
    ;;
  
  --type)
        TYPE=$value
    ;;
  
  --server)
        DNS=$value
    ;;
    *)
  echo "default."
    ;;
  esac

done
[ -z "$(cat /etc/resolv.conf)" ] && echo "#genarate by endns" >> /etc/resolv.conf

/usr/bin/chmod -R 666  /etc/resolv.conf
DNS_NAMESERVER="nameserver $DNS"

if [ ${TYPE} == "A"  ];then
#example:nameserver 114.114.114.114
     echo "$DNS_NAMESERVER"
     sed -i "1i$DNS_NAMESERVER" /etc/resolv.conf
elif [ ${TYPE} == "D"  ];then
     sed -i "/$DNS_NAMESERVER/d" /etc/resolv.conf
fi
/usr/bin/chmod -R 444  /etc/resolv.conf
