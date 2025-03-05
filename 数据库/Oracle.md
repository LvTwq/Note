```sql
-- 创建schema
CREATE USER HJ_GW IDENTIFIED BY oracle;

-- 授予基本权限
GRANT CREATE SESSION TO HJ_GW;
GRANT CREATE TABLE TO HJ_GW;
GRANT CREATE SEQUENCE TO HJ_GW;
GRANT CREATE VIEW TO HJ_GW;
GRANT CREATE PROCEDURE TO HJ_GW;

-- 创建tablespace
create tablespace ZHXT_SYS
    datafile 'zhxt.dbf' size 10M;

-- 授予用户 HJ_GW 在表空间 ZHXT_SYS 中的无限配额
ALTER USER HJ_GW QUOTA UNLIMITED ON ZHXT_SYS;

SELECT s.sid, s.serial#, q.sql_text
   FROM v$session s
   JOIN v$sqlarea q ON s.sql_id = q.sql_id;

ALTER SYSTEM KILL SESSION 'dis,serial#';
```
