># PG（Abase/人大金仓）的一些技巧


## 背景
- [PG的简介](https://blog.csdn.net/weixin_42259580/article/details/90746660)
- 人大金仓V8R6（PG）基于Postgres
- GreenPlum数据库可以理解为Postgres集群



## 安装
- 不介绍
  - gp公司封装后一键安装（需要配置集群参数）
  - kingbase稍微多点，安装也极其简单


## 一些技巧
### 数据库导入导出
```shell
// 导入
pg_dump -Fc 数据库名> 2019-0531_db_xxxx.dump
pg_restore -d 数据库名 2019-0523_db_xxxx.dump
```
```shell
pg_dump -O -d db_jdba_ztk_dev -n db_jdbadsj -sc > ztk.sql
psql -d db_jdba_ztk_dev -f ztk.sql
```
- 导出命令：pg_dump
  - https://www.cnblogs.com/chjbbs/p/6480687.html
  - 其中F参数
    - p 输出纯文本SQL脚本文件（缺省）
    - t 输出适合输入到 pg_restore 里的tar归档文件。 使用这个归档允许在恢复数据库时重新排序和/或把数据库对象排除在外。 同时也可能可以在恢复的时候限制对哪些数据进行恢复。 
    - c 输出适于给 pg_restore 用的客户化归档。 这是最灵活的格式，它允许对装载的数据和对象定义进行重新排列。 这个格式缺省的时候是压缩的。
- 导入命令：pg_restore
- 执行sql文件命令：psql


### 断开连接
```sql
SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE datname='db_xxxx' AND pid<>pg_backend_pid();
```
> 当想修改、删除数据库时，可以下方式，将两句sql一起执行，趁程序没反应过来(重连需要时间)，执行修改操作
```sql
SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE datname='db_xxxx' AND pid<>pg_backend_pid();ALTER DATABASE db_xxxx RENAME TO db_xxxx_bak;
```
### 保持连接时修改库名
#### 方法一
> 会造成程序与数据库断开连接，对正在运行中的程序有一定影响。（数据库连接池会自动重试）
- 见上
#### 方法二
- 修改系统表
```sql
UPDATE pg_database  SET datname = 'database1'  WHERE datname = 'database2';
```
> 已经建立连接的程序仍然是与旧库的连接，但重新连接或用新的程序连接时，才是此时此刻对应的库名


### 跨数据库操作（连表）
```sql
---0. 指定创建路径（一般默认在public下）
set search_path to public;

---1. 创建远程连接扩展
create extension dblink;

---2. 进行远程连接
select dblink_connect('xxxx','host= dbname= user= password=');

---3. 查询矫正数据并进行矫正

---4. 断开跨库链接
select dblink_disconnect('xxxx');


--如果要删除扩展
drop extension dblink;

```
### PG中的函数

#### 关于数组
- 几个函数
  - string_agg
  - array_agg
  - array_to_string
  - unnest
  - array_upper
  - array_length
- 运算符

| 操作符 | 	描述	|例子	|结果|
|:-----:|:------:|:----:|:----:|
| =	    | 等于	            |ARRAY[1.1,2.1,3.1]::int[] = ARRAY[1,2,3]	|t
| <>	| 不等于	        |ARRAY[1,2,3] <> ARRAY[1,2,4]	            |t
| <	    | 小于	            |ARRAY[1,2,3] < ARRAY[1,2,4]	            |t
| >	    | 大于	            |ARRAY[1,4,3] > ARRAY[1,2,4]	            |t
| <=	| 小于等于	        | ARRAY[1,2,3] <= ARRAY[1,2,3]	            |t
| >=	| 大于等于	        | ARRAY[1,4,3] >= ARRAY[1,4,3]	            |t
| @>	| 包含	            | ARRAY[1,4,3] @> ARRAY[3,1,3]	            |t
| <@	| 被包含	        | ARRAY[2,2,7] <@ ARRAY[1,7,4,2,6]	         |   t
| &&	| 重叠（具有公共元素）|	ARRAY[1,4,3] && ARRAY[2,1]	                    |t
| \|\|	| 数组和数组串接	|   ARRAY[1,2,3] \|\| ARRAY[4,5,6]	            |{1,2,3,4,5,6}
| \|\|	| 数组和数组串接	|   ARRAY[1,2,3] \|\| ARRAY[[4,5,6],[7,8,9]]	    |{{1,2,3},{4,5,6},{7,8,9}}
| \|\|	| 元素到数组串接	|   3 \|\| ARRAY[4,5,6]	                        |{3,4,5,6}
| \|\|	| 数组到元素串接	|   ARRAY[4,5,6] \|\| 7	                        |{4,5,6,7}

#### 字符串

#### 其他函数
- date_part('month', d_slrq)

#### 条件表达式
- least
- greatest
- nullif
- coalesce
- case
#### 某些语法
- select version()
- distinct on()
- with语句
  - 构建`临时表`
```sql
with organs(code) as (select xxx from ttt where aa=bb)
```
```sql
with organs(code) as (values
        <foreach collection="sqlParam.code" item="item" separator=",">
            (#{item})
        </foreach>
        )
```
  - with骚操作（单条sql执行多个插入语句）
```sql
WITH company as (INSERT INTO companies(id, name) VALUES ($1, $2)) INSERT INTO services(id, company_id, name) VALUES
($1, $2, $3),($1, $2, $3),($1, $2, $3),($1, $2, $3),
```
  - 递归
```sql
with recursive yaj as(
    select c_xajbs,c_yajbs,1 as i from t_xxxx_xshb where c_yajbs in ('','')
    union all
    select xaj.c_xajbs,ya.c_yajbs, ya.i+1  from yaj ya,t_xxxx_xshb xaj where xaj.c_yajbs=ya.c_xajbs
)
select distinct yaj.* from yaj,(select c_yajbs,max(i) i from yaj group by c_yajbs)maxAj where yaj.c_yajbs=maxAj.c_yajbs and yaj.i=maxAj.i
```
- 批量更新
```sql
    UPDATE "db_ag"."t_lcrzxx" record
    SET
        "c_bh_bjbr" = tmp."c_bh_bjbr",
        "d_rzrq" = tmp."d_rzrq"
    FROM
    (VALUES
        (xxx),(xxx),(xxx),(xxx),(xxx),(xxx),(xxx)
    ) AS tmp ("c_bh","c_bh_bjbr","d_rzrq"
    )
    WHERE
        record."c_bh" = tmp."c_bh" 
```
- select oid,datname from pg_database;
