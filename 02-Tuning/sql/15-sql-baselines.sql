-- Encontrar SQL_ID e PLANHASH pelo SQL_TEXT @ SYS
SELECT sys.dbms_sqltune_util0.sqltext_to_sqlid(sql_text || chr(0)) sql_id,
       (SELECT to_number(regexp_replace(plan_table_output, '^[^0-9]*'))
          FROM TABLE(dbms_xplan.display_sql_plan_baseline(sql_handle,
                                                          plan_name))
         WHERE plan_table_output LIKE 'Plan hash value: %') plan_hash_value,
       plan_name,
       enabled,
       accepted,
       fixed,
       reproduced,
       dbms_xplan.format_time_s(elapsed_time / 1e6) hours,
       creator,
       origin,
       created,
       last_modified,
       last_executed,
       sql_text
  FROM dba_sql_plan_baselines b
 WHERE sql_text LIKE 'SELECT MAX(FIM) FROM GRP_BAS_EXECUCAO_TAREFA %'
 ORDER BY sql_id, hours DESC;