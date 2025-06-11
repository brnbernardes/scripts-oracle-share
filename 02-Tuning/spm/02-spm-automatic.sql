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

-- Somente para sistemas não autônomos, no PDB relevante
-- execute o seguinte como SYS para garantir a origem do plano correta
-- e ACCEPT_PLANS tem seu valor padrão, TRUE,
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

-- Somente para sistemas não autônomos,
-- execute o seguinte como SYS se quiser retornar
-- parâmetros para valores SPM 'manuais' - por exemplo
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
A tarefa SPM Evolve Advisor de alta frequência complementa a tarefa padrão Automatic SPM Evolve Advisor.

Por padrão, SYS_AUTO_SPM_EVOLVE_TASKé executado diariamente na janela de manutenção programada do AutoTask. 
Se os dados mudarem frequentemente entre duas execuções consecutivas de tarefas, o otimizador poderá escolher planos abaixo do ideal. Por exemplo, 
se os preços da lista de produtos mudarem com mais frequência do que as execuções de SYS_AUTO_SPM_EVOLVE_TASK, mais consultas fora do intervalo poderão ocorrer, possivelmente levando a planos abaixo do ideal.

Quando você habilita a tarefa de alta frequência Automatic SPM Evolve Advisor, SYS_AUTO_SPM_EVOLVE_TASK ela é executada com mais frequência, 
realizando as mesmas operações durante cada execução. A tarefa de alta frequência é executada a cada hora e não dura mais do que 30 minutos. 
Essas configurações não são configuráveis. As execuções frequentes significam que o otimizador tem mais oportunidades de encontrar e desenvolver planos de melhor desempenho.

--> Enable the Automatic SPM Evolve Advisor task: EXECUTE privilege on the SYS.DBMS_AUTO_TASK_ADMIN package.
--> Enable the high-frequency Automatic SPM Evolve Advisor task: EXECUTE privilege on the SYS.DBMS_SPM package.

Tanto a tarefa padrão do Automatic SPM Evolve Advisor quanto a tarefa de alta frequência têm o mesmo nome: SYS_AUTO_SPM_EVOLVE_TASK. 
Em DBA_ADVISOR_EXECUTIONS, as duas tarefas são diferenciadas pelo nome da execução. 
O nome da execução da tarefa padrão tem o formato EXEC_number, enquanto o nome da execução de alta frequência tem o formato SYS_SPM_timestamp.

DBMS_SPM.CONFIGURE habilita a tarefa de alta frequência, mas não tem dependência do SPM Evolve Advisor (DBMS_AUTO_TASK_ADMIN). 
A tarefa padrão e a tarefa de alta frequência são independentes e são agendadas por meio de duas estruturas diferentes.
*/

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------