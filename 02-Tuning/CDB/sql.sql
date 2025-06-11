-- SQL
SELECT (SELECT name FROM v$pdbs WHERE con_id = v$sql.con_id) pdb,
       parsing_schema_name SCHEMA,
       child_number child,
       sql_id,
       (SELECT command_name FROM v$sqlcommand WHERE command_type = v$sql.command_type) commnand,
       plan_hash_value,
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
       program_id,
       program_line#,
       'SELECT * FROM TABLE(dbms_xplan.display_cursor(sql_id=> '''|| sql_id 
                                                      || ''',cursor_child_no => ' 
                                                      || child_number || ', format=>''TYPICAL ALLSTATS LAST +PEEKED_BINDS''));' dbms_xplan
  FROM v$sql
 WHERE sql_id = 'g82z20npnmspj' 
ORDER BY last_active_time ;

-- SQL Hist
SELECT (SELECT name FROM v$pdbs WHERE con_id = s.con_id) pdb,
       s.snap_id,
       sql_id,
       begin_interval_time,
       end_interval_time,
       s.parsing_schema_name SCHEMA,
       s.plan_hash_value phv,
       executions_delta execs,
       round(elapsed_time_delta / 1000000 / 60,2) "TOTAL_DELTA (Min)",
       round(elapsed_time_delta / (NVL(executions_delta,1))) "TIME_PER_EXEC_DELTA (Micro)",
       s.buffer_gets_delta,
       s.cpu_time_delta
  FROM dba_hist_sqlstat s, dba_hist_snapshot t
 WHERE s.instance_number = t.instance_number
   AND s.snap_id = t.snap_id
   AND executions_delta > 1
   --AND begin_interval_time >= TO_DATE('18/12/2024 14', 'DD/MM/YYYY HH24')
   --AND begin_interval_time <= TO_DATE('18/12/2024 15', 'DD/MM/YYYY HH24')
   --AND TRUNC(begin_interval_time) >= TRUNC(SYSDATE-2)    
   AND sql_id IN ('ga5dc810ynpuz')
 ORDER BY cpu_time_delta DESC;
