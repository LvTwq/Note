[TOC]


# 原理


# 命令
```sh
# 查看topic版本 kafka_2.11-2.0.1.jar（2.11为scala版本，2.0.1为kafka版本）
ls /opt/kafka_2.11-2.0.1/libs

# 查看topic列表
sh kafka-topics.sh --list --zookeeper localhost:2181

# 查看topic信息
sh kafka-topics.sh --describe --zookeeper localhost:2181 --topic [name]

# 查看topic消息列表
sh kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic [name] --from-beginning

# 创建topic（2.2.0版本前后命令有差异）
sh kafka-topics.sh --create --zookeeper localhost:2181 --topic dfl --replication-factor 1 --partitions 1

```