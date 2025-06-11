--Top SQLs
/*
High I/O: order by DISK_READS desc;
High CPU: order by BUFFER_GETS desc;
Poor parsing applications: order by PARSE_CALLS / EXECUTIONS;
Memory hogs: order by SHARABLE_MEM desc;
*/
SELECT * FROM (
SELECT parsing_schema_name SCHEMA,
       child_number CHILD,
       sql_id,
       optimizer_cost,       
       executions,
       round(elapsed_time/executions/1000000,2) avg_elapsed_time,
       disk_reads,
       buffer_gets,
       --parse_calls/executions,
       --sharable_mem,       
       round(cpu_time /executions,2) avg_cpu,       
       sql_text,
       sql_fulltext,
       last_active_time,
       last_load_time,
       program_id,
       program_line#
  FROM v$sql s
 WHERE executions > 0
 AND optimizer_cost >0)
WHERE avg_elapsed_time > 0
AND SCHEMA  IN ('ERP', 'ERP_ADB')
 ORDER BY avg_elapsed_time DESC;

SELECT PROGRAM_ID, PROGRAM_LINE#
  FROM   v$sql
WHERE  sql_id = 'ff35fbgz27513';

SELECT * FROM dba_objects WHERE object_id = :program_id


-- Full table scan
SELECT o.owner,
       o.object_name,
       o.object_type,
       t.num_rows,
       t.last_analyzed,
       s.sql_id,
       s.sql_id,
       s.sql_text,
       round(elapsed_time / executions / 1000000, 2) avg_elapsed_time
  FROM v$sql_plan sp
 INNER JOIN dba_objects o
    ON sp.object_owner = o.owner
   AND sp.object_name = o.object_name
 INNER JOIN v$sql s
    ON sp.sql_id = s.sql_id
   AND sp.address = s.address
   AND sp.hash_value = s.hash_value
  LEFT JOIN dba_tables t
    ON sp.object_owner = t.owner
   AND sp.object_name = t.table_name
 WHERE operation = 'TABLE ACCESS'
   AND options = 'FULL'
   AND object_owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'CTXSYS')
   AND t.num_rows IS NOT NULL
 ORDER BY num_rows DESC;