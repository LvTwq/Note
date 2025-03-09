[什么是ClickHouse？ | ClickHouse Docs](https://clickhouse.com/docs/zh)

# 介绍

[什么是ClickHouse？ | ClickHouse Docs](https://clickhouse.com/docs/zh)


基本使用

## 建表

```sql
CREATE TABLE logs
(
    event_time DateTime,
    event_type String,
    user_id UInt64,
    data String
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(event_time)  -- 按年和月分区
ORDER BY (event_time, user_id);	   -- 定义数据在每个分区内部如何排序
```

### PARTITION BY

用来定义数据如何分区存储。分区是一种将数据按某种规则（通常是时间或某些字段的值）划分成多个逻辑块（分区）的方式，从而提高查询性能和数据管理效率

好处：

1、可以避免全表扫描，对于按时间范围查询等场景非常有效

2、便于数据删除：

```sql
ALTER TABLE logs DROP PARTITION '2024-01';  -- 删除2024年1月的数据

```

3、**分区修整（`Merging`）** ：ClickHouse会定期进行分区修整，将小的分区合并成较大的分区。这有助于减少存储空间的浪费，并提高查询性能

### primary key

并不是传统意义上的唯一性约束，而是一个  **排序字段**

指定了数据在每个分区内的排序方式

它是 `ORDER BY`键的一个子集，用于建立数据的索引结构，以加速对数据的访问

查询执行时，ClickHouse会使用 `PRIMARY KEY`来快速定位到包含所需数据的数据块（parts），从而减少查询时需要扫描的数据量

### ORDER BY

* 定义了表中数据的物理排序方式。在MergeTree系列的表引擎中，数据首先按照 `ORDER BY`中指定的列进行排序存储
* 这种排序是持久化的，意味着数据在磁盘上是按照这个顺序存储的

### MergeTree

1、索引（Indexing）：使用稀疏索引，基于 primary key

2、支持高效的批量插入

3、数据压缩

4、支持并行查询

### ReplacingMergeTree

用于处理数据中可能存在的重复记录。在合并过程中，如果两行具有相同的主键（`ORDER BY`中的字段），则可以根据一个列的值（如时间戳）来保留最新的记录，删除重复数据

### SummingMergeTree

适用于进行聚合操作的场景。`SummingMergeTree` 会对具有相同主键的数据行进行合并并进行求和操作，适合存储和处理实时统计数据

# SQL 优化

1、选择合适的表引擎

MergeTree不一定适用于所有场景

2、不要使用 Nullable

因为存储Nullable时，需要创建一个额外的文件来存储NULL的标记，并且Nullable无法被索引

3、合适的分区和索引

PARTITION BY，通常建议按天分区

1、不适用join
