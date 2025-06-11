--SQL Hist
/*
col schema for a5
col begin_interval_time for a21
col end_interval_time for a21
COL execs FOR a6
SET COLSEP ' | '
*/
SELECT s.con_id,
       s.snap_id,
       sql_id,
       begin_interval_time,
       end_interval_time,
       s.parsing_schema_name SCHEMA,
       s.plan_hash_value phv,
       executions_delta execs,
       s.rows_processed_delta  "ROWS",
       round(elapsed_time_delta / 1000000 / 60,2) "TOTAL_DELTA (Min)",
       round(elapsed_time_delta / (NVL(executions_delta,1))) "TIME_PER_EXEC_DELTA (Micro)"
  FROM dba_hist_sqlstat s, dba_hist_snapshot t
 WHERE sql_id IN ('gty4w37ht1cd3')
   AND s.instance_number = t.instance_number
   AND s.snap_id = t.snap_id
   AND executions_delta > 1
   AND TRUNC(begin_interval_time) >= TRUNC(SYSDATE-2) 
 ORDER BY begin_interval_time DESC, end_interval_time DESC;