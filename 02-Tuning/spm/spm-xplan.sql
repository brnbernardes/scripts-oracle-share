SELECT s.sql_id,
       s.child_number,
       b.created,
       b.last_executed,
       b.last_verified,
       b.last_modified,
       b.signature,
       b.sql_handle,
       b.plan_name,
       b.enabled,
       b.accepted,
       b.adaptive,
       (SELECT REPLACE(s.plan_table_output, 'Plan hash value: ', '')
          FROM dbms_xplan.display_sql_plan_baseline('' || b.sql_handle || '',
                                                    '' || b.plan_name || '')
         WHERE plan_table_output LIKE '%Plan hash value%') AS plan_hash_value
      ,
       'select * from dbms_xplan.display_sql_plan_baseline(''' ||
       b.sql_handle || ''',''' || b.plan_name || ''');' AS get_full_plan
  FROM dba_sql_plan_baselines b
  INNER JOIN v$sql s ON signature = s.exact_matching_signature
WHERE sql_plan_baseline IS NOT NULL
--AND sql_id like '&sql_id'
 ORDER BY s.sql_id, b.created;     