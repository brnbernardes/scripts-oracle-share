----------------------------------------
prompt SGA_INF.SQL - System Global Area INFORMATION
set lines 2000
set pages 100
set echo off
Set serveroutput on size 1000000
alter session set nls_date_format='dd-mon-yy hh24:mi:ss';

column inst_id format 99
column name format a32
column value format a10
BREAK on inst_id
Select inst_id, name, to_number(value)/1024/1024 Mbytes
 from gv$parameter
 where upper(name) in ('SGA_MAX_SIZE','SGA_TARGET', 'PGA_AGGREGATE_LIMIT', 'PGA_AGGREGATE_TARGET', 'MEMORY_MAX_TARGET', 'MEMORY_TARGET', 'DB_CACHE_SIZE')
 order by inst_id, name;
 
Select inst_id, name, value
 from gv$parameter
 where upper(name) in ('SHARED_POOL_SIZE','JAVA_POOL_SIZE','JAVA_POOL_SIZE','STREAMS_POOL_SIZE')
 order by inst_id, name;
 
 
CLEAR BREAKS
 