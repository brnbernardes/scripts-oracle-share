--------------------------------------------------------------------------------------------------
-- AutoTasks:
/*
Automatic SQL Tuning Advisor Task Does Not Run At PDB Level (Doc ID 2538576.1)
SQL TUNING ADVISOR só pode ser executado pelo CDB
*/

--------------------------------------------------------------------------------------------------
-- Features
-- You should check AWR and SQL Tuning Pack usage:
select * from dba_feature_usage_statistics where name like 'Au%W%R%';
select * from dba_feature_usage_statistics where name like 'SQL%T%A%';
select * from dba_feature_usage_statistics where name like 'A%W%R%';

-- You should also check control_management_pack_access parameter and disable if it’s not “NONE”:
select value from v$parameter where name like 'control_management_pack_access';


--------------------------------------------------------------------------------------------------
-- Advisor: 
SELECT * FROM dba_advisor_execution_types;

SELECT task_name, parameter_name, parameter_value, is_default, description
  FROM dba_advisor_parameters
 WHERE task_name like 'SYS_AUTO_SQL_TUNING_TASK'
 ORDER BY parameter_name;

SELECT * FROM dba_advisor_tasks WHERE task_name  LIKE 'SYS_AUTO_SQL_TUNING_TASK' ORDER BY created DESC;

SELECT * FROM dba_advisor_log WHERE task_name  like 'SYS_AUTO_SQL_TUNING_TASK';

SELECT * FROM dba_advisor_executions WHERE task_name  like 'SYS_AUTO_SQL_TUNING_TASK' ORDER BY execution_start DESC;


--------------------------------------------------------------------------------------------------
-- Autotask

SELECT client_name, status, attributes FROM dba_autotask_client;

SELECT window_name, autotask_status, optimizer_stats
  FROM dba_autotask_window_clients;

SELECT * FROM dba_autotask_schedule ORDER BY start_time;

SELECT * FROM dba_scheduler_window_groups;

SELECT owner,
       window_name,
       resource_plan,
       schedule_owner,
       schedule_name,
       schedule_type,
       start_date,
       repeat_interval,
       end_date duration,
       window_priority,
       to_char(next_start_date),
       to_char(last_start_date),
       enabled,
       active,
       manual_open_time,
       manual_duration,
       comments
  FROM dba_scheduler_windows;

SELECT log_id,
       log_date, 
       owner, 
       window_name,
       to_char(req_start_date),
       to_char(actual_start_date),
       window_duration,
       actual_duration,
       instance_id,
       additional_info
  FROM dba_scheduler_window_details;



-- Auto Task -> sql tuning advisor
-- Enable 
BEGIN
  dbms_auto_task_admin.enable(client_name => 'sql tuning advisor', operation => NULL, window_name => NULL);
END;
/

-- Disable 
BEGIN
  dbms_auto_task_admin.disable(client_name => 'sql tuning advisor', operation => NULL, window_name => NULL);
END;
/

-- SQL Tuning Advisor @ cdb
SELECT con_id,
       (SELECT NAME FROM v$pdbs WHERE con_id = ac.con_id) con_name,
       client_name,
       status
  FROM cdb_autotask_client ac
WHERE client_name = 'sql tuning advisor'
 ORDER BY 1,2,3;

-- List parameters @ cdb
SELECT task_name, parameter_name, parameter_value, is_default, description
  FROM dba_advisor_parameters
 WHERE task_name like 'SYS_AUTO_SQL_TUNING_TASK'
 ORDER BY parameter_name;

-- Define parameters @ cdb
BEGIN
  DBMS_SQLTUNE.set_tuning_task_parameter('SYS_AUTO_SQL_TUNING_TASK', 'LOCAL_TIME_LIMIT', 3600);
  DBMS_SQLTUNE.set_tuning_task_parameter('SYS_AUTO_SQL_TUNING_TASK', 'ACCEPT_SQL_PROFILES', 'FALSE');
  DBMS_SQLTUNE.set_tuning_task_parameter('SYS_AUTO_SQL_TUNING_TASK', 'MAX_SQL_PROFILES_PER_EXEC', 60);
  DBMS_SQLTUNE.set_tuning_task_parameter('SYS_AUTO_SQL_TUNING_TASK', 'MAX_AUTO_SQL_PROFILES', 10000);
  DBMS_SQLTUNE.set_tuning_task_parameter('SYS_AUTO_SQL_TUNING_TASK', 'TIME_LIMIT', 18000);
