SELECT * FROM v$pdbs;

SELECT *
  FROM dba_hist_sqltext
 WHERE sql_id = '93pg4m23js06m'
   AND con_id = 11;
   
SELECT *
  FROM dba_hist_sqlstat 
 WHERE sql_id = '93pg4m23js06m'
   AND con_id = 11;

SELECT sql.snap_id,
       ss.begin_interval_time,
       ss.end_interval_time,
       sql.sql_id,
       sql.plan_hash_value,
       sql.optimizer_cost,
       sql.optimizer_mode,
       sql.optimizer_env_hash_value,
       sql.sharable_mem,
       sql.module,
       sql.action,
       sql.sql_profile,
       sql.sorts_total,
       sql.executions_total,
       sql.px_servers_execs_total,
       sql.loads_total,
       sql.invalidations_total,
       sql.parse_calls_total,
       sql.disk_reads_total,
       sql.buffer_gets_total,
       sql.rows_processed_total,
       sql.cpu_time_total,
       sql.elapsed_time_total,
       sql.iowait_total,
       sql.clwait_total,
       sql.ccwait_total,
       sql.direct_writes_total,
       sql.physical_read_requests_total,
       sql.physical_read_bytes_total,
       sql.physical_write_requests_total,
       sql.physical_write_bytes_total,
       sql.optimized_physical_reads_total,
       sql.cell_uncompressed_bytes_total,
       sql.io_offload_return_bytes_total
  FROM dba_hist_sqlstat sql
 INNER JOIN dba_hist_snapshot ss
    ON ss.snap_id = sql.snap_id
 WHERE sql.sql_id = '93pg4m23js06m'
   AND sql.con_id = 11
ORDER BY 1; 

DECLARE
  v_task_name VARCHAR2(30);
BEGIN
  v_task_name := DBMS_SQLTUNE.create_tuning_task(
                   sql_id      => '&SQL_ID',  -- Substitua pelo SQL_ID da sua query
                   begin_snap  => 3419,             -- Substitua pelo ID do snapshot de início (opcional)
                   end_snap    => 3430,             -- Substitua pelo ID do snapshot de fim (opcional)
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