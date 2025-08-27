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

* 按主键/排序键排序存储：数据在写入时，根据 `order by`子句定义的排序键进行排序
* 数据部分：数据以不可变的“部分”(Parts) 形式写入磁盘。每次 `INSERT` 操作通常会创建一个新的数据部分
* 后台合并(Merge)：

* ClickHouse 会定期在后台将多个小的数据部分合并成更大的部分。合并过程会：
  * 保持数据在新部分中仍然有序。
  * **删除主键完全相同的行** （这是 `MergeTree` 唯一的“去重”能力，但非常有限且不可靠，因为它只对同一部分内或合并时遇到的完全相同行起作用，且不保证所有重复行都被删除）。
* **分区 (Partitioning)** ：可以按 `PARTITION BY` 子句（如按日期）将数据划分为多个分区，便于管理和删除旧数据。

### ReplacingMergeTree

* **定位** ：在 `MergeTree` 的基础上， **专门解决了数据重复问题** 。
* **核心特性** ：
* **继承 `MergeTree` 的所有特性** ：包括排序、分区、后台合并等。
* **显式去重逻辑** ：这是它与 `MergeTree` 最大的区别。在后台合并数据部分时，`ReplacingMergeTree` 会 **根据指定的排序键（或主键）来识别重复行** 。
* **`version` 参数** ：`ReplacingMergeTree` 可以接受一个可选的 `version` 列参数。
  * **不指定 `version`** ：在合并时， **保留最后插入的那条重复行** （基于 `_part` 或 `_part_offset` 等内部元数据，结果可能不确定）。
  * **指定 `version` 列** ：在合并时， **保留 `version` 值最大的那条重复行** 。这使得你可以控制哪条是“最新”的数据。`version` 通常是一个整数（如版本号、时间戳）。
* **重要限制** ：
* **合并时才去重** ：去重 **不是实时的** 。只有在后台合并 (Merge) 发生时才会执行。在合并之前，查询可能会看到多条重复数据。可以使用 `FINAL` 关键字强制去重，但这会严重影响查询性能，不推荐在生产中频繁使用。
* **不能保证 100% 无重复** ：如果合并尚未发生，或者由于某些原因合并策略没有触发对特定部分的合并，重复数据可能暂时存在。
* **适用场景** ：
* 存储可能被多次插入或更新的数据，例如：
  * 用户资料信息（可能被多次更新）。
  * 从不同来源或重试机制下收集的状态数据。
  * 需要根据版本号保留最新状态的场景。
* **与 `MergeTree` 的关键区别** ：`ReplacingMergeTree` 提供了 **可预测且可控的去重机制** （尤其是在使用 `version` 时），而 `MergeTree` 的去重是偶然且不可靠的。

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
