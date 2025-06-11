-----------------------------------------------------------------------------------------------------------------------------------------
-- Statistics Parameters
COL PARAMETER FOR a30
COL VALUE FOR A80
SELECT 'APPROXIMATE_NDV_ALGORITHM' AS PARAMETER, DBMS_STATS.GET_PREFS('APPROXIMATE_NDV_ALGORITHM') AS VALUE FROM DUAL
UNION ALL
SELECT 'AUTO_STAT_EXTENSIONS', DBMS_STATS.GET_PREFS('AUTO_STAT_EXTENSIONS') FROM DUAL
UNION ALL
SELECT 'AUTO_TASK_STATUS', DBMS_STATS.GET_PREFS('AUTO_TASK_STATUS') FROM DUAL
UNION ALL
SELECT 'AUTO_TASK_MAX_RUN_TIME', DBMS_STATS.GET_PREFS('AUTO_TASK_MAX_RUN_TIME') FROM DUAL
UNION ALL
SELECT 'AUTO_TASK_INTERVAL', DBMS_STATS.GET_PREFS('AUTO_TASK_INTERVAL') FROM DUAL
UNION ALL
SELECT 'CASCADE', DBMS_STATS.GET_PREFS('CASCADE') FROM DUAL
UNION ALL
SELECT 'CONCURRENT', DBMS_STATS.GET_PREFS('CONCURRENT') FROM DUAL
UNION ALL
SELECT 'DEGREE', DBMS_STATS.GET_PREFS('DEGREE') FROM DUAL
UNION ALL
SELECT 'ESTIMATE_PERCENT', DBMS_STATS.GET_PREFS('ESTIMATE_PERCENT') FROM DUAL
UNION ALL
SELECT 'GLOBAL_TEMP_TABLE_STATS', DBMS_STATS.GET_PREFS('GLOBAL_TEMP_TABLE_STATS') FROM DUAL
UNION ALL
SELECT 'GRANULARITY', DBMS_STATS.GET_PREFS('GRANULARITY') FROM DUAL
UNION ALL
SELECT 'INCREMENTAL', DBMS_STATS.GET_PREFS('INCREMENTAL') FROM DUAL
UNION ALL
SELECT 'INCREMENTAL_STALENESS', DBMS_STATS.GET_PREFS('INCREMENTAL_STALENESS') FROM DUAL
UNION ALL
SELECT 'INCREMENTAL_LEVEL', DBMS_STATS.GET_PREFS('INCREMENTAL_LEVEL') FROM DUAL
UNION ALL
SELECT 'METHOD_OPT', DBMS_STATS.GET_PREFS('METHOD_OPT') FROM DUAL
UNION ALL
SELECT 'NO_INVALIDATE', DBMS_STATS.GET_PREFS('NO_INVALIDATE') FROM DUAL
UNION ALL
SELECT 'OPTIONS', DBMS_STATS.GET_PREFS('OPTIONS') FROM DUAL
UNION ALL
SELECT 'PREFERENCE_OVERRIDES_PARAMETER', DBMS_STATS.GET_PREFS('PREFERENCE_OVERRIDES_PARAMETER') FROM DUAL
UNION ALL
SELECT 'PUBLISH', DBMS_STATS.GET_PREFS('PUBLISH') FROM DUAL
UNION ALL
SELECT 'STALE_PERCENT', DBMS_STATS.GET_PREFS('STALE_PERCENT') FROM DUAL
UNION ALL
SELECT 'STAT_CATEGORY', DBMS_STATS.GET_PREFS('STAT_CATEGORY') FROM DUAL
UNION ALL
SELECT 'TABLE_CACHED_BLOCKS', DBMS_STATS.GET_PREFS('TABLE_CACHED_BLOCKS') FROM DUAL
UNION ALL
SELECT 'WAIT_TIME_TO_UPDATE_STATS', DBMS_STATS.GET_PREFS('WAIT_TIME_TO_UPDATE_STATS') FROM DUAL;

-----------------------------------------------------------------------------------------------------------------------------------------
-- Optimizer Parameters
col parameter for a50
col default_value for a30
SELECT NAME || ' = ' || VALUE parameter, default_value
  FROM v$parameter
 WHERE NAME like 'optimizer%'
 ORDER BY NAME;

-----------------------------------------------------------------------------------------------------------------------------------------
--SPM Automatic:
EXEC DBMS_SPM.CONFIGURE('AUTO_SPM_EVOLVE_TASK','ON');
EXEC DBMS_SPM.SET_EVOLVE_TASK_PARAMETER(task_name => 'SYS_AUTO_SPM_EVOLVE_TASK', parameter => 'ALTERNATE_PLAN_BASELINE', value => 'EXISTING');
EXEC DBMS_SPM.SET_EVOLVE_TASK_PARAMETER(task_name => 'SYS_AUTO_SPM_EVOLVE_TASK', parameter => 'ALTERNATE_PLAN_SOURCE', value => 'AUTO');

--Check the automatic SPM directly (e.g. ON or OFF), you can do this:
SELECT parameter_value spm_status FROM   dba_sql_management_config WHERE  parameter_name = 'AUTO_SPM_EVOLVE_TASK';

-- Check the high-frequency task to see if it is enabled:
SELECT enabled FROM   dba_autotask_schedule_control WHERE  dbid = sys_context('userenv','con_dbid') AND    task_name = 'Auto SPM Task';

col parameter_name for a30
col parameter_value for a30
SELECT parameter_name, parameter_value FROM dba_advisor_parameters WHERE task_name = 'SYS_AUTO_SPM_EVOLVE_TASK' AND parameter_value != 'UNUSED';


-----------------------------------------------------------------------------------------------------------------------------------------

-- https://blogs.oracle.com/optimizer/post/optimizer-adaptive-features-in-oracle-database-12c-release-2

-- https://oracle-base.com/articles/12c/adaptive-query-optimization-12cr1

-- Optimizer:
ALTER SYSTEM OPTIMIZER_ADAPTIVE_PLANS = TRUE; 
ALTER SYSTEM SET OPTIMIZER_ADAPTIVE_STATISTICS = FALSE;
ALTER SYSTEM  SET OPTIMIZER_DYNAMIC_SAMPLING = 4;

-----------------------------------------------------------------------------------------------------------------------------------------
-- Statistics
EXEC DBMS_STATS.SET_GLOBAL_PREFS('AUTO_STAT_EXTENSIONS', 'ON');


-----------------------------------------------------------------------------------------------------------------------------------------
--Clientes:
Thema
Caxias


-----------------------------------------------------------------------------------------------------------------------------------------
-- Extended Statistics
SELECT owner, COUNT(DISTINCT table_name) 
FROM dba_stat_extensions
 GROUP BY owner 
ORDER BY 1;

SELECT owner, table_name, COUNT(DISTINCT extension_name)
  FROM dba_stat_extensions
 GROUP BY owner, table_name 
ORDER BY 3 DESC;


SELECT owner || '.' || table_name table_name, to_char(extension) FROM dba_stat_extensions WHERE table_name = 'PRO$_PERCURSO_PROTOCOLO_E';