END;
/


Quando o SQL Tuning Advisor é executado na tarefa automática na janela de manutenção, o seu foco principal é para as instruções SQL de alta carga, baseado em 4 períodos diferentes: 
- Na semana passada 
- Em qualquer dia da semana passada
- Em qualquer hora do semana passada
- Em um único tempo de resposta. 

Ele verifica as instruções de alta carga com base tanto no tempo de CPU como no de I/O. Ambos os tempos de CPU e I/O devem que ser melhores, mesmo que apenas um deles apresente melhor resultado, o Oracle ignora o plano para o SQL Profile. 
Ao verificar se deve ou não criar um “sql profile” para a instrução, ele e verifica se a instrução pode ser melhorada 3 vezes mais do que a execução original, por isso se a instrução ficar três vezes melhor do que a original, 
olhando juntos para os benefícios de CPU e I/O, ele recomenda a aceitação do sql profile. 



-- Report Auto Tuning Task @ cdb
DECLARE
  my_rept CLOB;
  PROCEDURE print_clob(p_clob IN CLOB) IS
    v_offset     NUMBER DEFAULT 1;
    v_chunk_size NUMBER := 10000;
  BEGIN
    LOOP
      EXIT WHEN v_offset > dbms_lob.getlength(p_clob);
      dbms_output.put_line(dbms_lob.substr(p_clob, v_chunk_size, v_offset));
      v_offset := v_offset + v_chunk_size;
    END LOOP;
  END print_clob;
BEGIN
  dbms_output.enable(NULL);
  my_rept := dbms_sqltune.report_auto_tuning_task(begin_exec => NULL,
                                                  end_exec => NULL,
                                                  TYPE => 'TEXT',
                                                  LEVEL => 'TYPICAL',
                                                  section => 'ALL',
                                                  object_id => NULL,
                                                  result_limit => NULL);
  print_clob(my_rept);
END;
/

SELECT * FROM DBA_AUTOTASK_CLIENT_HISTORY;
SELECT * FROM DBA_AUTOTASK_CLIENT_JOB;
SELECT * FROM DBA_AUTOTASK_JOB_HISTORY;
SELECT * FROM DBA_AUTOTASK_OPERATION;
SELECT * FROM DBA_AUTOTASK_SCHEDULE;
SELECT * FROM DBA_AUTOTASK_TASK;
SELECT * FROM DBA_AUTOTASK_WINDOW_CLIENTS;
SELECT * FROM DBA_AUTOTASK_WINDOW_HISTORY;

--------------------------------------------------------------------------------------------------
-- SQL Profiles
SELECT con_id,
       (SELECT NAME FROM v$pdbs WHERE con_id = sp.con_id) con_name,
       NAME,
       sql_text,
       category,
       status
  FROM cdb_sql_profiles sp;
  
--------------------------------------------------------------------------------------------------
-- Window Maintence: 

-- Execute
DECLARE
  l_return VARCHAR2(50);
BEGIN
  l_return := DBMS_AUTO_SQLTUNE.execute_auto_tuning_task;
  DBMS_OUTPUT.put_line(l_return);
END;
/

-- Cancel Execute
BEGIN
 DBMS_SQLTUNE.CANCEL_TUNING_TASK('SYS_AUTO_SQL_TUNING_TASK');
END;
/

BEGIN
  DBMS_SCHEDULER.disable(
    name  => 'SYS.MAINTENANCE_WINDOW_GROUP',
    force => TRUE);

  DBMS_SCHEDULER.enable(
    name  => 'SYS.MAINTENANCE_WINDOW_GROUP');
END;
/

  
  
select substr(comp_name,1,30) comp_name, substr(comp_id,1,10) comp_id,substr(schema,1,12) schema,substr(version,1,12) version,status from dba_registry;  

 

