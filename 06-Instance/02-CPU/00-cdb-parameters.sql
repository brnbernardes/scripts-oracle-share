-- Parâmetros: Dynamic Scalling CPU com PIVOT @ CDB
SELECT pdb,
       cpu_min_count,
       cpu_max_count
  FROM (SELECT con_id,
               nvl((SELECT NAME
                     FROM v$pdbs
                    WHERE con_id = sp.con_id), 'CDB') pdb,
               NAME,
               VALUE
          FROM v$system_parameter sp
         WHERE NAME IN ('cpu_count', 'cpu_min_count')) cpus
pivot(MAX(VALUE)
   FOR NAME IN('cpu_min_count' cpu_min_count, 'cpu_count' cpu_max_count));


-- Resource Manager: todos os planos de recursos ativos @ CDB
SELECT NVL((SELECT name FROM v$pdbs WHERE con_id = v$rsrc_plan.con_id), 'CDB') pdb,
       NAME,
       shares,
       cpu_managed,
       instance_caging,
       is_top_plan
  FROM v$rsrc_plan
 WHERE is_top_plan = 'TRUE';


-- Parâmetro: Dynamic Scalling CPU @ PDB
SELECT parameter.con_id,
       parameter.cpu_count,
       parameter.cpu_min_count,
       parameter.resource_manager_plan,
       v$rsrc_plan.NAME RSRC_NAME,
       v$rsrc_plan.cpu_managed,
       v$rsrc_plan.instance_caging,
       v$rsrc_plan.shares
  FROM (SELECT con_id,
               NAME,
               VALUE              
          FROM v$parameter
         WHERE NAME IN
               ('resource_manager_plan', 'cpu_count', 'cpu_min_count'))
pivot(MAX(VALUE) FOR NAME IN('cpu_count' cpu_count, 'cpu_min_count' cpu_min_count, 'resource_manager_plan' resource_manager_plan)) parameter, 
v$rsrc_plan WHERE is_top_plan = 'TRUE';


--Definições 
ALTER SYSTEM SET cpu_count = 0;
ALTER SYSTEM SET cpu_min_count = "0.5";
ALTER SYSTEM SET resource_manager_plan = '';


-- Monitor: CPU and Sessions @ CDB
WITH 
  avg_sess AS
  (SELECT (SELECT NAME FROM v$pdbs WHERE con_id = rmh.con_id) pdb,
          to_char(begin_time, 'HH24:MI') TIME,
         SUM(avg_running_sessions) avg_running_sessions,
         SUM(avg_waiting_sessions) avg_waiting_sessions,
         SUM(avg_cpu_utilization) av_cpu_utilization
    FROM v$rsrcmgrmetric_history rmh
    WHERE con_id > 2
    --AND to_char(begin_time, 'HH24:MI') = to_char(SYSDATE-2/24/60, 'hh24:mi') 
   GROUP BY con_id, begin_time
   ORDER BY TIME DESC, con_id),
  pdbs_cpus AS 
   (SELECT pdb,
         to_number(cpu_min_count,'999D99','NLS_NUMERIC_CHARACTERS = ''.,''') cpu_min_count,
         to_number(cpu_count) CPU_COUNT
    FROM (SELECT con_id,
                 nvl((SELECT NAME
                       FROM v$pdbs
                      WHERE con_id = sp.con_id), 'CDB') pdb,
                 NAME,
                 VALUE
            FROM v$system_parameter sp
           WHERE NAME IN ('cpu_count', 'cpu_min_count')
           AND con_id > 2) cpus
  pivot(MAX(VALUE)
     FOR NAME IN('cpu_min_count' cpu_min_count, 'cpu_count' cpu_count ))
  ORDER BY 1)
  SELECT *
    FROM avg_sess
   INNER JOIN pdbs_cpus
   USING (pdb)
   WHERE avg_running_sessions > cpu_count OR avg_waiting_sessions > 0;


-- Para monitorar o Instance Caging em uma instância, monitore o número médio de sessões em execução e em espera.
/*
avg_running_sessions: é o número médio de sessões em execução para este minuto. Se avg_running_sessions for muito menor que cpu_count, a instância não está utilizando totalmente 
                       sua alocação de cpu_count. cpu_count pode ser diminuído sem afetar o desempenho.

avg_waiting_sessions: é o número médio de sessões aguardando para serem agendadas para este minuto. Se avg_waiting_sessions for consistentemente maior que 0, o desempenho da instância 
                       pode ser melhorado aumentando cpu_count por esta quantidade.
*/                       
SELECT (SELECT NAME FROM v$pdbs WHERE con_id = rmh.con_id) pdb,
        to_char(begin_time, 'HH24:MI') TIME,
       SUM(avg_running_sessions) avg_running_sessions,
       SUM(avg_waiting_sessions) avg_waiting_sessions
  FROM v$rsrcmgrmetric_history rmh
 GROUP BY con_id, begin_time
 ORDER BY avg_running_sessions DESC;


