----------------------------------------------------------------------------------------------------------------------------------
-- Tuning Task: AWR + SQL_ID 
DECLARE
  v_snap_min NUMBER;
  v_snap_max NUMBER;
  v_task_name VARCHAR2(30);
BEGIN  
  SELECT MIN(sql.snap_id), MAX(sql.snap_id)
    INTO v_snap_min, v_snap_max
  FROM dba_hist_sqlstat sql
 INNER JOIN dba_hist_snapshot ss
    ON ss.snap_id = sql.snap_id
 WHERE sql.sql_id = '&SQL_ID'
 AND ss.begin_interval_time >= trunc(SYSDATE)-30 ; 
 
BEGIN
 DBMS_SQLTUNE.drop_tuning_task (task_name => 'Task_name-&SQL_ID');
EXCEPTION 
  WHEN OTHERS THEN
    NULL;
END;

  v_task_name := DBMS_SQLTUNE.create_tuning_task(
                   sql_id      => '&SQL_ID',  -- Substitua pelo SQL_ID da sua query
                   begin_snap  => v_snap_min,             -- Substitua pelo ID do snapshot de início (opcional)
                   end_snap    => v_snap_max,             -- Substitua pelo ID do snapshot de fim (opcional)
                   scope       => 'COMPREHENSIVE',
                   time_limit  => 600,               -- Limite de tempo para a análise em segundos
                   task_name   => 'Task_name-&SQL_ID',  -- Nome da tarefa
                   description => 'Tuning task for specific query in AWR'
                 );

  DBMS_OUTPUT.put_line('Tuning Task Created: ' || v_task_name);
END;
/


-- Report:
SELECT dbms_sqltune.report_tuning_task(task_name => 'Task_name-&SQL_ID') AS recommendations FROM dual;


--Ordenado de PLAN_HASH por menor AVG_ELAPSED
SELECT /*+ PARALLEL(4)*/
 parsing_schema_name,
 module,
 sql_id,
 plan_hash_value,
 SUM(executions_total) AS executions,
 round((SUM(elapsed_time_total) / SUM(executions_total)) / 1e6, 4) avg_et,
 row_number() over(PARTITION BY sql_id ORDER BY SUM(elapsed_time_total) / SUM(executions_total) ASC) AS rn
  FROM dba_hist_sqlstat a
  JOIN dba_hist_snapshot b
    ON (a.snap_id = b.snap_id AND a.instance_number = b.instance_number)
 WHERE a.executions_total > 0
   AND a.plan_hash_value > 0
   AND b.begin_interval_time >= trunc(SYSDATE) - 30
    AND a.sql_id = '6csw3d3n2f74j'
 GROUP BY parsing_schema_name, module, sql_id, plan_hash_value
 ORDER BY sql_id, avg_et;

-- SQL Hist 
SELECT s.snap_id,
       sql_id,
       to_char(begin_interval_time, 'Dd-Mon-Yy Hh24:Mi') beg,
       s.parsing_schema_name SCHEMA,
       s.plan_hash_value phv,
       executions_delta execs,
       rows_processed_delta rowsp,
       round(elapsed_time_delta / 1000000 / 60,2) "Total Delta Mins",
       round(elapsed_time_delta / (executions_delta + .01)) "Time per exec µs"
  FROM dba_hist_sqlstat s, dba_hist_snapshot t
 WHERE sql_id IN ('6csw3d3n2f74j')
   AND s.instance_number = t.instance_number
   AND s.snap_id = t.snap_id
   AND executions_delta > 1
 ORDER BY 1 DESC;