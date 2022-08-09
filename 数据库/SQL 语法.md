[TOC]

## UNION 和 UNION all 的区别

1、对重复结果的处理：UNION在进行表链接后会筛选掉重复的记录，Union All不会去除重复记录
2、对排序的处理：Union将会按照字段的顺序进行排序；UNION ALL只是简单的将两个结果合并后就返回

![](..\images\union.png)
![](..\images\union2.png)
![](..\images\union3.png)


要查询两个字段，并且根据其中一个字段对另一个进行处理

```sql
        SELECT
        wtxs.c_xszt cXszt,
        fb.c_jhfs cJhfs,
```

要求：当cJhfs=6时，将cXszt置为11

通过 case when then else end as：

举例：

| NAME | SCORE |
| ---- | ----- |
| 张三 | 52    |
| 李四 | 70    |
| 王五 | 98    |

想要根据分数自动判定学生成绩的等级：

```sql
selest name,
	case 
		when score > 90 then '优秀'
		when score < 60 then '不及格'
		else '良好'
		end as rank
from xxxxx
```

| name | rank   |
| ---- | ------ |
| 张三 | 不及格 |
| 李四 | 良好   |
| 王五 | 优秀   |



```sql
CASE
WHEN fb.c_jhfs != '6' THEN
	wtxs.c_xszt
ELSE
	'11'
END cXszt,
```

如果fb.c_jhfs不等于6，就将wtxs.c_xszt作为cXszt，否则将11作为cXszt的值。





## limit 和 offset 的区别

都是用于限制查询结果返回的数量

postgresql不支持LIMIT #，#语法

* limit x 表示读取 x 条数据
* limit x,y 表示跳过前 x 条数据，读取 y 条数据
* limit y offset x 
  * 从第x条（不包括），取出y条数据

```sql
-- 从第0个开始，获取20条数据
select * from testtable limit 0, 20; 
select * from testtable limit 20 offset 0;    
```







# PostgreSql

若某字段为null，则设置为0

```sql
select COALESCE(字段, 0) as price from 表名
```

