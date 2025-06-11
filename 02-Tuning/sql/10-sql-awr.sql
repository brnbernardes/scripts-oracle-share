-- SQL
SELECT (SELECT name FROM v$pdbs WHERE con_id = v$sql.con_id) pdb,
       parsing_schema_name SCHEMA,
       child_number child,
       sql_id,
       PLAN_HASH_VALUE,
       optimizer_cost,
       executions,
       round(elapsed_time / executions / 1000000, 2) avg_elapsed_time,
       disk_reads,
       buffer_gets,
       parse_calls / executions,
       sharable_mem,
       round(cpu_time / executions, 2) avg_cpu, 
       sql_text,
       sql_fulltext,
       last_active_time,
       last_load_time,
       (SELECT object_name FROM dba_objects WHERE object_id = program_id) object_id,
       program_line#,
       'SELECT * FROM TABLE(dbms_xplan.display_cursor(sql_id=> '''|| sql_id 
                                                      || ''',cursor_child_no => ' 
                                                      || child_number || ', format=>''ADVANCED ALLSTATS LAST +PEEKED_BINDS''));' dbms_xplan
  FROM v$sql
 WHERE sql_id = 'gjs1fgjhhxgbt' 
ORDER BY last_active_time ;

--SQL Hist
SELECT s.snap_id,
       sql_id,
       to_char(begin_interval_time, 'Dd-Mon-Yy-Hh24:Mi') beg,
       s.parsing_schema_name SCHEMA,
       s.plan_hash_value phv,
       executions_delta execs,
       rows_processed_delta rowsp,
       round(elapsed_time_delta / 1000000 / 60,2) "Total Delta Mins",
       round(elapsed_time_delta / (executions_delta + .01)) "Time per exec µs"
  FROM dba_hist_sqlstat s, dba_hist_snapshot t
 WHERE sql_id IN ('gjs1fgjhhxgbt')
   AND s.instance_number = t.instance_number
   AND s.snap_id = t.snap_id
   AND executions_delta > 1
 ORDER BY 1 DESC;

-- Binds
SELECT sql_id,
       child_number,
       position,
       datatype_string,
       NAME,  
       value_string,
       last_captured
  FROM v$sql_bind_capture
 WHERE sql_id = 'gjs1fgjhhxgbt';

-- Bind Hist
SELECT datatype_string, max_length, name, value_string, con_id, (SELECT NAME FROM v$pdbs WHERE con_id = dba_hist_sqlbind.con_id) PDB
  FROM dba_hist_sqlbind
 WHERE sql_id = 'gjs1fgjhhxgbt'
   AND last_captured = (SELECT MAX(last_captured)
                          FROM dba_hist_sqlbind
                         WHERE sql_id = 'gjs1fgjhhxgbt')
 ORDER BY NAME;

-- Diplay Plan Time (dplant)
SELECT id
       ,LPAD (' ', DEPTH) || operation operation
       ,options
       ,last_elapsed_time "ACTUAL_TIME (Micro)"
       ,to_char(last_elapsed_time / 1000000) "ACTUAL_TIME (Seg)"
       ,object_name
       ,last_starts
       ,last_output_rows actual_rows 
       ,s.last_cr_buffer_gets buffers
  FROM v$sql_plan_statistics_all s
 WHERE sql_id = '60xvnjj0fw2wh'
   AND child_number = 0;
