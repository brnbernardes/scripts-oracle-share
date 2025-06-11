-- SQL
SELECT parsing_schema_name SCHEMA,
       child_number child,    
       sql_id,
       (SELECT command_name FROM v$sqlcommand WHERE command_type = v$sql.command_type) commnand,
       plan_hash_value,
       optimizer_cost,
       executions,
       round(elapsed_time / decode(executions,0,1,executions) / 1000000, 2) avg_elapsed_time,
       disk_reads,
       buffer_gets,
       parse_calls / decode(executions,0,1,executions)ecutions,
       sharable_mem,
       round(cpu_time / decode(executions,0,1,executions), 2) avg_cpu, 
       sql_text,
       sql_fulltext,
       last_active_time,
       last_load_time,
       program_id,
       program_line#,
       'set pages 9999'|| chr(10) ||
       'col plan_table_output for a300' || chr(10) ||
       'SELECT plan_table_output FROM TABLE(dbms_xplan.display_cursor(sql_id=> '''|| sql_id 
                                                      || ''',cursor_child_no => ' 
                                                      || child_number || ', format=>''TYPICAL +predicate +outline +projection ALLSTATS LAST +PEEKED_BINDS''));' dbms_xplan                                                      
  FROM v$sql
 WHERE sql_id = 'g82z20npnmspj' 
  --OR (sql_text LIKE '%DBA_THEMA: Teste %' AND sql_text NOT LIKE '%v$sql%')  
ORDER BY last_active_time ;