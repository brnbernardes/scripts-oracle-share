--> AUTOMATIC SQL PLAN MANAGEMENT
-- https://blogs.oracle.com/optimizer/post/what-is-automatic-sql-plan-management-and-why-should-you-care


-- SPM Automatic: Status 
SELECT parameter_name, parameter_value spm_status
FROM   dba_sql_management_config 
WHERE  parameter_name = 'AUTO_SPM_EVOLVE_TASK';

-- SPM Automatic: Parameters (SYS_AUTO_SPM_EVOLVE_TASK): 
-- Importante: ACCEPT_PLANS, ALTERNATE_PLAN_BASELINE, ALTERNATE_PLAN_LIMIT, ALTERNATE_PLAN_SOURCE,  TIME_LIMIT
SELECT parameter_name, parameter_value
FROM   dba_advisor_parameters
WHERE  task_name = 'SYS_AUTO_SPM_EVOLVE_TASK'
AND    parameter_value <> 'UNUSED';

-- Scheduler: Status
-- A ativacao DBMS_SPM.CONFIGURE('AUTO_SPM_EVOLVE_TASK','ON') cria as linhas para "Auto SPM Task"  e "Auto STS Capture Task"
SELECT *
FROM   dba_autotask_schedule_control 
WHERE  dbid = sys_context('userenv','con_dbid') 
AND    task_name in ('Auto SPM Task', 'Auto STS Capture Task'); 

-- Scheduler: Executions (high-frequency execution_name like SYS_SPM%)
SELECT *
  FROM dba_advisor_executions
 WHERE task_name LIKE '%SPM%';

-- Report:
SELECT DBMS_SPM.report_auto_evolve_task FROM  dual;

-- Baselines:
SELECT *
  FROM dba_sql_plan_baselines
 WHERE created >= to_date('12/02/2025 20:00', 'dd/mm/yyyy hh24:mi')
 ORDER BY last_verified;

-- Controle
SELECT (SELECT NAME
          FROM v$pdbs
         WHERE con_id = sc.con_id) pdb,
         sc.*
  FROM dba_autotask_schedule_control sc
 --WHERE task_name = 'Auto STS Capture Task'
ORDER BY 1;

------------------------------------------------------------------------------------------------
-- Ativar SPM Automatic (optimizer_capture_sql_plan_baselines = FALSE)

BEGIN
  DBMS_SPM.CONFIGURE('AUTO_SPM_EVOLVE_TASK','ON'); --> Ativa as duas tasks automaticamente: Auto STS Capture Task, Auto SPM Task
END;
/

-- Somente para sistemas n�o aut�nomos, no PDB relevante
-- execute o seguinte como SYS para garantir a origem do plano correta
-- e ACCEPT_PLANS tem seu valor padr�o, TRUE,
BEGIN
   DBMS_SPM.SET_EVOLVE_TASK_PARAMETER(
      task_name => 'SYS_AUTO_SPM_EVOLVE_TASK',
      parameter => 'ALTERNATE_PLAN_SOURCE',
      value     => 'SQL_TUNING_SET');
END;
/
BEGIN
   DBMS_SPM.SET_EVOLVE_TASK_PARAMETER(
      task_name => 'SYS_AUTO_SPM_EVOLVE_TASK' ,
      parameter => 'ACCEPT_PLANS',
      value     => 'TRUE');
END;
/

------------------------------------------------------------------------------------------------
-- Desativar SPM Automatic

BEGIN
  DBMS_SPM.CONFIGURE('AUTO_SPM_EVOLVE_TASK','OFF');
END;
/

-- Somente para sistemas n�o aut�nomos,
-- execute o seguinte como SYS se quiser retornar
-- par�metros para valores SPM 'manuais' - por exemplo
BEGIN 
   DBMS_SPM.SET_EVOLVE_TASK_PARAMETER( 
      task_name => 'SYS_AUTO_SPM_EVOLVE_TASK' ,
      parameter => 'ALTERNATE_PLAN_BASELINE', 
      value     => 'EXISTING');
 
    DBMS_SPM.SET_EVOLVE_TASK_PARAMETER(
      task_name => 'SYS_AUTO_SPM_EVOLVE_TASK',
      parameter => 'ALTERNATE_PLAN_SOURCE',
      value     => 'AUTO');
END;
/      



-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*
29.2.2.4.1 Sobre a tarefa do High-Frequency Automatic SPM Evolve Advisor
A tarefa SPM Evolve Advisor de alta frequ�ncia complementa a tarefa padr�o Automatic SPM Evolve Advisor.

Por padr�o, SYS_AUTO_SPM_EVOLVE_TASK� executado diariamente na janela de manuten��o programada do AutoTask. 
Se os dados mudarem frequentemente entre duas execu��es consecutivas de tarefas, o otimizador poder� escolher planos abaixo do ideal. Por exemplo, 
se os pre�os da lista de produtos mudarem com mais frequ�ncia do que as execu��es de SYS_AUTO_SPM_EVOLVE_TASK, mais consultas fora do intervalo poder�o ocorrer, possivelmente levando a planos abaixo do ideal.

Quando voc� habilita a tarefa de alta frequ�ncia Automatic SPM Evolve Advisor, SYS_AUTO_SPM_EVOLVE_TASK ela � executada com mais frequ�ncia, 
realizando as mesmas opera��es durante cada execu��o. A tarefa de alta frequ�ncia � executada a cada hora e n�o dura mais do que 30 minutos. 
Essas configura��es n�o s�o configur�veis. As execu��es frequentes significam que o otimizador tem mais oportunidades de encontrar e desenvolver planos de melhor desempenho.

--> Enable the Automatic SPM Evolve Advisor task: EXECUTE privilege on the SYS.DBMS_AUTO_TASK_ADMIN package.
--> Enable the high-frequency Automatic SPM Evolve Advisor task: EXECUTE privilege on the SYS.DBMS_SPM package.

Tanto a tarefa padr�o do Automatic SPM Evolve Advisor quanto a tarefa de alta frequ�ncia t�m o mesmo nome: SYS_AUTO_SPM_EVOLVE_TASK. 
Em DBA_ADVISOR_EXECUTIONS, as duas tarefas s�o diferenciadas pelo nome da execu��o. 
O nome da execu��o da tarefa padr�o tem o formato EXEC_number, enquanto o nome da execu��o de alta frequ�ncia tem o formato SYS_SPM_timestamp.

DBMS_SPM.CONFIGURE habilita a tarefa de alta frequ�ncia, mas n�o tem depend�ncia do SPM Evolve Advisor (DBMS_AUTO_TASK_ADMIN). 
A tarefa padr�o e a tarefa de alta frequ�ncia s�o independentes e s�o agendadas por meio de duas estruturas diferentes.
*/

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------