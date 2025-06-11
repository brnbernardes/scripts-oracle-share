----------------------------------------------------------------------------------------------------------------------------------
-- SQL Tuning Advisor  -> Consultor de ajustes de SQL
-- SQL Tuning Sets     -> Conjunto de ajustes de SQL
----------------------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------------------------
-- Tuning Task: SQL_ID
DECLARE 
 ret_val varchar2(4000);
 v_sqlid varchar2(100) := '&SQL_ID'; 
BEGIN
ret_val := dbms_sqltune.create_tuning_task(task_name => 'Task_name-'||v_sqlid, sql_id => v_sqlid, time_limit => 180);
dbms_sqltune.execute_tuning_task(task_name => 'Task_name-'||v_sqlid);
END;
/

----------------------------------------------------------------------------------------------------------------------------------
-- Report:
SELECT dbms_sqltune.report_tuning_task(task_name => 'Task_name-&SQL_ID') AS recommendations FROM dual;

----------------------------------------------------------------------------------------------------------------------------------
-- Drop Tuning Task: SQL_ID
DECLARE 
 v_sqlid varchar2(100) := '&SQL_ID'; 
BEGIN
 DBMS_SQLTUNE.drop_tuning_task (task_name => 'Task_name-'||v_sqlid);
END;
/

----------------------------------------------------------------------------------------------------------------------------------
-- Profiles
SELECT * FROM dba_sql_profiles;

BEGIN
 dbms_sqltune.drop_sql_profile('&sql_profile_name');
END;
/

----------------------------------------------------------------------------------------------------------------------------------
-- Hints:
--set lines 155
--col hint for a150
SELECT hint
  FROM (SELECT p.name,
               p.signature,
               p.category,
               row_number() over(PARTITION BY sd.signature, sd.category ORDER BY sd.signature) row_num,
               extractvalue(VALUE(t), '/hint') hint
          FROM sys.sqlobj$data sd,
               dba_sql_profiles p,
               TABLE(xmlsequence(extract(xmltype(sd.comp_data),
                                         '/outline_data/hint'))) t
         WHERE sd.obj_type = 1
           AND p.signature = sd.signature
           AND p.name LIKE nvl('&sql_profile_name', NAME)
           )
 ORDER BY row_num;


