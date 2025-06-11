-- Criação do SQL Tuning Task
DECLARE
ret_val VARCHAR2(4000);
BEGIN
ret_val := dbms_sqltune.create_tuning_task(task_name=>'&Task_name', sql_id=>'&sql_id', time_limit=>&time_limit);
dbms_sqltune.execute_tuning_task('&Task_name');
END;
/

-- Criação do SQL Tuning task, vou utilizar as informações encontradas no AWR, 
--então irei informar o snap_id inicial e final para identificar o período em que o SQL foi executado
DECLARE
   l_sql_tune_task_id  VARCHAR2(100);
 BEGIN
   l_sql_tune_task_id := DBMS_SQLTUNE.create_tuning_task (
                           begin_snap  => 43996,
                           end_snap    => 43997,
                           sql_id      => '2sk15bdfc6gaf',
                           scope       => DBMS_SQLTUNE.scope_comprehensive,
                           time_limit  => 1200,
                           task_name   => '2sk15bdfc6gaf_AWR_tuning_task',
                           description => 'Tuning task for statement 2sk15bdfc6gaf in AWR.');
   DBMS_OUTPUT.put_line('l_sql_tune_task_id: ' || l_sql_tune_task_id);
 END;
 /

-- Recomendações geradas pelo SQL Tuning Task
SELECT DBMS_SQLTUNE.report_tuning_task('&Task_name') AS recommendations FROM dual;

-- Interrompendo e reassumindo a execução
 EXEC DBMS_SQLTUNE.interrupt_tuning_task (task_name => '&Task_name');
 EXEC DBMS_SQLTUNE.resume_tuning_task (task_name => '&Task_name'); 
 
 -- Cancelando o SQL tuning task. 
 EXEC DBMS_SQLTUNE.cancel_tuning_task (task_name => '&Task_name'); 
 
 -- Reiniciando o SQL Tuning Task, permintindo sua execução novamente. 
 EXEC DBMS_SQLTUNE.reset_tuning_task (task_name => '&Task_name')