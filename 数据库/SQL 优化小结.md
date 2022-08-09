## 1.关于in和exists的使用

```sql
1.当父查询结果集小于子查询结果集则选择exists，如果父查询结果集大于子查询结果集选择in。（可尝试等价改写）
in和exists都有子查询优化，提升子查询，有时候这两的执行计划一样。需要注意的是如果子查询包含了父查询里面的条件，in不会被优化。

2.in里面的值一般不超过100个
3.单表abase的in和个数关系不大，都可以走索引。
4.当有连表并且有in的个数很多，count的时候需要解析这些值很慢，所以可以封装成any valuse的形式来求count，而分页还是使用in。此例主要是in和any(values)的等价改写
any values：c_bh=any(values('53'),('530001'),('530002'),...)


abase在查询的时候会自动做表连接。将两张表做hash join操作：
1.EXPLAIN SELECT * FROM X WHERE x_num IN(SELECT y_num FROM y);  
2.                              QUERY PLAN                                
3.----------------------------------------------------------------------  
4. Hash Join  (cost=23.25..49.88 rows=350 width=86)  
5.   Hash Cond: (x.x_num = y.y_num)  
6.   ->  Seq Scan on x  (cost=0.00..17.00 rows=700 width=86)  
7.   ->  Hash  (cost=20.75..20.75 rows=200 width=4)  
8.         ->  HashAggregate  (cost=18.75..20.75 rows=200 width=4)  
               ->  Seq Scan on y  (cost=0.00..17.00 rows=700 width=4)
```


## 2.关于not in和not exists的使用

```sql
1.建议使用not exists，不使用not in
2.not in不能提升子查询
3.当not in中包含null值时，无结果集
```



## 3.like条件无索引

```
前，后模糊匹配，都需要建立索引，防止大量的全表扫描。
全模糊匹配程序上可以控制输入的字符个数，防止全表扫描，返回大量数据。
```


## 4.对join，left join的使用,将条件放到on和where后面的区别问题

```sql
postgresql中left join中将条件放入 on和where的区别。
1.on是肯定会返回左表的数据，所以在on里面的条件都会返回，如果想要过滤数据则需要在where中加条件
2.由于 inner join是两表都有的，所以，返回的结果是和where条件一样的。

示例：
select * form tab1 left join tab2 on (tab1.size = tab2.size) where tab2.name=’AAA’
select * form tab1 left join tab2 on (tab1.size = tab2.size and tab2.name=’AAA’)
```

[left join参考实例](https://blog.csdn.net/qq_35101027/article/details/78288279)

## 5.滥用索引

### 1.索引过多

```sql
一个表10-20个索引，一个表的索引建议不超过6个。
```

### 2.重复索引

```
重复索引，占用空间，字段一样、字段顺序一样，命名不一样
```

### 3.滥用组合索引

```sql
一个组合索引7-8个字段。建议组合字段的个数不超过3个。
```

[组合多个索引](https://www.postgresql.org/docs/10/indexes-bitmap-scans.html)

## 6.inser使用 

### 1.多条insert数据，建议修改为insert values形式

### 2.批量插入的时候values里面的参数个数不能超过32767

```sql
批量插入的时候values里面的参数个数不能超过32767，可以设置300-500个提交一次。
程序报错：
Caused by: java.io.IOException: Tried to send an out-of-range integer as a 2-byte value: 43800
pg的jdbc driver对prepared Statement的参数 set的时候，client端的一个发送大小限制在2-byte。
相当于所有的values里面的字段总和不能超过32767，开发环境的数据要少点所以没复现。
```


## 7.删除重复数据

```sql
1.常规删除方法
explain analyse delete from deltest a where a.ctid <> (select min(t.ctid) from deltest t where a.id=t.id);
2.group by删除方法
explain analyse delete from deltest a where a.ctid not in (select min(ctid) from deltest group by id);
3.row_number删除方法
explain analyze delete from deltest a where a.ctid = any(array (select ctid from (select row_number() over (partition by id), ctid from deltest) t where t.row_number > 1));


根据某个字段分组删除重复数据，只保留日期最大的一条，建议使用窗口函数效率更高
```

[删除重复数据](https://blog.csdn.net/arcticJian/article/details/50042647)

## 8.连表更新

```sql
（1）update db_zxzhld_bak.t_zhld_zbajxx set d_larq = 
(select larq from db_zxzhld_bak.cacheTable where db_zxzhld_bak.t_zhld_zbajxx.c_ajbh = db_zxzhld_bak.cacheTable.c_ajbh) where c_zblx in ('2001','2002');
更新757726条数据耗时3h。

（2）update db_zxzhld_bak.t_zhld_zbajxx t1 set d_larq = t.larq from db_zxzhld_bak.cacheTable t where t.c_ajbh = t1.c_ajbh AND t1.c_zblx in ('2001','2002');
修改过后的sql耗时6.5s

第一个sql查询其实是一个循环查询，特别耗时，类似于:
select c_bh,(select d_larq from t2) as larq from t1 ,嵌套循环。
```

## 9.nulls last,和null first

```sql
默认情况下，执行器认为Null值要大于所有值，所以，简单的如 dt_qzsj desc降序排序会把所有的null排在最前面，dt_qzsj asc会将null排在最后面。
某些情况下使用dt_qzsj desc需要将null值放到最后，如下：

explain analyze 
SELECT
	qzsq.c_id sqId,
	...
FROM
	ywst.t_qzsq qzsq
LEFT JOIN ywst.t_qzst_ws ws ON qzsq.c_id_ws = ws.c_id
LEFT JOIN ywst.t_qzst_aj aj ON qzsq.c_id_aj = aj.c_id
WHERE
	qzsq.n_qzzt = 4
ORDER BY dt_qzsj DESC  LIMIT 10 OFFSET 0

创建了索引create index i_t_qzsq_dt_qzsj on ywst.t_qzsq(dt_qzsj desc last);

虽然创建了索引，但是并没有走索引，需要在sql中也加入nulls last才行，正确的写法：ORDER BY dt_qzsj DESC nulls last   LIMIT 10 OFFSET 0
```

## 10.有关日期的查询

### 1.获取月份

```sql
select EXTRACT(YEAR FROM ((CURRENT_DATE-1)::date))::VARCHAR||
CASE WHEN EXTRACT(MONTH FROM (CURRENT_DATE-1)::date)<10 then '0'||(EXTRACT(MONTH FROM(CURRENT_DATE-1)::date))::VARCHAR else (EXTRACT(MONTH FROM(CURRENT_DATE-1)::date))::VARCHAR end;

该条sql如此复杂，只是为了获取当前月份，月份可以用下面的to_char获取
select to_char(current_date,'YYYYMM');
```

另外该sql还有大小写问题，建议关键字全小写。

### 2.对字段使用函数

```sql
to_char(cw.d_cjsj, 'yyyy-MM') >= to_char((now() - INTERVAL '1 years' + INTERVAL '1 months'),'yyyy-MM')
该条sql
修改后：cw.d_cjsj >= '2017-08-01 00:00:00'

对字段使用to_char后，不能使用默认索引。
```

### 3.对字段使用函数

```sql
 to_char(dt_tskssj, 'yyyy-MM') = to_char(now(), 'yyyy-MM') 
修改后：
 dt_tskssj>='2018-08-01 00:00:00.000' and dt_tskssj < '2018-08-31 24:00:00.000'

同实例2，该sql可以直接传入日期查询。
```

### 4.使用like获取当月数据 

```sql
explain analyze 
select count(*) from t_wj where to_char(d_crsj,'yyyymmdd') like '%201803%';--768ms
Aggregate (cost=26658.85..26658.86 rows=1 width=0)
	->  Index Only Scan using t_wj_i_crsj on t_wj 	(cost=0.42..26658.33 rows=205 width=0)
				Filter: (to_char(d_crsj, 'yyyymmdd'::text) ~~ '%201803%'::text)

explain analyze 
select count(*) from t_wj where d_crsj>'20180301' and d_crsj < '20180401'; --0.069ms
Aggregate (cost=1002.18..1002.19 rows=1 width=0)
	-> Index Only Scan using t_wj_i_crsj on t_wj (cost=0.42..990.34 rows=4738 width=0)
				Index Cond: ((d_crsj >= '2018-03-01 00:00:00'::timestamp without time zone) AND (d_crsj < '2018-04-01 00:00:00'::timestamp without time zone))
```

### 5.字段顺序不规范 

```sql
1.不规范写法
select *from db_yzgl.t_zfxx where '2018-06-17 11:07:22.694' <= dt_create_time
2.正常写法
select *from db_yzgl.t_zfxx where dt_create_time>'2018-06-17 11:07:22.694' 

两种写法其实效果一样，但是如果是涉及到字段的计算或者对字段使用了函数，则会影响使用索引。
```

## 11.count

### 1.建议使用count(*)

```sql
平时写count()语句时，括弧里面写的是什么？ count(*)？count(1)？count(主键)? 有对比过他们的效率，看过执行计划吗？
针对上面疑问，楼主做了实验，并得出以下结论：

1、abase执行计划：count(*)、count(1)是选取了一个整型索引字段进行查询的。
2、sybase执行计划：count(*)、count(1)、count(主键)是选取了一个整型索引字段进行查询的。
3、abase执行效率：count(*)>=count(1)>=count(整型索引字段)>count(字符索引字段)>count(字符主键)>count(整型非索引字段)
4、sybase执行效率：count(*)=count(1)=count(整型主键)>count(整型索引字段)>count(字符索引字段)>count(整型非索引字段)
5、abase与sybase的count() 括号里面都是是判断是否为空的，空则不参与计算（李贵阳曰）
6、非特殊场景查询，统一要求使用count(*)

```



2.查询大量的数据分页，求count(*)

```
查询几百万的数据用以分页，求count，造成查询缓慢，耗费资源。
```

## 12.对表设计不熟悉

```sql
优化前：
SELECT
	COUNT (DISTINCT cwjb.c_bh) cwsl
FROM
	db_sacw.t_aj_ajjbxx ajjb,
	db_sacw.t_aj_ajfbxx ajfb,
	db_sacw.t_cw_cwjbxx cwjb,
	db_sacw.t_cw_cwfbxx cwfb
WHERE
	ajjb.c_bh = cwjb.c_ajbh
AND ajjb.c_bh = ajfb.c_ajbh
AND cwjb.c_bh = cwfb.c_cwbh

修改后sql：
select count(*) from db_sacw.t_cw_cwjbxx cwjb;

此例主要说明在写sql的过程中最好了解表的设计，表间关系，原本可以直接从一个表里面获得的数据，经过大量的连表查询耗时几十秒。
```

## 13.频繁的查询

```sql
序号 : 1 
最长运行时间 : 44ms 
执行次数 : 358186
平均执行时间 : 1ms 
最早运行日期 : 2019-01-15 00:08:35.999 
最晚运行日期 : 2019-01-15 21:28:31.0 
PSQL内容 :  
select c_bmid from db_uim.t_ywgy_qx_rysj where c_corpid is null and c_ryid=? and c_sysid=?

除了参数不一样，在短时间内，对一张表大量的执行同一条sql。
```



## 14.=null问题

```
null只能使用is null和is not null来判断
```



[比较操作符](http://www.postgres.cn/docs/10/functions-comparison.html)

## 15.order by使用索引问题

```sql
如果order by要用上索引，那么必须order by的写法要与创建索引时指定的顺序一致。

例如select * from tbl where a=? order by a,b desc nulls last;
```

## 16.数据加压问题

```sql
加压数据分布不均，如时间，类型等不均。造成查询缓慢。
```

## 17.长事务问题

```sql
长事务导致数据库缓慢，select * from pg_stat_activity ;
可以设置数据库参数：idle_in_transaction_session_timeout为60s
```

[idle_in_transaction](https://segmentfault.com/a/1190000007397841)

## 18.sqlfx分析出大量的慢sql均为同一条sql仅参数不同

```sql
原因是没有升级log4jdbc,导致没有统计psql
```

## 19.表缺少主键和逻辑外键索引

```
表必须有主键，逻辑外键必须添加索引。避免全表扫描，嵌套循环
```

## 20.定时任务

```sql
多个开发环境同时执行定时任务，慢sql更加慢的问题。建议只开一个，其他都关闭。
```

## 21.使用exists替换distinct

```sql
and c_ajbh  in (select distinct c_ajbh from db_zxzhld.t_zhld_zbajxx where n_dbzt = 1 and c_zblx = '1003' and c_gy = '2550' ) 
改写为：
and exists (select  c_ajbh from db_zxzhld.t_zhld_zbajxx where n_dbzt = 1 and c_zblx = '1003' and c_gy = '2550' ) 

一旦满足条件则立刻返回。所以使用exists的时候子查询可以直接去掉distinct。从执行计划来看使用exists可以消除分组，提高效率。
```



##22.count(distinct xx)改写		

```sql
Select count(distinct c_ajbh) from t_aj
改写后：
Select count(*) from (select distinct c_ajbh from t_aj where ...)t2
```

